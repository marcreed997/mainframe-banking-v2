      *****************************************************************
      * BKACH - NACHA / ACH 94-byte record layouts (lab)
      *****************************************************************
       01  ACH-FILE-HDR.
           05  ACH-H1-TYPE          PIC X VALUE '1'.
           05  ACH-H1-PRIORITY      PIC 9(2).
           05  ACH-H1-DEST          PIC X(10).
           05  ACH-H1-ORIGIN        PIC X(10).
           05  ACH-H1-FILE-DTE      PIC 9(6).
           05  ACH-H1-FILE-TME      PIC 9(4).
           05  ACH-H1-ID-MOD        PIC X.
           05  ACH-H1-RECSIZE       PIC 9(3).
           05  ACH-H1-BLOCKING      PIC 9(2).
           05  ACH-H1-FORMAT        PIC 9.
           05  ACH-H1-DEST-NAME     PIC X(23).
           05  ACH-H1-ORIG-NAME     PIC X(23).
           05  ACH-H1-REF           PIC X(8).
       01  ACH-BATCH-HDR.
           05  ACH-H5-TYPE          PIC X VALUE '5'.
           05  ACH-H5-SERV-CLASS    PIC 9(3).
               88  ACH-MIXED        VALUE 200.
               88  ACH-CR-ONLY      VALUE 220.
               88  ACH-DR-ONLY      VALUE 225.
           05  ACH-H5-CO-NAME       PIC X(16).
           05  ACH-H5-CO-DISC       PIC X(20).
           05  ACH-H5-CO-ID         PIC X(10).
           05  ACH-H5-SEC           PIC X(3).
               88  SEC-PPD          VALUE 'PPD'.
               88  SEC-CCD          VALUE 'CCD'.
               88  SEC-WEB          VALUE 'WEB'.
               88  SEC-TEL          VALUE 'TEL'.
               88  SEC-CTX          VALUE 'CTX'.
               88  SEC-IAT          VALUE 'IAT'.
           05  ACH-H5-ENTRY-DESC    PIC X(10).
           05  ACH-H5-DESC-DTE      PIC X(6).
           05  ACH-H5-EFF-DTE       PIC 9(6).
           05  ACH-H5-SETTLE        PIC X(3).
           05  ACH-H5-STATUS        PIC X.
           05  ACH-H5-DFID          PIC X(8).
           05  ACH-H5-BATCH-NO      PIC 9(7).
       01  ACH-ENTRY.
           05  ACH-E6-TYPE          PIC X VALUE '6'.
           05  ACH-E6-TX-CODE       PIC 9(2).
               88  TX-CK-DR         VALUE 27.
               88  TX-CK-CR         VALUE 22.
               88  TX-SAV-DR        VALUE 37.
               88  TX-SAV-CR        VALUE 32.
               88  TX-PRE-DR        VALUE 28 38.
               88  TX-PRE-CR        VALUE 23 33.
               88  TX-RET-DR        VALUE 21 26 31 36.
           05  ACH-E6-RDFID         PIC 9(8).
           05  ACH-E6-CHK-DIGIT     PIC 9.
           05  ACH-E6-DDA           PIC X(17).
           05  ACH-E6-AMT           PIC 9(8)V99.
           05  ACH-E6-INDIV-ID      PIC X(15).
           05  ACH-E6-INDIV-NAME    PIC X(22).
           05  ACH-E6-DISC          PIC X(2).
           05  ACH-E6-ADDENDA       PIC X.
           05  ACH-E6-TRACE         PIC 9(15).
       01  ACH-BATCH-CTL.
           05  ACH-C8-TYPE          PIC X VALUE '8'.
           05  ACH-C8-SERV-CLASS    PIC 9(3).
           05  ACH-C8-ENTRY-CNT     PIC 9(6).
           05  ACH-C8-ENTRY-HASH    PIC 9(10).
           05  ACH-C8-TOT-DR        PIC 9(10)V99.
           05  ACH-C8-TOT-CR        PIC 9(10)V99.
           05  ACH-C8-CO-ID         PIC X(10).
           05  ACH-C8-MSG           PIC X(19).
           05  ACH-C8-DFID          PIC X(8).
           05  ACH-C8-BATCH-NO      PIC 9(7).
       01  ACH-FILE-CTL.
           05  ACH-C9-TYPE          PIC X VALUE '9'.
           05  ACH-C9-BATCH-CNT     PIC 9(6).
           05  ACH-C9-BLOCK-CNT     PIC 9(6).
           05  ACH-C9-ENTRY-CNT     PIC 9(8).
           05  ACH-C9-ENTRY-HASH    PIC 9(10).
           05  ACH-C9-TOT-DR        PIC 9(10)V99.
           05  ACH-C9-TOT-CR        PIC 9(10)V99.
           05  ACH-C9-FILL          PIC X(39).
       01  ACH-RETURN.
           05  ACH-R7-TYPE          PIC X VALUE '7'.
           05  ACH-R7-ADD-TYPE      PIC 9(2).
           05  ACH-R7-RET-CODE      PIC X(3).
               88  R01-NSF          VALUE 'R01'.
               88  R02-CLOSED       VALUE 'R02'.
               88  R03-NO-ACCT      VALUE 'R03'.
               88  R04-INVALID      VALUE 'R04'.
               88  R07-REVOKED      VALUE 'R07'.
               88  R08-STOP         VALUE 'R08'.
               88  R10-UNAUTH       VALUE 'R10'.
           05  ACH-R7-ORIG-TRACE    PIC 9(15).
           05  ACH-R7-DATE          PIC 9(6).
           05  ACH-R7-ORIG-RDFID    PIC X(8).
           05  ACH-R7-ADD-TRACE     PIC 9(15).
       01  ACH-WORK.
           05  ACH-WS-DR            PIC S9(13)V99 COMP-3 VALUE 0.
           05  ACH-WS-CR            PIC S9(13)V99 COMP-3 VALUE 0.
           05  ACH-WS-CNT           PIC 9(7) VALUE 0.
           05  ACH-WS-HASH          PIC 9(12) VALUE 0.
           05  ACH-WS-BATCHES       PIC 9(5) VALUE 0.
           05  ACH-WS-WINDOW        PIC X(8).
               88  ACH-NIGHT        VALUE 'NIGHT   '.
               88  ACH-SAME-DAY     VALUE 'SAMEDAY '.
