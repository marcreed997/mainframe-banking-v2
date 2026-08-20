      *****************************************************************
      * PROGRAM-ID : BKCA01
      * TITLE      : CTR large-cash capture — occupation/source required at threshold
      * Synthetic lab system. Not a real bank. Educational / portfolio only.
      * Aggregates CIF cash in/out for business date. Exempt phased businesses skip filing.
      *****************************************************************
       IDENTIFICATION DIVISION.
       PROGRAM-ID. BKCA01.
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
       COPY BKCTR.
       COPY BKCIF.

       LINKAGE SECTION.
       01  DFHCOMMAREA              PIC X(1).
       PROCEDURE DIVISION.
       0000-MAIN.
           PERFORM 1000-RECV
           PERFORM 2000-AGGR
           PERFORM 3000-THRESHOLD
           PERFORM 4000-STORE
           PERFORM 5000-SEND
           PERFORM 9000-RETURN
           .
       1000-RECV.
           EXEC CICS RECEIVE MAP('BKCAMSS') MAPSET('BKCAMS')
                RESP(WS-RESP) RESP2(WS-RESP2)
           END-EXEC
           PERFORM 8100-CICS-RESP
           EXIT.
       2000-AGGR.
           IF WS-RC > 4 GO TO 2000-X END-IF
           EXEC SQL SELECT CIF_NO INTO :CTR-CIF-NO
             FROM BANK_CUSTOMER WHERE ACCOUNT_NO = :CTR-CIF-NO
           END-EXEC
           EXEC SQL SELECT COALESCE(CASH_IN,0), COALESCE(CASH_OUT,0),
                           EXEMPT_IND
             INTO :CTR-CASH-IN, :CTR-CASH-OUT, :CTR-EXEMPT-IND
             FROM BANK_CTR
            WHERE CIF_NO = :CTR-CIF-NO
              AND BUS_DTE = CURRENT DATE
           END-EXEC
           IF SQLCODE = +100
              MOVE 0 TO CTR-CASH-IN
              MOVE 0 TO CTR-CASH-OUT
              SET CTR-PERSON TO TRUE
           END-IF
           .
       2000-X.
           EXIT.
       3000-THRESHOLD.
           IF WS-RC > 4 GO TO 3000-X END-IF
           IF CTR-PHASED
              MOVE 'EXEMPT-PHASED' TO BK-OP-MSG
              MOVE 4 TO WS-RC
              GO TO 3000-X
           END-IF
           IF CTR-CASH-IN + CTR-CASH-OUT < CTR-THRESHOLD
              MOVE 'UNDER-THRESHOLD' TO BK-OP-MSG
              MOVE 4 TO WS-RC
              GO TO 3000-X
           END-IF
           IF CTR-OCCUPATION = SPACES OR CTR-SRC-FUNDS = SPACES
              MOVE 12 TO WS-RC
              MOVE 'CTR-FIELDS-REQD' TO BK-OP-MSG
           END-IF
           .
       3000-X.
           EXIT.
       4000-STORE.
           IF WS-RC > 4 AND WS-RC NOT = 4 GO TO 4000-X END-IF
           EXEC SQL
             MERGE INTO BANK_CTR AS T
             USING (VALUES (:CTR-CIF-NO, CURRENT DATE, :CTR-CASH-IN,
                            :CTR-CASH-OUT, :CTR-OCCUPATION, :CTR-SRC-FUNDS,
                            :CTR-BENEFICIARY, 'Y', :CTR-EXEMPT-IND,
                            :CTR-TELLER, :CTR-BRANCH))
               AS S(CIF_NO, BUS_DTE, CASH_IN, CASH_OUT, OCCUPATION,
                    SRC_FUNDS, BENEFICIARY, FILED_IND, EXEMPT_IND,
                    TELLER_ID, BRANCH_NO)
               ON T.CIF_NO = S.CIF_NO AND T.BUS_DTE = S.BUS_DTE
             WHEN MATCHED THEN UPDATE SET
                  CASH_IN = S.CASH_IN, CASH_OUT = S.CASH_OUT,
                  OCCUPATION = S.OCCUPATION, SRC_FUNDS = S.SRC_FUNDS,
                  BENEFICIARY = S.BENEFICIARY, FILED_IND = 'Y'
             WHEN NOT MATCHED THEN INSERT
                  (CIF_NO, BUS_DTE, CASH_IN, CASH_OUT, OCCUPATION,
                   SRC_FUNDS, BENEFICIARY, FILED_IND, EXEMPT_IND,
                   TELLER_ID, BRANCH_NO)
                  VALUES (S.CIF_NO, S.BUS_DTE, S.CASH_IN, S.CASH_OUT,
                          S.OCCUPATION, S.SRC_FUNDS, S.BENEFICIARY,
                          S.FILED_IND, S.EXEMPT_IND, S.TELLER_ID,
                          S.BRANCH_NO)
           END-EXEC
           PERFORM 8000-MAP-SQL
           .
       4000-X.
           EXIT.
       5000-SEND.
           EXEC CICS SEND MAP('BKCAMSS') MAPSET('BKCAMS') ERASE
                RESP(WS-RESP)
           END-EXEC
           PERFORM 8100-CICS-RESP
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
