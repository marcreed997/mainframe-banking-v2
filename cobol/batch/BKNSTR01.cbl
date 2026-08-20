      *****************************************************************
      * PROGRAM-ID : BKNSTR01
      * TITLE      : Nostro/vostro stub — nets WIRE channel vs correspondent expected
      * Synthetic lab system. Not a real bank. Educational / portfolio only.
      * RC=4 if nostro break; does not adjust DDA.
      *****************************************************************
       IDENTIFICATION DIVISION.
       PROGRAM-ID. BKNSTR01.
       AUTHOR. LAB-V2.
       DATE-WRITTEN. 2026-08-20.
       ENVIRONMENT DIVISION.
       CONFIGURATION SECTION.
       SOURCE-COMPUTER. IBM-Z.
       OBJECT-COMPUTER. IBM-Z.
       INPUT-OUTPUT SECTION.
       FILE-CONTROL.
           SELECT NOS-IN ASSIGN TO UNOS
               ORGANIZATION IS SEQUENTIAL.
       DATA DIVISION.
       FILE SECTION.
       FD  NOS-IN.
       01  NOS-REC PIC X(80).
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
       COPY BKGL.
       01 WS-EXP PIC S9(15)V99 COMP-3.
       01 WS-ACT PIC S9(15)V99 COMP-3.
       PROCEDURE DIVISION.
       0000-MAIN.
           PERFORM 0500-INIT
           PERFORM 1000-PROCESS
           PERFORM 8000-MAP-SQL
           PERFORM 9000-TERM
           GOBACK
           .
       0500-INIT.
           OPEN INPUT NOS-IN
           EXIT.
       1000-PROCESS.
           EXEC SQL SELECT COALESCE(SUM(AMOUNT),0) INTO :WS-ACT
             FROM BANK_JOURNAL WHERE CHANNEL = 'WIRE'
              AND CYCLE_DTE = CURRENT DATE
           END-EXEC
           READ NOS-IN AT END MOVE 0 TO WS-EXP
           END-READ
           IF WS-ACT NOT = WS-EXP
              MOVE 4 TO WS-RC
              MOVE 'NOSTRO-BREAK' TO BK-OP-MSG
           END-IF
           CLOSE NOS-IN
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
