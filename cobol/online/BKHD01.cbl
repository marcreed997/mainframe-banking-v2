      *****************************************************************
      * PROGRAM-ID : BKHD01
      * TITLE      : Hold place/release — hold amt increases ACC-HOLD; no BAL change
      * Synthetic lab system. Not a real bank. Educational / portfolio only.
      * Invariant: HOLD does not change BALANCE.
      *****************************************************************
       IDENTIFICATION DIVISION.
       PROGRAM-ID. BKHD01.
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
       COPY BKHLD.
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
           EXEC CICS RECEIVE MAP('BKHLDMP') MAPSET('BKHLDMS')
                RESP(WS-RESP) RESP2(WS-RESP2)
           END-EXEC
           PERFORM 8100-CICS-RESP
           EXIT.
       2000-EDIT.
           IF HLD-AMT <= 0 AND HLD-STATUS = 'A'
              MOVE 12 TO WS-RC
           END-IF
           EXIT.
       3000-WORK.
           IF HLD-ACTIVE
              EXEC SQL INSERT INTO BANK_HOLD
                (HOLD_ID, ACCOUNT_NO, AMOUNT, REASON, EXP_DTE, STATUS)
                VALUES (:HLD-ID, :HLD-ACC-NO, :HLD-AMT, :HLD-REASON,
                        :HLD-EXP-DTE, 'A')
              END-EXEC
              EXEC SQL UPDATE BANK_CUSTOMER
                SET HOLD_AMT = HOLD_AMT + :HLD-AMT
                WHERE ACCOUNT_NO = :HLD-ACC-NO
              END-EXEC
           ELSE
              EXEC SQL UPDATE BANK_HOLD SET STATUS = 'R'
                WHERE HOLD_ID = :HLD-ID AND STATUS = 'A'
              END-EXEC
              EXEC SQL UPDATE BANK_CUSTOMER
                SET HOLD_AMT = HOLD_AMT - :HLD-AMT
                WHERE ACCOUNT_NO = :HLD-ACC-NO
              END-EXEC
           END-IF
           PERFORM 8000-MAP-SQL
           EXIT.
       4000-SEND.
           EXEC CICS SEND MAP('BKHLDMP') MAPSET('BKHLDMS') ERASE
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
