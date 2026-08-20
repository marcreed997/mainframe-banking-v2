      *****************************************************************
      * BKINT - Interest accrual stub (batch only)
      *****************************************************************
       01  BK-INT-ACC.
           05  INT-ACC-NO           PIC X(6).
           05  INT-BAL              PIC S9(13)V99 COMP-3.
           05  INT-RATE-BP          PIC 9(5).
           05  INT-ACCRUAL          PIC S9(13)V99 COMP-3.
           05  INT-CYCLE-DTE        PIC X(10).
