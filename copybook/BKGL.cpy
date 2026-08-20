      *****************************************************************
      * BKGL - General ledger feed record
      *****************************************************************
       01  BK-GL-FEED.
           05  GL-CYCLE-DTE         PIC X(10).
           05  GL-ACCT              PIC X(10).
           05  GL-CCY               PIC X(3).
           05  GL-DRCR              PIC X.
           05  GL-AMT               PIC S9(13)V99 COMP-3.
           05  GL-SRC-LOC           PIC X(8).
           05  GL-NARR              PIC X(40).
