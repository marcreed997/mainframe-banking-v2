      *****************************************************************
      * BKSTP - Stop payment on a check / ACH debit
      *****************************************************************
       01  BK-STOP-PAY.
           05  STP-ID               PIC X(12).
           05  STP-ACC-NO           PIC X(6).
           05  STP-KIND             PIC X.
               88  STP-CHECK        VALUE 'C'.
               88  STP-ACH          VALUE 'A'.
               88  STP-RANGE        VALUE 'R'.
           05  STP-CHECK-NO         PIC 9(10).
           05  STP-CHECK-THRU       PIC 9(10).
           05  STP-AMT              PIC S9(13)V99 COMP-3.
           05  STP-AMT-OPT          PIC X.
               88  STP-AMT-EXACT    VALUE 'E'.
               88  STP-AMT-ANY      VALUE 'A'.
           05  STP-PAYEE            PIC X(30).
           05  STP-EXPIRE-DTE       PIC X(10).
           05  STP-STATUS           PIC X.
               88  STP-ACTIVE       VALUE 'A'.
               88  STP-EXPIRED      VALUE 'X'.
               88  STP-HIT          VALUE 'H'.
               88  STP-CANCEL       VALUE 'C'.
           05  STP-FEE-AMT          PIC S9(7)V99 COMP-3.
           05  STP-TELLER           PIC X(8).
           05  STP-OVERRIDE         PIC X(8).
           05  STP-CREATE-TS        PIC X(26).
