      *****************************************************************
      * PROGRAM-ID : BKCTR01
      * TITLE      : CTR aggregation — cash in/out per CIF per business day
      * Synthetic lab system. Not a real bank. Educational / portfolio only.
      * Threshold 10000. Does not file; writes BANK_CTR for BKCA01 to complete.
      *****************************************************************
       IDENTIFICATION DIVISION.
       PROGRAM-ID. BKCTR01.
       AUTHOR. LAB-V2.
       DATE-WRITTEN. 2026-08-20.
       ENVIRONMENT DIVISION.
       CONFIGURATION SECTION.
       SOURCE-COMPUTER. IBM-Z.
       OBJECT-COMPUTER. IBM-Z.
       INPUT-OUTPUT SECTION.
       FILE-CONTROL.
           SELECT CTRRPT ASSIGN TO UCTRRPT
               ORGANIZATION IS SEQUENTIAL
               FILE STATUS IS WS-FS1.
       DATA DIVISION.
       FILE SECTION.
       FD  CTRRPT.
       01  CTR-RPT                  PIC X(120).
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
       COPY BKCTR.
       COPY BKJRN.
       01  WS-FS1                   PIC XX.
       01  WS-CIF                   PIC X(10).
       01  WS-IN                    PIC S9(13)V99 COMP-3.
       01  WS-OUT                   PIC S9(13)V99 COMP-3.
       01  WS-FLAGGED               PIC 9(5) VALUE 0.

       PROCEDURE DIVISION.
       0000-MAIN.
           PERFORM 1000-AGGR
           PERFORM 9000-TERM
           GOBACK
           .
       1000-AGGR.
           OPEN OUTPUT CTRRPT
           EXEC SQL DECLARE C-CASH CURSOR FOR
             SELECT C.CIF_NO,
                    COALESCE(SUM(CASE WHEN J.DR_CR='C' THEN J.AMOUNT END),0),
                    COALESCE(SUM(CASE WHEN J.DR_CR='D' THEN J.AMOUNT END),0)
               FROM BANK_JOURNAL J
               JOIN BANK_CUSTOMER C ON C.ACCOUNT_NO = J.ACCOUNT_NO
              WHERE J.CYCLE_DTE = CURRENT DATE
                AND J.CHANNEL IN ('TELLER','ATM')
                AND J.NARR LIKE 'CASH%'
              GROUP BY C.CIF_NO
           END-EXEC
           EXEC SQL OPEN C-CASH END-EXEC
           PERFORM UNTIL SQLCODE NOT = 0
              EXEC SQL FETCH C-CASH INTO :WS-CIF, :WS-IN, :WS-OUT
              END-EXEC
              IF SQLCODE = 0
                 IF WS-IN + WS-OUT >= 10000.00
                    ADD 1 TO WS-FLAGGED
                    EXEC SQL
                      MERGE INTO BANK_CTR AS T
                      USING (VALUES (:WS-CIF, CURRENT DATE, :WS-IN,
                                     :WS-OUT))
                        AS S(CIF_NO, BUS_DTE, CASH_IN, CASH_OUT)
                        ON T.CIF_NO = S.CIF_NO AND T.BUS_DTE = S.BUS_DTE
                      WHEN MATCHED THEN UPDATE SET
                           CASH_IN = S.CASH_IN, CASH_OUT = S.CASH_OUT
                      WHEN NOT MATCHED THEN INSERT
                           (CIF_NO, BUS_DTE, CASH_IN, CASH_OUT, FILED_IND)
                           VALUES (S.CIF_NO, S.BUS_DTE, S.CASH_IN,
                                   S.CASH_OUT, 'N')
                    END-EXEC
                    MOVE 'CTR-CANDIDATE' TO CTR-RPT
                    WRITE CTR-RPT
                 END-IF
              END-IF
           END-PERFORM
           EXEC SQL CLOSE C-CASH END-EXEC
           CLOSE CTRRPT
           IF WS-FLAGGED = 0
              MOVE 4 TO WS-RC
           END-IF
           EXIT.

       8000-MAP-SQL.
           COPY BKSQLM.
           EXIT.
       9000-TERM.
           MOVE WS-RC TO RETURN-CODE
           EXIT.
