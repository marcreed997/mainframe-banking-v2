      *****************************************************************
      * BKSQLM - PROCEDURE snippet: SQLCODE -> RETURN-CODE contract
      *****************************************************************
           MOVE SQLCODE TO WS-SQLCODE-DISP
           EVALUATE SQLCODE
             WHEN 0
                CONTINUE
             WHEN +100
                IF WS-RC = 0
                   MOVE 4 TO WS-RC
                END-IF
             WHEN -803
                MOVE 12 TO WS-RC
                SET BK-E-DUPGEN TO TRUE
                MOVE 'BK-E-DUPGEN' TO BK-OP-MSG
             WHEN -911
             WHEN -913
                MOVE 8 TO WS-RC
                MOVE 'DEADLOCK-RETRY' TO BK-OP-MSG
             WHEN OTHER
                IF SQLCODE < 0
                   MOVE 16 TO WS-RC
                END-IF
           END-EVALUATE
           MOVE WS-RC TO RETURN-CODE
