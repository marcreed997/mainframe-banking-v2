      *****************************************************************
      * BKTLL - Teller sign-on / drawer
      *****************************************************************
       01  BK-TELLER.
           05  TLL-ID               PIC X(8).
           05  TLL-BRANCH           PIC X(6).
           05  TLL-DRAWER-CASH      PIC S9(13)V99 COMP-3.
           05  TLL-SIGNED-ON        PIC X.
           05  TLL-OVERRIDE-LVL     PIC 9.
           05  TLL-LAST-TS          PIC X(26).
