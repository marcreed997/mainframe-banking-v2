      *****************************************************************
      * PROGRAM-ID : BKABD01
      * TITLE      : Controlled user-abend demonstration — dump DD, LE TRAP comment
      * Synthetic lab system. Not a real bank. Educational / portfolio only.
      * SYSIN ABEND -> user abend analog RETURN-CODE 16 + dump. Else notify only.
      *****************************************************************
       IDENTIFICATION DIVISION.
       PROGRAM-ID. BKABD01.
       AUTHOR. LAB-V2.
       DATE-WRITTEN. 2026-08-20.
       ENVIRONMENT DIVISION.
       CONFIGURATION SECTION.
       SOURCE-COMPUTER. IBM-Z.
       OBJECT-COMPUTER. IBM-Z.
       INPUT-OUTPUT SECTION.
       FILE-CONTROL.
           SELECT DUMP-FILE ASSIGN TO SYSUDUMP
               ORGANIZATION IS SEQUENTIAL
               FILE STATUS IS WS-FS1.
       DATA DIVISION.
       FILE SECTION.
       FD  DUMP-FILE.
       01  DUMP-REC                 PIC X(80).
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
       COPY BKMSG.
       01  WS-FS1                   PIC XX.
       01  WS-SYSIN                 PIC X(8).
       01  WS-ABEND-CODE            PIC 9(4) VALUE 4038.

       PROCEDURE DIVISION.
       0000-MAIN.
           ACCEPT WS-SYSIN FROM SYSIN
           IF WS-SYSIN = 'ABEND'
              PERFORM 1000-DUMP
              MOVE 16 TO WS-RC
              SET BK-E-RESTART TO TRUE
              MOVE 'BK-E-RESTART U4038' TO BK-OP-MSG
              MOVE WS-RC TO RETURN-CODE
      * Production: LE TRAP(ON,SPIE) / TERMTHDACT(UADUMP). Lab: STOP RUN.
              STOP RUN
           END-IF
           MOVE 0 TO WS-RC
           MOVE WS-RC TO RETURN-CODE
           GOBACK
           .
       1000-DUMP.
           OPEN OUTPUT DUMP-FILE
           MOVE 'USER ABEND U4038 LAB DUMP' TO DUMP-REC
           WRITE DUMP-REC
           MOVE 'DO NOT USE EVEN ON MONETARY STEPS' TO DUMP-REC
           WRITE DUMP-REC
           CLOSE DUMP-FILE
           EXIT.

       8000-MAP-SQL.
           COPY BKSQLM.
           EXIT.
       9000-TERM.
           MOVE WS-RC TO RETURN-CODE
           EXIT.
