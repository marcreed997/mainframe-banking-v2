      *****************************************************************
      * BKHLD - Funds hold / release
      *****************************************************************
       01  BK-HOLD.
           05  HLD-ID               PIC X(12).
           05  HLD-ACC-NO           PIC X(6).
           05  HLD-AMT              PIC S9(13)V99 COMP-3.
           05  HLD-REASON           PIC X(20).
           05  HLD-EXP-DTE          PIC X(10).
           05  HLD-STATUS           PIC X.
               88  HLD-ACTIVE       VALUE 'A'.
               88  HLD-REL          VALUE 'R'.
               88  HLD-EXP          VALUE 'E'.
           05  HLD-TYPE             PIC X(8).
               88  HLD-LEVY         VALUE 'LEVY    '.
               88  HLD-GARNISH      VALUE 'GARNISH '.
               88  HLD-CARD         VALUE 'CARD    '.
               88  HLD-REGCC        VALUE 'REGCC   '.

