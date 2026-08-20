      *****************************************************************
      * BKTAX - 1099-INT / backup withholding
      *****************************************************************
       01  BK-TAX.
           05  TAX-CIF-NO           PIC X(10).
           05  TAX-TIN              PIC X(9).
           05  TAX-TIN-STAT         PIC X.
               88  TIN-OK           VALUE 'O'.
               88  TIN-MISSING      VALUE 'M'.
               88  TIN-B-NOTICE     VALUE 'B'.
               88  TIN-C-NOTICE     VALUE 'C'.
           05  TAX-YEAR             PIC 9(4).
           05  TAX-INT-YTD          PIC S9(13)V99 COMP-3.
           05  TAX-WH-YTD           PIC S9(13)V99 COMP-3.
           05  TAX-WH-RATE          PIC 9V99 VALUE 0.24.
           05  TAX-WH-THIS          PIC S9(13)V99 COMP-3.
           05  TAX-PAYEE-NAME       PIC X(40).
           05  TAX-1099-IND         PIC X.
