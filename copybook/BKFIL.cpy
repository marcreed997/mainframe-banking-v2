      *****************************************************************
      * BKFIL - Inbound file register (arrived / validated / gen)
      *****************************************************************
       01  BK-FILE-CTL.
           05  FIL-LOC-ID           PIC X(8).
           05  FIL-CYCLE-DTE        PIC X(10).
           05  FIL-GEN-NO           PIC 9(4).
           05  FIL-ARRIVED-IND      PIC X.
           05  FIL-VALIDATED-IND    PIC X.
           05  FIL-HASH-DR          PIC S9(15)V99 COMP-3.
           05  FIL-HASH-CR          PIC S9(15)V99 COMP-3.
           05  FIL-REC-COUNT        PIC 9(9).
           05  FIL-DSNAME           PIC X(44).
