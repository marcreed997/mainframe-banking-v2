      *****************************************************************
      * PROGRAM-ID : BKRCN02
      * TITLE      : ATM vs hub — orphan reversal and unmatched dispense
      * Synthetic lab system. Not a real bank. Educational / portfolio only.
      * Pairs ATM_ADVICE to JOURNAL; ATM-NET only.
      *****************************************************************
       IDENTIFICATION DIVISION.
       PROGRAM-ID. BKRCN02.
       AUTHOR. LAB-V2.
       DATE-WRITTEN. 2026-08-20.
       ENVIRONMENT DIVISION.
       CONFIGURATION SECTION.
       SOURCE-COMPUTER. IBM-Z.
       OBJECT-COMPUTER. IBM-Z.
       INPUT-OUTPUT SECTION.
       FILE-CONTROL.
           SELECT ATM-FILE ASSIGN TO UATMIN
               ORGANIZATION IS SEQUENTIAL.
       DATA DIVISION.
       FILE SECTION.
       FD  ATM-FILE.
       01  ATM-REC PIC X(200).
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
       COPY BKATM.
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
           OPEN INPUT ATM-FILE
           EXIT.
       1000-PROCESS.
           EXEC SQL DECLARE C-OREV CURSOR FOR
             SELECT A.TRACE_ID FROM BANK_ATM_ADVICE A
              WHERE A.REV_OF IS NOT NULL
                AND NOT EXISTS (
                  SELECT 1 FROM BANK_ATM_ADVICE O
                   WHERE O.TRACE_ID = A.REV_OF)
           END-EXEC
           EXEC SQL OPEN C-OREV END-EXEC
           PERFORM UNTIL SQLCODE NOT = 0
              EXEC SQL FETCH C-OREV INTO :ATM-TRACE END-EXEC
              IF SQLCODE = 0
                 SET RSN-ORPH-REV TO TRUE
                 EXEC SQL INSERT INTO BANK_RECON_XCPT
                   (LOC_ID, TRACE_ID, REASON, STATUS)
                   VALUES ('ATMNET', :ATM-TRACE, 'ORPHAN-REV', 'O')
                 END-EXEC
                 MOVE 4 TO WS-RC
              END-IF
           END-PERFORM
           EXEC SQL CLOSE C-OREV END-EXEC
           CLOSE ATM-FILE
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
