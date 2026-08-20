      *****************************************************************
      * PROGRAM-ID : BKCRD01
      * TITLE      : Card presentment settlement vs open authorization hold
      * Synthetic lab system. Not a real bank. Educational / portfolio only.
      * Capture cannot exceed auth. Partial capture keeps residual hold. No auth = suspense.
      *****************************************************************
       IDENTIFICATION DIVISION.
       PROGRAM-ID. BKCRD01.
       AUTHOR. LAB-V2.
       DATE-WRITTEN. 2026-08-20.
       ENVIRONMENT DIVISION.
       CONFIGURATION SECTION.
       SOURCE-COMPUTER. IBM-Z.
       OBJECT-COMPUTER. IBM-Z.
       INPUT-OUTPUT SECTION.
       FILE-CONTROL.
           SELECT PRES-FILE ASSIGN TO UCRDIN
               ORGANIZATION IS SEQUENTIAL
               FILE STATUS IS WS-FS1.
       DATA DIVISION.
       FILE SECTION.
       FD  PRES-FILE.
       01  PRES-REC                 PIC X(180).
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
       COPY BKCRD.
       COPY BKHLD.
       COPY BKJRN.
       COPY BKACC.
       01  WS-FS1                   PIC XX.
       01  WS-RESIDUAL              PIC S9(13)V99 COMP-3.
       01  WS-CAP                   PIC S9(13)V99 COMP-3.

       PROCEDURE DIVISION.
       0000-MAIN.
           PERFORM 0500-OPEN
           PERFORM 1000-EACH
           PERFORM 9000-TERM
           GOBACK
           .
       0500-OPEN.
           OPEN INPUT PRES-FILE
           IF WS-FS1 = '35'
              SET BK-W-FILEWAIT TO TRUE
              MOVE 8 TO WS-RC
           END-IF
           EXIT.
       1000-EACH.
           IF WS-RC > 4 GO TO 1000-X END-IF
           PERFORM UNTIL WS-FS1 NOT = '00'
              READ PRES-FILE INTO BK-CARD-PRESENT
                AT END EXIT PERFORM
              END-READ
              PERFORM 2000-AUTH
              PERFORM 3000-CAPTURE
              IF WS-RC >= 12 EXIT PERFORM END-IF
           END-PERFORM
           CLOSE PRES-FILE
           .
       1000-X.
           EXIT.
       2000-AUTH.
           EXEC SQL SELECT AUTH_ID, AUTH_AMT, CAPTURE_AMT, STATUS,
                           ACCOUNT_NO, HOLD_ID
             INTO :CRD-AUTH-ID, :CRD-AUTH-AMT, :CRD-CAPTURE-AMT,
                  :CRD-STATUS, :CRD-ACC-NO, :CRD-HOLD-ID
             FROM BANK_CARD_AUTH
            WHERE AUTH_ID = :CRD-P-AUTH-ID
           END-EXEC
           IF SQLCODE = +100
              SET BK-E-UNMATCHED TO TRUE
              MOVE 'NO-AUTH' TO BK-OP-MSG
              EXEC SQL INSERT INTO BANK_SUSPENSE
                (CYCLE_DTE, TRACE_ID, AMOUNT, REASON, STATUS)
                VALUES (CURRENT DATE, :CRD-P-TRACE, :CRD-P-AMT,
                        'NO-AUTH', 'O')
              END-EXEC
              MOVE 4 TO WS-RC
              GO TO 2000-X
           END-IF
           IF CRD-VOID OR CRD-EXPIRED
              MOVE 12 TO WS-RC
              MOVE 'AUTH-DEAD' TO BK-OP-MSG
           END-IF
           .
       2000-X.
           EXIT.
       3000-CAPTURE.
           IF WS-RC >= 12 GO TO 3000-X END-IF
           IF SQLCODE = +100 GO TO 3000-X END-IF
           COMPUTE WS-CAP = CRD-P-AMT + CRD-P-SURCHARGE
           IF CRD-CAPTURE-AMT + WS-CAP > CRD-AUTH-AMT
              MOVE 12 TO WS-RC
              SET BK-E-HASH TO TRUE
              MOVE 'CAPTURE-GT-AUTH' TO BK-OP-MSG
              GO TO 3000-X
           END-IF
           EXEC SQL INSERT INTO BANK_CARD_PRES
             (ARN, AUTH_ID, TRACE_ID, AMOUNT, SURCHARGE)
             VALUES (:CRD-P-ARN, :CRD-P-AUTH-ID, :CRD-P-TRACE,
                     :CRD-P-AMT, :CRD-P-SURCHARGE)
           END-EXEC
           PERFORM 8000-MAP-SQL
           EXEC SQL INSERT INTO BANK_JOURNAL
             (TRACE_ID, ACCOUNT_NO, CHANNEL, DR_CR, AMOUNT, POSTED_IND,
              NARR)
             VALUES (:CRD-P-TRACE, :CRD-ACC-NO, 'ATM', 'D', :WS-CAP,
                     'N', 'CARD-CAPTURE')
           END-EXEC
           COMPUTE WS-RESIDUAL = CRD-AUTH-AMT - CRD-CAPTURE-AMT - WS-CAP
           IF WS-RESIDUAL = 0
              EXEC SQL UPDATE BANK_CARD_AUTH
                SET STATUS = 'C', CAPTURE_AMT = AUTH_AMT
                WHERE AUTH_ID = :CRD-P-AUTH-ID
              END-EXEC
              EXEC SQL UPDATE BANK_HOLD SET STATUS = 'R'
                WHERE HOLD_ID = :CRD-HOLD-ID
              END-EXEC
           ELSE
              EXEC SQL UPDATE BANK_CARD_AUTH
                SET CAPTURE_AMT = CAPTURE_AMT + :WS-CAP
                WHERE AUTH_ID = :CRD-P-AUTH-ID
              END-EXEC
              EXEC SQL UPDATE BANK_HOLD SET AMOUNT = :WS-RESIDUAL
                WHERE HOLD_ID = :CRD-HOLD-ID
              END-EXEC
           END-IF
           PERFORM 8000-MAP-SQL
           .
       3000-X.
           EXIT.

       8000-MAP-SQL.
           COPY BKSQLM.
           EXIT.
       9000-TERM.
           MOVE WS-RC TO RETURN-CODE
           EXIT.
