      *****************************************************************
      * BKESC - Escrow disbursement (tax/insurance)
      *****************************************************************
       01  BK-ESCROW.
           05  ESC-LOAN-NO          PIC X(10).
           05  ESC-TYPE             PIC X(8).
               88  ESC-TAX          VALUE 'TAX     '.
               88  ESC-INS          VALUE 'INS     '.
               88  ESC-MI           VALUE 'MI      '.
           05  ESC-PAYEE            PIC X(40).
           05  ESC-DUE-DTE          PIC X(10).
           05  ESC-AMT              PIC S9(13)V99 COMP-3.
           05  ESC-BAL              PIC S9(13)V99 COMP-3.
           05  ESC-SHORT            PIC S9(13)V99 COMP-3.
           05  ESC-STATUS           PIC X.
               88  ESC-DUE          VALUE 'D'.
               88  ESC-PAID         VALUE 'P'.
               88  ESC-HELD         VALUE 'H'.
               88  ESC-NSF-ESC      VALUE 'N'.
