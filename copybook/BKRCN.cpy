      *****************************************************************
      * BKRCN - Reconciliation exception
      *****************************************************************
       01  BK-RECON-XCPT.
           05  RCN-XCPT-ID          PIC 9(9).
           05  RCN-CYCLE-DTE        PIC X(10).
           05  RCN-LOC-ID           PIC X(8).
           05  RCN-TRACE-ID         PIC X(26).
           05  RCN-ACC-NO           PIC X(6).
           05  RCN-REASON           PIC X(16).
               88  RSN-UNMATCH-LOC  VALUE 'UNMATCH-LOC'.
               88  RSN-UNMATCH-HUB  VALUE 'UNMATCH-HUB'.
               88  RSN-DUP-TRACE    VALUE 'DUP-TRACE'.
               88  RSN-HASH         VALUE 'HASH-FAIL'.
               88  RSN-CUTOFF       VALUE 'CUTOFF'.
               88  RSN-ORPH-REV     VALUE 'ORPHAN-REV'.
               88  RSN-LOCMIS       VALUE 'LOC-MISMATCH'.
           05  RCN-AMT              PIC S9(13)V99 COMP-3.
           05  RCN-STATUS           PIC X.
               88  XCPT-OPEN        VALUE 'O'.
               88  XCPT-RECYCLED    VALUE 'R'.
               88  XCPT-FORCED      VALUE 'F'.
