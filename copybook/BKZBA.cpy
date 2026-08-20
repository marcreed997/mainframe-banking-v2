      *****************************************************************
      * BKZBA - Zero-balance / sweep vehicle
      *****************************************************************
       01  BK-ZBA.
           05  ZBA-CHILD-ACC        PIC X(6).
           05  ZBA-PARENT-ACC       PIC X(6).
           05  ZBA-TARGET           PIC S9(13)V99 COMP-3.
           05  ZBA-MIN-SWEEP        PIC S9(13)V99 COMP-3.
           05  ZBA-CHILD-BAL        PIC S9(13)V99 COMP-3.
           05  ZBA-PARENT-BAL       PIC S9(13)V99 COMP-3.
           05  ZBA-SWEEP-AMT        PIC S9(13)V99 COMP-3.
           05  ZBA-DIR              PIC X.
               88  ZBA-TO-PARENT    VALUE 'U'.
               88  ZBA-TO-CHILD     VALUE 'D'.
               88  ZBA-NONE         VALUE 'N'.
           05  ZBA-VEHICLE          PIC X(8).
               88  ZBA-MMDA         VALUE 'MMDA    '.
               88  ZBA-NOTE         VALUE 'NOTE    '.
               88  ZBA-REPO         VALUE 'REPO    '.
           05  ZBA-STATUS           PIC X.
