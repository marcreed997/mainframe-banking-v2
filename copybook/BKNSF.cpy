      *****************************************************************
      * BKNSF - NSF / overdraft decision
      *****************************************************************
       01  BK-NSF.
           05  NSF-ACC-NO           PIC X(6).
           05  NSF-REQ-AMT          PIC S9(13)V99 COMP-3.
           05  NSF-AVAIL            PIC S9(13)V99 COMP-3.
           05  NSF-OD-LIMIT         PIC S9(13)V99 COMP-3.
           05  NSF-FEE              PIC S9(7)V99 COMP-3.
           05  NSF-DECISION         PIC X.
               88  NSF-PAY          VALUE 'P'.
               88  NSF-RETURN       VALUE 'R'.
               88  NSF-WATCH        VALUE 'W'.
