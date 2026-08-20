      *****************************************************************
      * PROGRAM-ID : BKWIR01
      * TITLE      : Correspondent wire inbox — CORRBANK loc, channel WIRE
      * Synthetic lab system. Not a real bank. Educational / portfolio only.
      * Validates BIC-like counterparty field in bytes 80-91 of extract.
      *****************************************************************
       IDENTIFICATION DIVISION.
       PROGRAM-ID. BKWIR01.
       AUTHOR. LAB-V2.
       DATE-WRITTEN. 2026-08-20.
       ENVIRONMENT DIVISION.
       CONFIGURATION SECTION.
       SOURCE-COMPUTER. IBM-Z.
       OBJECT-COMPUTER. IBM-Z.
       INPUT-OUTPUT SECTION.
       FILE-CONTROL.
           SELECT WIR-IN ASSIGN TO UWIRE
               ORGANIZATION IS SEQUENTIAL
               FILE STATUS IS WS-FS1.
       DATA DIVISION.
       FILE SECTION.
       FD  WIR-IN.
       01  WIR-REC PIC X(200).
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
       01 WS-BIC PIC X(11).
       01 WS-FS1 PIC XX.
       PROCEDURE DIVISION.
       0000-MAIN.
           PERFORM 0500-INIT
           PERFORM 1000-PROCESS
           PERFORM 8000-MAP-SQL
           PERFORM 9000-TERM
           GOBACK
           .
       0500-INIT.
           OPEN INPUT WIR-IN
           IF WS-FS1 = '35'
              MOVE 8 TO WS-RC
              SET BK-W-FILEWAIT TO TRUE
           END-IF
           EXIT.
       1000-PROCESS.
           IF WS-RC > 4 GO TO 1000-X END-IF
           READ WIR-IN INTO BK-EXTRACT-REC
             AT END GO TO 1000-X
           END-READ
           IF XTR-LOC-ID NOT = 'CORRBANK'
              SET BK-E-LOCMISMATCH TO TRUE
              MOVE 12 TO WS-RC
           END-IF
           MOVE WIR-REC(80:11) TO WS-BIC
           IF WS-BIC = SPACES
              MOVE 12 TO WS-RC
              MOVE 'BIC-MISSING' TO BK-OP-MSG
           END-IF
           CLOSE WIR-IN
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
