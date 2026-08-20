      *****************************************************************
      * PROGRAM-ID : BKCS01
      * TITLE      : Cash deposit — journal + balance in one UOW; location stamped
      * Synthetic lab system. Not a real bank. Educational / portfolio only.
      * Invariant: no BAL update without BANK_JOURNAL insert same UOW.
      *****************************************************************
       IDENTIFICATION DIVISION.
       PROGRAM-ID. BKCS01.
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
       COPY BKCTL.
       LINKAGE SECTION.
       01  DFHCOMMAREA              PIC X(1).
       PROCEDURE DIVISION.
       0000-MAIN.
           PERFORM 1000-RECV
           PERFORM 2000-EDIT
           PERFORM 3000-WORK
           PERFORM 4000-SEND
           PERFORM 9000-RETURN
           .
       1000-RECV.
           EXEC CICS RECEIVE MAP('BKCSMP') MAPSET('BKCSMS')
                RESP(WS-RESP) RESP2(WS-RESP2)
           END-EXEC
           PERFORM 8100-CICS-RESP
           EXIT.
       2000-EDIT.
           EXEC SQL SELECT ONLINE_INHIBIT INTO :CTL-ONLINE-INHIBIT
             FROM BANK_CYCLE_CTL
             FETCH FIRST 1 ROW ONLY
           END-EXEC
           IF CTL-ONLINE-INHIBIT = 'Y'
              SET BK-E-ONLINEUP TO TRUE
              MOVE 8 TO WS-RC
              MOVE 'SYSTEM IN BATCH — RETRY' TO BK-OP-MSG
           END-IF
           IF JRN-AMT <= 0
              MOVE 12 TO WS-RC
           END-IF
           EXIT.
       3000-WORK.
           IF WS-RC > 4
              GO TO 3000-X
           END-IF
           SET JRN-CREDIT TO TRUE
           SET CH-TELLER TO TRUE
           EXEC SQL
             INSERT INTO BANK_JOURNAL
               (TRACE_ID, ACCOUNT_NO, LOC_ID, CHANNEL, DR_CR, AMOUNT,
                CYCLE_DTE, POSTED_IND, TERM_ID, TELLER_ID, NARR)
             VALUES (:JRN-TRACE-ID, :JRN-ACC-NO, :BK-LOC-ID, :BK-CHANNEL,
                     :JRN-DRCR, :JRN-AMT, :CTL-CYCLE-DTE, 'Y',
                     :BK-TERM-ID, :BK-TELLER-ID, 'TELLER DEPOSIT')
           END-EXEC
           PERFORM 8000-MAP-SQL
           IF WS-RC > 4
              GO TO 3000-X
           END-IF
           EXEC SQL UPDATE BANK_CUSTOMER
             SET BALANCE = BALANCE + :JRN-AMT,
                 LAST_POST_TS = CURRENT TIMESTAMP
             WHERE ACCOUNT_NO = :JRN-ACC-NO AND STATUS = 'O'
           END-EXEC
           PERFORM 8000-MAP-SQL
           IF SQLCODE = +100
              MOVE 12 TO WS-RC
              MOVE 'ACCT-NOT-OPEN' TO BK-OP-MSG
              EXEC CICS SYNCPOINT ROLLBACK END-EXEC
           END-IF
           .
       3000-X.
           EXIT.
       4000-SEND.
           EXEC CICS SEND MAP('BKCSMP') MAPSET('BKCSMS') ERASE
                RESP(WS-RESP)
           END-EXEC
           PERFORM 8100-CICS-RESP
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
       8100-CICS-RESP.
           EVALUATE WS-RESP
             WHEN 0
                CONTINUE
             WHEN 13
                MOVE 'MAPFAIL' TO BK-OP-MSG
                MOVE 8 TO WS-RC
             WHEN 12
                MOVE 'NOTFND' TO BK-OP-MSG
                MOVE 4 TO WS-RC
             WHEN 15
                MOVE 'DUPKEY' TO BK-OP-MSG
                MOVE 12 TO WS-RC
             WHEN 18
                MOVE 'ENQBUSY' TO BK-OP-MSG
                SET BK-E-BUSY TO TRUE
                MOVE 8 TO WS-RC
             WHEN OTHER
                MOVE 16 TO WS-RC
           END-EVALUATE
           EXIT.
       9000-RETURN.
           MOVE WS-RC TO RETURN-CODE
           EXEC CICS RETURN END-EXEC
           .
