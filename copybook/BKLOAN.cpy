      *****************************************************************
      * BKLOAN - Instalment loan payment application
      *****************************************************************
       01  BK-LOAN.
           05  LN-NOTE-NO           PIC X(10).
           05  LN-ACC-NO            PIC X(6).
           05  LN-PRIN-BAL          PIC S9(13)V99 COMP-3.
           05  LN-INT-ACCRUED       PIC S9(13)V99 COMP-3.
           05  LN-ESCROW-BAL        PIC S9(13)V99 COMP-3.
           05  LN-LATE-FEE-DUE      PIC S9(7)V99 COMP-3.
           05  LN-RATE-BP           PIC 9(5).
           05  LN-PMT-AMT           PIC S9(13)V99 COMP-3.
           05  LN-DUE-DTE           PIC X(10).
           05  LN-DAYS-LATE         PIC 9(3).
           05  LN-STATUS            PIC X.
               88  LN-CURRENT       VALUE 'C'.
               88  LN-DLQ           VALUE 'D'.
               88  LN-CHGOFF        VALUE 'O'.
               88  LN-PAIDOFF       VALUE 'P'.
           05  LN-APPLY-LATE        PIC S9(13)V99 COMP-3.
           05  LN-APPLY-INT         PIC S9(13)V99 COMP-3.
           05  LN-APPLY-ESC         PIC S9(13)V99 COMP-3.
           05  LN-APPLY-PRIN        PIC S9(13)V99 COMP-3.
           05  LN-UNAPP              PIC S9(13)V99 COMP-3.
