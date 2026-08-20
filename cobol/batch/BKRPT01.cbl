      *****************************************************************
      * PROGRAM-ID : BKRPT01
      * TITLE      : Exception report — prints OPEN recon items by reason/location
      * Synthetic lab system. Not a real bank. Educational / portfolio only.
      * Always RC=0 unless SQL severe. Safe after integrity fail (COND EVEN).
      *****************************************************************
       IDENTIFICATION DIVISION.
       PROGRAM-ID. BKRPT01.
       AUTHOR. LAB-V2.
       DATE-WRITTEN. 2026-08-20.
       ENVIRONMENT DIVISION.
       CONFIGURATION SECTION.
       SOURCE-COMPUTER. IBM-Z.
       OBJECT-COMPUTER. IBM-Z.
       INPUT-OUTPUT SECTION.
       FILE-CONTROL.
           SELECT RPT-OUT ASSIGN TO URPT
               ORGANIZATION IS SEQUENTIAL.
       DATA DIVISION.
       FILE SECTION.
       FD  RPT-OUT.
       01  RPT-LINE PIC X(132).
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
       COPY BKRCN.
       PROCEDURE DIVISION.
       0000-MAIN.
           PERFORM 0500-INIT
           PERFORM 1000-PROCESS
           PERFORM 8000-MAP-SQL
           PERFORM 9000-TERM
           GOBACK
           .
       0500-INIT.
           OPEN OUTPUT RPT-OUT
           MOVE 'RECON EXCEPTION REPORT' TO RPT-LINE
           WRITE RPT-LINE
           EXIT.
       1000-PROCESS.
           EXEC SQL DECLARE C-RPT CURSOR FOR
             SELECT LOC_ID, REASON, COUNT(*), SUM(AMOUNT)
               FROM BANK_RECON_XCPT WHERE STATUS = 'O'
               GROUP BY LOC_ID, REASON
           END-EXEC
           EXEC SQL OPEN C-RPT END-EXEC
           PERFORM UNTIL SQLCODE NOT = 0
              EXEC SQL FETCH C-RPT INTO :RCN-LOC-ID, :RCN-REASON,
                   :RCN-XCPT-ID, :RCN-AMT
              END-EXEC
              IF SQLCODE = 0
                 STRING RCN-LOC-ID DELIMITED BY SIZE
                        RCN-REASON DELIMITED BY SIZE
                   INTO RPT-LINE
                 WRITE RPT-LINE
              END-IF
           END-PERFORM
           EXEC SQL CLOSE C-RPT END-EXEC
           CLOSE RPT-OUT
           MOVE 0 TO WS-RC
           EXIT.
       8000-MAP-SQL.
           MOVE SQLCODE TO WS-SQLCODE-DISP
           EVALUATE SQLCODE
             WHEN 0
                MOVE 0 TO WS-RC
             WHEN +100
                MOVE 4 TO WS-RC
             WHEN -803
                MOVE 12 TO WS-RC
                SET BK-E-DUPGEN TO TRUE
             WHEN -911
             WHEN -913
                MOVE 8 TO WS-RC
                MOVE 'DEADLOCK-RETRY' TO BK-OP-MSG
             WHEN OTHER
                MOVE 16 TO WS-RC
           END-EVALUATE
           MOVE WS-RC TO RETURN-CODE
           EXIT.
       9000-TERM.
           MOVE WS-RC TO RETURN-CODE
           EXIT.
