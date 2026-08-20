      *****************************************************************
      * PROGRAM-ID : BKINT01
      * TITLE      : Interest accrual stub — basis points on positive collected bal
      * Synthetic lab system. Not a real bank. Educational / portfolio only.
      * Does not capitalize; writes accrual only (GL later).
      *****************************************************************
       IDENTIFICATION DIVISION.
       PROGRAM-ID. BKINT01.
       AUTHOR. LAB-V2.
       DATE-WRITTEN. 2026-08-20.
       ENVIRONMENT DIVISION.
       CONFIGURATION SECTION.
       SOURCE-COMPUTER. IBM-Z.
       OBJECT-COMPUTER. IBM-Z.
       INPUT-OUTPUT SECTION.
       FILE-CONTROL.
           SELECT INT-OUT ASSIGN TO UINTOUT
               ORGANIZATION IS SEQUENTIAL.
       DATA DIVISION.
       FILE SECTION.
       FD  INT-OUT.
       01  INT-REC PIC X(80).
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
       COPY BKINT.
       COPY BKACC.
       PROCEDURE DIVISION.
       0000-MAIN.
           PERFORM 0500-INIT
           PERFORM 1000-PROCESS
           PERFORM 8000-MAP-SQL
           PERFORM 9000-TERM
           GOBACK
           .
       0500-INIT.
           OPEN OUTPUT INT-OUT
           MOVE 350 TO INT-RATE-BP
           EXIT.
       1000-PROCESS.
           EXEC SQL DECLARE C-INT CURSOR FOR
             SELECT ACCOUNT_NO, BALANCE FROM BANK_CUSTOMER
              WHERE STATUS = 'O' AND BALANCE > 0
           END-EXEC
           EXEC SQL OPEN C-INT END-EXEC
           PERFORM UNTIL SQLCODE NOT = 0
              EXEC SQL FETCH C-INT INTO :INT-ACC-NO, :INT-BAL END-EXEC
              IF SQLCODE = 0
                 COMPUTE INT-ACCRUAL = INT-BAL * INT-RATE-BP / 3650000
                 WRITE INT-REC FROM BK-INT-ACC
                 EXEC SQL INSERT INTO BANK_INT_ACCRUAL
                   (ACCOUNT_NO, CYCLE_DTE, ACCRUAL, RATE_BP)
                   VALUES (:INT-ACC-NO, CURRENT DATE, :INT-ACCRUAL,
                           :INT-RATE-BP)
                 END-EXEC
              END-IF
           END-PERFORM
           EXEC SQL CLOSE C-INT END-EXEC
           CLOSE INT-OUT
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
