      *****************************************************************
      * PROGRAM-ID : BKRCN03
      * TITLE      : Three-way recon — location extract vs hub journal vs GL feed
      * Synthetic lab system. Not a real bank. Educational / portfolio only.
      * Writes unmatched both directions. Sets RECON_CLOSED only if all three legs net.
      *****************************************************************
       IDENTIFICATION DIVISION.
       PROGRAM-ID. BKRCN03.
       AUTHOR. LAB-V2.
       DATE-WRITTEN. 2026-08-20.
       ENVIRONMENT DIVISION.
       CONFIGURATION SECTION.
       SOURCE-COMPUTER. IBM-Z.
       OBJECT-COMPUTER. IBM-Z.
       INPUT-OUTPUT SECTION.
       FILE-CONTROL.
           SELECT X3 ASSIGN TO UX3OUT
               ORGANIZATION IS SEQUENTIAL
               FILE STATUS IS WS-FS1.
       DATA DIVISION.
       FILE SECTION.
       FD  X3.
       01  X3-REC                   PIC X(132).
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
       COPY BKRCN.
       COPY BKJRN.
       COPY BKTRN.
       COPY BKGLMP.
       01  WS-FS1                   PIC XX.
       01  WS-LOC-ORPH              PIC 9(7) VALUE 0.
       01  WS-HUB-ORPH              PIC 9(7) VALUE 0.
       01  WS-GL-ORPH               PIC 9(7) VALUE 0.
       01  WS-MATCH                 PIC 9(7) VALUE 0.

       PROCEDURE DIVISION.
       0000-MAIN.
           PERFORM 0500-GATE
           PERFORM 1000-LOC-VS-HUB
           PERFORM 2000-HUB-VS-GL
           PERFORM 3000-CLOSE
           PERFORM 9000-TERM
           GOBACK
           .
       0500-GATE.
           EXEC SQL SELECT VALIDATED_IND, STATUS
             INTO :CTL-VALIDATED-IND, :CTL-STATUS
             FROM BANK_CYCLE_CTL FETCH FIRST 1 ROW ONLY
           END-EXEC
           IF CTL-VALIDATED-IND NOT = 'Y'
              SET BK-E-NOT-VALID TO TRUE
              MOVE 8 TO WS-RC
              MOVE 'BK-E-NOT-VALID' TO BK-OP-MSG
           END-IF
           OPEN OUTPUT X3
           EXIT.
       1000-LOC-VS-HUB.
           IF WS-RC > 4 GO TO 1000-X END-IF
           EXEC SQL DECLARE C-LOC CURSOR FOR
             SELECT TRACE_ID, LOC_ID, ACCOUNT_NO, AMOUNT, DR_CR
               FROM BANK_LOCATION_XTR
              WHERE CYCLE_DTE = CURRENT DATE
           END-EXEC
           EXEC SQL OPEN C-LOC END-EXEC
           PERFORM UNTIL SQLCODE NOT = 0
              EXEC SQL FETCH C-LOC INTO :XTR-TRACE-ID, :XTR-LOC-ID,
                   :XTR-ACC-NO, :XTR-AMT, :XTR-DRCR
              END-EXEC
              IF SQLCODE = 0
                 EXEC SQL SELECT TRACE_ID INTO :JRN-TRACE-ID
                   FROM BANK_JOURNAL WHERE TRACE_ID = :XTR-TRACE-ID
                 END-EXEC
                 IF SQLCODE = +100
                    ADD 1 TO WS-LOC-ORPH
                    SET RSN-UNMATCH-HUB TO TRUE
                    EXEC SQL INSERT INTO BANK_RECON_XCPT
                      (CYCLE_DTE, LOC_ID, TRACE_ID, ACCOUNT_NO, REASON,
                       AMOUNT, STATUS)
                      VALUES (CURRENT DATE, :XTR-LOC-ID, :XTR-TRACE-ID,
                              :XTR-ACC-NO, 'UNMATCH-HUB', :XTR-AMT, 'O')
                    END-EXEC
                 ELSE
                    ADD 1 TO WS-MATCH
                 END-IF
              END-IF
           END-PERFORM
           EXEC SQL CLOSE C-LOC END-EXEC
           EXEC SQL DECLARE C-HUB CURSOR FOR
             SELECT TRACE_ID, LOC_ID, ACCOUNT_NO, AMOUNT
               FROM BANK_JOURNAL
              WHERE CYCLE_DTE = CURRENT DATE
                AND CHANNEL <> 'TELLER'
                AND TRACE_ID NOT IN
                    (SELECT TRACE_ID FROM BANK_LOCATION_XTR
                      WHERE CYCLE_DTE = CURRENT DATE)
           END-EXEC
           EXEC SQL OPEN C-HUB END-EXEC
           PERFORM UNTIL SQLCODE NOT = 0
              EXEC SQL FETCH C-HUB INTO :JRN-TRACE-ID, :JRN-LOC-ID,
                   :JRN-ACC-NO, :JRN-AMT
              END-EXEC
              IF SQLCODE = 0
                 ADD 1 TO WS-HUB-ORPH
                 EXEC SQL INSERT INTO BANK_RECON_XCPT
                   (CYCLE_DTE, LOC_ID, TRACE_ID, ACCOUNT_NO, REASON,
                    AMOUNT, STATUS)
                   VALUES (CURRENT DATE, :JRN-LOC-ID, :JRN-TRACE-ID,
                           :JRN-ACC-NO, 'UNMATCH-LOC', :JRN-AMT, 'O')
                 END-EXEC
              END-IF
           END-PERFORM
           EXEC SQL CLOSE C-HUB END-EXEC
           .
       1000-X.
           EXIT.
       2000-HUB-VS-GL.
           IF WS-RC > 4 GO TO 2000-X END-IF
           EXEC SQL SELECT COUNT(*) INTO :WS-GL-ORPH
             FROM BANK_GL_FEED F
            WHERE F.CYCLE_DTE = CURRENT DATE
              AND NOT EXISTS (
                  SELECT 1 FROM BANK_JOURNAL J
                   WHERE J.CYCLE_DTE = F.CYCLE_DTE
                     AND J.GL_ACCT = F.GL_ACCT)
           END-EXEC
           .
       2000-X.
           EXIT.
       3000-CLOSE.
           IF WS-RC > 4 GO TO 3000-X END-IF
           IF WS-LOC-ORPH = 0 AND WS-HUB-ORPH = 0 AND WS-GL-ORPH = 0
              EXEC SQL UPDATE BANK_CYCLE_CTL
                SET RECON_CLOSED = 'Y', STATUS = 'RECON'
                WHERE CYCLE_DTE = CURRENT DATE
              END-EXEC
              MOVE 'THREE-WAY-CLOSED' TO X3-REC
           ELSE
              MOVE 12 TO WS-RC
              SET BK-E-UNMATCHED TO TRUE
              MOVE 'BK-E-UNMATCHED 3WAY' TO BK-OP-MSG
              MOVE 'THREE-WAY-OPEN' TO X3-REC
           END-IF
           WRITE X3-REC
           CLOSE X3
           .
       3000-X.
           EXIT.

       8000-MAP-SQL.
           COPY BKSQLM.
           EXIT.
       9000-TERM.
           MOVE WS-RC TO RETURN-CODE
           EXIT.
