      *****************************************************************
      * BKJRN - Hub monetary journal (system of record log)
      *****************************************************************
       01  BK-JOURNAL.
           05  JRN-TRACE-ID         PIC X(26).
           05  JRN-ACC-NO           PIC X(6).
           05  JRN-LOC-ID           PIC X(8).
           05  JRN-CHANNEL          PIC X(8).
           05  JRN-DRCR             PIC X.
               88  JRN-DEBIT        VALUE 'D'.
               88  JRN-CREDIT       VALUE 'C'.
           05  JRN-AMT              PIC S9(13)V99 COMP-3.
           05  JRN-CYCLE-DTE        PIC X(10).
           05  JRN-POSTED-IND       PIC X.
               88  JRN-UNPOSTED     VALUE 'N'.
               88  JRN-POSTED       VALUE 'Y'.
               88  JRN-SUSPENDED    VALUE 'S'.
           05  JRN-REVERSAL-OF      PIC X(26).
           05  JRN-TERM-ID          PIC X(8).
           05  JRN-TELLER-ID        PIC X(8).
           05  JRN-CREATE-TS        PIC X(26).
           05  JRN-POST-TS          PIC X(26).
           05  JRN-NARR             PIC X(40).
