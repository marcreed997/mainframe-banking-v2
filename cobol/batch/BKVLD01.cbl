      *****************************************************************
      * PROGRAM-ID : BKVLD01
      * TITLE      : Inbound location validate — header LOC, body hash vs trailer
      * Synthetic lab system. Not a real bank. Educational / portfolio only.
      * RC=8 file wait; RC=12 hash/loc mismatch. Does not post.
      *****************************************************************
       IDENTIFICATION DIVISION.
       PROGRAM-ID. BKVLD01.
       AUTHOR. LAB-V2.
       DATE-WRITTEN. 2026-08-20.
       ENVIRONMENT DIVISION.
       CONFIGURATION SECTION.
       SOURCE-COMPUTER. IBM-Z.
       OBJECT-COMPUTER. IBM-Z.
       INPUT-OUTPUT SECTION.
       FILE-CONTROL.
           SELECT EXT-FILE ASSIGN TO UTEXTIN
               ORGANIZATION IS SEQUENTIAL
               FILE STATUS IS WS-FS1.
           SELECT CTL-FILE ASSIGN TO UCTL
               ORGANIZATION IS SEQUENTIAL
               FILE STATUS IS WS-FS2.
       DATA DIVISION.
       FILE SECTION.
       FD  EXT-FILE.
       01  EXT-REC                  PIC X(200).
       FD  CTL-FILE.
       01  CTL-REC                  PIC X(80).
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
       COPY BKTRN.
       COPY BKTRL.
       COPY BKFIL.
       01 WS-FS1 PIC XX. 01 WS-FS2 PIC XX.
       01 WS-CNT PIC 9(9) VALUE 0.
       01 WS-HDR-LOC PIC X(8).
       01 WS-SUM-DR PIC S9(15)V99 COMP-3 VALUE 0.
       01 WS-SUM-CR PIC S9(15)V99 COMP-3 VALUE 0.
       01 WS-EXPECT-LOC PIC X(8).
       PROCEDURE DIVISION.
       0000-MAIN.
           PERFORM 0500-INIT
           PERFORM 1000-PROCESS
           PERFORM 8000-MAP-SQL
           PERFORM 9000-TERM
           GOBACK
           .
       0500-INIT.
           ACCEPT WS-EXPECT-LOC FROM SYSIN
           OPEN INPUT EXT-FILE
           IF WS-FS1 = '35'
              SET BK-W-FILEWAIT TO TRUE
              MOVE 8 TO WS-RC
              MOVE 'BK-W-FILEWAIT' TO BK-OP-MSG
              GO TO 0500-X
           END-IF
           OPEN OUTPUT CTL-FILE
           .
       0500-X.
           EXIT.
       1000-PROCESS.
           IF WS-RC > 4
              GO TO 1000-X
           END-IF
           READ EXT-FILE INTO BK-EXTRACT-REC
             AT END MOVE 4 TO WS-RC
                    SET BK-W-EMPTY TO TRUE
                    GO TO 1000-X
           END-READ
           IF XTR-REC-TYPE NOT = 'H'
              MOVE 12 TO WS-RC
              SET BK-E-LOCMISMATCH TO TRUE
              GO TO 1000-X
           END-IF
           MOVE XTR-LOC-ID TO WS-HDR-LOC
           IF WS-HDR-LOC NOT = WS-EXPECT-LOC
              SET BK-E-LOCMISMATCH TO TRUE
              MOVE 12 TO WS-RC
              GO TO 1000-X
           END-IF
           PERFORM UNTIL XTR-REC-TYPE = 'T' OR WS-FS1 NOT = '00'
              READ EXT-FILE INTO BK-EXTRACT-REC
                AT END EXIT PERFORM
              END-READ
              IF XTR-BODY
                 ADD 1 TO WS-CNT
                 IF XTR-DRCR = 'D'
                    ADD XTR-AMT TO WS-SUM-DR
                 ELSE
                    ADD XTR-AMT TO WS-SUM-CR
                 END-IF
                 IF XTR-LOC-ID NOT = WS-HDR-LOC
                    SET BK-E-LOCMISMATCH TO TRUE
                    MOVE 12 TO WS-RC
                 END-IF
              END-IF
           END-PERFORM
           IF XTR-TRL
              IF TRL-REC-COUNT OF BK-TRAILER NOT = WS-CNT
                 OR TRL-HASH-DR NOT = WS-SUM-DR
                 OR TRL-HASH-CR NOT = WS-SUM-CR
                    SET BK-E-HASH TO TRUE
                    MOVE 12 TO WS-RC
              END-IF
           END-IF
           IF WS-RC = 0
              EXEC SQL UPDATE BANK_LOCATION_FILE_CTL
                SET VALIDATED_IND = 'Y',
                    REC_COUNT = :WS-CNT,
                    HASH_DR = :WS-SUM-DR,
                    HASH_CR = :WS-SUM-CR
                WHERE LOC_ID = :WS-HDR-LOC
                  AND CYCLE_DTE = :XTR-CYCLE-DTE
              END-EXEC
              PERFORM 8000-MAP-SQL
           END-IF
           CLOSE EXT-FILE
           CLOSE CTL-FILE
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
