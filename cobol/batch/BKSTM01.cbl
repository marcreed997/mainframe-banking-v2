      *****************************************************************
      * PROGRAM-ID : BKSTM01
      * TITLE      : Statement cycle extract — suppress zero-activity paperless
      * Synthetic lab system. Not a real bank. Educational / portfolio only.
      * Emits one header + postings per account whose statement cycle is today.
      *****************************************************************
       IDENTIFICATION DIVISION.
       PROGRAM-ID. BKSTM01.
       AUTHOR. LAB-V2.
       DATE-WRITTEN. 2026-08-20.
       ENVIRONMENT DIVISION.
       CONFIGURATION SECTION.
       SOURCE-COMPUTER. IBM-Z.
       OBJECT-COMPUTER. IBM-Z.
       INPUT-OUTPUT SECTION.
       FILE-CONTROL.
           SELECT STMOUT ASSIGN TO USTMOUT
               ORGANIZATION IS SEQUENTIAL
               FILE STATUS IS WS-FS1.
       DATA DIVISION.
       FILE SECTION.
       FD  STMOUT.
       01  STM-REC                  PIC X(160).
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
       01  WS-CNT                   PIC 9(7) VALUE 0.
       01  WS-ACT                   PIC 9(5).
       01  WS-PAPERLESS             PIC X.

       PROCEDURE DIVISION.
       0000-MAIN.
           PERFORM 0500-OPEN
           PERFORM 1000-ACCTS
           PERFORM 9000-TERM
           GOBACK
           .
       0500-OPEN.
           OPEN OUTPUT STMOUT
           EXIT.
       1000-ACCTS.
           EXEC SQL DECLARE C-STM CURSOR FOR
             SELECT ACCOUNT_NO, CUSTOMER_NAME, BALANCE, HOLD_AMT
               FROM BANK_CUSTOMER
              WHERE STATUS IN ('O','D')
           END-EXEC
           EXEC SQL OPEN C-STM END-EXEC
           PERFORM UNTIL SQLCODE NOT = 0
              EXEC SQL FETCH C-STM INTO :ACC-NO, :ACC-NAME, :ACC-BAL,
                   :ACC-HOLD-AMT
              END-EXEC
              IF SQLCODE = 0
                 PERFORM 2000-ONE
              END-IF
           END-PERFORM
           EXEC SQL CLOSE C-STM END-EXEC
           CLOSE STMOUT
           IF WS-CNT = 0
              MOVE 4 TO WS-RC
           END-IF
           EXIT.
       2000-ONE.
           EXEC SQL SELECT COUNT(*) INTO :WS-ACT
             FROM BANK_JOURNAL
            WHERE ACCOUNT_NO = :ACC-NO
              AND CYCLE_DTE BETWEEN CURRENT DATE - 30 DAYS
                                AND CURRENT DATE
           END-EXEC
           MOVE 'N' TO WS-PAPERLESS
           IF WS-ACT = 0 AND WS-PAPERLESS = 'Y'
              GO TO 2000-X
           END-IF
           MOVE ACC-NO TO STM-REC
           WRITE STM-REC
           ADD 1 TO WS-CNT
           EXEC SQL DECLARE C-J CURSOR FOR
             SELECT TRACE_ID, DR_CR, AMOUNT, NARR, CREATE_TS
               FROM BANK_JOURNAL
              WHERE ACCOUNT_NO = :ACC-NO
                AND CYCLE_DTE BETWEEN CURRENT DATE - 30 DAYS
                                  AND CURRENT DATE
              ORDER BY CREATE_TS
           END-EXEC
           EXEC SQL OPEN C-J END-EXEC
           PERFORM UNTIL SQLCODE NOT = 0
              EXEC SQL FETCH C-J INTO :JRN-TRACE-ID, :JRN-DRCR,
                   :JRN-AMT, :JRN-NARR, :JRN-CREATE-TS
              END-EXEC
              IF SQLCODE = 0
                 MOVE JRN-TRACE-ID TO STM-REC
                 WRITE STM-REC
              END-IF
           END-PERFORM
           EXEC SQL CLOSE C-J END-EXEC
           .
       2000-X.
           EXIT.

       8000-MAP-SQL.
           COPY BKSQLM.
           EXIT.
       9000-TERM.
           MOVE WS-RC TO RETURN-CODE
           EXIT.
