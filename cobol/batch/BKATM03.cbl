      *****************************************************************
      * PROGRAM-ID : BKATM03
      * TITLE      : ATM cassette totals vs switch dispenses for cycle
      * Synthetic lab system. Not a real bank. Educational / portfolio only.
      * Switch settlement, not branch vault.
      *****************************************************************
       IDENTIFICATION DIVISION.
       PROGRAM-ID. BKATM03.
       AUTHOR. LAB-V2.
       DATE-WRITTEN. 2026-08-20.
       ENVIRONMENT DIVISION.
       CONFIGURATION SECTION.
       SOURCE-COMPUTER. IBM-Z.
       OBJECT-COMPUTER. IBM-Z.
       INPUT-OUTPUT SECTION.
       FILE-CONTROL.
           SELECT CAS-IN ASSIGN TO UCASIN
               ORGANIZATION IS SEQUENTIAL.
       DATA DIVISION.
       FILE SECTION.
       FD  CAS-IN.
       01  CAS-REC PIC X(80).
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
       COPY BKATM.
       01 WS-SW PIC S9(15)V99 COMP-3.
       01 WS-CS PIC S9(15)V99 COMP-3.
       PROCEDURE DIVISION.
       0000-MAIN.
           PERFORM 0500-INIT
           PERFORM 1000-PROCESS
           PERFORM 8000-MAP-SQL
           PERFORM 9000-TERM
           GOBACK
           .
       0500-INIT.
           OPEN INPUT CAS-IN
           EXIT.
       1000-PROCESS.
           EXEC SQL SELECT COALESCE(SUM(AMOUNT),0) INTO :WS-SW
             FROM BANK_ATM_ADVICE
            WHERE DATE(SWITCH_TS) = CURRENT DATE AND DISP_IND = 'Y'
           END-EXEC
           MOVE 0 TO WS-CS
           PERFORM UNTIL SQLCODE = 100
              READ CAS-IN AT END EXIT PERFORM
              END-READ
              ADD FUNCTION NUMVAL(CAS-REC(1:12)) TO WS-CS
           END-PERFORM
           IF WS-SW NOT = WS-CS
              MOVE 4 TO WS-RC
              MOVE 'CASSETTE-DIFF' TO BK-OP-MSG
           END-IF
           CLOSE CAS-IN
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
