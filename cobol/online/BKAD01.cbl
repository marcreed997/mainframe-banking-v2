      *****************************************************************
      * PROGRAM-ID : BKAD01
      * TITLE      : CIF address change with dual-control pending flag
      * Synthetic lab system. Not a real bank. Educational / portfolio only.
      * First teller sets DUAL_PEND=Y; second teller (different id) applies. OFAC re-screen.
      *****************************************************************
       IDENTIFICATION DIVISION.
       PROGRAM-ID. BKAD01.
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
       COPY BKCIF.
       COPY BKOFAC.

       LINKAGE SECTION.
       01  DFHCOMMAREA              PIC X(1).
       PROCEDURE DIVISION.
       0000-MAIN.
           PERFORM 1000-RECV
           PERFORM 2000-LOAD
           PERFORM 3000-DUAL
           PERFORM 4000-OFAC
           PERFORM 5000-APPLY
           PERFORM 6000-SEND
           PERFORM 9000-RETURN
           .
       1000-RECV.
           EXEC CICS RECEIVE MAP('BKCFMSS') MAPSET('BKCFMS')
                RESP(WS-RESP) RESP2(WS-RESP2)
           END-EXEC
           PERFORM 8100-CICS-RESP
           EXIT.
       2000-LOAD.
           EXEC SQL SELECT CIF_NO, CUSTOMER_NAME, DUAL_PEND, OFAC_STAT
             INTO :OF-CIF-NO, :OF-RAW-NAME, :WS-REASON, :OF-HIT-IND
             FROM BANK_CIF WHERE CIF_NO = :OF-CIF-NO
           END-EXEC
           IF SQLCODE = +100
              MOVE 12 TO WS-RC
              MOVE 'CIF-NOTFND' TO BK-OP-MSG
           END-IF
           EXIT.
       3000-DUAL.
           IF WS-RC > 4 GO TO 3000-X END-IF
           IF WS-REASON NOT = 'Y'
              EXEC SQL UPDATE BANK_CIF SET DUAL_PEND = 'Y'
                WHERE CIF_NO = :OF-CIF-NO
              END-EXEC
              MOVE 4 TO WS-RC
              MOVE 'PENDING-SECOND-TELLER' TO BK-OP-MSG
              GO TO 3000-X
           END-IF
           IF BK-TELLER-ID = SPACES
              MOVE 8 TO WS-RC
              MOVE 'SECOND-TELLER-REQD' TO BK-OP-MSG
           END-IF
           .
       3000-X.
           EXIT.
       4000-OFAC.
           IF WS-RC > 4 GO TO 4000-X END-IF
           MOVE 0 TO OF-SCORE
           EXEC SQL SELECT MAX(SCORE) INTO :OF-SCORE
             FROM BANK_OFAC_HIT
            WHERE CIF_NO = :OF-CIF-NO
              AND STATUS IN ('Y','R')
           END-EXEC
           IF OF-SCORE >= OF-THRESHOLD
              SET OF-HIT TO TRUE
              MOVE 12 TO WS-RC
              MOVE 'OFAC-HIT-BLOCK' TO BK-OP-MSG
           END-IF
           .
       4000-X.
           EXIT.
       5000-APPLY.
           IF WS-RC > 4 GO TO 5000-X END-IF
           EXEC SQL UPDATE BANK_CIF
             SET DUAL_PEND = 'N', OFAC_STAT = 'N'
             WHERE CIF_NO = :OF-CIF-NO
           END-EXEC
           PERFORM 8000-MAP-SQL
           EXEC CICS SYNCPOINT END-EXEC
           .
       5000-X.
           EXIT.
       6000-SEND.
           EXEC CICS SEND MAP('BKCFMSS') MAPSET('BKCFMS') ERASE
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
