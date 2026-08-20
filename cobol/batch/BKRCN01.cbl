      *****************************************************************
      * PROGRAM-ID : BKRCN01
      * TITLE      : Location vs hub journal recon — unmatched either side -> XCPT
      * Synthetic lab system. Not a real bank. Educational / portfolio only.
      * Does not post. Requires all locations VALIDATED. Three-way prep.
      *****************************************************************
       IDENTIFICATION DIVISION.
       PROGRAM-ID. BKRCN01.
       AUTHOR. LAB-V2.
       DATE-WRITTEN. 2026-08-20.
       ENVIRONMENT DIVISION.
       CONFIGURATION SECTION.
       SOURCE-COMPUTER. IBM-Z.
       OBJECT-COMPUTER. IBM-Z.
       INPUT-OUTPUT SECTION.
       FILE-CONTROL.
           SELECT LOC-FILE ASSIGN TO ULOCIN
               ORGANIZATION IS SEQUENTIAL
               FILE STATUS IS WS-FS1.
       DATA DIVISION.
       FILE SECTION.
       FD  LOC-FILE.
       01  LOC-REC PIC X(200).
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
       COPY BKTRN.
       COPY BKRCN.
       COPY BKJRN.
       01 WS-U-LOC PIC 9(7) VALUE 0.
       01 WS-U-HUB PIC 9(7) VALUE 0.
       PROCEDURE DIVISION.
       0000-MAIN.
           PERFORM 0500-INIT
           PERFORM 1000-PROCESS
           PERFORM 8000-MAP-SQL
           PERFORM 9000-TERM
           GOBACK
           .
       0500-INIT.
           EXEC SQL SELECT VALIDATED_IND INTO :CTL-VALIDATED-IND
             FROM BANK_CYCLE_CTL FETCH FIRST 1 ROW ONLY
           END-EXEC
           IF CTL-VALIDATED-IND NOT = 'Y'
              MOVE 8 TO WS-RC
              SET BK-E-NOT-VALID TO TRUE
           END-IF
           OPEN INPUT LOC-FILE
           EXIT.
       1000-PROCESS.
           IF WS-RC > 4 GO TO 1000-X END-IF
           READ LOC-FILE INTO BK-EXTRACT-REC
             AT END GO TO 1100-HUB-ORPHANS
           END-READ
           PERFORM UNTIL WS-FS1 NOT = '00'
              IF XTR-BODY
                 EXEC SQL SELECT TRACE_ID INTO :JRN-TRACE-ID
                   FROM BANK_JOURNAL WHERE TRACE_ID = :XTR-TRACE-ID
                 END-EXEC
                 IF SQLCODE = +100
                    SET RSN-UNMATCH-HUB TO TRUE
                    ADD 1 TO WS-U-LOC
                    EXEC SQL INSERT INTO BANK_RECON_XCPT
                      (CYCLE_DTE, LOC_ID, TRACE_ID, ACCOUNT_NO, REASON,
                       AMOUNT, STATUS)
                      VALUES (:XTR-CYCLE-DTE, :XTR-LOC-ID,
                              :XTR-TRACE-ID, :XTR-ACC-NO, 'UNMATCH-HUB',
                              :XTR-AMT, 'O')
                    END-EXEC
                    SET BK-E-UNMATCHED TO TRUE
                    MOVE 4 TO WS-RC
                 END-IF
                 EXEC SQL SELECT COUNT(*) INTO :RCN-XCPT-ID
                   FROM BANK_JOURNAL WHERE TRACE_ID = :XTR-TRACE-ID
                 END-EXEC
              END-IF
              READ LOC-FILE INTO BK-EXTRACT-REC
                AT END EXIT PERFORM
              END-READ
           END-PERFORM
           .
       1100-HUB-ORPHANS.
           EXEC SQL DECLARE C-ORPH CURSOR FOR
             SELECT J.TRACE_ID, J.ACCOUNT_NO, J.AMOUNT, J.LOC_ID
               FROM BANK_JOURNAL J
              WHERE J.CYCLE_DTE = :CTL-CYCLE-DTE
                AND NOT EXISTS (
                    SELECT 1 FROM BANK_LOCATION_XTR X
                     WHERE X.TRACE_ID = J.TRACE_ID)
           END-EXEC
           EXEC SQL OPEN C-ORPH END-EXEC
           PERFORM UNTIL SQLCODE NOT = 0
              EXEC SQL FETCH C-ORPH INTO :JRN-TRACE-ID, :JRN-ACC-NO,
                   :JRN-AMT, :JRN-LOC-ID
              END-EXEC
              IF SQLCODE = 0
                 ADD 1 TO WS-U-HUB
                 EXEC SQL INSERT INTO BANK_RECON_XCPT
                   (CYCLE_DTE, LOC_ID, TRACE_ID, ACCOUNT_NO, REASON,
                    AMOUNT, STATUS)
                   VALUES (:CTL-CYCLE-DTE, :JRN-LOC-ID, :JRN-TRACE-ID,
                           :JRN-ACC-NO, 'UNMATCH-LOC', :JRN-AMT, 'O')
                 END-EXEC
              END-IF
           END-PERFORM
           EXEC SQL CLOSE C-ORPH END-EXEC
           IF WS-U-LOC = 0 AND WS-U-HUB = 0
              EXEC SQL UPDATE BANK_CYCLE_CTL SET RECON_CLOSED = 'Y'
              END-EXEC
              MOVE 0 TO WS-RC
           ELSE
              MOVE 4 TO WS-RC
           END-IF
           CLOSE LOC-FILE
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
