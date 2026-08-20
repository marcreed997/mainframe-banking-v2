      *****************************************************************
      * BKLOC - Location / region / branch identity
      *****************************************************************
       01  BK-LOCATION.
           05  BK-LOC-ID            PIC X(8).
               88  LOC-HQ           VALUE 'HQ      '.
               88  LOC-EAST         VALUE 'RGNEAST '.
               88  LOC-WEST         VALUE 'RGNWEST '.
               88  LOC-ATM          VALUE 'ATMNET  '.
               88  LOC-CORR         VALUE 'CORRBANK'.
           05  BK-REGION            PIC X(4).
               88  RGN-HQ           VALUE 'HQ  '.
               88  RGN-E            VALUE 'EAST'.
               88  RGN-W            VALUE 'WEST'.
               88  RGN-SW           VALUE 'SWCH'.
           05  BK-BRANCH-NO         PIC X(6).
           05  BK-TERM-ID           PIC X(8).
           05  BK-TELLER-ID         PIC X(8).
           05  BK-CHANNEL           PIC X(8).
               88  CH-TELLER        VALUE 'TELLER  '.
               88  CH-ATM           VALUE 'ATM     '.
               88  CH-WIRE          VALUE 'WIRE    '.
               88  CH-ACH           VALUE 'ACH     '.
               88  CH-BATCH         VALUE 'BATCH   '.
               88  CH-CORR          VALUE 'CORR    '.
