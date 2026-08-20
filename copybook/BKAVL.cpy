      *****************************************************************
      * BKAVL - Funds availability (Reg CC lab stub)
      *****************************************************************
       01  BK-AVAIL-SCHED.
           05  AVL-ACC-NO           PIC X(6).
           05  AVL-TRACE            PIC X(26).
           05  AVL-AMT              PIC S9(13)V99 COMP-3.
           05  AVL-DEP-DTE          PIC X(10).
           05  AVL-AVAIL-DTE        PIC X(10).
           05  AVL-HOLD-DAYS        PIC 9(2).
           05  AVL-CLASS            PIC X(8).
               88  AVL-CASH         VALUE 'CASH    '.
               88  AVL-ONUS         VALUE 'ONUS    '.
               88  AVL-LOCAL        VALUE 'LOCAL   '.
               88  AVL-NLOCAL       VALUE 'NLOCAL  '.
               88  AVL-NEXTDAY      VALUE 'NEXTDAY '.
               88  AVL-WIRE         VALUE 'WIRE    '.
               88  AVL-ACH          VALUE 'ACH     '.
           05  AVL-REASON           PIC X(16).
               88  AVL-NEW-ACCT     VALUE 'NEW-ACCOUNT'.
               88  AVL-LARGE        VALUE 'LARGE-DEP'.
               88  AVL-REDEPOSIT    VALUE 'REDEPOSIT'.
               88  AVL-ROUTINE      VALUE 'ROUTINE'.
           05  AVL-STATUS           PIC X.
               88  AVL-HELD         VALUE 'H'.
               88  AVL-RELEASED     VALUE 'R'.
