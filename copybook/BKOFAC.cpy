      *****************************************************************
      * BKOFAC - SDN / OFAC name-screen work area (lab stub)
      *****************************************************************
       01  BK-OFAC-NAME.
           05  OF-RAW-NAME          PIC X(80).
           05  OF-TOKEN-1           PIC X(20).
           05  OF-TOKEN-2           PIC X(20).
           05  OF-TOKEN-3           PIC X(20).
           05  OF-SOUNDEX           PIC X(4).
           05  OF-SCORE             PIC 9(3).
           05  OF-THRESHOLD         PIC 9(3) VALUE 85.
           05  OF-HIT-IND           PIC X.
               88  OF-CLEAR         VALUE 'N'.
               88  OF-HIT           VALUE 'Y'.
               88  OF-REVIEW        VALUE 'R'.
           05  OF-SDN-ID            PIC X(12).
           05  OF-LIST              PIC X(8).
               88  OF-SDN           VALUE 'SDN     '.
               88  OF-SSI           VALUE 'SSI     '.
               88  OF-FSE           VALUE 'FSE     '.
           05  OF-CIF-NO            PIC X(10).
           05  OF-CHANNEL           PIC X(8).
