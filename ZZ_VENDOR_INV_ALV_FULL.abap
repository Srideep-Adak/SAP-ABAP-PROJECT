# Combined Project Code File

```abap
" ============================================================
" FILE: ZZ_VENDOR_INV_ALV_FULL.abap
" Combined version of TOP include + main report for GitHub
" ============================================================

REPORT zz_vendor_inv_alv.

TYPE-POOLS: slis.

TABLES: bkpf, bsik, bsak, lfa1.

"------------------------------------------------------------
" Internal Table Structure
"------------------------------------------------------------
TYPES: BEGIN OF ty_invoice,
         bukrs      TYPE bukrs,
         lifnr      TYPE lifnr,
         name1      TYPE lfa1-name1,
         belnr      TYPE belnr_d,
         gjahr      TYPE gjahr,
         budat      TYPE budat,
         zfbdt      TYPE zfbdt,
         dmbtr      TYPE dmbtr,
         waers      TYPE waers,
         days_due   TYPE i,
         aging_cat  TYPE char20,
       END OF ty_invoice.

DATA: gt_invoice TYPE STANDARD TABLE OF ty_invoice,
      gs_invoice TYPE ty_invoice,
      go_salv    TYPE REF TO cl_salv_table.

"------------------------------------------------------------
" Selection Screen
"------------------------------------------------------------
SELECTION-SCREEN BEGIN OF BLOCK b1 WITH FRAME TITLE text-001.
SELECT-OPTIONS:
  s_bukrs FOR bkpf-bukrs,
  s_lifnr FOR lfa1-lifnr,
  s_budat FOR bkpf-budat.
SELECTION-SCREEN END OF BLOCK b1.

SELECTION-SCREEN BEGIN OF BLOCK b2 WITH FRAME TITLE text-002.
PARAMETERS:
  p_open  AS CHECKBOX DEFAULT 'X',
  p_clear AS CHECKBOX,
  p_both  AS CHECKBOX.
SELECTION-SCREEN END OF BLOCK b2.

SELECTION-SCREEN BEGIN OF BLOCK b3 WITH FRAME TITLE text-003.
PARAMETERS:
  p_curr TYPE c AS CHECKBOX DEFAULT 'X',
  p_30   TYPE c AS CHECKBOX DEFAULT 'X',
  p_60   TYPE c AS CHECKBOX DEFAULT 'X',
  p_90   TYPE c AS CHECKBOX DEFAULT 'X',
  p_90p  TYPE c AS CHECKBOX DEFAULT 'X'.
SELECTION-SCREEN END OF BLOCK b3.

"------------------------------------------------------------
" Main Processing
"------------------------------------------------------------
START-OF-SELECTION.

  PERFORM fetch_data.
  PERFORM calculate_aging.
  PERFORM display_alv.

"------------------------------------------------------------
" Fetch Open and Cleared Vendor Invoices
"------------------------------------------------------------
FORM fetch_data.

  IF p_open = 'X' OR p_both = 'X'.

    SELECT a~bukrs,
           a~lifnr,
           b~name1,
           a~belnr,
           a~gjahr,
           c~budat,
           a~zfbdt,
           a~dmbtr,
           a~waers
      INTO CORRESPONDING FIELDS OF TABLE @gt_invoice
      FROM bsik AS a
      INNER JOIN lfa1 AS b
        ON a~lifnr = b~lifnr
      INNER JOIN bkpf AS c
        ON a~bukrs = c~bukrs
       AND a~belnr = c~belnr
       AND a~gjahr = c~gjahr
      WHERE a~bukrs IN @s_bukrs
        AND a~lifnr IN @s_lifnr
        AND c~budat IN @s_budat.

  ENDIF.

  IF p_clear = 'X' OR p_both = 'X'.

    SELECT a~bukrs,
           a~lifnr,
           b~name1,
           a~belnr,
           a~gjahr,
           c~budat,
           a~zfbdt,
           a~dmbtr,
           a~waers
      APPENDING CORRESPONDING FIELDS OF TABLE @gt_invoice
      FROM bsak AS a
      INNER JOIN lfa1 AS b
        ON a~lifnr = b~lifnr
      INNER JOIN bkpf AS c
        ON a~bukrs = c~bukrs
       AND a~belnr = c~belnr
       AND a~gjahr = c~gjahr
      WHERE a~bukrs IN @s_bukrs
        AND a~lifnr IN @s_lifnr
        AND c~budat IN @s_budat.

  ENDIF.

ENDFORM.

"------------------------------------------------------------
" Dynamic Aging Bucket Calculation
"------------------------------------------------------------
FORM calculate_aging.

  LOOP AT gt_invoice INTO gs_invoice.

    gs_invoice-days_due = sy-datum - gs_invoice-zfbdt.

    IF gs_invoice-days_due <= 0.
      gs_invoice-aging_cat = 'Current'.

    ELSEIF gs_invoice-days_due <= 30.
      gs_invoice-aging_cat = '1-30 Days'.

    ELSEIF gs_invoice-days_due <= 60.
      gs_invoice-aging_cat = '31-60 Days'.

    ELSEIF gs_invoice-days_due <= 90.
      gs_invoice-aging_cat = '61-90 Days'.

    ELSE.
      gs_invoice-aging_cat = '90+ Days'.
    ENDIF.

    MODIFY gt_invoice FROM gs_invoice.

  ENDLOOP.

ENDFORM.

"------------------------------------------------------------
" Display SALV Report
"------------------------------------------------------------
FORM display_alv.

  DATA: lo_columns TYPE REF TO cl_salv_columns_table,
        lo_column  TYPE REF TO cl_salv_column,
        lo_sorts   TYPE REF TO cl_salv_sorts,
        lo_aggr    TYPE REF TO cl_salv_aggregations.

  TRY.
      cl_salv_table=>factory(
        IMPORTING
          r_salv_table = go_salv
        CHANGING
          t_table      = gt_invoice ).

    CATCH cx_salv_msg.
      MESSAGE 'ALV could not be created' TYPE 'E'.
  ENDTRY.

  " Column Texts
  lo_columns = go_salv->get_columns( ).

  lo_column ?= lo_columns->get_column( 'AGING_CAT' ).
  lo_column->set_long_text( 'Aging Bucket' ).

  lo_column ?= lo_columns->get_column( 'DAYS_DUE' ).
  lo_column->set_long_text( 'Days Overdue' ).

  " Vendor-wise Subtotals
  lo_sorts = go_salv->get_sorts( ).
  lo_sorts->add_sort(
    columnname = 'LIFNR'
    subtotal   = abap_true ).

  " Total Amount Aggregation
  lo_aggr = go_salv->get_aggregations( ).
  lo_aggr->add_aggregation( 'DMBTR' ).

  go_salv->display( ).

ENDFORM.
```

