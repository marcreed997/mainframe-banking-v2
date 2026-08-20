      *****************************************************************
      * PROGRAM-ID : BKGL01
      * TITLE      : GL extract — refuses unless RECON_CLOSED=Y (out-of-order guard)
      * Synthetic lab system. Not a real bank. Educational / portfolio only.
      * Writes BANK_GL_FEED by location net.
      *****************************************************************
       IDENTIFICATION DIVISION.
       PROGRAM-ID. BKGL01.
       AUTHOR. LAB-V2.
       DATE-WRITTEN. 2026-08-20.
       ENVIRONMENT DIVISION.
       CONFIGURATION SECTION.
       SOURCE-COMPUTER. IBM-Z.
       OBJECT-COMPUTER. IBM-Z.
       INPUT-OUTPUT SECTION.
       FILE-CONTROL.
           SELECT GL-OUT ASSIGN TO UGLOUT
               ORGANIZATION IS SEQUENTIAL.
       DATA DIVISION.
       FILE SECTION.
       FD  GL-OUT.
       01  GL-REC PIC X(120).
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
       COPY BKGL.
       COPY BKCTL.
       01 WS-NET PIC S9(15)V99 COMP-3.
       PROCEDURE DIVISION.
       0000-MAIN.
           PERFORM 0500-INIT
           PERFORM 1000-PROCESS
           PERFORM 8000-MAP-SQL
           PERFORM 9000-TERM
           GOBACK
           .
       0500-INIT.
           EXEC SQL SELECT RECON_CLOSED INTO :CTL-RECON-CLOSED
             FROM BANK_CYCLE_CTL FETCH FIRST 1 ROW ONLY
           END-EXEC
           IF CTL-RECON-CLOSED NOT = 'Y'
              MOVE 8 TO WS-RC
              MOVE 'RECON-NOT-CLOSED' TO BK-OP-MSG
           END-IF
           OPEN OUTPUT GL-OUT
           EXIT.
       1000-PROCESS.
           IF WS-RC > 4 GO TO 1000-X END-IF
           EXEC SQL DECLARE C-GL CURSOR FOR
             SELECT LOC_ID,
                    SUM(CASE WHEN DR_CR='D' THEN AMOUNT ELSE -AMOUNT END)
               FROM BANK_JOURNAL
              WHERE CYCLE_DTE = :CTL-CYCLE-DTE AND POSTED_IND = 'Y'
              GROUP BY LOC_ID
           END-EXEC
           EXEC SQL OPEN C-GL END-EXEC
           PERFORM UNTIL SQLCODE NOT = 0
              EXEC SQL FETCH C-GL INTO :GL-SRC-LOC, :WS-NET END-EXEC
              IF SQLCODE = 0
                 MOVE WS-NET TO GL-AMT
                 MOVE '1000-DDA' TO GL-ACCT
                 WRITE GL-REC FROM BK-GL-FEED
                 EXEC SQL INSERT INTO BANK_GL_FEED
                   (CYCLE_DTE, GL_ACCT, CCY, DR_CR, AMOUNT, SRC_LOC)
                   VALUES (:CTL-CYCLE-DTE, :GL-ACCT, 'USD',
                           CASE WHEN :WS-NET >= 0 THEN 'D' ELSE 'C' END,
                           :WS-NET, :GL-SRC-LOC)
                 END-EXEC
              END-IF
           END-PERFORM
           EXEC SQL CLOSE C-GL END-EXEC
           CLOSE GL-OUT
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
