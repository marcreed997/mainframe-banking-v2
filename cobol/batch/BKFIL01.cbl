      *****************************************************************
      * PROGRAM-ID : BKFIL01
      * TITLE      : File register — catalog inbound generation; detect duplicate gen
      * Synthetic lab system. Not a real bank. Educational / portfolio only.
      * Second arrival of same LOC+CYCLE+GEN -> RC=8 DUP-GEN, no validate.
      *****************************************************************
       IDENTIFICATION DIVISION.
       PROGRAM-ID. BKFIL01.
       AUTHOR. LAB-V2.
       DATE-WRITTEN. 2026-08-20.
       ENVIRONMENT DIVISION.
       CONFIGURATION SECTION.
       SOURCE-COMPUTER. IBM-Z.
       OBJECT-COMPUTER. IBM-Z.
       INPUT-OUTPUT SECTION.
       FILE-CONTROL.
           SELECT REG-FILE ASSIGN TO UREG
               ORGANIZATION IS SEQUENTIAL
               FILE STATUS IS WS-FS1.
       DATA DIVISION.
       FILE SECTION.
       FD  REG-FILE.
       01  REG-REC PIC X(80).
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
       COPY BKFIL.
       01 WS-FS1 PIC XX VALUE '00'.
       PROCEDURE DIVISION.
       0000-MAIN.
           PERFORM 0500-INIT
           PERFORM 1000-PROCESS
           PERFORM 8000-MAP-SQL
           PERFORM 9000-TERM
           GOBACK
           .
       0500-INIT.
           OPEN INPUT REG-FILE
           EXIT.
       1000-PROCESS.
           ACCEPT FIL-LOC-ID FROM SYSIN
           EXEC SQL SELECT GEN_NO, ARRIVED_IND
             INTO :FIL-GEN-NO, :FIL-ARRIVED-IND
             FROM BANK_LOCATION_FILE_CTL
            WHERE LOC_ID = :FIL-LOC-ID
              AND CYCLE_DTE = :FIL-CYCLE-DTE
           END-EXEC
           IF SQLCODE = 0 AND FIL-ARRIVED-IND = 'Y'
              SET BK-E-DUPGEN TO TRUE
              MOVE 8 TO WS-RC
              GO TO 1000-X
           END-IF
           EXEC SQL
             INSERT INTO BANK_LOCATION_FILE_CTL
               (LOC_ID, CYCLE_DTE, GEN_NO, ARRIVED_IND, VALIDATED_IND)
             VALUES (:FIL-LOC-ID, :FIL-CYCLE-DTE, :FIL-GEN-NO, 'Y', 'N')
           END-EXEC
           IF SQLCODE = -803
              SET BK-E-DUPGEN TO TRUE
              MOVE 8 TO WS-RC
           END-IF
           PERFORM 8000-MAP-SQL
           CLOSE REG-FILE
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
