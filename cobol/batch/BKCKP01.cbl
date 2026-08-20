      *****************************************************************
      * PROGRAM-ID : BKCKP01
      * TITLE      : Cycle open / inhibit / close — sets tokens batch posting reads
      * Synthetic lab system. Not a real bank. Educational / portfolio only.
      * PARM=INHIBIT|ENABLE|CLOSE|OPEN
      *****************************************************************
       IDENTIFICATION DIVISION.
       PROGRAM-ID. BKCKP01.
       AUTHOR. LAB-V2.
       DATE-WRITTEN. 2026-08-20.
       ENVIRONMENT DIVISION.
       CONFIGURATION SECTION.
       SOURCE-COMPUTER. IBM-Z.
       OBJECT-COMPUTER. IBM-Z.
       INPUT-OUTPUT SECTION.
       FILE-CONTROL.
           SELECT DUMMY ASSIGN TO UDUMMY
               ORGANIZATION IS SEQUENTIAL.
       DATA DIVISION.
       FILE SECTION.
       FD  DUMMY. 01 D-REC PIC X.
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
       COPY BKCTL.
       PROCEDURE DIVISION.
       0000-MAIN.
           PERFORM 0500-INIT
           PERFORM 1000-PROCESS
           PERFORM 8000-MAP-SQL
           PERFORM 9000-TERM
           GOBACK
           .
       0500-INIT.
           ACCEPT CTL-STATUS FROM SYSIN
           EXIT.
       1000-PROCESS.
           EVALUATE CTL-STATUS
             WHEN 'INHIBIT'
                SET ONLINE-BLOCKED TO TRUE
                SET CYC-INHIBIT TO TRUE
             WHEN 'ENABLE'
                SET ONLINE-ALLOWED TO TRUE
                SET CYC-OPEN TO TRUE
             WHEN 'POSTING'
                IF CTL-ONLINE-INHIBIT NOT = 'Y'
                   SET BK-E-CICS-ACTIVE TO TRUE
                   MOVE 12 TO WS-RC
                   GO TO 1000-X
                END-IF
                SET CYC-POSTING TO TRUE
             WHEN 'CLOSE'
                IF CTL-RECON-CLOSED NOT = 'Y'
                   MOVE 8 TO WS-RC
                   MOVE 'RECON-NOT-CLOSED' TO BK-OP-MSG
                   GO TO 1000-X
                END-IF
                SET CYC-CLOSED TO TRUE
             WHEN OTHER
                MOVE 12 TO WS-RC
           END-EVALUATE
           EXEC SQL UPDATE BANK_CYCLE_CTL
             SET STATUS = :CTL-STATUS,
                 ONLINE_INHIBIT = :CTL-ONLINE-INHIBIT
           END-EXEC
           PERFORM 8000-MAP-SQL
           .
       1000-X.
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
