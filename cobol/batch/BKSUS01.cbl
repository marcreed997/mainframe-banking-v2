      *****************************************************************
      * PROGRAM-ID : BKSUS01
      * TITLE      : Suspense recycle — FORCE=Y dual-control flag required to post xcpt
      * Synthetic lab system. Not a real bank. Educational / portfolio only.
      * Without FORCE, RC=4 and no balance change.
      *****************************************************************
       IDENTIFICATION DIVISION.
       PROGRAM-ID. BKSUS01.
       AUTHOR. LAB-V2.
       DATE-WRITTEN. 2026-08-20.
       ENVIRONMENT DIVISION.
       CONFIGURATION SECTION.
       SOURCE-COMPUTER. IBM-Z.
       OBJECT-COMPUTER. IBM-Z.
       INPUT-OUTPUT SECTION.
       FILE-CONTROL.
           SELECT SUS-IN ASSIGN TO USUSIN
               ORGANIZATION IS SEQUENTIAL.
       DATA DIVISION.
       FILE SECTION.
       FD  SUS-IN.
       01  SUS-REC PIC X(200).
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
       COPY BKRCN.
       COPY BKJRN.
       01 WS-FORCE PIC X.
       PROCEDURE DIVISION.
       0000-MAIN.
           PERFORM 0500-INIT
           PERFORM 1000-PROCESS
           PERFORM 8000-MAP-SQL
           PERFORM 9000-TERM
           GOBACK
           .
       0500-INIT.
           ACCEPT WS-FORCE FROM SYSIN
           OPEN INPUT SUS-IN
           EXIT.
       1000-PROCESS.
           EXEC SQL DECLARE C-SUS CURSOR FOR
             SELECT XCPT_ID, TRACE_ID, ACCOUNT_NO, AMOUNT, REASON
               FROM BANK_RECON_XCPT WHERE STATUS = 'O'
           END-EXEC
           EXEC SQL OPEN C-SUS END-EXEC
           PERFORM UNTIL SQLCODE NOT = 0
              EXEC SQL FETCH C-SUS INTO :RCN-XCPT-ID, :RCN-TRACE-ID,
                   :RCN-ACC-NO, :RCN-AMT, :RCN-REASON
              END-EXEC
              IF SQLCODE = 0
                 IF WS-FORCE NOT = 'Y'
                    MOVE 4 TO WS-RC
                    MOVE 'NO-FORCE-SKIP' TO BK-OP-MSG
                 ELSE
                    EXEC SQL UPDATE BANK_RECON_XCPT
                      SET STATUS = 'F' WHERE XCPT_ID = :RCN-XCPT-ID
                    END-EXEC
                    EXEC SQL INSERT INTO BANK_JOURNAL
                      (TRACE_ID, ACCOUNT_NO, CHANNEL, DR_CR, AMOUNT,
                       POSTED_IND, NARR)
                      VALUES (:RCN-TRACE-ID, :RCN-ACC-NO, 'BATCH', 'C',
                              :RCN-AMT, 'N', 'SUSPENSE FORCE')
                    END-EXEC
                 END-IF
              END-IF
           END-PERFORM
           EXEC SQL CLOSE C-SUS END-EXEC
           CLOSE SUS-IN
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
