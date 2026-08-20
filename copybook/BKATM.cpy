      *****************************************************************
      * BKATM - ATM advice / reversal pairing
      *****************************************************************
       01  BK-ATM-ADV.
           05  ATM-TRACE            PIC X(26).
           05  ATM-PAN-HASH         PIC X(16).
           05  ATM-TERM             PIC X(8).
           05  ATM-AMT              PIC S9(13)V99 COMP-3.
           05  ATM-DISP-IND         PIC X.
           05  ATM-REV-OF           PIC X(26).
           05  ATM-SWITCH-TS        PIC X(26).
           05  ATM-CASSETTE         PIC X(4).
