      *****************************************************************
      * PROGRAM-ID : BKZBA01
      * TITLE      : Nightly zero-balance sweep — child to/from parent
      * Synthetic lab system. Not a real bank. Educational / portfolio only.
      * Skip child cover if parent available < deficit. Min-sweep threshold.
      *****************************************************************
       IDENTIFICATION DIVISION.
       PROGRAM-ID. BKZBA01.
       AUTHOR. LAB-V2.
       DATE-WRITTEN. 2026-08-20.
       ENVIRONMENT DIVISION.
       CONFIGURATION SECTION.
       SOURCE-COMPUTER. IBM-Z.
       OBJECT-COMPUTER. IBM-Z.
       INPUT-OUTPUT SECTION.
       FILE-CONTROL.
           SELECT ZBARPT ASSIGN TO UZBARPT
               ORGANIZATION IS SEQUENTIAL
               FILE STATUS IS WS-FS1.
       DATA DIVISION.
       FILE SECTION.
       FD  ZBARPT.
       01  ZBA-RPT                  PIC X(120).
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
       COPY BKZBA.
       COPY BKACC.
       COPY BKJRN.
       01  WS-FS1                   PIC XX.
       01  WS-DEF                   PIC S9(13)V99 COMP-3.
       01  WS-EXC                   PIC S9(13)V99 COMP-3.
       01  WS-PAVAIL                PIC S9(13)V99 COMP-3.

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
           OPEN OUTPUT ZBARPT
           EXIT.
       1000-EACH.
           IF WS-RC >= 12 GO TO 1000-X END-IF
           EXEC SQL DECLARE C-ZBA CURSOR FOR
             SELECT CHILD_ACC, PARENT_ACC, TARGET_BAL, MIN_SWEEP
               FROM BANK_ZBA WHERE STATUS = 'A'
           END-EXEC
           EXEC SQL OPEN C-ZBA END-EXEC
           PERFORM UNTIL SQLCODE NOT = 0
              EXEC SQL FETCH C-ZBA INTO :ZBA-CHILD-ACC, :ZBA-PARENT-ACC,
                   :ZBA-TARGET, :ZBA-MIN-SWEEP
              END-EXEC
              IF SQLCODE = 0
                 PERFORM 2000-SWEEP-ONE
              END-IF
           END-PERFORM
           EXEC SQL CLOSE C-ZBA END-EXEC
           CLOSE ZBARPT
           .
       1000-X.
           EXIT.
       2000-SWEEP-ONE.
           EXEC SQL SELECT BALANCE, HOLD_AMT
             INTO :ZBA-CHILD-BAL, :ACC-HOLD-AMT
             FROM BANK_CUSTOMER WHERE ACCOUNT_NO = :ZBA-CHILD-ACC
           END-EXEC
           EXEC SQL SELECT BALANCE, HOLD_AMT
             INTO :ZBA-PARENT-BAL, :WS-PAVAIL
             FROM BANK_CUSTOMER WHERE ACCOUNT_NO = :ZBA-PARENT-ACC
           END-EXEC
           COMPUTE WS-PAVAIL = ZBA-PARENT-BAL - WS-PAVAIL
           IF ZBA-CHILD-BAL > ZBA-TARGET
              COMPUTE WS-EXC = ZBA-CHILD-BAL - ZBA-TARGET
              IF WS-EXC < ZBA-MIN-SWEEP
                 SET ZBA-NONE TO TRUE
                 GO TO 2000-X
              END-IF
              SET ZBA-TO-PARENT TO TRUE
              MOVE WS-EXC TO ZBA-SWEEP-AMT
              PERFORM 3000-MOVE
           ELSE
              COMPUTE WS-DEF = ZBA-TARGET - ZBA-CHILD-BAL
              IF WS-DEF < ZBA-MIN-SWEEP
                 SET ZBA-NONE TO TRUE
                 GO TO 2000-X
              END-IF
              IF WS-PAVAIL < WS-DEF
                 MOVE 4 TO WS-RC
                 MOVE 'PARENT-NSF-SKIP' TO BK-OP-MSG
                 SET ZBA-NONE TO TRUE
                 GO TO 2000-X
              END-IF
              SET ZBA-TO-CHILD TO TRUE
              MOVE WS-DEF TO ZBA-SWEEP-AMT
              PERFORM 3000-MOVE
           END-IF
           .
       2000-X.
           EXIT.
       3000-MOVE.
           IF ZBA-TO-PARENT
              EXEC SQL UPDATE BANK_CUSTOMER
                SET BALANCE = BALANCE - :ZBA-SWEEP-AMT
                WHERE ACCOUNT_NO = :ZBA-CHILD-ACC
              END-EXEC
              EXEC SQL UPDATE BANK_CUSTOMER
                SET BALANCE = BALANCE + :ZBA-SWEEP-AMT
                WHERE ACCOUNT_NO = :ZBA-PARENT-ACC
              END-EXEC
           ELSE
              EXEC SQL UPDATE BANK_CUSTOMER
                SET BALANCE = BALANCE - :ZBA-SWEEP-AMT
                WHERE ACCOUNT_NO = :ZBA-PARENT-ACC
              END-EXEC
              EXEC SQL UPDATE BANK_CUSTOMER
                SET BALANCE = BALANCE + :ZBA-SWEEP-AMT
                WHERE ACCOUNT_NO = :ZBA-CHILD-ACC
              END-EXEC
           END-IF
           EXEC SQL INSERT INTO BANK_JOURNAL
             (TRACE_ID, ACCOUNT_NO, CHANNEL, DR_CR, AMOUNT, POSTED_IND,
              NARR)
             VALUES (:WS-TRACE, :ZBA-CHILD-ACC, 'BATCH', 'D',
                     :ZBA-SWEEP-AMT, 'Y', 'ZBA-SWEEP')
           END-EXEC
           PERFORM 8000-MAP-SQL
           MOVE 'SWEPT' TO ZBA-RPT
           WRITE ZBA-RPT
           EXIT.

       8000-MAP-SQL.
           COPY BKSQLM.
           EXIT.
       9000-TERM.
           MOVE WS-RC TO RETURN-CODE
           EXIT.
