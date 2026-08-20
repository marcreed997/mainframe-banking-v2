      *****************************************************************
      * PROGRAM-ID : BKGDG01
      * TITLE      : GDG generation-date guard — refuse (-1) processed as current
      * Synthetic lab system. Not a real bank. Educational / portfolio only.
      * Header cycle date must equal BANK_CYCLE_CTL. Out-of-order GDG -> RC=12 BK-E-CUTOFF.
      *****************************************************************
       IDENTIFICATION DIVISION.
       PROGRAM-ID. BKGDG01.
       AUTHOR. LAB-V2.
       DATE-WRITTEN. 2026-08-20.
       ENVIRONMENT DIVISION.
       CONFIGURATION SECTION.
       SOURCE-COMPUTER. IBM-Z.
       OBJECT-COMPUTER. IBM-Z.
       INPUT-OUTPUT SECTION.
       FILE-CONTROL.
           SELECT GDG-FILE ASSIGN TO UGDGIN
               ORGANIZATION IS SEQUENTIAL
               FILE STATUS IS WS-FS1.
       DATA DIVISION.
       FILE SECTION.
       FD  GDG-FILE.
       01  GDG-REC                  PIC X(200).
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
       01  WS-FS1                   PIC XX.
       01  WS-EXPECT-DTE            PIC X(10).
       01  WS-HDR-DTE               PIC X(10).
       01  WS-DSNAME                PIC X(44).
       01  WS-GEN-IN-NAME           PIC 9(4).

       PROCEDURE DIVISION.
       0000-MAIN.
           PERFORM 0500-OPEN
           PERFORM 1000-HDR
           PERFORM 2000-NAME
           PERFORM 9000-TERM
           GOBACK
           .
       0500-OPEN.
           ACCEPT WS-DSNAME FROM SYSIN
           EXEC SQL SELECT CYCLE_DTE INTO :WS-EXPECT-DTE
             FROM BANK_CYCLE_CTL FETCH FIRST 1 ROW ONLY
           END-EXEC
           OPEN INPUT GDG-FILE
           IF WS-FS1 = '35'
              SET BK-W-FILEWAIT TO TRUE
              MOVE 8 TO WS-RC
              MOVE 'BK-W-FILEWAIT' TO BK-OP-MSG
           END-IF
           EXIT.
       1000-HDR.
           IF WS-RC > 4 GO TO 1000-X END-IF
           READ GDG-FILE INTO BK-EXTRACT-REC
             AT END MOVE 4 TO WS-RC
                    SET BK-W-EMPTY TO TRUE
                    GO TO 1000-X
           END-READ
           IF NOT XTR-HDR
              MOVE 12 TO WS-RC
              SET BK-E-LOCMISMATCH TO TRUE
              MOVE 'BK-E-LOCMISMATCH NOHDR' TO BK-OP-MSG
              GO TO 1000-X
           END-IF
           MOVE XTR-CYCLE-DTE TO WS-HDR-DTE
           IF WS-HDR-DTE NOT = WS-EXPECT-DTE
              SET BK-E-CUTOFF TO TRUE
              MOVE 12 TO WS-RC
              MOVE 'BK-E-CUTOFF GDG-DTE' TO BK-OP-MSG
           END-IF
           .
       1000-X.
           EXIT.
       2000-NAME.
           IF WS-RC > 4 GO TO 2000-X END-IF
      * Lab parse: last 4 chars of DSNAME as generation number.
           MOVE WS-DSNAME(41:4) TO WS-GEN-IN-NAME
           EXEC SQL SELECT GEN_NO INTO :FIL-GEN-NO
             FROM BANK_LOCATION_FILE_CTL
            WHERE LOC_ID = :XTR-LOC-ID
              AND CYCLE_DTE = :WS-EXPECT-DTE
           END-EXEC
           IF SQLCODE = 0 AND FIL-GEN-NO NOT = WS-GEN-IN-NAME
              MOVE 12 TO WS-RC
              SET BK-E-CUTOFF TO TRUE
              MOVE 'BK-E-CUTOFF WRONG-GEN' TO BK-OP-MSG
           END-IF
           CLOSE GDG-FILE
           .
       2000-X.
           EXIT.

       8000-MAP-SQL.
           COPY BKSQLM.
           EXIT.
       9000-TERM.
           MOVE WS-RC TO RETURN-CODE
           EXIT.
