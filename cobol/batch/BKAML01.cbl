      *****************************************************************
      * PROGRAM-ID : BKAML01
      * TITLE      : Large-amount flag file — journal rows >= 10000 to AML extract
      * Synthetic lab system. Not a real bank. Educational / portfolio only.
      * No posting; watchlist file only.
      *****************************************************************
       IDENTIFICATION DIVISION.
       PROGRAM-ID. BKAML01.
       AUTHOR. LAB-V2.
       DATE-WRITTEN. 2026-08-20.
       ENVIRONMENT DIVISION.
       CONFIGURATION SECTION.
       SOURCE-COMPUTER. IBM-Z.
       OBJECT-COMPUTER. IBM-Z.
       INPUT-OUTPUT SECTION.
       FILE-CONTROL.
           SELECT AML-OUT ASSIGN TO UAMLOUT
               ORGANIZATION IS SEQUENTIAL.
       DATA DIVISION.
       FILE SECTION.
       FD  AML-OUT.
       01  AML-REC PIC X(80).
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
       PROCEDURE DIVISION.
       0000-MAIN.
           PERFORM 0500-INIT
           PERFORM 1000-PROCESS
           PERFORM 8000-MAP-SQL
           PERFORM 9000-TERM
           GOBACK
           .
       0500-INIT.
           OPEN OUTPUT AML-OUT
           EXIT.
       1000-PROCESS.
           EXEC SQL DECLARE C-AML CURSOR FOR
             SELECT TRACE_ID, ACCOUNT_NO, AMOUNT, LOC_ID
               FROM BANK_JOURNAL
              WHERE AMOUNT >= 10000 AND CYCLE_DTE = CURRENT DATE
           END-EXEC
           EXEC SQL OPEN C-AML END-EXEC
           PERFORM UNTIL SQLCODE NOT = 0
              EXEC SQL FETCH C-AML INTO :JRN-TRACE-ID, :JRN-ACC-NO,
                   :JRN-AMT, :JRN-LOC-ID
              END-EXEC
              IF SQLCODE = 0
                 WRITE AML-REC FROM JRN-TRACE-ID
              END-IF
           END-PERFORM
           EXEC SQL CLOSE C-AML END-EXEC
           CLOSE AML-OUT
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
