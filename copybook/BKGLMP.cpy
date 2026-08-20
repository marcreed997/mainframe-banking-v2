      *****************************************************************
      * BKGLMP - Channel/DRCR -> GL account map
      *****************************************************************
       01  BK-GL-MAP.
           05  GLM-CHANNEL          PIC X(8).
           05  GLM-DRCR             PIC X.
           05  GLM-PROD             PIC X(4).
               88  PROD-DDA         VALUE 'DDA '.
               88  PROD-SAV         VALUE 'SAV '.
               88  PROD-CD          VALUE 'CD  '.
               88  PROD-LN          VALUE 'LN  '.
               88  PROD-GL          VALUE 'GL  '.
           05  GLM-GL-ACCT          PIC X(10).
           05  GLM-CCY              PIC X(3).
           05  GLM-NARR             PIC X(40).
       01  BK-GL-PROVE.
           05  GLP-JRN-DR           PIC S9(15)V99 COMP-3.
           05  GLP-JRN-CR           PIC S9(15)V99 COMP-3.
           05  GLP-FEED-DR          PIC S9(15)V99 COMP-3.
           05  GLP-FEED-CR          PIC S9(15)V99 COMP-3.
           05  GLP-LOC-DR           PIC S9(15)V99 COMP-3.
           05  GLP-LOC-CR           PIC S9(15)V99 COMP-3.
           05  GLP-VAR-DR           PIC S9(15)V99 COMP-3.
           05  GLP-VAR-CR           PIC S9(15)V99 COMP-3.
           05  GLP-CLOSED-IND       PIC X.
