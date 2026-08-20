      *****************************************************************
      * PROGRAM-ID : BKNSF01
      * TITLE      : NSF / return item batch — fee 35.00 if returned, journal fee
      * Synthetic lab system. Not a real bank. Educational / portfolio only.
      * Different from online WD: overnight presentment file.
      *****************************************************************
       IDENTIFICATION DIVISION.
       PROGRAM-ID. BKNSF01.
       AUTHOR. LAB-V2.
       DATE-WRITTEN. 2026-08-20.
       ENVIRONMENT DIVISION.
       CONFIGURATION SECTION.
       SOURCE-COMPUTER. IBM-Z.
       OBJECT-COMPUTER. IBM-Z.
       INPUT-OUTPUT SECTION.
       FILE-CONTROL.
           SELECT NSF-IN ASSIGN TO UNSFIN
               ORGANIZATION IS SEQUENTIAL.
       DATA DIVISION.
       FILE SECTION.
       FD  NSF-IN.
       01  NSF-REC PIC X(80).
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
       COPY BKNSF.
       COPY BKJRN.
       COPY BKACC.
       PROCEDURE DIVISION.
       0000-MAIN.
           PERFORM 0500-INIT
           PERFORM 1000-PROCESS
           PERFORM 8000-MAP-SQL
           PERFORM 9000-TERM
           GOBACK
           .
       0500-INIT.
           OPEN INPUT NSF-IN
           MOVE 35.00 TO NSF-FEE
           EXIT.
       1000-PROCESS.
           PERFORM UNTIL SQLCODE = 100
              READ NSF-IN AT END EXIT PERFORM
              END-READ
              MOVE NSF-REC(1:6) TO NSF-ACC-NO
              EXEC SQL SELECT BALANCE, OD_LIMIT
                INTO :NSF-AVAIL, :NSF-OD-LIMIT
                FROM BANK_CUSTOMER WHERE ACCOUNT_NO = :NSF-ACC-NO
              END-EXEC
              IF NSF-AVAIL < 0
                 SET NSF-RETURN TO TRUE
                 EXEC SQL INSERT INTO BANK_JOURNAL
                   (ACCOUNT_NO, CHANNEL, DR_CR, AMOUNT, POSTED_IND, NARR)
                   VALUES (:NSF-ACC-NO, 'BATCH', 'D', :NSF-FEE, 'N',
                           'NSF FEE')
                 END-EXEC
                 EXEC SQL UPDATE BANK_CUSTOMER SET STATUS = 'N'
                   WHERE ACCOUNT_NO = :NSF-ACC-NO
                 END-EXEC
              ELSE
                 SET NSF-PAY TO TRUE
              END-IF
           END-PERFORM
           CLOSE NSF-IN
           PERFORM 8000-MAP-SQL
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
       9000-TERM.
           MOVE WS-RC TO RETURN-CODE
           EXIT.
