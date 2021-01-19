*&———————————————————————*
*& Report  YOTQR2
*&———————————————————————*
*& this program directly print BMP file of any barcode
*& https://blogs.sap.com/2016/05/12/qr-code-or-2d-bar-code-in-sap/
*&———————————————————————*
REPORT z_qr_test.
PARAMETERS: barcode      LIKE tfo05-tdbarcode DEFAULT 'ZQRCODE',
            barcdata(50) TYPE c LOWER CASE DEFAULT '1234567890_Иванов Иван Иванович',
            filename     TYPE string LOWER CASE.

INITIALIZATION.
  DATA gv_temp_dir TYPE string.
  DATA gv_file_separator TYPE char1.
*  cl_gui_frontend_services=>get_temp_directory(
  cl_gui_frontend_services=>get_sapgui_workdir(
    CHANGING
      sapworkdir = gv_temp_dir
    EXCEPTIONS
      OTHERS = 0 ).
  cl_gui_frontend_services=>get_file_separator(
    CHANGING
      file_separator = gv_file_separator
    EXCEPTIONS
      OTHERS = 0 ).
  cl_gui_cfw=>flush( EXCEPTIONS OTHERS = 0 ).
  CONCATENATE gv_temp_dir gv_file_separator '1.bmp' INTO filename.

START-OF-SELECTION.

  DATA bitmap_xstring TYPE xstring.
  zcl_qr_code=>get_bds_bitmap(
    EXPORTING
      i_code_type = barcode
      i_text = barcdata
    IMPORTING
      e_bitmap = bitmap_xstring ).

  DATA bitmap2 TYPE rmps_rspolpbi.
  DATA bitmap2_size TYPE i.

  zcl_qr_code=>bds_to_bmp(
    EXPORTING
      i_bitmap    = bitmap_xstring
    IMPORTING
      e_bmp_tab = bitmap2[]
      e_size = bitmap2_size ).

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
  DATA file_exist TYPE abap_bool.
  cl_gui_frontend_services=>file_exist(
    EXPORTING
      file                 =  filename
    RECEIVING
      result               = file_exist
    EXCEPTIONS
      OTHERS               = 0 ).
  IF file_exist = abap_true.
    cl_gui_frontend_services=>execute(
      EXPORTING
        document               = filename
      EXCEPTIONS
        OTHERS                 = 10 ).
  ENDIF.
