      *****************************************************************
      * PROGRAM-ID : BKUCP01
      * TITLE      : Unclaimed property / escheat — state dormancy years
      * Synthetic lab system. Not a real bank. Educational / portfolio only.
      * DE 5 years, all others 3 in this lab. Notice then remit to GL 2900001000.
      *****************************************************************
       IDENTIFICATION DIVISION.
       PROGRAM-ID. BKUCP01.
       AUTHOR. LAB-V2.
       DATE-WRITTEN. 2026-08-20.
       ENVIRONMENT DIVISION.
       CONFIGURATION SECTION.
       SOURCE-COMPUTER. IBM-Z.
       OBJECT-COMPUTER. IBM-Z.
       INPUT-OUTPUT SECTION.
       FILE-CONTROL.
           SELECT UCPRPT ASSIGN TO UUCPRPT
               ORGANIZATION IS SEQUENTIAL
               FILE STATUS IS WS-FS1.
       DATA DIVISION.
       FILE SECTION.
       FD  UCPRPT.
       01  UCP-RPT                  PIC X(120).
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
       COPY BKUCP.
       COPY BKACC.
       COPY BKGL.
       01  WS-FS1                   PIC XX.
       01  WS-YEARS                 PIC 9(4).
       01  WS-REMIT                 PIC 9(5) VALUE 0.

       PROCEDURE DIVISION.
       0000-MAIN.
           PERFORM 1000-SCAN
           PERFORM 9000-TERM
           GOBACK
           .
       1000-SCAN.
           OPEN OUTPUT UCPRPT
           EXEC SQL DECLARE C-DORM CURSOR FOR
             SELECT ACCOUNT_NO, CIF_NO, BALANCE, LAST_CUST_DTE, STATUS
               FROM BANK_CUSTOMER
              WHERE STATUS IN ('D','O')
           END-EXEC
           EXEC SQL OPEN C-DORM END-EXEC
           PERFORM UNTIL SQLCODE NOT = 0
              EXEC SQL FETCH C-DORM INTO :UCP-ACC-NO, :UCP-CIF-NO,
                   :UCP-BAL, :UCP-LAST-CUST-DTE, :ACC-STATUS
              END-EXEC
              IF SQLCODE = 0
                 PERFORM 2000-RULE
              END-IF
           END-PERFORM
           EXEC SQL CLOSE C-DORM END-EXEC
           CLOSE UCPRPT
           EXIT.
       2000-RULE.
           EXEC SQL SELECT STATE INTO :UCP-STATE
             FROM BANK_CIF WHERE CIF_NO = :UCP-CIF-NO
           END-EXEC
           IF UCP-STATE = 'DE'
              MOVE 5 TO UCP-DORM-YEARS
           ELSE
              MOVE 3 TO UCP-DORM-YEARS
           END-IF
           EXEC SQL SELECT YEAR(CURRENT DATE) - YEAR(:UCP-LAST-CUST-DTE)
             INTO :WS-YEARS FROM SYSIBM.SYSDUMMY1
           END-EXEC
           IF WS-YEARS < UCP-DORM-YEARS
              GO TO 2000-X
           END-IF
           IF WS-YEARS = UCP-DORM-YEARS
              SET UCP-NOTICED TO TRUE
              EXEC SQL
                MERGE INTO BANK_UCP AS T
                USING (VALUES (:UCP-ACC-NO, :UCP-CIF-NO, :UCP-STATE,
                               :UCP-DORM-YEARS, :UCP-LAST-CUST-DTE,
                               CURRENT DATE, 'N', YEAR(CURRENT DATE)))
                  AS S(ACCOUNT_NO, CIF_NO, STATE, DORM_YEARS,
                       LAST_CUST_DTE, NOTICE_DTE, STATUS, REPORT_YEAR)
                  ON T.ACCOUNT_NO = S.ACCOUNT_NO
                WHEN MATCHED THEN UPDATE SET STATUS = 'N',
                     NOTICE_DTE = CURRENT DATE
                WHEN NOT MATCHED THEN INSERT
                     (ACCOUNT_NO, CIF_NO, STATE, DORM_YEARS,
                      LAST_CUST_DTE, NOTICE_DTE, STATUS, REPORT_YEAR)
                     VALUES (S.ACCOUNT_NO, S.CIF_NO, S.STATE,
                             S.DORM_YEARS, S.LAST_CUST_DTE, S.NOTICE_DTE,
                             S.STATUS, S.REPORT_YEAR)
              END-EXEC
           ELSE
              SET UCP-REMITTED TO TRUE
              EXEC SQL UPDATE BANK_CUSTOMER
                SET BALANCE = 0, STATUS = 'C'
                WHERE ACCOUNT_NO = :UCP-ACC-NO
              END-EXEC
              EXEC SQL INSERT INTO BANK_GL_FEED
                (CYCLE_DTE, GL_ACCT, CCY, DR_CR, AMOUNT, NARR)
                VALUES (CURRENT DATE, '2900001000', 'USD', 'C',
                        :UCP-BAL, 'ESCHEAT')
              END-EXEC
              ADD 1 TO WS-REMIT
           END-IF
           PERFORM 8000-MAP-SQL
           MOVE UCP-ACC-NO TO UCP-RPT
           WRITE UCP-RPT
           .
       2000-X.
           EXIT.

       8000-MAP-SQL.
           COPY BKSQLM.
           EXIT.
       9000-TERM.
           MOVE WS-RC TO RETURN-CODE
           EXIT.
