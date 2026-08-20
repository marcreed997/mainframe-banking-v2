      *****************************************************************
      * PROGRAM-ID : BKPST01
      * TITLE      : DDA post with 500-row checkpoint — RESTART vs COLD
      * Synthetic lab system. Not a real bank. Educational / portfolio only.
      * Refuses if ONLINE_INHIBIT=N or VALIDATED_IND=N. Never re-posts POSTED_IND=Y.
      *****************************************************************
       IDENTIFICATION DIVISION.
       PROGRAM-ID. BKPST01.
       AUTHOR. LAB-V2.
       DATE-WRITTEN. 2026-08-20.
       ENVIRONMENT DIVISION.
       CONFIGURATION SECTION.
       SOURCE-COMPUTER. IBM-Z.
       OBJECT-COMPUTER. IBM-Z.
       INPUT-OUTPUT SECTION.
       FILE-CONTROL.
           SELECT RST-FILE ASSIGN TO URST
               ORGANIZATION IS SEQUENTIAL
               FILE STATUS IS WS-FS1.
       DATA DIVISION.
       FILE SECTION.
       FD  RST-FILE.
       01  RST-REC PIC X(120).
       WORKING-STORAGE SECTION.
       01  WS-FS1 PIC XX.
       WORKING-STORAGE SECTION.
           EXEC SQL INCLUDE SQLCA END-EXEC.
       COPY BKSQL.
       COPY BKMSG.
       COPY BKCTL.
       COPY BKLOC.
       01  WS-RC                    PIC S9(4) COMP VALUE 0.
       01  WS-RESP                  PIC S9(8) COMP VALUE 0.
       01  WS-RESP2                 PIC S9(8) COMP VALUE 0.
       01  WS-SQLCODE-DISP          PIC S9(9) SIGN LEADING SEPARATE.
       01  WS-TRACE                 PIC X(26).
       01  WS-REASON                PIC X(16) VALUE SPACES.
       COPY BKJRN.
       COPY BKRST.
       COPY BKACC.
       COPY BKCTL.
       01 WS-CHUNK PIC 9(7) VALUE 0.
       PROCEDURE DIVISION.
       0000-MAIN.
           PERFORM 0500-INIT
           PERFORM 1000-PROCESS
           PERFORM 8000-MAP-SQL
           PERFORM 9000-TERM
           GOBACK
           .
       0500-INIT.
           EXEC SQL SELECT ONLINE_INHIBIT, STATUS, VALIDATED_IND
             INTO :CTL-ONLINE-INHIBIT, :CTL-STATUS, :CTL-VALIDATED-IND
             FROM BANK_CYCLE_CTL FETCH FIRST 1 ROW ONLY
           END-EXEC
           IF CTL-ONLINE-INHIBIT NOT = 'Y'
              SET BK-E-CICS-ACTIVE TO TRUE
              MOVE 12 TO WS-RC
              GO TO 0500-X
           END-IF
           IF CTL-VALIDATED-IND NOT = 'Y'
              SET BK-E-NOT-VALID TO TRUE
              MOVE 8 TO WS-RC
              GO TO 0500-X
           END-IF
           ACCEPT RST-MODE FROM SYSIN
           EXEC SQL SELECT LAST_TRACE, CHUNK_NO
             INTO :RST-LAST-TRACE, :RST-CHUNK-NO
             FROM BANK_RESTART
            WHERE CYCLE_DTE = :CTL-CYCLE-DTE
           END-EXEC
           IF RST-COLD AND SQLCODE = 0 AND RST-LAST-TRACE NOT = SPACES
              IF RST-FORCE NOT = 'Y'
                 SET BK-E-RESTART TO TRUE
                 MOVE 16 TO WS-RC
              END-IF
           END-IF
           .
       0500-X.
           EXIT.
       1000-PROCESS.
           IF WS-RC > 4 GO TO 1000-X END-IF
           EXEC SQL DECLARE C-POST CURSOR FOR
             SELECT TRACE_ID, ACCOUNT_NO, DR_CR, AMOUNT
               FROM BANK_JOURNAL
              WHERE POSTED_IND = 'N'
                AND TRACE_ID > :RST-LAST-TRACE
              ORDER BY TRACE_ID
              FETCH FIRST 500 ROWS ONLY
           END-EXEC
           EXEC SQL OPEN C-POST END-EXEC
           PERFORM UNTIL SQLCODE NOT = 0
              EXEC SQL FETCH C-POST INTO :JRN-TRACE-ID, :JRN-ACC-NO,
                   :JRN-DRCR, :JRN-AMT
              END-EXEC
              IF SQLCODE = 0
                 IF JRN-DEBIT
                    EXEC SQL UPDATE BANK_CUSTOMER
                      SET BALANCE = BALANCE - :JRN-AMT
                      WHERE ACCOUNT_NO = :JRN-ACC-NO
                    END-EXEC
                 ELSE
                    EXEC SQL UPDATE BANK_CUSTOMER
                      SET BALANCE = BALANCE + :JRN-AMT
                      WHERE ACCOUNT_NO = :JRN-ACC-NO
                    END-EXEC
                 END-IF
                 EXEC SQL UPDATE BANK_JOURNAL SET POSTED_IND = 'Y',
                   POST_TS = CURRENT TIMESTAMP
                   WHERE TRACE_ID = :JRN-TRACE-ID
                 END-EXEC
                 MOVE JRN-TRACE-ID TO RST-LAST-TRACE
                 ADD 1 TO WS-CHUNK
              END-IF
           END-PERFORM
           EXEC SQL CLOSE C-POST END-EXEC
           EXEC SQL
             MERGE INTO BANK_RESTART AS T
             USING (VALUES (:CTL-CYCLE-DTE, :RST-LAST-TRACE, :WS-CHUNK))
               AS S(CYCLE_DTE, LAST_TRACE, CHUNK_NO)
               ON T.CYCLE_DTE = S.CYCLE_DTE
             WHEN MATCHED THEN UPDATE SET LAST_TRACE = S.LAST_TRACE,
                  CHUNK_NO = S.CHUNK_NO
             WHEN NOT MATCHED THEN INSERT
                  (CYCLE_DTE, LAST_TRACE, CHUNK_NO)
                  VALUES (S.CYCLE_DTE, S.LAST_TRACE, S.CHUNK_NO)
           END-EXEC
           PERFORM 8000-MAP-SQL
           .
       1000-X.
           EXIT.
       8000-MAP-SQL.
           MOVE SQLCODE TO WS-SQLCODE-DISP
           EVALUATE SQLCODE
             WHEN 0
                MOVE 0 TO WS-RC
             WHEN +100
                MOVE 4 TO WS-RC
             WHEN -803
                MOVE 12 TO WS-RC
                SET BK-E-DUPGEN TO TRUE
             WHEN -911
             WHEN -913
                MOVE 8 TO WS-RC
                MOVE 'DEADLOCK-RETRY' TO BK-OP-MSG
             WHEN OTHER
                MOVE 16 TO WS-RC
           END-EVALUATE
           MOVE WS-RC TO RETURN-CODE
           EXIT.
       9000-TERM.
           MOVE WS-RC TO RETURN-CODE
           EXIT.
