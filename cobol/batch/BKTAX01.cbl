      *****************************************************************
      * PROGRAM-ID : BKTAX01
      * TITLE      : 1099-INT extract + backup withholding on B/C notice
      * Synthetic lab system. Not a real bank. Educational / portfolio only.
      * TIN missing or B-notice -> withhold 24% of this-cycle interest.
      *****************************************************************
       IDENTIFICATION DIVISION.
       PROGRAM-ID. BKTAX01.
       AUTHOR. LAB-V2.
       DATE-WRITTEN. 2026-08-20.
       ENVIRONMENT DIVISION.
       CONFIGURATION SECTION.
       SOURCE-COMPUTER. IBM-Z.
       OBJECT-COMPUTER. IBM-Z.
       INPUT-OUTPUT SECTION.
       FILE-CONTROL.
           SELECT TAXOUT ASSIGN TO UTAXOUT
               ORGANIZATION IS SEQUENTIAL
               FILE STATUS IS WS-FS1.
       DATA DIVISION.
       FILE SECTION.
       FD  TAXOUT.
       01  TAX-REC                  PIC X(132).
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
       COPY BKTAX.
       COPY BKINT.
       01  WS-FS1                   PIC XX.
       01  WS-INT                   PIC S9(13)V99 COMP-3.
       01  WS-CIF                   PIC X(10).
       01  WS-WH                    PIC 9(5) VALUE 0.

       PROCEDURE DIVISION.
       0000-MAIN.
           PERFORM 1000-YTD
           PERFORM 9000-TERM
           GOBACK
           .
       1000-YTD.
           OPEN OUTPUT TAXOUT
           EXEC SQL DECLARE C-INT CURSOR FOR
             SELECT C.CIF_NO, COALESCE(SUM(A.ACCRUAL),0), C.TIN, C.TIN_STAT
               FROM BANK_INT_ACCRUAL A
               JOIN BANK_CUSTOMER CU ON CU.ACCOUNT_NO = A.ACCOUNT_NO
               JOIN BANK_CIF C ON C.CIF_NO = CU.CIF_NO
              WHERE YEAR(A.CYCLE_DTE) = YEAR(CURRENT DATE)
              GROUP BY C.CIF_NO, C.TIN, C.TIN_STAT
           END-EXEC
           EXEC SQL OPEN C-INT END-EXEC
           PERFORM UNTIL SQLCODE NOT = 0
              EXEC SQL FETCH C-INT INTO :TAX-CIF-NO, :TAX-INT-YTD,
                   :TAX-TIN, :TAX-TIN-STAT
              END-EXEC
              IF SQLCODE = 0
                 PERFORM 2000-WH
              END-IF
           END-PERFORM
           EXEC SQL CLOSE C-INT END-EXEC
           CLOSE TAXOUT
           EXIT.
       2000-WH.
           MOVE 0 TO TAX-WH-THIS
           IF TIN-MISSING OR TIN-B-NOTICE OR TIN-C-NOTICE
              COMPUTE TAX-WH-THIS = TAX-INT-YTD * TAX-WH-RATE
              ADD 1 TO WS-WH
           END-IF
           EXEC SQL
             MERGE INTO BANK_TAX_1099 AS T
             USING (VALUES (:TAX-CIF-NO, YEAR(CURRENT DATE), :TAX-INT-YTD,
                            :TAX-WH-THIS, :TAX-TIN, :TAX-TIN-STAT))
               AS S(CIF_NO, TAX_YEAR, INT_YTD, WH_YTD, TIN, TIN_STAT)
               ON T.CIF_NO = S.CIF_NO AND T.TAX_YEAR = S.TAX_YEAR
             WHEN MATCHED THEN UPDATE SET
                  INT_YTD = S.INT_YTD, WH_YTD = S.WH_YTD
             WHEN NOT MATCHED THEN INSERT
                  (CIF_NO, TAX_YEAR, INT_YTD, WH_YTD, TIN, TIN_STAT,
                   FILED_IND)
                  VALUES (S.CIF_NO, S.TAX_YEAR, S.INT_YTD, S.WH_YTD,
                          S.TIN, S.TIN_STAT, 'N')
           END-EXEC
           PERFORM 8000-MAP-SQL
           MOVE TAX-CIF-NO TO TAX-REC
           WRITE TAX-REC
           EXIT.

       8000-MAP-SQL.
           COPY BKSQLM.
           EXIT.
       9000-TERM.
           MOVE WS-RC TO RETURN-CODE
           EXIT.
