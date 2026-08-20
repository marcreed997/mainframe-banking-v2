      *****************************************************************
      * PROGRAM-ID : BKSP01
      * TITLE      : Stop payment — check / ACH / range; reject if already paid
      * Synthetic lab system. Not a real bank. Educational / portfolio only.
      * ENQ on account. Duplicate stop on same serial = RC=12. Paid check = RC=12. Fee journal.
      *****************************************************************
       IDENTIFICATION DIVISION.
       PROGRAM-ID. BKSP01.
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
       COPY BKSTP.

       LINKAGE SECTION.
       01  DFHCOMMAREA              PIC X(1).
       PROCEDURE DIVISION.
       0000-MAIN.
           PERFORM 1000-RECV
           PERFORM 1100-INHIBIT
           PERFORM 2000-EDIT
           PERFORM 2500-ENQ
           PERFORM 3000-PAID-CHECK
           PERFORM 3100-DUP-STOP
           PERFORM 4000-INSERT
           PERFORM 4100-FEE
           PERFORM 5000-SEND
           PERFORM 9000-RETURN
           .
       1000-RECV.
           EXEC CICS RECEIVE MAP('BKSPMSS') MAPSET('BKSPMS')
                RESP(WS-RESP) RESP2(WS-RESP2)
           END-EXEC
           PERFORM 8100-CICS-RESP
           EXIT.
       1100-INHIBIT.
           EXEC SQL SELECT ONLINE_INHIBIT INTO :CTL-ONLINE-INHIBIT
             FROM BANK_CYCLE_CTL FETCH FIRST 1 ROW ONLY
           END-EXEC
           IF ONLINE-BLOCKED
              MOVE 'SYSTEM IN BATCH — RETRY' TO BK-OP-MSG
              MOVE 8 TO WS-RC
           END-IF
           EXIT.
       2000-EDIT.
           IF WS-RC > 4 GO TO 2000-X END-IF
           IF STP-ACC-NO = SPACES
              MOVE 12 TO WS-RC
              MOVE 'ACCT-REQD' TO BK-OP-MSG
              GO TO 2000-X
           END-IF
           IF STP-CHECK AND STP-CHECK-NO = 0
              MOVE 12 TO WS-RC
              MOVE 'CHECK-REQD' TO BK-OP-MSG
           END-IF
           IF STP-RANGE AND (STP-CHECK-THRU <= STP-CHECK-NO)
              MOVE 12 TO WS-RC
              MOVE 'RANGE-BAD' TO BK-OP-MSG
           END-IF
           IF STP-AMT-EXACT AND STP-AMT <= 0
              MOVE 12 TO WS-RC
              MOVE 'AMT-REQD' TO BK-OP-MSG
           END-IF
           EXEC SQL SELECT STATUS, BALANCE INTO :ACC-STATUS, :ACC-BAL
             FROM BANK_CUSTOMER WHERE ACCOUNT_NO = :STP-ACC-NO
           END-EXEC
           IF SQLCODE = +100
              MOVE 12 TO WS-RC
              MOVE 'ACCT-NOTFND' TO BK-OP-MSG
           END-IF
           IF ACC-CLOSED OR ACC-FROZEN
              MOVE 12 TO WS-RC
              MOVE 'ACCT-STATUS' TO BK-OP-MSG
           END-IF
           .
       2000-X.
           EXIT.
       2500-ENQ.
           IF WS-RC > 4 GO TO 2500-X END-IF
           EXEC CICS ENQ RESOURCE(STP-ACC-NO) LENGTH(6)
                RESP(WS-RESP)
           END-EXEC
           PERFORM 8100-CICS-RESP
           .
       2500-X.
           EXIT.
       3000-PAID-CHECK.
           IF WS-RC > 4 OR STP-ACH GO TO 3000-X END-IF
           EXEC SQL SELECT TRACE_ID INTO :WS-TRACE
             FROM BANK_JOURNAL
            WHERE ACCOUNT_NO = :STP-ACC-NO
              AND CHECK_NO = :STP-CHECK-NO
              AND POSTED_IND = 'Y'
              FETCH FIRST 1 ROW ONLY
           END-EXEC
           IF SQLCODE = 0
              MOVE 12 TO WS-RC
              MOVE 'ALREADY-PAID' TO BK-OP-MSG
              SET BK-E-UNMATCHED TO TRUE
           END-IF
           .
       3000-X.
           EXIT.
       3100-DUP-STOP.
           IF WS-RC > 4 GO TO 3100-X END-IF
           EXEC SQL SELECT STOP_ID INTO :STP-ID
             FROM BANK_STOP
            WHERE ACCOUNT_NO = :STP-ACC-NO
              AND CHECK_NO = :STP-CHECK-NO
              AND STATUS = 'A'
           END-EXEC
           IF SQLCODE = 0
              MOVE 12 TO WS-RC
              SET BK-E-DUPGEN TO TRUE
              MOVE 'BK-E-DUPGEN STOP' TO BK-OP-MSG
           END-IF
           .
       3100-X.
           EXIT.
       4000-INSERT.
           IF WS-RC > 4 GO TO 4000-X END-IF
           MOVE 12 TO STP-FEE-AMT
           EXEC SQL INSERT INTO BANK_STOP
             (STOP_ID, ACCOUNT_NO, KIND, CHECK_NO, CHECK_THRU, AMOUNT,
              AMT_OPT, PAYEE, EXPIRE_DTE, STATUS, FEE_AMT, TELLER_ID)
             VALUES (:STP-ID, :STP-ACC-NO, :STP-KIND, :STP-CHECK-NO,
                     :STP-CHECK-THRU, :STP-AMT, :STP-AMT-OPT, :STP-PAYEE,
                     :STP-EXPIRE-DTE, 'A', :STP-FEE-AMT, :BK-TELLER-ID)
           END-EXEC
           PERFORM 8000-MAP-SQL
           .
       4000-X.
           EXIT.
       4100-FEE.
           IF WS-RC > 4 GO TO 4100-X END-IF
           EXEC SQL INSERT INTO BANK_JOURNAL
             (TRACE_ID, ACCOUNT_NO, LOC_ID, CHANNEL, DR_CR, AMOUNT,
              POSTED_IND, NARR)
             VALUES (:WS-TRACE, :STP-ACC-NO, :BK-LOC-ID, 'TELLER',
                     'D', :STP-FEE-AMT, 'Y', 'STOP-PAY-FEE')
           END-EXEC
           PERFORM 8000-MAP-SQL
           EXEC SQL UPDATE BANK_CUSTOMER
             SET BALANCE = BALANCE - :STP-FEE-AMT
             WHERE ACCOUNT_NO = :STP-ACC-NO
           END-EXEC
           PERFORM 8000-MAP-SQL
           EXEC CICS SYNCPOINT RESP(WS-RESP) END-EXEC
           PERFORM 8100-CICS-RESP
           EXEC CICS DEQ RESOURCE(STP-ACC-NO) LENGTH(6) END-EXEC
           .
       4100-X.
           EXIT.
       5000-SEND.
           EXEC CICS SEND MAP('BKSPMSS') MAPSET('BKSPMS')
                ERASE RESP(WS-RESP)
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
