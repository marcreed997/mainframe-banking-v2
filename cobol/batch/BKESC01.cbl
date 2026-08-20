      *****************************************************************
      * PROGRAM-ID : BKESC01
      * TITLE      : Escrow disbursement — tax/insurance/MI from loan escrow balance
      * Synthetic lab system. Not a real bank. Educational / portfolio only.
      * Shortfall -> status N, do not overdraft escrow. GL credit to payee stub.
      *****************************************************************
       IDENTIFICATION DIVISION.
       PROGRAM-ID. BKESC01.
       AUTHOR. LAB-V2.
       DATE-WRITTEN. 2026-08-20.
       ENVIRONMENT DIVISION.
       CONFIGURATION SECTION.
       SOURCE-COMPUTER. IBM-Z.
       OBJECT-COMPUTER. IBM-Z.
       INPUT-OUTPUT SECTION.
       FILE-CONTROL.
           SELECT ESCOUT ASSIGN TO UESCOUT
               ORGANIZATION IS SEQUENTIAL
               FILE STATUS IS WS-FS1.
       DATA DIVISION.
       FILE SECTION.
       FD  ESCOUT.
       01  ESC-REC                  PIC X(120).
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
       COPY BKESC.
       COPY BKLOAN.
       COPY BKGL.
       01  WS-FS1                   PIC XX.
       01  WS-PAID                  PIC 9(5) VALUE 0.
       01  WS-SHORT                 PIC 9(5) VALUE 0.

       PROCEDURE DIVISION.
       0000-MAIN.
           PERFORM 1000-DUE
           PERFORM 9000-TERM
           GOBACK
           .
       1000-DUE.
           OPEN OUTPUT ESCOUT
           EXEC SQL DECLARE C-ESC CURSOR FOR
             SELECT LOAN_NO, ESC_TYPE, DUE_DTE, PAYEE, AMOUNT
               FROM BANK_ESCROW_DUE
              WHERE STATUS = 'D'
                AND DUE_DTE <= CURRENT DATE
           END-EXEC
           EXEC SQL OPEN C-ESC END-EXEC
           PERFORM UNTIL SQLCODE NOT = 0
              EXEC SQL FETCH C-ESC INTO :ESC-LOAN-NO, :ESC-TYPE,
                   :ESC-DUE-DTE, :ESC-PAYEE, :ESC-AMT
              END-EXEC
              IF SQLCODE = 0
                 PERFORM 2000-PAY
              END-IF
           END-PERFORM
           EXEC SQL CLOSE C-ESC END-EXEC
           CLOSE ESCOUT
           EXIT.
       2000-PAY.
           EXEC SQL SELECT ESCROW_BAL INTO :ESC-BAL
             FROM BANK_LOAN WHERE NOTE_NO = :ESC-LOAN-NO
           END-EXEC
           IF SQLCODE = +100
              MOVE 12 TO WS-RC
              MOVE 'LOAN-NOTFND' TO BK-OP-MSG
              GO TO 2000-X
           END-IF
           IF ESC-BAL < ESC-AMT
              COMPUTE ESC-SHORT = ESC-AMT - ESC-BAL
              SET ESC-NSF-ESC TO TRUE
              EXEC SQL UPDATE BANK_ESCROW_DUE
                SET STATUS = 'N'
                WHERE LOAN_NO = :ESC-LOAN-NO
                  AND ESC_TYPE = :ESC-TYPE
                  AND DUE_DTE = :ESC-DUE-DTE
              END-EXEC
              ADD 1 TO WS-SHORT
              GO TO 2000-X
           END-IF
           EXEC SQL UPDATE BANK_LOAN
             SET ESCROW_BAL = ESCROW_BAL - :ESC-AMT
             WHERE NOTE_NO = :ESC-LOAN-NO
           END-EXEC
           EXEC SQL UPDATE BANK_ESCROW_DUE SET STATUS = 'P'
             WHERE LOAN_NO = :ESC-LOAN-NO
               AND ESC_TYPE = :ESC-TYPE
               AND DUE_DTE = :ESC-DUE-DTE
           END-EXEC
           EXEC SQL INSERT INTO BANK_GL_FEED
             (CYCLE_DTE, GL_ACCT, CCY, DR_CR, AMOUNT, NARR)
             VALUES (CURRENT DATE, '2110005000', 'USD', 'D', :ESC-AMT,
                     :ESC-PAYEE)
           END-EXEC
           ADD 1 TO WS-PAID
           PERFORM 8000-MAP-SQL
           MOVE ESC-LOAN-NO TO ESC-REC
           WRITE ESC-REC
           .
       2000-X.
           EXIT.

       8000-MAP-SQL.
           COPY BKSQLM.
           EXIT.
       9000-TERM.
           MOVE WS-RC TO RETURN-CODE
           EXIT.
