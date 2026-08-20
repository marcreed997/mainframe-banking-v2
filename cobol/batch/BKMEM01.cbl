      *****************************************************************
      * PROGRAM-ID : BKMEM01
      * TITLE      : Intra-day memo-post drop at inhibit — convert or reverse
      * Synthetic lab system. Not a real bank. Educational / portfolio only.
      * MEMO_IND=Y and POSTED_IND=N become real posts if validated; else reverse.
      *****************************************************************
       IDENTIFICATION DIVISION.
       PROGRAM-ID. BKMEM01.
       AUTHOR. LAB-V2.
       DATE-WRITTEN. 2026-08-20.
       ENVIRONMENT DIVISION.
       CONFIGURATION SECTION.
       SOURCE-COMPUTER. IBM-Z.
       OBJECT-COMPUTER. IBM-Z.
       INPUT-OUTPUT SECTION.
       FILE-CONTROL.
           SELECT MEMRPT ASSIGN TO UMEMRPT
               ORGANIZATION IS SEQUENTIAL
               FILE STATUS IS WS-FS1.
       DATA DIVISION.
       FILE SECTION.
       FD  MEMRPT.
       01  MEM-RPT                  PIC X(120).
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
       COPY BKACC.
       COPY BKCTL.
       01  WS-FS1                   PIC XX.
       01  WS-CONV                  PIC 9(7) VALUE 0.
       01  WS-REV                   PIC 9(7) VALUE 0.

       PROCEDURE DIVISION.
       0000-MAIN.
           PERFORM 0500-GATE
           PERFORM 1000-DROP
           PERFORM 9000-TERM
           GOBACK
           .
       0500-GATE.
           EXEC SQL SELECT ONLINE_INHIBIT, VALIDATED_IND
             INTO :CTL-ONLINE-INHIBIT, :CTL-VALIDATED-IND
             FROM BANK_CYCLE_CTL FETCH FIRST 1 ROW ONLY
           END-EXEC
           IF ONLINE-ALLOWED
              SET BK-E-CICS-ACTIVE TO TRUE
              MOVE 12 TO WS-RC
              MOVE 'BK-E-ONLINEUP' TO BK-OP-MSG
           END-IF
           OPEN OUTPUT MEMRPT
           EXIT.
       1000-DROP.
           IF WS-RC >= 12 GO TO 1000-X END-IF
           EXEC SQL DECLARE C-MEM CURSOR FOR
             SELECT TRACE_ID, ACCOUNT_NO, DR_CR, AMOUNT
               FROM BANK_JOURNAL
              WHERE MEMO_IND = 'Y'
                AND POSTED_IND = 'N'
           END-EXEC
           EXEC SQL OPEN C-MEM END-EXEC
           PERFORM UNTIL SQLCODE NOT = 0
              EXEC SQL FETCH C-MEM INTO :JRN-TRACE-ID, :JRN-ACC-NO,
                   :JRN-DRCR, :JRN-AMT
              END-EXEC
              IF SQLCODE = 0
                 IF CTL-VALIDATED-IND = 'Y'
                    EXEC SQL UPDATE BANK_JOURNAL
                      SET MEMO_IND = 'N', POSTED_IND = 'Y',
                          POST_TS = CURRENT TIMESTAMP
                      WHERE TRACE_ID = :JRN-TRACE-ID
                    END-EXEC
                    ADD 1 TO WS-CONV
                    MOVE 'CONVERTED' TO MEM-RPT
                 ELSE
                    EXEC SQL UPDATE BANK_JOURNAL
                      SET MEMO_IND = 'R', POSTED_IND = 'S'
                      WHERE TRACE_ID = :JRN-TRACE-ID
                    END-EXEC
                    IF JRN-DEBIT
                       EXEC SQL UPDATE BANK_CUSTOMER
                         SET BALANCE = BALANCE + :JRN-AMT
                         WHERE ACCOUNT_NO = :JRN-ACC-NO
                       END-EXEC
                    ELSE
                       EXEC SQL UPDATE BANK_CUSTOMER
                         SET BALANCE = BALANCE - :JRN-AMT
                         WHERE ACCOUNT_NO = :JRN-ACC-NO
                       END-EXEC
                    END-IF
                    ADD 1 TO WS-REV
                    MOVE 'REVERSED' TO MEM-RPT
                 END-IF
                 WRITE MEM-RPT
              END-IF
           END-PERFORM
           EXEC SQL CLOSE C-MEM END-EXEC
           CLOSE MEMRPT
           .
       1000-X.
           EXIT.

       8000-MAP-SQL.
           COPY BKSQLM.
           EXIT.
       9000-TERM.
           MOVE WS-RC TO RETURN-CODE
           EXIT.
