      *****************************************************************
      * BKRST - Batch restart token
      *****************************************************************
       01  BK-RESTART.
           05  RST-CYCLE-DTE        PIC X(10).
           05  RST-LAST-TRACE       PIC X(26).
           05  RST-CHUNK-NO         PIC 9(7).
           05  RST-MODE             PIC X(8).
               88  RST-COLD         VALUE 'COLD    '.
               88  RST-WARM         VALUE 'RESTART '.
           05  RST-FORCE            PIC X.
           05  RST-COMMIT-TS        PIC X(26).
