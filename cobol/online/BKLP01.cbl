      *****************************************************************
      * PROGRAM-ID : BKLP01
      * TITLE      : Loan payment — late, interest, escrow, then principal
      * Synthetic lab system. Not a real bank. Educational / portfolio only.
      * Funds from DDA. Invariant: applied parts sum to payment; remainder = unapplied.
      *****************************************************************
       IDENTIFICATION DIVISION.
       PROGRAM-ID. BKLP01.
       AUTHOR. LAB-V2.
       DATE-WRITTEN. 2026-08-20.
       ENVIRONMENT DIVISION.
       CONFIGURATION SECTION.
       SOURCE-COMPUTER. IBM-Z.
       OBJECT-COMPUTER. IBM-Z.
       DATA DIVISION.
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
       COPY BKLOAN.

       LINKAGE SECTION.
       01  DFHCOMMAREA              PIC X(1).
       PROCEDURE DIVISION.
       0000-MAIN.
           PERFORM 1000-RECV
           PERFORM 2000-LOAD
           PERFORM 3000-APPLY
           PERFORM 4000-POST
           PERFORM 5000-SEND
           PERFORM 9000-RETURN
           .
       1000-RECV.
           EXEC CICS RECEIVE MAP('BKLNMSS') MAPSET('BKLNMS')
                RESP(WS-RESP) RESP2(WS-RESP2)
           END-EXEC
           PERFORM 8100-CICS-RESP
           EXIT.
       2000-LOAD.
           IF WS-RC > 4 GO TO 2000-X END-IF
           EXEC SQL SELECT NOTE_NO, ACCOUNT_NO, PRIN_BAL, INT_ACCRUED,
                           ESCROW_BAL, LATE_FEE_DUE, DUE_DTE, STATUS
             INTO :LN-NOTE-NO, :LN-ACC-NO, :LN-PRIN-BAL, :LN-INT-ACCRUED,
                  :LN-ESCROW-BAL, :LN-LATE-FEE-DUE, :LN-DUE-DTE, :LN-STATUS
             FROM BANK_LOAN WHERE NOTE_NO = :LN-NOTE-NO
           END-EXEC
           IF SQLCODE = +100
              MOVE 12 TO WS-RC
              MOVE 'NOTE-NOTFND' TO BK-OP-MSG
              GO TO 2000-X
           END-IF
           IF LN-CHGOFF
              MOVE 12 TO WS-RC
              MOVE 'CHARGED-OFF' TO BK-OP-MSG
              GO TO 2000-X
           END-IF
           EXEC SQL SELECT BALANCE, HOLD_AMT
             INTO :ACC-BAL, :ACC-HOLD-AMT
             FROM BANK_CUSTOMER WHERE ACCOUNT_NO = :LN-ACC-NO
           END-EXEC
           IF ACC-BAL - ACC-HOLD-AMT < LN-PMT-AMT
              MOVE 12 TO WS-RC
              MOVE 'DDA-NSF' TO BK-OP-MSG
           END-IF
           .
       2000-X.
           EXIT.
       3000-APPLY.
           IF WS-RC > 4 GO TO 3000-X END-IF
           MOVE LN-PMT-AMT TO LN-UNAPP
           IF LN-DAYS-LATE > 15 AND LN-LATE-FEE-DUE > 0
              IF LN-UNAPP >= LN-LATE-FEE-DUE
                 MOVE LN-LATE-FEE-DUE TO LN-APPLY-LATE
                 SUBTRACT LN-LATE-FEE-DUE FROM LN-UNAPP
              ELSE
                 MOVE LN-UNAPP TO LN-APPLY-LATE
                 MOVE 0 TO LN-UNAPP
              END-IF
           END-IF
           IF LN-UNAPP > 0 AND LN-INT-ACCRUED > 0
              IF LN-UNAPP >= LN-INT-ACCRUED
                 MOVE LN-INT-ACCRUED TO LN-APPLY-INT
                 SUBTRACT LN-INT-ACCRUED FROM LN-UNAPP
              ELSE
                 MOVE LN-UNAPP TO LN-APPLY-INT
                 MOVE 0 TO LN-UNAPP
              END-IF
           END-IF
           IF LN-UNAPP > 0
              MOVE 0 TO LN-APPLY-ESC
           END-IF
           IF LN-UNAPP > 0
              IF LN-UNAPP >= LN-PRIN-BAL
                 MOVE LN-PRIN-BAL TO LN-APPLY-PRIN
                 SUBTRACT LN-PRIN-BAL FROM LN-UNAPP
                 SET LN-PAIDOFF TO TRUE
              ELSE
                 MOVE LN-UNAPP TO LN-APPLY-PRIN
                 MOVE 0 TO LN-UNAPP
              END-IF
           END-IF
           COMPUTE WS-SQLCODE-DISP = LN-APPLY-LATE + LN-APPLY-INT
                            + LN-APPLY-ESC + LN-APPLY-PRIN + LN-UNAPP
           IF WS-SQLCODE-DISP NOT = LN-PMT-AMT
              MOVE 16 TO WS-RC
              MOVE 'APPLY-OUT-OF-BALANCE' TO BK-OP-MSG
           END-IF
           .
       3000-X.
           EXIT.
       4000-POST.
           IF WS-RC > 4 GO TO 4000-X END-IF
           EXEC SQL UPDATE BANK_CUSTOMER
             SET BALANCE = BALANCE - :LN-PMT-AMT
             WHERE ACCOUNT_NO = :LN-ACC-NO
           END-EXEC
           EXEC SQL INSERT INTO BANK_JOURNAL
             (TRACE_ID, ACCOUNT_NO, CHANNEL, DR_CR, AMOUNT, POSTED_IND,
              NARR)
             VALUES (:WS-TRACE, :LN-ACC-NO, 'TELLER', 'D', :LN-PMT-AMT,
                     'Y', 'LOAN-PMT')
           END-EXEC
           EXEC SQL UPDATE BANK_LOAN
             SET PRIN_BAL = PRIN_BAL - :LN-APPLY-PRIN,
                 INT_ACCRUED = INT_ACCRUED - :LN-APPLY-INT,
                 LATE_FEE_DUE = LATE_FEE_DUE - :LN-APPLY-LATE,
                 ESCROW_BAL = ESCROW_BAL + :LN-APPLY-ESC,
                 STATUS = :LN-STATUS
             WHERE NOTE_NO = :LN-NOTE-NO
           END-EXEC
           PERFORM 8000-MAP-SQL
           EXEC CICS SYNCPOINT END-EXEC
           .
       4000-X.
           EXIT.
       5000-SEND.
           EXEC CICS SEND MAP('BKLNMSS') MAPSET('BKLNMS') ERASE
                RESP(WS-RESP)
           END-EXEC
           PERFORM 8100-CICS-RESP
           EXIT.

       8000-MAP-SQL.
           COPY BKSQLM.
           EXIT.
       8100-CICS-RESP.
           COPY BKCICM.
           EXIT.
       9000-RETURN.
           MOVE WS-RC TO RETURN-CODE
           EXEC CICS RETURN END-EXEC
           .
