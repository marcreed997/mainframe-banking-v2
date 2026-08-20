      *****************************************************************
      * PROGRAM-ID : BKHT01
      * TITLE      : Hash total utility — standalone debit=credit proof for a file
      * Synthetic lab system. Not a real bank. Educational / portfolio only.
      * RC=4 if empty; RC=12 if DR<>CR (out of balance file).
      *****************************************************************
       IDENTIFICATION DIVISION.
       PROGRAM-ID. BKHT01.
       AUTHOR. LAB-V2.
       DATE-WRITTEN. 2026-08-20.
       ENVIRONMENT DIVISION.
       CONFIGURATION SECTION.
       SOURCE-COMPUTER. IBM-Z.
       OBJECT-COMPUTER. IBM-Z.
       INPUT-OUTPUT SECTION.
       FILE-CONTROL.
           SELECT IN-FILE ASSIGN TO UHASHIN
               ORGANIZATION IS SEQUENTIAL
               FILE STATUS IS WS-FS1.
       DATA DIVISION.
       FILE SECTION.
       FD  IN-FILE.
       01  IN-REC PIC X(200).
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
       01 WS-DR PIC S9(15)V99 COMP-3 VALUE 0.
       01 WS-CR PIC S9(15)V99 COMP-3 VALUE 0.
       01 WS-N PIC 9(9) VALUE 0.
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
           OPEN INPUT IN-FILE
           IF WS-FS1 = '35'
              MOVE 8 TO WS-RC
              SET BK-W-FILEWAIT TO TRUE
           END-IF
           EXIT.
       1000-PROCESS.
           IF WS-RC > 4 GO TO 1000-X END-IF
           PERFORM UNTIL WS-FS1 NOT = '00'
              READ IN-FILE INTO BK-EXTRACT-REC
                AT END EXIT PERFORM
              END-READ
              IF XTR-BODY
                 ADD 1 TO WS-N
                 IF XTR-DRCR = 'D'
                    ADD XTR-AMT TO WS-DR
                 ELSE
                    ADD XTR-AMT TO WS-CR
                 END-IF
              END-IF
           END-PERFORM
           IF WS-N = 0
              MOVE 4 TO WS-RC
           END-IF
           IF WS-DR NOT = WS-CR
              SET BK-E-HASH TO TRUE
              MOVE 12 TO WS-RC
           END-IF
           CLOSE IN-FILE
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
