      *****************************************************************
      * PROGRAM-ID : BKMRG01
      * TITLE      : Merge EAST/WEST/ATM extracts after each validate RC<=4
      * Synthetic lab system. Not a real bank. Educational / portfolio only.
      * Rejects if any location not arrived (wait). SORT sequence TRACE-ID.
      *****************************************************************
       IDENTIFICATION DIVISION.
       PROGRAM-ID. BKMRG01.
       AUTHOR. LAB-V2.
       DATE-WRITTEN. 2026-08-20.
       ENVIRONMENT DIVISION.
       CONFIGURATION SECTION.
       SOURCE-COMPUTER. IBM-Z.
       OBJECT-COMPUTER. IBM-Z.
       INPUT-OUTPUT SECTION.
       FILE-CONTROL.
           SELECT MERGED ASSIGN TO UMERGE
               ORGANIZATION IS SEQUENTIAL.
       DATA DIVISION.
       FILE SECTION.
       FD  MERGED.
       01  MRG-REC PIC X(200).
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
       COPY BKFIL.
       01 WS-MISS PIC 9 VALUE 0.
       PROCEDURE DIVISION.
       0000-MAIN.
           PERFORM 0500-INIT
           PERFORM 1000-PROCESS
           PERFORM 8000-MAP-SQL
           PERFORM 9000-TERM
           GOBACK
           .
       0500-INIT.
           EXEC SQL SELECT COUNT(*) INTO :WS-MISS
             FROM BANK_LOCATION_FILE_CTL
            WHERE CYCLE_DTE = :FIL-CYCLE-DTE
              AND (ARRIVED_IND <> 'Y' OR VALIDATED_IND <> 'Y')
              AND LOC_ID IN ('RGNEAST','RGNWEST','ATMNET')
           END-EXEC
           IF WS-MISS > 0
              SET BK-W-FILEWAIT TO TRUE
              MOVE 8 TO WS-RC
           END-IF
           OPEN OUTPUT MERGED
           EXIT.
       1000-PROCESS.
           IF WS-RC > 4 GO TO 1000-X END-IF
           EXEC SQL DECLARE C-MRG CURSOR FOR
             SELECT TRACE_ID, ACCOUNT_NO, DR_CR, AMOUNT, LOC_ID
               FROM BANK_LOCATION_XTR
              WHERE CYCLE_DTE = :FIL-CYCLE-DTE
              ORDER BY TRACE_ID
           END-EXEC
           EXEC SQL OPEN C-MRG END-EXEC
           PERFORM UNTIL SQLCODE NOT = 0
              EXEC SQL FETCH C-MRG INTO :XTR-TRACE-ID, :XTR-ACC-NO,
                   :XTR-DRCR, :XTR-AMT, :XTR-LOC-ID
              END-EXEC
              IF SQLCODE = 0
                 WRITE MRG-REC FROM BK-EXTRACT-REC
              END-IF
           END-PERFORM
           EXEC SQL CLOSE C-MRG END-EXEC
           CLOSE MERGED
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
