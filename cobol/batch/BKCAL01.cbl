      *****************************************************************
      * PROGRAM-ID : BKCAL01
      * TITLE      : Business-day calendar load / next-business-day compute
      * Synthetic lab system. Not a real bank. Educational / portfolio only.
      * Sat/Sun and HOLIDAY_IND=Y are not business days. Feeds ACH same-day cutoff.
      *****************************************************************
       IDENTIFICATION DIVISION.
       PROGRAM-ID. BKCAL01.
       AUTHOR. LAB-V2.
       DATE-WRITTEN. 2026-08-20.
       ENVIRONMENT DIVISION.
       CONFIGURATION SECTION.
       SOURCE-COMPUTER. IBM-Z.
       OBJECT-COMPUTER. IBM-Z.
       INPUT-OUTPUT SECTION.
       FILE-CONTROL.
           SELECT CALIN ASSIGN TO UCALIN
               ORGANIZATION IS SEQUENTIAL
               FILE STATUS IS WS-FS1.
       DATA DIVISION.
       FILE SECTION.
       FD  CALIN.
       01  CAL-REC                  PIC X(80).
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
       COPY BKCAL.
       01  WS-FS1                   PIC XX.
       01  WS-LOADED                PIC 9(5) VALUE 0.
       01  WS-SKIP                  PIC 9(5) VALUE 0.

       PROCEDURE DIVISION.
       0000-MAIN.
           PERFORM 0500-OPEN
           PERFORM 1000-LOAD
           PERFORM 2000-CHAIN
           PERFORM 9000-TERM
           GOBACK
           .
       0500-OPEN.
           OPEN INPUT CALIN
           IF WS-FS1 = '35'
              SET BK-W-FILEWAIT TO TRUE
              MOVE 8 TO WS-RC
           END-IF
           EXIT.
       1000-LOAD.
           IF WS-RC > 4 GO TO 1000-X END-IF
           PERFORM UNTIL WS-FS1 NOT = '00'
              READ CALIN INTO BK-CALENDAR
                AT END EXIT PERFORM
              END-READ
              IF CAL-SAT OR CAL-SUN
                 SET CAL-HOLIDAY TO TRUE
                 ADD 1 TO WS-SKIP
              END-IF
              EXEC SQL
                MERGE INTO BANK_CALENDAR AS T
                USING (VALUES (:CAL-DTE, :CAL-DOW, :CAL-HOLIDAY-IND,
                               :CAL-HOLIDAY-NAME, :CAL-FED-OPEN,
                               :CAL-SAME-DAY-CUT, :CAL-WIRE-CUT))
                  AS S(CAL_DTE, DOW, HOLIDAY_IND, HOLIDAY_NAME, FED_OPEN,
                       SAME_DAY_CUT, WIRE_CUT)
                  ON T.CAL_DTE = S.CAL_DTE
                WHEN MATCHED THEN UPDATE SET
                     DOW = S.DOW, HOLIDAY_IND = S.HOLIDAY_IND,
                     HOLIDAY_NAME = S.HOLIDAY_NAME
                WHEN NOT MATCHED THEN INSERT
                     (CAL_DTE, DOW, HOLIDAY_IND, HOLIDAY_NAME, FED_OPEN,
                      SAME_DAY_CUT, WIRE_CUT)
                     VALUES (S.CAL_DTE, S.DOW, S.HOLIDAY_IND,
                             S.HOLIDAY_NAME, S.FED_OPEN, S.SAME_DAY_CUT,
                             S.WIRE_CUT)
              END-EXEC
              ADD 1 TO WS-LOADED
              PERFORM 8000-MAP-SQL
           END-PERFORM
           CLOSE CALIN
           .
       1000-X.
           EXIT.
       2000-CHAIN.
           IF WS-RC >= 12 GO TO 2000-X END-IF
           EXEC SQL UPDATE BANK_CALENDAR C
             SET NEXT_BUS = (SELECT MIN(C2.CAL_DTE) FROM BANK_CALENDAR C2
                              WHERE C2.CAL_DTE > C.CAL_DTE
                                AND C2.HOLIDAY_IND = 'N'
                                AND C2.DOW BETWEEN 2 AND 6),
                 PREV_BUS = (SELECT MAX(C3.CAL_DTE) FROM BANK_CALENDAR C3
                              WHERE C3.CAL_DTE < C.CAL_DTE
                                AND C3.HOLIDAY_IND = 'N'
                                AND C3.DOW BETWEEN 2 AND 6)
           END-EXEC
           PERFORM 8000-MAP-SQL
           .
       2000-X.
           EXIT.

       8000-MAP-SQL.
           COPY BKSQLM.
           EXIT.
       9000-TERM.
           MOVE WS-RC TO RETURN-CODE
           EXIT.
