      *****************************************************************
      * PROGRAM-ID : BKFEA01
      * TITLE      : Account analysis / monthly service charge
      * Synthetic lab system. Not a real bank. Educational / portfolio only.
      * Waive if average ledger >= waive_bal on BANK_FEE_SCHED. NSF items extra.
      *****************************************************************
       IDENTIFICATION DIVISION.
       PROGRAM-ID. BKFEA01.
       AUTHOR. LAB-V2.
       DATE-WRITTEN. 2026-08-20.
       ENVIRONMENT DIVISION.
       CONFIGURATION SECTION.
       SOURCE-COMPUTER. IBM-Z.
       OBJECT-COMPUTER. IBM-Z.
       INPUT-OUTPUT SECTION.
       FILE-CONTROL.
           SELECT FEERPT ASSIGN TO UFEERPT
               ORGANIZATION IS SEQUENTIAL
               FILE STATUS IS WS-FS1.
       DATA DIVISION.
       FILE SECTION.
       FD  FEERPT.
       01  FEE-RPT                  PIC X(120).
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
       COPY BKACC.
       COPY BKJRN.
       01  WS-FS1                   PIC XX.
       01  WS-FEE                   PIC S9(7)V99 COMP-3.
       01  WS-WAIVE                 PIC S9(13)V99 COMP-3.
       01  WS-NSF                   PIC 9(4).
       01  WS-CHARGED               PIC 9(7) VALUE 0.
       01  WS-WAIVED                PIC 9(7) VALUE 0.

       PROCEDURE DIVISION.
       0000-MAIN.
           PERFORM 0500-GATE
           PERFORM 1000-EACH
           PERFORM 9000-TERM
           GOBACK
           .
       0500-GATE.
           EXEC SQL SELECT ONLINE_INHIBIT INTO :CTL-ONLINE-INHIBIT
             FROM BANK_CYCLE_CTL FETCH FIRST 1 ROW ONLY
           END-EXEC
           IF ONLINE-ALLOWED
              SET BK-E-CICS-ACTIVE TO TRUE
              MOVE 12 TO WS-RC
           END-IF
           OPEN OUTPUT FEERPT
           EXIT.
       1000-EACH.
           IF WS-RC >= 12 GO TO 1000-X END-IF
           EXEC SQL DECLARE C-ACC CURSOR FOR
             SELECT ACCOUNT_NO, BALANCE, PROD, NSF_COUNT
               FROM BANK_CUSTOMER WHERE STATUS = 'O'
           END-EXEC
           EXEC SQL OPEN C-ACC END-EXEC
           PERFORM UNTIL SQLCODE NOT = 0
              EXEC SQL FETCH C-ACC INTO :ACC-NO, :ACC-BAL, :ACC-CCY,
                   :WS-NSF
              END-EXEC
              IF SQLCODE = 0
                 PERFORM 2000-FEE-ONE
              END-IF
           END-PERFORM
           EXEC SQL CLOSE C-ACC END-EXEC
           CLOSE FEERPT
           .
       1000-X.
           EXIT.
       2000-FEE-ONE.
           EXEC SQL SELECT AMOUNT, WAIVE_BAL
             INTO :WS-FEE, :WS-WAIVE
             FROM BANK_FEE_SCHED
            WHERE PROD = 'DDA '
              AND FEE_CODE = 'MAINT'
           END-EXEC
           IF SQLCODE = +100
              MOVE 8.00 TO WS-FEE
              MOVE 1500.00 TO WS-WAIVE
           END-IF
           IF ACC-BAL >= WS-WAIVE
              ADD 1 TO WS-WAIVED
              GO TO 2000-X
           END-IF
           COMPUTE WS-FEE = WS-FEE + (WS-NSF * 35.00)
           EXEC SQL UPDATE BANK_CUSTOMER
             SET BALANCE = BALANCE - :WS-FEE
             WHERE ACCOUNT_NO = :ACC-NO
           END-EXEC
           EXEC SQL INSERT INTO BANK_JOURNAL
             (TRACE_ID, ACCOUNT_NO, CHANNEL, DR_CR, AMOUNT, POSTED_IND,
              NARR)
             VALUES (:WS-TRACE, :ACC-NO, 'BATCH', 'D', :WS-FEE, 'Y',
                     'SVC-CHRG')
           END-EXEC
           ADD 1 TO WS-CHARGED
           MOVE 'CHARGED' TO FEE-RPT
           WRITE FEE-RPT
           PERFORM 8000-MAP-SQL
           .
       2000-X.
           EXIT.

       8000-MAP-SQL.
           COPY BKSQLM.
           EXIT.
       9000-TERM.
           MOVE WS-RC TO RETURN-CODE
           EXIT.
