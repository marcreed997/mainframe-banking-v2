      *****************************************************************
      * BKCTR - Currency Transaction Report aggregation (lab)
      *****************************************************************
       01  BK-CTR.
           05  CTR-CIF-NO           PIC X(10).
           05  CTR-BUS-DTE          PIC X(10).
           05  CTR-CASH-IN          PIC S9(13)V99 COMP-3.
           05  CTR-CASH-OUT         PIC S9(13)V99 COMP-3.
           05  CTR-THRESHOLD        PIC S9(13)V99 COMP-3 VALUE 10000.00.
           05  CTR-OCCUPATION       PIC X(30).
           05  CTR-SRC-FUNDS        PIC X(30).
           05  CTR-BENEFICIARY      PIC X(30).
           05  CTR-FILED-IND        PIC X.
           05  CTR-EXEMPT-IND       PIC X.
               88  CTR-PHASED       VALUE 'P'.
               88  CTR-PERSON       VALUE 'N'.
           05  CTR-TELLER           PIC X(8).
           05  CTR-BRANCH           PIC X(6).
