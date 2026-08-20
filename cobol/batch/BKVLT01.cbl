      *****************************************************************
      * PROGRAM-ID : BKVLT01
      * TITLE      : Branch vault vs teller cash proof — out of balance RC=12
      * Synthetic lab system. Not a real bank. Educational / portfolio only.
      * Physical cash location control, not DDA.
      *****************************************************************
       IDENTIFICATION DIVISION.
       PROGRAM-ID. BKVLT01.
       AUTHOR. LAB-V2.
       DATE-WRITTEN. 2026-08-20.
       ENVIRONMENT DIVISION.
       CONFIGURATION SECTION.
       SOURCE-COMPUTER. IBM-Z.
       OBJECT-COMPUTER. IBM-Z.
       INPUT-OUTPUT SECTION.
       FILE-CONTROL.
           SELECT VLT-RPT ASSIGN TO UVLTRPT
               ORGANIZATION IS SEQUENTIAL.
       DATA DIVISION.
       FILE SECTION.
       FD  VLT-RPT.
       01  VLT-LINE PIC X(80).
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
       COPY BKBRN.
       COPY BKTLL.
       01 WS-SUM PIC S9(13)V99 COMP-3.
       PROCEDURE DIVISION.
       0000-MAIN.
           PERFORM 0500-INIT
           PERFORM 1000-PROCESS
           PERFORM 8000-MAP-SQL
           PERFORM 9000-TERM
           GOBACK
           .
       0500-INIT.
           OPEN OUTPUT VLT-RPT
           EXIT.
       1000-PROCESS.
           EXEC SQL SELECT VAULT_CASH, TELLER_TOT
             INTO :BRN-VAULT, :BRN-TELLER-TOT
             FROM BANK_BRANCH_CASH
           END-EXEC
           EXEC SQL SELECT COALESCE(SUM(DRAWER_CASH),0) INTO :WS-SUM
             FROM BANK_TELLER WHERE SIGNED_ON = 'Y'
           END-EXEC
           IF WS-SUM NOT = BRN-TELLER-TOT
              MOVE 12 TO WS-RC
              SET BK-E-HASH TO TRUE
              MOVE 'TELLER-VAULT-MISMATCH' TO BK-OP-MSG
           END-IF
           WRITE VLT-LINE FROM BK-OP-MSG
           CLOSE VLT-RPT
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
