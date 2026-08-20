      *****************************************************************
      * PROGRAM-ID : BKOD01
      * TITLE      : Overdraft decision — pay via OD limit or return NSF
      * Synthetic lab system. Not a real bank. Educational / portfolio only.
      * Three NSF in cycle freeze account. OD advance is a separate journal + fee.
      *****************************************************************
       IDENTIFICATION DIVISION.
       PROGRAM-ID. BKOD01.
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
       01  WS-ITEM-AMT              PIC S9(13)V99 COMP-3.
       01  WS-AVAIL                 PIC S9(13)V99 COMP-3.
       01  WS-OD-USED               PIC S9(13)V99 COMP-3.
       01  WS-FEE                   PIC S9(7)V99 COMP-3 VALUE 35.00.
       01  WS-NSF-CNT               PIC 9(4) VALUE 0.
       01  WS-DECISION              PIC X.
           88  DEC-PAY              VALUE 'P'.
           88  DEC-RETURN           VALUE 'R'.

       LINKAGE SECTION.
       01  DFHCOMMAREA              PIC X(1).
       PROCEDURE DIVISION.
       0000-MAIN.
           PERFORM 1000-LOAD
           PERFORM 2000-DECIDE
           PERFORM 3000-POST
           PERFORM 9000-RETURN
           .
       1000-LOAD.
           EXEC SQL SELECT BALANCE, HOLD_AMT, OD_LIMIT, NSF_COUNT, STATUS
             INTO :ACC-BAL, :ACC-HOLD-AMT, :ACC-OD-LIMIT, :WS-NSF-CNT,
                  :ACC-STATUS
             FROM BANK_CUSTOMER WHERE ACCOUNT_NO = :ACC-NO
           END-EXEC
           IF SQLCODE = +100
              MOVE 12 TO WS-RC
              GO TO 1000-X
           END-IF
           COMPUTE WS-AVAIL = ACC-BAL - ACC-HOLD-AMT
           .
       1000-X.
           EXIT.
       2000-DECIDE.
           IF WS-RC > 4 GO TO 2000-X END-IF
           IF ACC-FROZEN OR ACC-CLOSED
              SET DEC-RETURN TO TRUE
              MOVE 'ACCT-FROZEN' TO BK-OP-MSG
              GO TO 2000-X
           END-IF
           IF WS-ITEM-AMT <= WS-AVAIL
              SET DEC-PAY TO TRUE
              MOVE 0 TO WS-OD-USED
              GO TO 2000-X
           END-IF
           COMPUTE WS-OD-USED = WS-ITEM-AMT - WS-AVAIL
           IF WS-OD-USED <= ACC-OD-LIMIT
              SET DEC-PAY TO TRUE
              MOVE 'OD-ADVANCE' TO BK-OP-MSG
           ELSE
              SET DEC-RETURN TO TRUE
              MOVE 'NSF-RETURN' TO BK-OP-MSG
           END-IF
           .
       2000-X.
           EXIT.
       3000-POST.
           IF DEC-PAY AND WS-OD-USED > 0
              EXEC SQL INSERT INTO BANK_JOURNAL
                (TRACE_ID, ACCOUNT_NO, CHANNEL, DR_CR, AMOUNT,
                 POSTED_IND, NARR)
                VALUES (:WS-TRACE, :ACC-NO, 'TELLER', 'D', :WS-FEE,
                        'Y', 'OD-FEE')
              END-EXEC
              EXEC SQL UPDATE BANK_CUSTOMER
                SET BALANCE = BALANCE - :WS-ITEM-AMT - :WS-FEE
                WHERE ACCOUNT_NO = :ACC-NO
              END-EXEC
           END-IF
           IF DEC-RETURN
              EXEC SQL UPDATE BANK_CUSTOMER
                SET NSF_COUNT = NSF_COUNT + 1
                WHERE ACCOUNT_NO = :ACC-NO
              END-EXEC
              EXEC SQL SELECT NSF_COUNT INTO :WS-NSF-CNT
                FROM BANK_CUSTOMER WHERE ACCOUNT_NO = :ACC-NO
              END-EXEC
              IF WS-NSF-CNT >= 3
                 EXEC SQL UPDATE BANK_CUSTOMER
                   SET STATUS = 'F'
                   WHERE ACCOUNT_NO = :ACC-NO
                 END-EXEC
                 MOVE 'FROZEN-3-NSF' TO BK-OP-MSG
              END-IF
              EXEC SQL INSERT INTO BANK_SUSPENSE
                (CYCLE_DTE, TRACE_ID, ACCOUNT_NO, AMOUNT, REASON, STATUS)
                VALUES (CURRENT DATE, :WS-TRACE, :ACC-NO, :WS-ITEM-AMT,
                        'NSF', 'O')
              END-EXEC
              MOVE 12 TO WS-RC
           END-IF
           PERFORM 8000-MAP-SQL
           EXEC CICS SYNCPOINT END-EXEC
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
