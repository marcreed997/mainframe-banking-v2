      *****************************************************************
      * PROGRAM-ID : BKHLD02
      * TITLE      : Hold expiry — release available funds except legal holds
      * Synthetic lab system. Not a real bank. Educational / portfolio only.
      * LEVY and GARNISH never auto-expire. Card-auth holds expire with AUTH status E.
      *****************************************************************
       IDENTIFICATION DIVISION.
       PROGRAM-ID. BKHLD02.
       AUTHOR. LAB-V2.
       DATE-WRITTEN. 2026-08-20.
       ENVIRONMENT DIVISION.
       CONFIGURATION SECTION.
       SOURCE-COMPUTER. IBM-Z.
       OBJECT-COMPUTER. IBM-Z.
       INPUT-OUTPUT SECTION.
       FILE-CONTROL.
           SELECT HLD-RPT ASSIGN TO UHLDREP
               ORGANIZATION IS SEQUENTIAL
               FILE STATUS IS WS-FS1.
       DATA DIVISION.
       FILE SECTION.
       FD  HLD-RPT.
       01  HLD-RPT-REC              PIC X(120).
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
       COPY BKHLD.
       COPY BKACC.
       01  WS-FS1                   PIC XX.
       01  WS-REL-CNT               PIC 9(7) VALUE 0.
       01  WS-SKIP-CNT              PIC 9(7) VALUE 0.
       01  WS-HOLD-TYPE             PIC X(8).
       01  WS-HOLD-AMT              PIC S9(13)V99 COMP-3.
       01  WS-HOLD-ID               PIC X(12).
       01  WS-ACC                   PIC X(6).

       PROCEDURE DIVISION.
       0000-MAIN.
           PERFORM 0500-OPEN
           PERFORM 1000-CURSOR
           PERFORM 9000-TERM
           GOBACK
           .
       0500-OPEN.
           EXEC SQL SELECT ONLINE_INHIBIT INTO :CTL-ONLINE-INHIBIT
             FROM BANK_CYCLE_CTL FETCH FIRST 1 ROW ONLY
           END-EXEC
           IF ONLINE-ALLOWED
              SET BK-E-CICS-ACTIVE TO TRUE
              MOVE 12 TO WS-RC
              MOVE 'BK-E-ONLINEUP' TO BK-OP-MSG
           END-IF
           OPEN OUTPUT HLD-RPT
           EXIT.
       1000-CURSOR.
           IF WS-RC >= 12 GO TO 1000-X END-IF
           EXEC SQL DECLARE C-HLD CURSOR FOR
             SELECT HOLD_ID, ACCOUNT_NO, AMOUNT, HOLD_TYPE
               FROM BANK_HOLD
              WHERE STATUS = 'A'
                AND EXP_DTE <= CURRENT DATE
           END-EXEC
           EXEC SQL OPEN C-HLD END-EXEC
           PERFORM UNTIL SQLCODE NOT = 0
              EXEC SQL FETCH C-HLD
                INTO :WS-HOLD-ID, :WS-ACC, :WS-HOLD-AMT, :WS-HOLD-TYPE
              END-EXEC
              IF SQLCODE = 0
                 IF WS-HOLD-TYPE = 'LEVY    ' OR WS-HOLD-TYPE = 'GARNISH '
                    ADD 1 TO WS-SKIP-CNT
                    MOVE 'SKIP-LEGAL' TO HLD-RPT-REC
                    WRITE HLD-RPT-REC
                 ELSE
                    EXEC SQL UPDATE BANK_HOLD SET STATUS = 'R'
                      WHERE HOLD_ID = :WS-HOLD-ID
                    END-EXEC
                    EXEC SQL UPDATE BANK_CUSTOMER
                      SET HOLD_AMT = HOLD_AMT - :WS-HOLD-AMT
                      WHERE ACCOUNT_NO = :WS-ACC
                    END-EXEC
                    ADD 1 TO WS-REL-CNT
                    MOVE 'RELEASED' TO HLD-RPT-REC
                    WRITE HLD-RPT-REC
                 END-IF
              END-IF
           END-PERFORM
           EXEC SQL CLOSE C-HLD END-EXEC
           IF WS-REL-CNT = 0
              MOVE 4 TO WS-RC
           END-IF
           CLOSE HLD-RPT
           .
       1000-X.
           EXIT.

       8000-MAP-SQL.
           COPY BKSQLM.
           EXIT.
       9000-TERM.
           MOVE WS-RC TO RETURN-CODE
           EXIT.
