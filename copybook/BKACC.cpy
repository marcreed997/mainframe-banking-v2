      *****************************************************************
      * BKACC - Account master (DDA) layout
      *****************************************************************
       01  BK-ACCOUNT.
           05  ACC-NO               PIC X(6).
           05  ACC-CIF-NO           PIC X(10).
           05  ACC-NAME             PIC X(30).
           05  ACC-STATUS           PIC X.
               88  ACC-OPEN         VALUE 'O'.
               88  ACC-CLOSED       VALUE 'C'.
               88  ACC-DORMANT      VALUE 'D'.
               88  ACC-FROZEN       VALUE 'F'.
               88  ACC-NSF-WATCH    VALUE 'N'.
           05  ACC-BRANCH           PIC X(6).
           05  ACC-REGION           PIC X(4).
           05  ACC-BAL              PIC S9(13)V99 COMP-3.
           05  ACC-HOLD-AMT         PIC S9(13)V99 COMP-3.
           05  ACC-AVAIL            PIC S9(13)V99 COMP-3.
           05  ACC-OD-LIMIT         PIC S9(13)V99 COMP-3.
           05  ACC-LAST-POST-TS     PIC X(26).
           05  ACC-OPEN-DTE         PIC X(10).
           05  ACC-CCY              PIC X(3) VALUE 'USD'.
