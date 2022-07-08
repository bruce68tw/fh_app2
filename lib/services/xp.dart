import 'dart:convert';
import 'dart:io';
import 'package:archive/archive_io.dart';
import 'package:flutter/material.dart';
import 'package:base_lib/all.dart';
//import 'package:path/path.dart';
import '../enums/all.dart';
import '../tables/project_tab.dart';

/// static class
class Xp {
  //=== constant start ===
  ///1.is https or not
  static const isHttps = false;
  static const isHttpsTest = false;
  static const version = '1.1(測試)';

  ///2.api server end point
  //home
  //static const apiServer = '192.168.1.103:5007';
  //static const apiServerTest = '192.168.1.103:5007';

  //efun wifi
  //static const apiServer = '192.168.50.164:5007';
  //static const apiServerTest = '192.168.50.164:5007';

  //富源網(new)
  static const apiServer = 'uper.gtiot.net:5007';
  static const apiServerTest = 'uper.gtiot.net:5007';
  //富源網(old)
  //static const apiServer = 'uper.fhnet.com.tw:5007';
  //static const apiServerTest = 'uper.fhnet.com.tw:5007';

  //default font size
  static const fontSize = 20.0; 
  static const titleFontSize = 18.0; 

  //新工單的目錄名稱
  static const dirNewImage = '_new'; 

  //專案workClass.Id, 必須與DB符合
  static const prjMeetWcId = '137b861a-b579-404e-be43-5260c9b8b321';  //會勘
  static const prjMachWcId = '74c1101e-7d05-4041-9e3e-7ca9ceb51ab6';  //裝機
  static const prjFixWcId = '14a8cee7-ac12-4679-bf22-dc0eb68957cd';   //維修
  static const prjCheckWcId = 'c224c312-71a4-4298-8509-e676fcdcc5e0'; //巡檢
  //FAN
  static const fanCheckWcId = '4288c0b9-c557-4f69-80a5-dd5ab688ed9b'; //會勘
  static const fanFixWcId = 'd38819f1-d208-41c9-91b4-ec154f08279c';   //維修
  static const fanMachWcId = 'c1d19fc5-fbd7-4728-a0e1-b0d276a9fb94';  //裝機
  //DCU
  static const dcuCheckWcId = 'a1dc0677-eae0-4313-9d2a-fb39c5400389'; //會勘
  static const dcuFixWcId = '3b254bfa-836e-4634-ad0c-492bf6e3aedf';   //維修
  static const dcuMachWcId = 'dd7e6506-6cc2-4597-8df2-c2e2c4548581';  //裝機

  //=== constant end ===

  //=== auto set start ===
  static List<IdStrDto> workClasses = [];  //WorkClass
  static List<IdStrDto> areas = [];
  static List<IdStrDto> dispatches = [];
  static List<IdStrDto> closes = [];
  static List<IdStr2Dto> closeDetails = [];
  //=== auto set end ===

  //=== folder start ===
  /// get directory of workOrder image
  static String dirWoImage([String id = '', bool create = false]) {
    var dirWo = FunUt.dirApp + 'image/wo/';
    if (id == '') return dirWo;

    //create folder if need
    var dirSave = dirWo + id;
    if (create){
      var dir = Directory(dirSave);
      if (!dir.existsSync()) {
        dir.createSync(recursive: true);
      }
    }

    return dirSave + '/';
  }
  //=== folder end ===

  /*
  static String timeStr(TimeOfDay time){
    return time.hour.toString() + ' : ' + 
        time.minute.toString();
  }
  */
  
  /// 完工送審核
  /// param id : row id, empty for new
  static sendAuditId([String id = '']) {
    //get row

    //return true;
  }

  /// 檢查後端回傳資料是否錯誤
  static bool checkResultError(BuildContext context, dynamic result) {    
    var json = result['Result'];
    if (json['Error'] == null || json['Error'] == ''){
      return true;
    } else {
      ToolUt.msg(context, json['Error']);
      return false;
    }
  }

  /// get result
  /// 後端會包2層 Result 屬性!!
  static dynamic getResult(dynamic result) {
    return result['Result']['Result'];
  }

