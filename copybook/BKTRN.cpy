      *****************************************************************
      * BKTRN - Location extract body record (site settlement tape)
      *****************************************************************
       01  BK-EXTRACT-REC.
           05  XTR-REC-TYPE         PIC X.
               88  XTR-BODY         VALUE 'D'.
               88  XTR-HDR          VALUE 'H'.
               88  XTR-TRL          VALUE 'T'.
           05  XTR-LOC-ID           PIC X(8).
           05  XTR-CYCLE-DTE        PIC X(10).
           05  XTR-TRACE-ID         PIC X(26).
           05  XTR-ACC-NO           PIC X(6).
           05  XTR-DRCR             PIC X.
           05  XTR-AMT              PIC S9(13)V99 COMP-3.
           05  XTR-CHANNEL          PIC X(8).
           05  XTR-REVERSAL-OF      PIC X(26).
           05  XTR-CUTOFF-TS        PIC X(26).
           05  XTR-ORIGIN-BR        PIC X(6).
