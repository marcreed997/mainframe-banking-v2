      *****************************************************************
      * PROGRAM-ID : BKTL01
      * TITLE      : Teller sign-on — drawer start cash; override level
      * Synthetic lab system. Not a real bank. Educational / portfolio only.
      * No customer monetary movement.
      *****************************************************************
       IDENTIFICATION DIVISION.
       PROGRAM-ID. BKTL01.
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
       COPY BKTLL.
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
           EXEC CICS RECEIVE MAP('BKTLMP') MAPSET('BKTLMS')
                RESP(WS-RESP) RESP2(WS-RESP2)
           END-EXEC
           PERFORM 8100-CICS-RESP
           EXIT.
       2000-EDIT.
           IF TLL-ID = SPACES
              MOVE 8 TO WS-RC
           END-IF
           EXIT.
       3000-WORK.
           MOVE 'Y' TO TLL-SIGNED-ON
           EXEC SQL
             UPDATE BANK_TELLER
                SET SIGNED_ON = 'Y',
                    DRAWER_CASH = :TLL-DRAWER-CASH,
                    OVERRIDE_LVL = :TLL-OVERRIDE-LVL
              WHERE TELLER_ID = :TLL-ID
           END-EXEC
           PERFORM 8000-MAP-SQL
           IF SQLCODE = +100
              EXEC SQL INSERT INTO BANK_TELLER
                (TELLER_ID, BRANCH_NO, DRAWER_CASH, SIGNED_ON,
                 OVERRIDE_LVL)
                VALUES (:TLL-ID, :TLL-BRANCH, :TLL-DRAWER-CASH, 'Y',
                        :TLL-OVERRIDE-LVL)
              END-EXEC
              PERFORM 8000-MAP-SQL
           END-IF
           EXIT.
       4000-SEND.
           EXEC CICS SEND MAP('BKTLMP') MAPSET('BKTLMS') ERASE
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
