      *****************************************************************
      * PROGRAM-ID : BKACH02
      * TITLE      : ACH returns / NOC — R01-R10 windows, match original trace
      * Synthetic lab system. Not a real bank. Educational / portfolio only.
      * R10 unauthorized: 60 calendar days. R01 NSF: 2 banking days via BANK_CALENDAR.
      *****************************************************************
       IDENTIFICATION DIVISION.
       PROGRAM-ID. BKACH02.
       AUTHOR. LAB-V2.
       DATE-WRITTEN. 2026-08-20.
       ENVIRONMENT DIVISION.
       CONFIGURATION SECTION.
       SOURCE-COMPUTER. IBM-Z.
       OBJECT-COMPUTER. IBM-Z.
       INPUT-OUTPUT SECTION.
       FILE-CONTROL.
           SELECT RET-FILE ASSIGN TO UACHRET
               ORGANIZATION IS SEQUENTIAL
               FILE STATUS IS WS-FS1.
       DATA DIVISION.
       FILE SECTION.
       FD  RET-FILE.
       01  RET-REC                  PIC X(94).
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
       COPY BKACH.
       COPY BKCAL.
       COPY BKJRN.
       01  WS-FS1                   PIC XX.
       01  WS-DAYS                  PIC 9(4) VALUE 0.
       01  WS-ORIG-DTE              PIC X(10).
       01  WS-BUS-DTE               PIC X(10).

       PROCEDURE DIVISION.
       0000-MAIN.
           PERFORM 0500-OPEN
           PERFORM 1000-EACH
           PERFORM 9000-TERM
           GOBACK
           .
       0500-OPEN.
           OPEN INPUT RET-FILE
           IF WS-FS1 = '35'
              SET BK-W-FILEWAIT TO TRUE
              MOVE 8 TO WS-RC
              MOVE 'BK-W-FILEWAIT' TO BK-OP-MSG
           END-IF
           EXEC SQL SELECT CAL_DTE INTO :WS-BUS-DTE
             FROM BANK_CALENDAR
            WHERE CAL_DTE = CURRENT DATE
           END-EXEC
           EXIT.
       1000-EACH.
           IF WS-RC > 4 GO TO 1000-X END-IF
           PERFORM UNTIL WS-FS1 NOT = '00'
              READ RET-FILE INTO ACH-RETURN
                AT END EXIT PERFORM
              END-READ
              IF ACH-R7-TYPE = '7'
                 PERFORM 2000-MATCH
                 PERFORM 3000-WINDOW
                 PERFORM 4000-POST-RET
              END-IF
              IF WS-RC >= 12
                 EXIT PERFORM
              END-IF
           END-PERFORM
           CLOSE RET-FILE
           .
       1000-X.
           EXIT.
       2000-MATCH.
           EXEC SQL SELECT CYCLE_DTE, AMOUNT, ACCOUNT_NO, STATUS
             INTO :WS-ORIG-DTE, :ACH-E6-AMT, :JRN-ACC-NO, :ACH-E6-DISC
             FROM BANK_ACH_ENTRY
            WHERE ACH_TRACE = :ACH-R7-ORIG-TRACE
           END-EXEC
           IF SQLCODE = +100
              SET BK-E-UNMATCHED TO TRUE
              MOVE 'BK-E-UNMATCHED ORIG' TO BK-OP-MSG
              EXEC SQL INSERT INTO BANK_RECON_XCPT
                (CYCLE_DTE, TRACE_ID, REASON, AMOUNT, STATUS)
                VALUES (CURRENT DATE, :ACH-R7-ORIG-TRACE, 'ACH-ORPHAN',
                        0, 'O')
              END-EXEC
              ADD 1 TO ACH-WS-CNT
           END-IF
           EXIT.
       3000-WINDOW.
           IF WS-RC >= 12 GO TO 3000-X END-IF
           IF SQLCODE = +100 GO TO 3000-X END-IF
           EXEC SQL SELECT DAYS(CURRENT DATE) - DAYS(:WS-ORIG-DTE)
             INTO :WS-DAYS
             FROM SYSIBM.SYSDUMMY1
           END-EXEC
           EVALUATE TRUE
             WHEN R01-NSF
                IF WS-DAYS > 2
                   MOVE 12 TO WS-RC
                   SET BK-E-CUTOFF TO TRUE
                   MOVE 'BK-E-CUTOFF R01' TO BK-OP-MSG
                END-IF
             WHEN R10-UNAUTH
                IF WS-DAYS > 60
                   MOVE 12 TO WS-RC
                   SET BK-E-CUTOFF TO TRUE
                   MOVE 'BK-E-CUTOFF R10' TO BK-OP-MSG
                END-IF
             WHEN R08-STOP
                CONTINUE
             WHEN OTHER
                IF WS-DAYS > 5
                   MOVE 4 TO WS-RC
                   MOVE 'LATE-RETURN-WARN' TO BK-OP-MSG
                END-IF
           END-EVALUATE
           .
       3000-X.
           EXIT.
       4000-POST-RET.
           IF WS-RC >= 12 GO TO 4000-X END-IF
           IF SQLCODE = +100 GO TO 4000-X END-IF
           EXEC SQL UPDATE BANK_ACH_ENTRY
             SET RETURN_CODE = :ACH-R7-RET-CODE,
                 ORIG_TRACE = :ACH-R7-ORIG-TRACE,
                 STATUS = 'X'
             WHERE ACH_TRACE = :ACH-R7-ORIG-TRACE
           END-EXEC
           EXEC SQL INSERT INTO BANK_JOURNAL
             (TRACE_ID, ACCOUNT_NO, CHANNEL, DR_CR, AMOUNT, POSTED_IND,
              NARR)
             VALUES (:ACH-R7-ADD-TRACE, :JRN-ACC-NO, 'ACH', 'C',
                     :ACH-E6-AMT, 'N', :ACH-R7-RET-CODE)
           END-EXEC
           PERFORM 8000-MAP-SQL
           .
       4000-X.
           EXIT.

       8000-MAP-SQL.
           COPY BKSQLM.
           EXIT.
       9000-TERM.
           MOVE WS-RC TO RETURN-CODE
           EXIT.
