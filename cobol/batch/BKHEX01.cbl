      *****************************************************************
      * PROGRAM-ID : BKHEX01
      * TITLE      : Hold expiry — releases HOLD_AMT when EXP_DTE < cycle date
      * Synthetic lab system. Not a real bank. Educational / portfolio only.
      * Does not credit BAL; only reduces HOLD.
      *****************************************************************
       IDENTIFICATION DIVISION.
       PROGRAM-ID. BKHEX01.
       AUTHOR. LAB-V2.
       DATE-WRITTEN. 2026-08-20.
       ENVIRONMENT DIVISION.
       CONFIGURATION SECTION.
       SOURCE-COMPUTER. IBM-Z.
       OBJECT-COMPUTER. IBM-Z.
       INPUT-OUTPUT SECTION.
       FILE-CONTROL.
           SELECT HEX-RPT ASSIGN TO UHEXRPT
               ORGANIZATION IS SEQUENTIAL.
       DATA DIVISION.
       FILE SECTION.
       FD  HEX-RPT.
       01  HEX-LINE PIC X(80).
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
       COPY BKHLD.
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
           OPEN OUTPUT HEX-RPT
           EXIT.
       1000-PROCESS.
           EXEC SQL DECLARE C-HEX CURSOR FOR
             SELECT HOLD_ID, ACCOUNT_NO, AMOUNT
               FROM BANK_HOLD
              WHERE STATUS = 'A' AND EXP_DTE < CURRENT DATE
           END-EXEC
           EXEC SQL OPEN C-HEX END-EXEC
           PERFORM UNTIL SQLCODE NOT = 0
              EXEC SQL FETCH C-HEX INTO :HLD-ID, :HLD-ACC-NO, :HLD-AMT
              END-EXEC
              IF SQLCODE = 0
                 EXEC SQL UPDATE BANK_HOLD SET STATUS = 'E'
                   WHERE HOLD_ID = :HLD-ID
                 END-EXEC
                 EXEC SQL UPDATE BANK_CUSTOMER
                   SET HOLD_AMT = HOLD_AMT - :HLD-AMT
                   WHERE ACCOUNT_NO = :HLD-ACC-NO
                 END-EXEC
                 WRITE HEX-LINE FROM HLD-ID
              END-IF
           END-PERFORM
           EXEC SQL CLOSE C-HEX END-EXEC
           CLOSE HEX-RPT
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
