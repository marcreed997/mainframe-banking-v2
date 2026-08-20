      *****************************************************************
      * PROGRAM-ID : BKFLT01
      * TITLE      : Funds availability / float — Reg CC lab stub by deposit class
      * Synthetic lab system. Not a real bank. Educational / portfolio only.
      * Cash/wire 0-day; on-us 1; local 2; non-local 5; new-account +1. Writes BANK_AVAIL.
      *****************************************************************
       IDENTIFICATION DIVISION.
       PROGRAM-ID. BKFLT01.
       AUTHOR. LAB-V2.
       DATE-WRITTEN. 2026-08-20.
       ENVIRONMENT DIVISION.
       CONFIGURATION SECTION.
       SOURCE-COMPUTER. IBM-Z.
       OBJECT-COMPUTER. IBM-Z.
       INPUT-OUTPUT SECTION.
       FILE-CONTROL.
           SELECT DEP-FILE ASSIGN TO UDEPIN
               ORGANIZATION IS SEQUENTIAL
               FILE STATUS IS WS-FS1.
       DATA DIVISION.
       FILE SECTION.
       FD  DEP-FILE.
       01  DEP-REC                  PIC X(160).
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
       COPY BKAVL.
       COPY BKCAL.
       COPY BKJRN.
       01  WS-FS1                   PIC XX.
       01  WS-DAYS                  PIC 9(2).
       01  WS-NEW                   PIC X.
       01  WS-OPEN-DTE              PIC X(10).

       PROCEDURE DIVISION.
       0000-MAIN.
           PERFORM 0500-OPEN
           PERFORM 1000-EACH
           PERFORM 9000-TERM
           GOBACK
           .
       0500-OPEN.
           OPEN INPUT DEP-FILE
           IF WS-FS1 = '35'
              SET BK-W-FILEWAIT TO TRUE
              MOVE 8 TO WS-RC
           END-IF
           EXIT.
       1000-EACH.
           IF WS-RC > 4 GO TO 1000-X END-IF
           PERFORM UNTIL WS-FS1 NOT = '00'
              READ DEP-FILE INTO BK-AVAIL-SCHED
                AT END EXIT PERFORM
              END-READ
              PERFORM 2000-CLASS
              PERFORM 3000-STORE
           END-PERFORM
           CLOSE DEP-FILE
           .
       1000-X.
           EXIT.
       2000-CLASS.
           EVALUATE TRUE
             WHEN AVL-CASH OR AVL-WIRE
                MOVE 0 TO WS-DAYS
                SET AVL-ROUTINE TO TRUE
             WHEN AVL-ACH OR AVL-NEXTDAY
                MOVE 1 TO WS-DAYS
             WHEN AVL-ONUS
                MOVE 1 TO WS-DAYS
             WHEN AVL-LOCAL
                MOVE 2 TO WS-DAYS
             WHEN AVL-NLOCAL
                MOVE 5 TO WS-DAYS
             WHEN OTHER
                MOVE 2 TO WS-DAYS
           END-EVALUATE
           EXEC SQL SELECT OPEN_DTE INTO :WS-OPEN-DTE
             FROM BANK_CUSTOMER WHERE ACCOUNT_NO = :AVL-ACC-NO
           END-EXEC
           EXEC SQL SELECT CASE WHEN DAYS(CURRENT DATE)
                                 - DAYS(:WS-OPEN-DTE) < 30
                            THEN 'Y' ELSE 'N' END
             INTO :WS-NEW FROM SYSIBM.SYSDUMMY1
           END-EXEC
           IF WS-NEW = 'Y'
              ADD 1 TO WS-DAYS
              SET AVL-NEW-ACCT TO TRUE
           END-IF
           IF AVL-AMT > 5000.00 AND WS-DAYS < 2
              MOVE 2 TO WS-DAYS
              SET AVL-LARGE TO TRUE
           END-IF
           MOVE WS-DAYS TO AVL-HOLD-DAYS
           EXEC SQL SELECT CAL_DTE INTO :AVL-AVAIL-DTE
             FROM BANK_CALENDAR
            WHERE CAL_DTE >= CURRENT DATE
              AND HOLIDAY_IND = 'N'
              AND DOW BETWEEN 2 AND 6
            ORDER BY CAL_DTE
            OFFSET :WS-DAYS ROWS
            FETCH FIRST 1 ROW ONLY
           END-EXEC
           EXIT.
       3000-STORE.
           SET AVL-HELD TO TRUE
           EXEC SQL INSERT INTO BANK_AVAIL
             (TRACE_ID, ACCOUNT_NO, AMOUNT, DEP_DTE, AVAIL_DTE,
              HOLD_DAYS, AVL_CLASS, REASON, STATUS)
             VALUES (:AVL-TRACE, :AVL-ACC-NO, :AVL-AMT, CURRENT DATE,
                     :AVL-AVAIL-DTE, :AVL-HOLD-DAYS, :AVL-CLASS,
                     :AVL-REASON, 'H')
           END-EXEC
           PERFORM 8000-MAP-SQL
           IF WS-DAYS > 0
              EXEC SQL UPDATE BANK_CUSTOMER
                SET HOLD_AMT = HOLD_AMT + :AVL-AMT
                WHERE ACCOUNT_NO = :AVL-ACC-NO
              END-EXEC
           END-IF
           EXIT.

       8000-MAP-SQL.
           COPY BKSQLM.
           EXIT.
       9000-TERM.
           MOVE WS-RC TO RETURN-CODE
           EXIT.