  /// 先上傳照片和錄影檔案再儲存資料(多筆)
  static Future<void> sendAuditRowsAsync(BuildContext context, List<ProjectTab> rows,
      Function fnOk) async {
    ToolUt.openWait(context);
    for(var row in rows){
      await sendAuditRowAsync(context, false, row, false);
    }
    ToolUt.closeWait(context);
    fnOk();
  }

  /// 先上傳照片和錄影檔案再儲存資料(單筆)
  static Future<void> sendAuditRowAsync(BuildContext context, bool isNew, 
      ProjectTab row, [bool showWait = true, Function? fnOk]) async {
    if (isNew) row.id = StrUt.uuid();
    
    //check zip file
    var zipDir = Xp.dirWoImage(isNew ? dirNewImage : row.id);
    var zipFile = FunUt.dirTemp + FileUt.getDirName(zipDir) + '.zip';
    var fileNos = _zipDir(row.id, zipDir, zipFile);
    var hasFile = (fileNos != null);
    /*
    if (files == null) {
      await _sendAuditRow2Async(context, row, showWait, fnOk);
      return;
    } 
    */

    //fileNos:檔案位置序號, for WorkOrderImage.Sort
    var data = {'row':jsonEncode(row.toServerJson()), 'fileNos':ListUt.toStr(fileNos)};
    await HttpUt.uploadZipAsync(context, 'api/Project/SendAuditZip', 
        hasFile ? File(zipFile) : null, data, true, (result) async {
      if (!checkResultError(context, result)) return;

      //callback
      if (fnOk != null) fnOk();
    }, showWait);

    /*
    await _sendAuditRow2Async(context, row, showWait, (woNo) async {
      //if (!checkResultError(context, result)) return;

      //var data = {'id':row.id};
      var data = {'id':row.id, 'woNo':woNo};
      await HttpUt.uploadZipAsync(context, 'api/Project/SendAuditZip', File(zipFile), data, true, (result) async {
        if (!checkResultError(context, result)) return;

        //callback
        if (fnOk != null) fnOk();
      });
    });
    */

    /*
    //send file first(by Yvonne)
    //upload zip file for both images & videos
    var data = {'id':row.id};
    await HttpUt.uploadZipAsync(context, 'api/Project/SendAuditZip', File(zipFile), data, true, (result) async {
      if (!checkResultError(context, result)) return;

      //then send row
      await _sendAuditRow2Async(context, row, showWait, fnOk);
    });
    */
  }

  /// zip files of folder (into temp folder)
  /// return file list, empty if no files
  static List<String>? _zipDir(String id, String fromDir, String toPath) {
    if (!FileUt.dirExist(fromDir)) return null;
    
    var files = Directory(fromDir).listSync();
    if (files.isEmpty) return null;
    
    //var toPath = FunUt.dirTemp + getDirName(fromDir) + '.zip';
    var encoder = ZipFileEncoder();
    encoder.create(toPath);

    List<String> result = [];
    for(var file in files){
      var path = file.path;
      var fileName = FileUt.getName(path);
      var fileStem = FileUt.getStem(fileName);
      var fileExt = FileUt.getExt(fileName);  //png,mp4
      var index = fileStem.substring(fileStem.length - 1);
      encoder.addFile(File(path),  '$id-$index.$fileExt');
      result.add(index);  //file index(base 0)
      //result.add(fileName);
    }
    encoder.close();
    return result;
  }

  /*
  //fnOk: fnOk(string woNo)
  static Future<void> _sendAuditRow2Async(BuildContext context, ProjectTab row, 
        bool showWait, [Function? fnOk]) async {
      var data = row.toServerJson();
      await HttpUt.getJsonAsync(context, 'api/Project/SendAudit', true, data, (result) async {
        if (!checkResultError(context, result)) return;

        //delete project row
        await ProjectTab.deleteAsync(row.id);

        if (fnOk != null) fnOk(getResult(result));
      }, null, showWait);
  }
  */

  /// get workOrder status name
  static String getWoStatusName(int status){
    switch (status) {
      case WorkStatusEnum.unAssign: return '未指派';
      case WorkStatusEnum.assigned: return 'assigned';
      case WorkStatusEnum.auditing: return '完工待審核';
      case WorkStatusEnum.closed: return 'closed';
      case WorkStatusEnum.refund: return 'refund';
      case WorkStatusEnum.waitClose: return 'waitClose';
      default: return '處理中';
    }
  }

} //class
