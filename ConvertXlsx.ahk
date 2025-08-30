/*
    Github: https://github.com/Nich-Cebolla/AutoHotkey-LibV2/blob/main/ConvertXlsx.ahk
    Author: Nich-Cebolla
    License: MIT
*/

class ConvertXlsx {
    /**
     * Opens an .xlsx file using the Excel COM object, then calls Workbook.SaveAs.
     *
     * @see {@link https://learn.microsoft.com/en-us/office/vba/api/excel.workbook.saveas}.
     *
     * @param {String} InPath - The path to the .xlsx file.
     * @param {String} [OutPath] - The path to use when saving the file. If `OutPath` is unset, the
     * original file's name and directory are used, changing only the extension.
     * @param {Boolean} [Overwrite = false] - If true, and if a file exists at the output path, the
     * file is deleted first before processing. If false, and if a file exists at the output path, an
     * error is thrown.
     * @param {Integer} [FileFormat = 6] - One of the following integers:
     * |  Name                           |  Value      |  Description                                |  Extension                 |
     * |  -------------------------------|-------------|---------------------------------------------|--------------------------  |
     * |  xlAddIn                        |  18         |  Microsoft Excel 97-2003 Add-In             |  *.xla                     |
     * |  xlAddIn8                       |  18         |  Microsoft Excel 97-2003 Add-In             |  *.xla                     |
     * |  xlCSV                          |  6          |  CSV                                        |  *.csv                     |
     * |  xlCSVMac                       |  22         |  Macintosh CSV                              |  *.csv                     |
     * |  xlCSVMSDOS                     |  24         |  MSDOS CSV                                  |  *.csv                     |
     * |  xlCSVUTF8                      |  62         |  UTF8 CSV                                   |  *.csv                     |
     * |  xlCSVWindows                   |  23         |  Windows CSV                                |  *.csv                     |
     * |  xlCurrentPlatformText          |  -4158      |  Current Platform Text                      |  *.txt                     |
     * |  xlDBF2                         |  7          |  Dbase 2 format                             |  *.dbf                     |
     * |  xlDBF3                         |  8          |  Dbase 3 format                             |  *.dbf                     |
     * |  xlDBF4                         |  11         |  Dbase 4 format                             |  *.dbf                     |
     * |  xlDIF                          |  9          |  Data Interchange format                    |  *.dif                     |
     * |  xlExcel12                      |  50         |  Excel Binary Workbook                      |  *.xlsb                    |
     * |  xlExcel2                       |  16         |  Excel version 2.0 (1987)                   |  *.xls                     |
     * |  xlExcel2FarEast                |  27         |  Excel version 2.0 Asia (1987)              |  *.xls                     |
     * |  xlExcel3                       |  29         |  Excel version 3.0 (1990)                   |  *.xls                     |
     * |  xlExcel4                       |  33         |  Excel version 4.0 (1992)                   |  *.xls                     |
     * |  xlExcel4Workbook               |  35         |  Excel version 4.0. Workbook format (1992)  |  *.xlw                     |
     * |  xlExcel5                       |  39         |  Excel version 5.0 (1994)                   |  *.xls                     |
     * |  xlExcel7                       |  39         |  Excel 95 (version 7.0)                     |  *.xls                     |
     * |  xlExcel8                       |  56         |  Excel 97-2003 Workbook                     |  *.xls                     |
     * |  xlExcel9795                    |  43         |  Excel version 95 and 97                    |  *.xls                     |
     * |  xlHtml                         |  44         |  HTML format                                |  *.htm; *.html             |
     * |  xlIntlAddIn                    |  26         |  International Add-In                       |  No file extension         |
     * |  xlIntlMacro                    |  25         |  International Macro                        |  No file extension         |
     * |  xlOpenDocumentSpreadsheet      |  60         |  OpenDocument Spreadsheet                   |  *.ods                     |
     * |  xlOpenXMLAddIn                 |  55         |  Open XML Add-In                            |  *.xlam                    |
     * |  xlOpenXMLStrictWorkbook        |  61 (&H3D)  |  Strict Open XML file                       |  *.xlsx                    |
     * |  xlOpenXMLTemplate              |  54         |  Open XML Template                          |  *.xltx                    |
     * |  xlOpenXMLTemplateMacroEnabled  |  53         |  Open XML Template Macro Enabled            |  *.xltm                    |
     * |  xlOpenXMLWorkbook              |  51         |  Open XML Workbook                          |  *.xlsx                    |
     * |  xlOpenXMLWorkbookMacroEnabled  |  52         |  Open XML Workbook Macro Enabled            |  *.xlsm                    |
     * |  xlSYLK                         |  2          |  Symbolic Link format                       |  *.slk                     |
     * |  xlTemplate                     |  17         |  Excel Template format                      |  *.xlt                     |
     * |  xlTemplate8                    |  17         |  Template 8                                 |  *.xlt                     |
     * |  xlTextMac                      |  19         |  Macintosh Text                             |  *.txt                     |
     * |  xlTextMSDOS                    |  21         |  MSDOS Text                                 |  *.txt                     |
     * |  xlTextPrinter                  |  36         |  Printer Text                               |  *.prn                     |
     * |  xlTextWindows                  |  20         |  Windows Text                               |  *.txt                     |
     * |  xlUnicodeText                  |  42         |  Unicode Text                               |  No file extension; *.txt  |
     * |  xlWebArchive                   |  45         |  Web Archive                                |  *.mht; *.mhtml            |
     * |  xlWJ2WD1                       |  14         |  Japanese 1-2-3                             |  *.wj2                     |
     * |  xlWJ3                          |  40         |  Japanese 1-2-3                             |  *.wj3                     |
     * |  xlWJ3FJ3                       |  41         |  Japanese 1-2-3 format                      |  *.wj3                     |
     * |  xlWK1                          |  5          |  Lotus 1-2-3 format                         |  *.wk1                     |
     * |  xlWK1ALL                       |  31         |  Lotus 1-2-3 format                         |  *.wk1                     |
     * |  xlWK1FMT                       |  30         |  Lotus 1-2-3 format                         |  *.wk1                     |
     * |  xlWK3                          |  15         |  Lotus 1-2-3 format                         |  *.wk3                     |
     * |  xlWK3FM3                       |  32         |  Lotus 1-2-3 format                         |  *.wk3                     |
     * |  xlWK4                          |  38         |  Lotus 1-2-3 format                         |  *.wk4                     |
     * |  xlWKS                          |  4          |  Lotus 1-2-3 format                         |  *.wks                     |
     * |  xlWorkbookDefault              |  51         |  Workbook default                           |  *.xlsx                    |
     * |  xlWorkbookNormal               |  -4143      |  Workbook normal                            |  *.xls                     |
     * |  xlWorks2FarEast                |  28         |  Microsoft Works 2.0 Asian format           |  *.wks                     |
     * |  xlWQ1                          |  34         |  Quattro Pro format                         |  *.wq1                     |
     * |  xlXMLSpreadsheet               |  46         |  XML Spreadsheet                            |  *.xml                     |
     * @returns {String} - The path where the ile was saved.
     */
    static Call(InPath, OutPath?, Overwrite := false, FileFormat := 62) {
        if !IsSet(OutPath) {
            SplitPath(InPath, , &Dir, , &Name)
            OutPath := Dir '\' Name '.' this.Extensions.Get(FileFormat)
        }
        if FileExist(OutPath) {
            if Overwrite {
                FileDelete(OutPath)
            } else {
                throw Error('A file already exists at the indicated path.', -1, OutPath)
            }
        }
        obj := { xl: '', wb: '', cb: '' }
        obj.cb := _Exit.Bind(obj)
        OnExit(obj.cb, 1)
        xl := obj.xl := ComObject('Excel.Application')
        xl.Visible := false
        wb := obj.wb := xl.Workbooks.Open(InPath)
        wb.SaveAs(OutPath, FileFormat)
        obj.cb.Call()

        return OutPath

        _Exit(obj, *) {
            if obj.wb {
                obj.wb.Close(false)
            }
            if obj.xl {
                obj.xl.Quit()
            }
            OnExit(obj.cb, 0)
            obj.wb := obj.xl := obj.cb := ''
        }
    }
    static __New() {
        this.DeleteProp('__New')
        this.Extensions := Map()
        this.Extensions.CaseSense := false
        this.Extensions.Set(
            18, 'xla'
          , 6, 'csv'
          , 22, 'csv'
          , 24, 'csv'
          , 62, 'csv'
          , 23, 'csv'
          , -4158, 'txt'
          , 7, 'dbf'
          , 8, 'dbf'
          , 11, 'dbf'
          , 9, 'dif'
          , 50, 'xlsb'
          , 16, 'xls'
          , 27, 'xls'
          , 29, 'xls'
          , 33, 'xls'
          , 35, 'xlw'
          , 39, 'xls'
          , 39, 'xls'
          , 56, 'xls'
          , 43, 'xls'
          , 44, 'html'
          , 60, 'ods'
          , 55, 'xlam'
          , 61, 'xlsx'
          , 54, 'xltx'
          , 53, 'xltm'
          , 51, 'xlsx'
          , 52, 'xlsm'
          , 2, 'slk'
          , 17, 'xlt'
          , 17, 'xlt'
          , 19, 'txt'
          , 21, 'txt'
          , 36, 'prn'
          , 20, 'txt'
          , 42, 'txt'
          , 45, 'mhtml'
          , 14, 'wj2'
          , 40, 'wj3'
          , 41, 'wj3'
          , 5, 'wk1'
          , 31, 'wk1'
          , 30, 'wk1'
          , 15, 'wk3'
          , 32, 'wk3'
          , 38, 'wk4'
          , 4, 'wks'
          , 51, 'xlsx'
          , -4143, 'xls'
          , 28, 'wks'
          , 34, 'wq1'
          , 46, 'xml'
        )

    }
}
