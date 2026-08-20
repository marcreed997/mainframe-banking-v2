      *****************************************************************
      * PROGRAM-ID : BKOFC01
      * TITLE      : OFAC batch name-screen against lab SDN file
      * Synthetic lab system. Not a real bank. Educational / portfolio only.
      * Score >= threshold -> HIT block; 70-84 review queue; else clear.
      *****************************************************************
       IDENTIFICATION DIVISION.
       PROGRAM-ID. BKOFC01.
       AUTHOR. LAB-V2.
       DATE-WRITTEN. 2026-08-20.
       ENVIRONMENT DIVISION.
       CONFIGURATION SECTION.
       SOURCE-COMPUTER. IBM-Z.
       OBJECT-COMPUTER. IBM-Z.
       INPUT-OUTPUT SECTION.
       FILE-CONTROL.
           SELECT SDN-FILE ASSIGN TO USDNIN
               ORGANIZATION IS SEQUENTIAL
               FILE STATUS IS WS-FS1.
       DATA DIVISION.
       FILE SECTION.
       FD  SDN-FILE.
       01  SDN-REC                  PIC X(80).
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
       COPY BKOFAC.
       COPY BKCIF.
       01  WS-FS1                   PIC XX.
       01  WS-SDN-NAME              PIC X(80).
       01  WS-SDN-ID                PIC X(12).
       01  WS-HITS                  PIC 9(7) VALUE 0.
       01  WS-REV                   PIC 9(7) VALUE 0.

       PROCEDURE DIVISION.
       0000-MAIN.
           PERFORM 0500-OPEN
           PERFORM 1000-CIF
           PERFORM 9000-TERM
           GOBACK
           .
       0500-OPEN.
           OPEN INPUT SDN-FILE
           IF WS-FS1 = '35'
              SET BK-W-FILEWAIT TO TRUE
              MOVE 8 TO WS-RC
           END-IF
           EXIT.
       1000-CIF.
           IF WS-RC > 4 GO TO 1000-X END-IF
           EXEC SQL DECLARE C-CIF CURSOR FOR
             SELECT CIF_NO, CUSTOMER_NAME FROM BANK_CIF
           END-EXEC
           EXEC SQL OPEN C-CIF END-EXEC
           PERFORM UNTIL SQLCODE NOT = 0
              EXEC SQL FETCH C-CIF INTO :OF-CIF-NO, :OF-RAW-NAME
              END-EXEC
              IF SQLCODE = 0
                 PERFORM 2000-SCAN-SDN
              END-IF
           END-PERFORM
           EXEC SQL CLOSE C-CIF END-EXEC
           CLOSE SDN-FILE
           IF WS-HITS > 0
              MOVE 12 TO WS-RC
              MOVE 'OFAC-HITS' TO BK-OP-MSG
           END-IF
           .
       1000-X.
           EXIT.
       2000-SCAN-SDN.
           CLOSE SDN-FILE
           OPEN INPUT SDN-FILE
           MOVE 0 TO OF-SCORE
           PERFORM UNTIL WS-FS1 NOT = '00'
              READ SDN-FILE
                AT END EXIT PERFORM
              END-READ
              MOVE SDN-REC(1:12) TO WS-SDN-ID
              MOVE SDN-REC(13:68) TO WS-SDN-NAME
              PERFORM 3000-SCORE
           END-PERFORM
           EVALUATE TRUE
             WHEN OF-SCORE >= OF-THRESHOLD
                SET OF-HIT TO TRUE
                ADD 1 TO WS-HITS
                PERFORM 4000-WRITE-HIT
             WHEN OF-SCORE >= 70
                SET OF-REVIEW TO TRUE
                ADD 1 TO WS-REV
                PERFORM 4000-WRITE-HIT
             WHEN OTHER
                SET OF-CLEAR TO TRUE
           END-EVALUATE
           EXIT.
       3000-SCORE.
           MOVE 0 TO OF-SCORE
           IF OF-RAW-NAME = WS-SDN-NAME
              MOVE 100 TO OF-SCORE
           ELSE
              IF OF-RAW-NAME(1:10) = WS-SDN-NAME(1:10)
                 MOVE 80 TO OF-SCORE
              ELSE
                 IF OF-RAW-NAME(1:4) = WS-SDN-NAME(1:4)
                    MOVE 60 TO OF-SCORE
                 END-IF
              END-IF
           END-IF
           EXIT.
       4000-WRITE-HIT.
           MOVE WS-SDN-ID TO OF-SDN-ID
           EXEC SQL INSERT INTO BANK_OFAC_HIT
             (CIF_NO, RAW_NAME, SCORE, SDN_ID, LIST_NAME, STATUS,
              CHANNEL)
             VALUES (:OF-CIF-NO, :OF-RAW-NAME, :OF-SCORE, :OF-SDN-ID,
                     'SDN', :OF-HIT-IND, 'BATCH')
           END-EXEC
           PERFORM 8000-MAP-SQL
           EXIT.

       8000-MAP-SQL.
           COPY BKSQLM.
           EXIT.
       9000-TERM.
           MOVE WS-RC TO RETURN-CODE
           EXIT.
