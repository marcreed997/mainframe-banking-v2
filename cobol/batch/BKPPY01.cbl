      *****************************************************************
      * PROGRAM-ID : BKPPY01
      * TITLE      : Positive pay match — issued file vs presentment
      * Synthetic lab system. Not a real bank. Educational / portfolio only.
      * Amount mismatch / not issued / dup pay / void / stop become pending exceptions.
      *****************************************************************
       IDENTIFICATION DIVISION.
       PROGRAM-ID. BKPPY01.
       AUTHOR. LAB-V2.
       DATE-WRITTEN. 2026-08-20.
       ENVIRONMENT DIVISION.
       CONFIGURATION SECTION.
       SOURCE-COMPUTER. IBM-Z.
       OBJECT-COMPUTER. IBM-Z.
       INPUT-OUTPUT SECTION.
       FILE-CONTROL.
           SELECT PRE-FILE ASSIGN TO UPPIN
               ORGANIZATION IS SEQUENTIAL
               FILE STATUS IS WS-FS1.
       DATA DIVISION.
       FILE SECTION.
       FD  PRE-FILE.
       01  PRE-REC                  PIC X(120).
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
       COPY BKPPY.
       COPY BKSTP.
       01  WS-FS1                   PIC XX.
       01  WS-HIT                   PIC 9(7) VALUE 0.
       01  WS-XCPT                  PIC 9(7) VALUE 0.

       PROCEDURE DIVISION.
       0000-MAIN.
           PERFORM 0500-OPEN
           PERFORM 1000-EACH
           PERFORM 9000-TERM
           GOBACK
           .
       0500-OPEN.
           OPEN INPUT PRE-FILE
           IF WS-FS1 = '35'
              SET BK-W-FILEWAIT TO TRUE
              MOVE 8 TO WS-RC
           END-IF
           EXIT.
       1000-EACH.
           IF WS-RC > 4 GO TO 1000-X END-IF
           PERFORM UNTIL WS-FS1 NOT = '00'
              READ PRE-FILE INTO BK-PP-PRESENT
                AT END EXIT PERFORM
              END-READ
              PERFORM 2000-MATCH
           END-PERFORM
           CLOSE PRE-FILE
           IF WS-XCPT > 0 AND WS-RC = 0
              MOVE 4 TO WS-RC
           END-IF
           .
       1000-X.
           EXIT.
       2000-MATCH.
           EXEC SQL SELECT SERIAL, AMOUNT, PAYEE, STATUS
             INTO :PP-ISS-SERIAL, :PP-ISS-AMT, :PP-ISS-PAYEE, :PP-ISS-STATUS
             FROM BANK_PP_ISSUED
            WHERE ACCOUNT_NO = :PP-PR-ACC
              AND SERIAL = :PP-PR-SERIAL
           END-EXEC
           IF SQLCODE = +100
              SET PP-NOT-ISSUED TO TRUE
              PERFORM 8000-XCPT
              GO TO 2000-X
           END-IF
           IF PP-VOID
              SET PP-VOID-HIT TO TRUE
              PERFORM 8000-XCPT
              GO TO 2000-X
           END-IF
           IF PP-PAID
              SET PP-DUP-PAY TO TRUE
              PERFORM 8000-XCPT
              GO TO 2000-X
           END-IF
           IF PP-STOP
              SET PP-STOP-HIT TO TRUE
              PERFORM 8000-XCPT
              GO TO 2000-X
           END-IF
           IF PP-ISS-AMT NOT = PP-PR-AMT
              SET PP-AMT-MISMATCH TO TRUE
              PERFORM 8000-XCPT
              GO TO 2000-X
           END-IF
           EXEC SQL SELECT STOP_ID INTO :STP-ID
             FROM BANK_STOP
            WHERE ACCOUNT_NO = :PP-PR-ACC
              AND CHECK_NO = :PP-PR-SERIAL
              AND STATUS = 'A'
           END-EXEC
           IF SQLCODE = 0
              SET PP-STOP-HIT TO TRUE
              PERFORM 8000-XCPT
              GO TO 2000-X
           END-IF
           ADD 1 TO WS-HIT
           EXEC SQL UPDATE BANK_PP_ISSUED SET STATUS = 'P'
             WHERE ACCOUNT_NO = :PP-PR-ACC AND SERIAL = :PP-PR-SERIAL
           END-EXEC
           .
       2000-X.
           EXIT.
       8000-XCPT.
           ADD 1 TO WS-XCPT
           SET PP-PEND TO TRUE
           EXEC SQL INSERT INTO BANK_PP_XCPT
             (ACCOUNT_NO, SERIAL, ISS_AMT, PRE_AMT, REASON, DECISION,
              CYCLE_DTE)
             VALUES (:PP-PR-ACC, :PP-PR-SERIAL, :PP-ISS-AMT, :PP-PR-AMT,
                     :PP-X-REASON, 'W', CURRENT DATE)
           END-EXEC
           PERFORM 8000-MAP-SQL
           EXIT.

       8000-MAP-SQL.
           COPY BKSQLM.
           EXIT.
       9000-TERM.
           MOVE WS-RC TO RETURN-CODE
           EXIT.
