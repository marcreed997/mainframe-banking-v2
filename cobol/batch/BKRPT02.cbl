      *****************************************************************
      * PROGRAM-ID : BKRPT02
      * TITLE      : Settlement summary by location — hash DR/CR vs hub posted
      * Synthetic lab system. Not a real bank. Educational / portfolio only.
      * Used by ops after recon.
      *****************************************************************
       IDENTIFICATION DIVISION.
       PROGRAM-ID. BKRPT02.
       AUTHOR. LAB-V2.
       DATE-WRITTEN. 2026-08-20.
       ENVIRONMENT DIVISION.
       CONFIGURATION SECTION.
       SOURCE-COMPUTER. IBM-Z.
       OBJECT-COMPUTER. IBM-Z.
       INPUT-OUTPUT SECTION.
       FILE-CONTROL.
           SELECT SUM-OUT ASSIGN TO USUM
               ORGANIZATION IS SEQUENTIAL.
       DATA DIVISION.
       FILE SECTION.
       FD  SUM-OUT.
       01  SUM-LINE PIC X(132).
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
       COPY BKTRL.
       COPY BKFIL.
       PROCEDURE DIVISION.
       0000-MAIN.
           PERFORM 0500-INIT
           PERFORM 1000-PROCESS
           PERFORM 8000-MAP-SQL
           PERFORM 9000-TERM
           GOBACK
           .
       0500-INIT.
           OPEN OUTPUT SUM-OUT
           EXIT.
       1000-PROCESS.
           EXEC SQL DECLARE C-SUM CURSOR FOR
             SELECT LOC_ID, HASH_DR, HASH_CR, REC_COUNT
               FROM BANK_LOCATION_FILE_CTL
              WHERE CYCLE_DTE = :FIL-CYCLE-DTE
           END-EXEC
           EXEC SQL OPEN C-SUM END-EXEC
           PERFORM UNTIL SQLCODE NOT = 0
              EXEC SQL FETCH C-SUM INTO :FIL-LOC-ID, :FIL-HASH-DR,
                   :FIL-HASH-CR, :FIL-REC-COUNT
              END-EXEC
              IF SQLCODE = 0
                 WRITE SUM-LINE FROM BK-FILE-CTL
              END-IF
           END-PERFORM
           EXEC SQL CLOSE C-SUM END-EXEC
           CLOSE SUM-OUT
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
