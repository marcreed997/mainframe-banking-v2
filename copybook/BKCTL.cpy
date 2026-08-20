      *****************************************************************
      * BKCTL - Cycle control / online inhibit / tokens
      *****************************************************************
       01  BK-CYCLE-CTL.
           05  CTL-CYCLE-DTE        PIC X(10).
           05  CTL-STATUS           PIC X(8).
               88  CYC-OPEN         VALUE 'OPEN    '.
               88  CYC-INHIBIT      VALUE 'INHIBIT '.
               88  CYC-POSTING      VALUE 'POSTING '.
               88  CYC-RECON        VALUE 'RECON   '.
               88  CYC-CLOSED       VALUE 'CLOSED  '.
           05  CTL-ONLINE-INHIBIT   PIC X.
               88  ONLINE-ALLOWED   VALUE 'N'.
               88  ONLINE-BLOCKED   VALUE 'Y'.
           05  CTL-VALIDATED-IND    PIC X.
           05  CTL-RECON-CLOSED     PIC X.
           05  CTL-POST-TOKEN       PIC X(26).
           05  CTL-LOCK-OWNER       PIC X(8).
           05  CTL-LOCK-TS          PIC X(26).
