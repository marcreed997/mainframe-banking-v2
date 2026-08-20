      *****************************************************************
      * BKUCP - Unclaimed property / escheat by state
      *****************************************************************
       01  BK-UCP.
           05  UCP-ACC-NO           PIC X(6).
           05  UCP-CIF-NO           PIC X(10).
           05  UCP-STATE            PIC X(2).
           05  UCP-DORM-YEARS       PIC 9(2).
           05  UCP-LAST-CUST-DTE    PIC X(10).
           05  UCP-BAL              PIC S9(13)V99 COMP-3.
           05  UCP-NOTICE-DTE       PIC X(10).
           05  UCP-STATUS           PIC X.
               88  UCP-WATCH        VALUE 'W'.
               88  UCP-NOTICED      VALUE 'N'.
               88  UCP-REMITTED     VALUE 'R'.
               88  UCP-REACTIV      VALUE 'A'.
           05  UCP-REPORT-YEAR      PIC 9(4).
