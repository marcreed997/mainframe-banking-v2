      *****************************************************************
      * PROGRAM-ID : BKPP01
      * TITLE      : Positive-pay exception decision — pay or return presented check
      * Synthetic lab system. Not a real bank. Educational / portfolio only.
      * Dual-control if presented amount > 5000. STOP-HIT always returns. VOID-HIT always returns.
      *****************************************************************
       IDENTIFICATION DIVISION.
       PROGRAM-ID. BKPP01.
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
       COPY BKPPY.

       LINKAGE SECTION.
       01  DFHCOMMAREA              PIC X(1).
       PROCEDURE DIVISION.
       0000-MAIN.
           PERFORM 1000-RECV
           PERFORM 2000-LOAD-XCPT
           PERFORM 3000-DECIDE
           PERFORM 4000-APPLY
           PERFORM 5000-SEND
           PERFORM 9000-RETURN
           .
       1000-RECV.
           EXEC CICS RECEIVE MAP('BKPPMSS') MAPSET('BKPPMS')
                RESP(WS-RESP) RESP2(WS-RESP2)
           END-EXEC
           PERFORM 8100-CICS-RESP
           EXIT.
       2000-LOAD-XCPT.
           IF WS-RC > 4 GO TO 2000-X END-IF
           EXEC SQL SELECT ACCOUNT_NO, SERIAL, ISS_AMT, PRE_AMT, REASON,
                           DECISION
             INTO :PP-PR-ACC, :PP-PR-SERIAL, :PP-ISS-AMT, :PP-PR-AMT,
                  :PP-X-REASON, :PP-X-DECISION
             FROM BANK_PP_XCPT
            WHERE ACCOUNT_NO = :PP-PR-ACC
              AND SERIAL = :PP-PR-SERIAL
              AND DECISION = 'W'
           END-EXEC
           IF SQLCODE = +100
              MOVE 4 TO WS-RC
              MOVE 'NO-PEND-XCPT' TO BK-OP-MSG
           END-IF
           PERFORM 8000-MAP-SQL
           .
       2000-X.
           EXIT.
       3000-DECIDE.
           IF WS-RC > 4 GO TO 3000-X END-IF
           IF PP-STOP-HIT OR PP-VOID-HIT
              SET PP-RETURN TO TRUE
              MOVE 'FORCED-RETURN' TO BK-OP-MSG
              GO TO 3000-X
           END-IF
           IF PP-PR-AMT > 5000.00 AND PP-X-DECIDER = SPACES
              MOVE 8 TO WS-RC
              SET BK-E-BUSY TO TRUE
              MOVE 'DUAL-CONTROL-REQD' TO BK-OP-MSG
              GO TO 3000-X
           END-IF
           IF NOT PP-PAY AND NOT PP-RETURN
              MOVE 12 TO WS-RC
              MOVE 'DECISION-REQD' TO BK-OP-MSG
           END-IF
           .
       3000-X.
           EXIT.
       4000-APPLY.
           IF WS-RC > 4 GO TO 4000-X END-IF
           EXEC SQL UPDATE BANK_PP_XCPT
             SET DECISION = :PP-X-DECISION, DECIDER = :PP-X-DECIDER
             WHERE ACCOUNT_NO = :PP-PR-ACC
               AND SERIAL = :PP-PR-SERIAL
               AND DECISION = 'W'
           END-EXEC
           PERFORM 8000-MAP-SQL
           IF PP-PAY
              EXEC SQL UPDATE BANK_PP_ISSUED
                SET STATUS = 'P'
                WHERE ACCOUNT_NO = :PP-PR-ACC
                  AND SERIAL = :PP-PR-SERIAL
              END-EXEC
              EXEC SQL INSERT INTO BANK_JOURNAL
                (TRACE_ID, ACCOUNT_NO, CHANNEL, DR_CR, AMOUNT,
                 POSTED_IND, CHECK_NO, NARR)
                VALUES (:PP-PR-TRACE, :PP-PR-ACC, 'BATCH', 'D',
                        :PP-PR-AMT, 'Y', :PP-PR-SERIAL, 'POSPAY-PAY')
              END-EXEC
              EXEC SQL UPDATE BANK_CUSTOMER
                SET BALANCE = BALANCE - :PP-PR-AMT
                WHERE ACCOUNT_NO = :PP-PR-ACC
              END-EXEC
           ELSE
              EXEC SQL INSERT INTO BANK_SUSPENSE
                (CYCLE_DTE, TRACE_ID, ACCOUNT_NO, AMOUNT, REASON, STATUS)
                VALUES (CURRENT DATE, :PP-PR-TRACE, :PP-PR-ACC,
                        :PP-PR-AMT, 'PP-RETURN', 'O')
              END-EXEC
           END-IF
           PERFORM 8000-MAP-SQL
           EXEC CICS SYNCPOINT END-EXEC
           .
       4000-X.
           EXIT.
       5000-SEND.
           EXEC CICS SEND MAP('BKPPMSS') MAPSET('BKPPMS') ERASE
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
