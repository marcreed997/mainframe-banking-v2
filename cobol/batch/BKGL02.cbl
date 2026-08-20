      *****************************************************************
      * PROGRAM-ID : BKGL02
      * TITLE      : GL prove — journal totals vs BANK_GL_FEED vs location trailers
      * Synthetic lab system. Not a real bank. Educational / portfolio only.
      * Blocked unless recon closed. Variance -> RC=12, do not set GL_PROVED.
      *****************************************************************
       IDENTIFICATION DIVISION.
       PROGRAM-ID. BKGL02.
       AUTHOR. LAB-V2.
       DATE-WRITTEN. 2026-08-20.
       ENVIRONMENT DIVISION.
       CONFIGURATION SECTION.
       SOURCE-COMPUTER. IBM-Z.
       OBJECT-COMPUTER. IBM-Z.
       INPUT-OUTPUT SECTION.
       FILE-CONTROL.
           SELECT GLRPT ASSIGN TO UGLRPT
               ORGANIZATION IS SEQUENTIAL
               FILE STATUS IS WS-FS1.
       DATA DIVISION.
       FILE SECTION.
       FD  GLRPT.
       01  GLRPT-REC                PIC X(132).
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
       COPY BKGLMP.
       COPY BKGL.
       COPY BKRCN.
       01  WS-FS1                   PIC XX.

       PROCEDURE DIVISION.
       0000-MAIN.
           PERFORM 0500-GATE
           PERFORM 1000-SUM-JRN
           PERFORM 2000-SUM-FEED
           PERFORM 3000-SUM-LOC
           PERFORM 4000-PROVE
           PERFORM 9000-TERM
           GOBACK
           .
       0500-GATE.
           EXEC SQL SELECT RECON_CLOSED, GL_PROVED, STATUS
             INTO :CTL-RECON-CLOSED, :GLP-CLOSED-IND, :CTL-STATUS
             FROM BANK_CYCLE_CTL FETCH FIRST 1 ROW ONLY
           END-EXEC
           IF CTL-RECON-CLOSED NOT = 'Y'
              MOVE 8 TO WS-RC
              MOVE 'RECON-NOT-CLOSED' TO BK-OP-MSG
              SET BK-E-NOT-VALID TO TRUE
           END-IF
           OPEN OUTPUT GLRPT
           EXIT.
       1000-SUM-JRN.
           IF WS-RC > 4 GO TO 1000-X END-IF
           EXEC SQL SELECT
               COALESCE(SUM(CASE WHEN DR_CR='D' THEN AMOUNT END),0),
               COALESCE(SUM(CASE WHEN DR_CR='C' THEN AMOUNT END),0)
             INTO :GLP-JRN-DR, :GLP-JRN-CR
             FROM BANK_JOURNAL
            WHERE CYCLE_DTE = CURRENT DATE
              AND POSTED_IND = 'Y'
           END-EXEC
           PERFORM 8000-MAP-SQL
           .
       1000-X.
           EXIT.
       2000-SUM-FEED.
           IF WS-RC > 4 GO TO 2000-X END-IF
           EXEC SQL SELECT
               COALESCE(SUM(CASE WHEN DR_CR='D' THEN AMOUNT END),0),
               COALESCE(SUM(CASE WHEN DR_CR='C' THEN AMOUNT END),0)
             INTO :GLP-FEED-DR, :GLP-FEED-CR
             FROM BANK_GL_FEED
            WHERE CYCLE_DTE = CURRENT DATE
           END-EXEC
           .
       2000-X.
           EXIT.
       3000-SUM-LOC.
           IF WS-RC > 4 GO TO 3000-X END-IF
           EXEC SQL SELECT COALESCE(SUM(HASH_DR),0), COALESCE(SUM(HASH_CR),0)
             INTO :GLP-LOC-DR, :GLP-LOC-CR
             FROM BANK_LOCATION_FILE_CTL
            WHERE CYCLE_DTE = CURRENT DATE
              AND VALIDATED_IND = 'Y'
           END-EXEC
           .
       3000-X.
           EXIT.
       4000-PROVE.
           IF WS-RC > 4 GO TO 4000-X END-IF
           COMPUTE GLP-VAR-DR = GLP-JRN-DR - GLP-FEED-DR
           COMPUTE GLP-VAR-CR = GLP-JRN-CR - GLP-FEED-CR
           IF GLP-JRN-DR NOT = GLP-JRN-CR
              MOVE 12 TO WS-RC
              SET BK-E-HASH TO TRUE
              MOVE 'BK-E-HASH JRN DR!=CR' TO BK-OP-MSG
              GO TO 4000-X
           END-IF
           IF GLP-VAR-DR NOT = 0 OR GLP-VAR-CR NOT = 0
              MOVE 12 TO WS-RC
              SET BK-E-UNMATCHED TO TRUE
              MOVE 'BK-E-UNMATCHED GL' TO BK-OP-MSG
              MOVE 'VARIANCE' TO GLRPT-REC
              WRITE GLRPT-REC
              GO TO 4000-X
           END-IF
           EXEC SQL UPDATE BANK_CYCLE_CTL SET GL_PROVED = 'Y'
             WHERE CYCLE_DTE = CURRENT DATE
           END-EXEC
           MOVE 'PROVED' TO GLRPT-REC
           WRITE GLRPT-REC
           CLOSE GLRPT
           .
       4000-X.
           EXIT.

       8000-MAP-SQL.
           COPY BKSQLM.
           EXIT.
       9000-TERM.
           MOVE WS-RC TO RETURN-CODE
           EXIT.
