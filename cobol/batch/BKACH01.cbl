      *****************************************************************
      * PROGRAM-ID : BKACH01
      * TITLE      : NACHA inbound parse — types 1/5/6/8/9, SEC routing, batch balance
      * Synthetic lab system. Not a real bank. Educational / portfolio only.
      * Does not post DDA. Writes BANK_ACH_*. Prenote (tx 23/28/33/38) zero-dollar only.
      *****************************************************************
       IDENTIFICATION DIVISION.
       PROGRAM-ID. BKACH01.
       AUTHOR. LAB-V2.
       DATE-WRITTEN. 2026-08-20.
       ENVIRONMENT DIVISION.
       CONFIGURATION SECTION.
       SOURCE-COMPUTER. IBM-Z.
       OBJECT-COMPUTER. IBM-Z.
       INPUT-OUTPUT SECTION.
       FILE-CONTROL.
           SELECT ACH-FILE ASSIGN TO UACHIN
               ORGANIZATION IS SEQUENTIAL
               FILE STATUS IS WS-FS1.
       DATA DIVISION.
       FILE SECTION.
       FD  ACH-FILE.
       01  ACH-REC                  PIC X(94).
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
       01  WS-FS1                   PIC XX.
       01  WS-REC-TYPE              PIC X.
       01  WS-EXPECT-TYPE           PIC X VALUE '1'.
       01  WS-BATCH-OPEN            PIC X VALUE 'N'.
       01  WS-FILE-DR               PIC S9(13)V99 COMP-3 VALUE 0.
       01  WS-FILE-CR               PIC S9(13)V99 COMP-3 VALUE 0.
       01  WS-FILE-CNT              PIC 9(8) VALUE 0.
       01  WS-FILE-HASH             PIC 9(12) VALUE 0.
       01  WS-BATCH-DR              PIC S9(13)V99 COMP-3 VALUE 0.
       01  WS-BATCH-CR              PIC S9(13)V99 COMP-3 VALUE 0.
       01  WS-BATCH-CNT             PIC 9(6) VALUE 0.
       01  WS-BATCH-HASH            PIC 9(10) VALUE 0.

       PROCEDURE DIVISION.
       0000-MAIN.
           PERFORM 0500-OPEN
           PERFORM 1000-READ-LOOP
           PERFORM 7000-FILE-CTL
           PERFORM 9000-TERM
           GOBACK
           .
       0500-OPEN.
           ACCEPT ACH-WS-WINDOW FROM SYSIN
           OPEN INPUT ACH-FILE
           IF WS-FS1 = '35'
              SET BK-W-FILEWAIT TO TRUE
              MOVE 'BK-W-FILEWAIT' TO BK-OP-MSG
              MOVE 8 TO WS-RC
           END-IF
           EXIT.
       1000-READ-LOOP.
           IF WS-RC > 4 GO TO 1000-X END-IF
           PERFORM UNTIL WS-FS1 NOT = '00' AND WS-FS1 NOT = SPACES
              READ ACH-FILE
                AT END EXIT PERFORM
              END-READ
              IF WS-FS1 = '00'
                 MOVE ACH-REC(1:1) TO WS-REC-TYPE
                 EVALUATE WS-REC-TYPE
                   WHEN '1' PERFORM 2100-FILE-HDR
                   WHEN '5' PERFORM 2500-BATCH-HDR
                   WHEN '6' PERFORM 2600-ENTRY
                   WHEN '7' PERFORM 2700-ADDENDA
                   WHEN '8' PERFORM 2800-BATCH-CTL
                   WHEN '9' PERFORM 2900-FILE-CTL-REC
                   WHEN OTHER
                      MOVE 12 TO WS-RC
                      MOVE 'ACH-BAD-TYPE' TO BK-OP-MSG
                 END-EVALUATE
              END-IF
              IF WS-RC >= 12
                 EXIT PERFORM
              END-IF
           END-PERFORM
           .
       1000-X.
           EXIT.
       2100-FILE-HDR.
           MOVE ACH-REC TO ACH-FILE-HDR
           IF ACH-H1-RECSIZE NOT = 94
              MOVE 12 TO WS-RC
              SET BK-E-HASH TO TRUE
              MOVE 'BK-E-HASH RECSIZE' TO BK-OP-MSG
           END-IF
           IF ACH-H1-BLOCKING NOT = 10
              MOVE 4 TO WS-RC
              MOVE 'BLOCKING-NOT-10' TO BK-OP-MSG
           END-IF
           EXIT.
       2500-BATCH-HDR.
           IF WS-BATCH-OPEN = 'Y'
              MOVE 12 TO WS-RC
              MOVE 'BATCH-NOT-CLOSED' TO BK-OP-MSG
              GO TO 2500-X
           END-IF
           MOVE ACH-REC TO ACH-BATCH-HDR
           IF NOT SEC-PPD AND NOT SEC-CCD AND NOT SEC-WEB
              AND NOT SEC-TEL AND NOT SEC-CTX
              MOVE 12 TO WS-RC
              MOVE 'SEC-UNSUPPORTED' TO BK-OP-MSG
              GO TO 2500-X
           END-IF
           MOVE 'Y' TO WS-BATCH-OPEN
           MOVE 0 TO WS-BATCH-DR WS-BATCH-CR WS-BATCH-CNT WS-BATCH-HASH
           ADD 1 TO ACH-WS-BATCHES
           .
       2500-X.
           EXIT.
       2600-ENTRY.
           IF WS-BATCH-OPEN NOT = 'Y'
              MOVE 12 TO WS-RC
              MOVE 'ENTRY-NO-BATCH' TO BK-OP-MSG
              GO TO 2600-X
           END-IF
           MOVE ACH-REC TO ACH-ENTRY
           IF TX-PRE-DR OR TX-PRE-CR
              IF ACH-E6-AMT NOT = 0
                 MOVE 12 TO WS-RC
                 MOVE 'PRENOTE-MUST-ZERO' TO BK-OP-MSG
                 GO TO 2600-X
              END-IF
           END-IF
           IF TX-CK-DR OR TX-SAV-DR
              ADD ACH-E6-AMT TO WS-BATCH-DR
              ADD ACH-E6-AMT TO WS-FILE-DR
           ELSE
              ADD ACH-E6-AMT TO WS-BATCH-CR
              ADD ACH-E6-AMT TO WS-FILE-CR
           END-IF
           ADD 1 TO WS-BATCH-CNT
           ADD 1 TO WS-FILE-CNT
           ADD ACH-E6-RDFID TO WS-BATCH-HASH
           ADD ACH-E6-RDFID TO WS-FILE-HASH
           EXEC SQL INSERT INTO BANK_ACH_ENTRY
             (ACH_TRACE, BATCH_NO, CYCLE_DTE, TX_CODE, RDFID, DDA,
              AMOUNT, INDIV_NAME, SEC_CODE, STATUS)
             VALUES (:ACH-E6-TRACE, :ACH-H5-BATCH-NO, CURRENT DATE,
                     :ACH-E6-TX-CODE, :ACH-E6-RDFID, :ACH-E6-DDA,
                     :ACH-E6-AMT, :ACH-E6-INDIV-NAME, :ACH-H5-SEC, 'R')
           END-EXEC
           PERFORM 8000-MAP-SQL
           .
       2600-X.
           EXIT.
       2700-ADDENDA.
           EXIT.
       2800-BATCH-CTL.
           MOVE ACH-REC TO ACH-BATCH-CTL
           IF ACH-C8-ENTRY-CNT NOT = WS-BATCH-CNT
              OR ACH-C8-TOT-DR NOT = WS-BATCH-DR
              OR ACH-C8-TOT-CR NOT = WS-BATCH-CR
              SET BK-E-HASH TO TRUE
              MOVE 'BK-E-HASH BATCH' TO BK-OP-MSG
              MOVE 12 TO WS-RC
              GO TO 2800-X
           END-IF
           IF ACH-MIXED AND WS-BATCH-DR NOT = WS-BATCH-CR
              MOVE 4 TO WS-RC
              MOVE 'MIXED-UNBALANCED-OK' TO BK-OP-MSG
           END-IF
           EXEC SQL INSERT INTO BANK_ACH_BATCH
             (BATCH_NO, CYCLE_DTE, SEC_CODE, CO_ID, SERV_CLASS,
              ENTRY_CNT, HASH_TOTAL, TOT_DR, TOT_CR, WINDOW, STATUS)
             VALUES (:ACH-H5-BATCH-NO, CURRENT DATE, :ACH-H5-SEC,
                     :ACH-H5-CO-ID, :ACH-H5-SERV-CLASS, :WS-BATCH-CNT,
                     :WS-BATCH-HASH, :WS-BATCH-DR, :WS-BATCH-CR,
                     :ACH-WS-WINDOW, 'V')
           END-EXEC
           PERFORM 8000-MAP-SQL
           MOVE 'N' TO WS-BATCH-OPEN
           .
       2800-X.
           EXIT.
       2900-FILE-CTL-REC.
           MOVE ACH-REC TO ACH-FILE-CTL
           MOVE ACH-C9-TOT-DR TO ACH-WS-DR
           MOVE ACH-C9-TOT-CR TO ACH-WS-CR
           EXIT.
       7000-FILE-CTL.
           IF WS-RC >= 12 GO TO 7000-X END-IF
           IF WS-BATCH-OPEN = 'Y'
              MOVE 12 TO WS-RC
              MOVE 'FILE-ENDED-OPEN-BATCH' TO BK-OP-MSG
              GO TO 7000-X
           END-IF
           IF ACH-C9-ENTRY-CNT NOT = WS-FILE-CNT
              OR ACH-C9-TOT-DR NOT = WS-FILE-DR
              OR ACH-C9-TOT-CR NOT = WS-FILE-CR
              SET BK-E-HASH TO TRUE
              MOVE 'BK-E-HASH FILE' TO BK-OP-MSG
              MOVE 12 TO WS-RC
           END-IF
           CLOSE ACH-FILE
           MOVE WS-RC TO RETURN-CODE
           .
       7000-X.
           EXIT.

       8000-MAP-SQL.
           COPY BKSQLM.
           EXIT.
       9000-TERM.
           MOVE WS-RC TO RETURN-CODE
           EXIT.
