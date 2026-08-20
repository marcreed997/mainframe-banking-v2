      *****************************************************************
      * PROGRAM-ID : BKSW01
      * TITLE      : Sweep / ZBA enrollment — child to parent vehicle
      * Synthetic lab system. Not a real bank. Educational / portfolio only.
      * Parent must be open. Child cannot already be a parent of someone else.
      *****************************************************************
       IDENTIFICATION DIVISION.
       PROGRAM-ID. BKSW01.
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
       COPY BKZBA.

       LINKAGE SECTION.
       01  DFHCOMMAREA              PIC X(1).
       PROCEDURE DIVISION.
       0000-MAIN.
           PERFORM 1000-RECV
           PERFORM 2000-EDIT
           PERFORM 3000-STORE
           PERFORM 5000-SEND
           PERFORM 9000-RETURN
           .
       1000-RECV.
           EXEC CICS RECEIVE MAP('BKSWMSS') MAPSET('BKSWMS')
                RESP(WS-RESP) RESP2(WS-RESP2)
           END-EXEC
           PERFORM 8100-CICS-RESP
           EXIT.
       2000-EDIT.
           IF ZBA-CHILD-ACC = ZBA-PARENT-ACC
              MOVE 12 TO WS-RC
              MOVE 'CHILD-EQ-PARENT' TO BK-OP-MSG
              GO TO 2000-X
           END-IF
           IF ZBA-TARGET < 0 OR ZBA-MIN-SWEEP < 0
              MOVE 12 TO WS-RC
              MOVE 'NEG-TARGET' TO BK-OP-MSG
              GO TO 2000-X
           END-IF
           EXEC SQL SELECT STATUS INTO :ACC-STATUS
             FROM BANK_CUSTOMER WHERE ACCOUNT_NO = :ZBA-PARENT-ACC
           END-EXEC
           IF SQLCODE = +100 OR ACC-CLOSED
              MOVE 12 TO WS-RC
              MOVE 'PARENT-BAD' TO BK-OP-MSG
              GO TO 2000-X
           END-IF
           IF NOT ZBA-MMDA AND NOT ZBA-NOTE AND NOT ZBA-REPO
              MOVE 12 TO WS-RC
              MOVE 'VEHICLE-BAD' TO BK-OP-MSG
              GO TO 2000-X
           END-IF
           EXEC SQL SELECT CHILD_ACC INTO :ZBA-CHILD-ACC
             FROM BANK_ZBA WHERE PARENT_ACC = :ZBA-CHILD-ACC
           END-EXEC
           IF SQLCODE = 0
              MOVE 12 TO WS-RC
              MOVE 'CHILD-IS-PARENT' TO BK-OP-MSG
           END-IF
           .
       2000-X.
           EXIT.
       3000-STORE.
           IF WS-RC > 4 GO TO 3000-X END-IF
           EXEC SQL INSERT INTO BANK_ZBA
             (CHILD_ACC, PARENT_ACC, TARGET_BAL, MIN_SWEEP, VEHICLE,
              STATUS)
             VALUES (:ZBA-CHILD-ACC, :ZBA-PARENT-ACC, :ZBA-TARGET,
                     :ZBA-MIN-SWEEP, :ZBA-VEHICLE, 'A')
           END-EXEC
           PERFORM 8000-MAP-SQL
           EXEC CICS SYNCPOINT END-EXEC
           .
       3000-X.
           EXIT.
       5000-SEND.
           EXEC CICS SEND MAP('BKSWMSS') MAPSET('BKSWMS') ERASE
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
