      *****************************************************************
      * BKTRL - Location trailer / hash totals
      *****************************************************************
       01  BK-TRAILER.
           05  TRL-LOC-ID           PIC X(8).
           05  TRL-CYCLE-DTE        PIC X(10).
           05  TRL-REC-COUNT        PIC 9(9).
           05  TRL-HASH-DR          PIC S9(15)V99 COMP-3.
           05  TRL-HASH-CR          PIC S9(15)V99 COMP-3.
           05  TRL-CUTOFF-TS        PIC X(26).
           05  TRL-GEN-NO           PIC 9(4).
