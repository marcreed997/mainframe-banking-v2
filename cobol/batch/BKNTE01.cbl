      *****************************************************************
      * PROGRAM-ID : BKNTE01
      * TITLE      : Abend-path demo — user abend only when PARM=DUMP (lab)
      * Synthetic lab system. Not a real bank. Educational / portfolio only.
      * Production would use LE TRAP. Default is RC=16 no dump.
      *****************************************************************
       IDENTIFICATION DIVISION.
       PROGRAM-ID. BKNTE01.
       AUTHOR. LAB-V2.
       DATE-WRITTEN. 2026-08-20.
       ENVIRONMENT DIVISION.
       CONFIGURATION SECTION.
       SOURCE-COMPUTER. IBM-Z.
       OBJECT-COMPUTER. IBM-Z.
       INPUT-OUTPUT SECTION.
       FILE-CONTROL.
           SELECT DMP ASSIGN TO UDMP
               ORGANIZATION IS SEQUENTIAL.
       DATA DIVISION.
       FILE SECTION.
       FD  DMP.
       01  DMP-REC PIC X(80).
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
       01 WS-PARM PIC X(8).
       PROCEDURE DIVISION.
       0000-MAIN.
           PERFORM 0500-INIT
           PERFORM 1000-PROCESS
           PERFORM 8000-MAP-SQL
           PERFORM 9000-TERM
           GOBACK
           .
       0500-INIT.
           ACCEPT WS-PARM FROM SYSIN
           OPEN OUTPUT DMP
           EXIT.
       1000-PROCESS.
           MOVE 16 TO WS-RC
           SET BK-E-RESTART TO TRUE
           WRITE DMP-REC FROM 'CONTROLLED SEVERE PATH'
           IF WS-PARM = 'DUMP'
              DISPLAY 'USER ABEND REQUESTED — LAB ONLY'
           END-IF
           CLOSE DMP
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
