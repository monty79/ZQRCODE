*&———————————————————————*
*& Report  YOTQR2
*&———————————————————————*
*& this program directly print BMP file of any barcode
*& https://blogs.sap.com/2016/05/12/qr-code-or-2d-bar-code-in-sap/
*&———————————————————————*
REPORT yotqr.
PARAMETERS: barcode      LIKE tfo05-tdbarcode DEFAULT 'ZQRCODE',
            barcdata(50) TYPE c LOWER CASE DEFAULT '1234567890Иванов Иван Иванович',
            filename     TYPE string LOWER CASE DEFAULT 'E:\Documents\1.bmp'.
DATA:errmsg(80)   TYPE c,
     bc_cmd       LIKE itcoo,
     bp_cmd       LIKE itcoo,
     bitmapsize   TYPE i,
     bitmap2_size TYPE i,
     w            TYPE i,
     h            TYPE i,
     bitmap       LIKE rspolpbi OCCURS 10 WITH HEADER LINE,
     bitmap2      LIKE rspolpbi OCCURS 10 WITH HEADER LINE,
     l_bitmap     TYPE xstring,
     otf          LIKE itcoo OCCURS 10 WITH HEADER LINE.

PERFORM get_otf_bc_cmd  IN PROGRAM sapmssco
                       USING barcode
                             barcdata
                             bc_cmd.

CHECK sy-subrc = 0.

bp_cmd-tdprintcom = 'bp'.

PERFORM get_otf_bp_cmd  IN PROGRAM sapmssco
                       USING barcode
                             bp_cmd-tdprintpar.

CHECK sy-subrc = 0.

PERFORM renderbarcode IN PROGRAM sapmssco
                     TABLES bitmap
                      USING bc_cmd
                            bp_cmd
                            barcdata
                            bitmapsize
                            w
                            h
                            errmsg.
CHECK sy-subrc = 0.

PERFORM bitmap2otf IN PROGRAM sapmssco
                   TABLES bitmap
                          otf
                    USING bitmapsize
                          w
                          h.

DATA length TYPE i.
DATA hex TYPE xstring.
DATA bitmap3 TYPE xstring.
FIELD-SYMBOLS  <fs>   TYPE x.

CLEAR: hex, bitmap3.

LOOP AT otf.
  length = otf-tdprintpar+2(2).
  ASSIGN otf-tdprintpar+4(length) TO <fs> CASTING.
  hex = <fs>(length).
  CONCATENATE bitmap3 hex INTO bitmap3 IN BYTE MODE.
ENDLOOP.

* convert from old format to new format
hex = 'FFFFFFFF01010000'.

CONCATENATE bitmap3(8) hex bitmap3+8 INTO bitmap3 IN BYTE MODE.

CLEAR hex.

SHIFT hex RIGHT BY 90 PLACES IN BYTE MODE.

CONCATENATE bitmap3(42) hex bitmap3+42 INTO bitmap3 IN BYTE MODE.

DATA bitmap4 TYPE sbdst_content.

CALL FUNCTION 'SCMS_XSTRING_TO_BINARY'
  EXPORTING
    buffer     = bitmap3 " xstring
  TABLES
    binary_tab = bitmap4.

DATA bitmap4_size TYPE i.

bitmap4_size = xstrlen( bitmap3 ).

CALL FUNCTION 'SAPSCRIPT_CONVERT_BITMAP'
  EXPORTING
    old_format               = 'BDS'
    new_format               = 'BMP'
    bitmap_file_bytecount_in = bitmap4_size
  IMPORTING
    bitmap_file_bytecount    = bitmap2_size
  TABLES
    bitmap_file              = bitmap2
    bds_bitmap_file          = bitmap4
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

cl_gui_frontend_services=>gui_download(
  EXPORTING
    bin_filesize = bitmap2_size
    filename     = filename
    filetype     = 'BIN'
  CHANGING
    data_tab     = bitmap2[]
  EXCEPTIONS
    file_write_error          = 1
    no_batch                  = 2
    gui_refuse_filetransfer   = 3
    invalid_type              = 4
    no_authority              = 5
    unknown_error             = 6
    header_not_allowed        = 7
    separator_not_allowed     = 8
    filesize_not_allowed      = 9
    header_too_long           = 10
    dp_error_create           = 11
    dp_error_send             = 12
    dp_error_write            = 13
    unknown_dp_error          = 14
    access_denied             = 15
    dp_out_of_memory          = 16
    disk_full                 = 17
    dp_timeout                = 18
    file_not_found            = 19
    dataprovider_exception    = 20
    control_flush_error       = 21
    not_supported_by_gui      = 22
    error_no_gui              = 23
    OTHERS                    = 24 ).
