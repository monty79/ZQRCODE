class ZCL_QR_CODE definition
  public
  final
  create public .

public section.

  constants C_CODE_TYPE type TFO05-TDBARCODE value 'ZQRCODE' ##NO_TEXT.

  class-methods BDS_TO_BMP
    importing
      !I_BITMAP type XSTRING
    exporting
      !E_SIZE type I
      !E_BMP_TAB type RMPS_RSPOLPBI .
  class-methods GET_BDS_BITMAP
    importing
      !I_CODE_TYPE type TDBARCODE default C_CODE_TYPE
      !I_TEXT type CSEQUENCE
    exporting
      !E_BITMAP type XSTRING
      !E_WIDTH type I
      !E_HEIGHT type I .
protected section.
private section.
ENDCLASS.



CLASS ZCL_QR_CODE IMPLEMENTATION.


METHOD bds_to_bmp.
  DATA bitmap4 TYPE sbdst_content.

  CALL FUNCTION 'SCMS_XSTRING_TO_BINARY'
    EXPORTING
      buffer     = i_bitmap
    TABLES
      binary_tab = bitmap4.

  DATA: bitmap4_size TYPE i.

  bitmap4_size = xstrlen( i_bitmap ).

  CALL FUNCTION 'SAPSCRIPT_CONVERT_BITMAP'
    EXPORTING
      old_format               = 'BDS'
      new_format               = 'BMP'
      bitmap_file_bytecount_in = bitmap4_size
    IMPORTING
      bitmap_file_bytecount    = e_size
    TABLES
      bds_bitmap_file          = bitmap4
      bitmap_file              = e_bmp_tab
    EXCEPTIONS
      no_bitmap_file           = 1
      format_not_supported     = 2
      bitmap_file_not_type_x   = 3
      no_bmp_file              = 4
      bmperr_invalid_format    = 5
      bmperr_no_colortable     = 6
      bmperr_unsup_compression = 7
      bmperr_corrupt_rle_data  = 8
      bmperr_eof               = 9
      bdserr_invalid_format    = 10
      bdserr_eof               = 11.
ENDMETHOD.


METHOD get_bds_bitmap.
  DATA:errmsg(80) TYPE c,
       bc_cmd     TYPE itcoo,
       bp_cmd     TYPE itcoo,
       bitmapsize TYPE i,
       bitmap     TYPE STANDARD TABLE OF rspolpbi,
       l_bitmap   TYPE xstring,
       otf_tab    TYPE STANDARD TABLE OF itcoo,
       ls_otf     LIKE LINE OF otf_tab.

  PERFORM get_otf_bc_cmd  IN PROGRAM sapmssco
                         USING i_code_type
                               i_text
                               bc_cmd.

  CHECK sy-subrc = 0.

  bp_cmd-tdprintcom = 'bp'.

  PERFORM get_otf_bp_cmd  IN PROGRAM sapmssco
                         USING i_code_type
                               bp_cmd-tdprintpar.

  CHECK sy-subrc = 0.

  PERFORM renderbarcode IN PROGRAM sapmssco
                       TABLES bitmap
                        USING bc_cmd
                              bp_cmd
                              i_text
                              bitmapsize
                              e_width
                              e_height
                              errmsg.
  CHECK sy-subrc = 0.

  PERFORM bitmap2otf IN PROGRAM sapmssco
                     TABLES bitmap
                            otf_tab
                      USING bitmapsize
                            e_width
                            e_height.

  DATA length TYPE i.
  DATA hex TYPE xstring.
  FIELD-SYMBOLS  <fs>   TYPE x.

  CLEAR: hex, e_bitmap.

  LOOP AT otf_tab INTO ls_otf.
    length = ls_otf-tdprintpar+2(2).
    ASSIGN ls_otf-tdprintpar+4(length) TO <fs> CASTING.
    hex = <fs>(length).
    CONCATENATE e_bitmap hex INTO e_bitmap IN BYTE MODE.
  ENDLOOP.

*convert from old format to new format
  hex = 'FFFFFFFF01010000'.

  CONCATENATE e_bitmap(8) hex e_bitmap+8 INTO e_bitmap IN BYTE MODE.

  CLEAR hex.

  SHIFT hex RIGHT BY 90 PLACES IN BYTE MODE.

  CONCATENATE e_bitmap(42) hex e_bitmap+42 INTO e_bitmap IN BYTE MODE.

ENDMETHOD.
ENDCLASS.
