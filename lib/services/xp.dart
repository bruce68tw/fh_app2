import 'dart:io';
import 'package:flutter/material.dart';
import 'package:base_lib/all.dart';
import '../tables/project_tab.dart';

/// static class
class Xp {
  //=== constant start ===
  ///1.is https or not
  static const isHttps = false;
  static const isHttpsTest = false;
  static const version = '1.1';

  ///2.api server end point
  //home
  //static const apiServer = '192.168.1.100:5007';
  //static const apiServerTest = '192.168.1.100:5007';

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
  static const prjFixWcId = '14a8cee7-ac12-4679-bf22-dc0eb68957cd';   //維修
  static const prjCheckWcId = 'c224c312-71a4-4298-8509-e676fcdcc5e0'; //巡檢
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
    var zipFile = FileUt.zipDir(zipDir);
    if (zipFile == '') {
      await _sendAuditRow2Async(context, row, showWait, fnOk);
      return;
    } 

    //send file first(by Yvonne)
    //upload zip file for both images & videos
    var data = {'id':row.id};
    await HttpUt.uploadZipAsync(context, 'api/Project/SendAuditZip', File(zipFile), data, true, (result) async {
      if (!checkResultError(context, result)) return;

      //then send row
      await _sendAuditRow2Async(context, row, showWait, fnOk);
    });
  }

  static Future<void> _sendAuditRow2Async(BuildContext context, ProjectTab row, 
        bool showWait, [Function? fnOk]) async {
      var data = ProjectTab.toServerMap(row);
      await HttpUt.getJsonAsync(context, 'api/Project/SendAudit', true, data, (result) async {
        if (!checkResultError(context, result)) return;

        //delete project row
        await ProjectTab.deleteAsync(row.id);

        if (fnOk != null) fnOk();
      }, null, showWait);
  }

} //class
