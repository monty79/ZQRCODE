*&---------------------------------------------------------------------*
*& Report  ZWWW_BAR_CODE
*&---------------------------------------------------------------------*
REPORT  zwww_qr_test.

DATA:
  it_val TYPE STANDARD TABLE OF zwww_values WITH HEADER LINE,
  s      TYPE string.
TYPES:
  char30(30),
  num20(20) TYPE n.

PARAMETERS:
  pqr      TYPE char30 DEFAULT 'QR Test проверка формирования' LOWER CASE.

INITIALIZATION.
  DATA:
    fmexist TYPE sxst_pare-exist.

  CALL FUNCTION 'CHECK_EXIST_FUNC'
    EXPORTING
      name   = 'ZVVN_BARCODE_GENERATE'
    IMPORTING
      exist  = fmexist
    EXCEPTIONS
      OTHERS = 99.

AT SELECTION-SCREEN OUTPUT.
  LOOP AT SCREEN.
    IF fmexist <> 'X'.
      screen-input = 0.
      MODIFY SCREEN.
    ENDIF.
  ENDLOOP.

START-OF-SELECTION.

  DEFINE setval.
    CLEAR it_val.
    it_val-var_name  = &1.
    it_val-var_num   = &2.
    it_val-find_text = &3.
    it_val-val_type  = &4.
    it_val-value     = &5.
    APPEND it_val.
  End-of-Definition.

End-of-Selection.

  setval 'LineQR' '1' '[кодировка]' '' 'QR Code'.
  setval 'LineQR' '1' '[данные]'    '' pqr.
  setval 'LineQR' '1' '[a]'     '' 'F1DDD1F  841B F1DDD1F'.
  setval 'LineQR' '1' '[b]'     '' '7455547 6BFAF 7455547'.
  setval 'LineQR' '1' '[c]'     '' '76 78B5 FAE8452B 2  C'.
  setval 'LineQR' '1' '[d]'     '' 'D45544D B38A9C15D6469'.
  setval 'LineQR' '1' '[e]'     '' 'F 777 F 26934894E3527'.
  setval 'LineQR' '1' '[f]'     '' '1111111 1 111  111 1 '.

  CALL FUNCTION 'ZWWW_OPENFORM'
    EXPORTING
      form_name   = 'ZWWW_QR_CODE'
      printdialog = ''
      protect     = ''
    TABLES
      it_values   = it_val
    EXCEPTIONS
      printcancel = 1
      OTHERS      = 99.
