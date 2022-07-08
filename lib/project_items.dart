import 'package:flutter/material.dart';
import 'package:base_lib/all.dart';
import 'all_com.dart';
import 'project_edit.dart';

//點擊 未指派/已指派 數字時開啟本畫面
class ProjectItems extends StatefulWidget {
  const ProjectItems({Key? key, required this.areaId, 
    required this.wcId, required this.actEnum}) : super(key: key);

  final String areaId;  //Area.Id
  final String wcId;    //WorkClass.Id
  final int actEnum;    //WoActEnum

  @override
  _ProjectItemsState createState() => _ProjectItemsState();
}

class _ProjectItemsState extends State<ProjectItems> {  
  bool _isOk = false;       //state variables
  late String _areaId = widget.areaId;  //empty means all
  List<ProjectItemDto> _rows = [];      //list rows from server
  int _checkeds = 0;   //checked count
  final addressCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    Future.delayed(Duration.zero, ()=> showAsync());
  }

  Future showAsync() async {
    //read db
    var readServer = true;  //從後端db讀取資料, false:read locale
    var act = '';
    switch(widget.actEnum){
      case WoActEnum.unAssign:
        act = 'UnAssigns'; break;
      case WoActEnum.assigned:
        act = 'Assigneds'; break;
      case WoActEnum.auditing:
        act = 'Auditings'; break;

      //get locale(已領取)
      case WoActEnum.picked:
        act = 'Pickeds'; 
        readServer = false;
        break;

      //get locale(未上傳)
      case WoActEnum.unUpload:
        act = 'Pickeds'; 
        readServer = false;
        break;
        
      default:
        ToolUt.msg(context, 'Input Wrong');
        return;
    }

    //read server
    if (readServer){
      var data = {
        'areaId': _areaId, 
        'wsId': widget.wcId,
      };
      await HttpUt.getJsonAsync(context, 'api/Project/$act', false, data, (result) async {
        var json = Xp.getResult(result);
        if (json == null) return;

        _rows = json.map((row) => ProjectItemDto.fromJson(row)).cast<ProjectItemDto>().toList(); //has cast<>
        setState(()=> _isOk = true);  
      });

    //read locale
    } else {      
      var sql = '''
select
  id as Id,
  name as Name,
  work_class_id as WorkClassId,
  address as Address,
  work_order_no as WorkOrderNo
from project 
where ('$_areaId'='' or area_id='$_areaId')
and work_class_id='${widget.wcId}'
and save_flag=${widget.actEnum == WoActEnum.unUpload ? 1 : 0}
''';
      var json = await DbUt.getMapsAsync(sql);
      _rows = json.map((row) => ProjectItemDto.fromJson(row)).cast<ProjectItemDto>().toList(); //has cast<>
      setState(()=> _isOk = true);  
    }    
  }

  //set checkeds count
  void setCheckeds() {
    _checkeds = _rows.where((a)=> a.checked).length;
  }

  //領取作業 for 未指派/已指派
  Future onPicksAsync() async {
    //get checked id list
    var list = getCheckedList(false);
    if (!hasCheckeds(list)) return;

    //call action & check result
    await HttpUt.getJsonAsync(context, 'api/Project/Picks', false, { 'list': list }, (result) async {
      String? data = Xp.getResult(result);
      if (data == null) return;

      //insert local db
      var count = 0;
      var ids = data.split(',');
      for(var row in _rows){
        if (row.checked && ids.contains(row.id)){
          var tab = ProjectTab(
            id: row.id, 
            name: row.name,
            work_order_no: row.workOrderNo,
            save_flag: 0,
            work_class_id: row.workClassId,
            //workDispatchId: row.workDispatchId,
            //workTime: row.workTime,
            //areaId: row.areaId,
            //latitude: row.latitude,
            //longitude: row.longitude,
            address: row.address,
            //location: row.location,
            //signal: row.signal,
            //closeReasonId: row.closeReasonId,
            //closeReasonDetailId: row.closeReasonDetailId,
            //note: row.note,
            //other1: row.other1,
            //other2: row.other2,
            //other3: row.other3
          );

          try{
            await ProjectTab.insertAsync(tab);
          } catch (error){
            await ProjectTab.updateAsync(tab);
          }
          count++;
      }}

      //close with msg
      ToolUt.closeForm(context, '成功領取 $count 筆資料。');
    });
  }

  //onclick (edit/view row)
  onEditAsync(String id, String wcId, bool isEdit, bool fromServer) async {
    var msg = await ToolUt.openFormAsync(context, 
      ProjectEdit(id: id, areaId: _areaId, wcId: wcId, isEdit: isEdit, fromServer: fromServer)) ?? '';
    if (msg != ''){
      ToolUt.msg(context, msg);
      await showAsync();
    }
  }

  bool hasCheckeds(String list){
    var empty = (list == '');
    if (empty){
      ToolUt.msg(context, '請先選取資料。');
    }
    return !empty;
  }

  String getCheckedList(bool comma){
    return _rows.where((a) => a.checked)
      .map((a) => comma ? "'${a.id}'" : a.id)
      .toList()
      .join(',');
  }

  //資料上傳審核 for 未上傳
  Future onUploadsAsync() async {
    //get checked id list
    var list = getCheckedList(true);
    if (!hasCheckeds(list)) return;

    var sql = '''
select * from project
where id in ($list)
''';
    var jsons = await DbUt.getMapsAsync(sql);
    var rows = jsons.map((a) => ProjectTab.fromJson(a)).cast<ProjectTab>().toList(); //has cast<>
    await Xp.sendAuditRowsAsync(context, rows, (){
      //回上個畫面
      ToolUt.closeForm(context, '資料上傳完成');
    });
  }

  /// 資料取消 by 已領取/未上傳 (已領取->未指派, 未上傳->刪除)
  /// isPakced: true(已領取), false(未上傳)
  Future onCancelsAsync(bool isPicked) async {
    //get checked id list
    var list = getCheckedList(true);
    if (!hasCheckeds(list)) return;

    if (isPicked){
    //update server db
    //call action & check result
    var data = { 'list': list.replaceAll("'", '') };  //後端不需要引號
    await HttpUt.getJsonAsync(context, 'api/Project/Cancels', false, data, (result) async {
      String? data = Xp.getResult(result);
      if (data == null) return;

      await _onCancelsAsync2(list);
    });
    } else {
      await _onCancelsAsync2(list);
    }
  }

  Future _onCancelsAsync2(String list) async {
    //delete locale db(no locale files)
    await ProjectTab.deletesAsync(list);

    //show msg
    ToolUt.msg(context, '作業完成。');
    await showAsync();
  }

  /// projectPicks to widget list
  /// 同時計算筆數與過濾地址
  /// @rows source rows
  /// @act C(checkbox),E(編輯),V(檢視)
  /// @return list widget
  void widgetsAddRows(List<Widget> widgets, List<ProjectItemDto> rows, 
    bool showCheck, String? editFun, bool fromServer) {
    //if (rows.isEmpty) return WG2.emptyMsg();

    var address = addressCtrl.text;
    //var isEdit = (btnType == 'E');
    for (int i = 0; i < rows.length; i++) {
      //過濾地址
      var row = rows[i];
      if (address != '' && !row.address.contains(address)){
        continue;
      }

      //add checkbox or text
      var statusName = Xp.getWoStatusName(row.status);
      widgets.add(
        showCheck 
          ? SizedBox(
              height: 35,
              child: WG.icheck(statusName, row.checked, (value){
                setState(()=> row.checked = value);
            }))
          : WG.getText(statusName)
      );

      //add text with onclick function
      widgets.add(InkWell(
        onTap: (editFun == null)
          ? null
          : ()=> onEditAsync(row.id, row.workClassId, (editFun == 'E'), fromServer),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            WG.getText(row.name),
            WG.getText(row.address),
            WG.getText(row.workOrderNo),
        ])));

      widgets.add(WG2.divider());
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!_isOk) return Container();

    var title = '';
    var showCheck = true;   //show checkbox
    var fromServer = true;  //read rows from server
    String? editFun;        //null,E(edit),V(view) 
    var actEnum = widget.actEnum;
    switch(actEnum){
      case WoActEnum.unAssign:
        title = '未指派'; 
        break;
      case WoActEnum.assigned:
        title = '已指派'; 
        break;
      case WoActEnum.picked:
        title = '已領取'; 
        //showCheck = false;
        fromServer = false;
        editFun = 'E';  //edit
        break;
      case WoActEnum.unUpload:
        title = '未上傳'; 
        fromServer = false;
        editFun = 'E';  //edit
        break;
      case WoActEnum.auditing:       
        title = '當日完工待審核'; 
        showCheck = false;
        editFun = 'V';  //view
        break;
    }

    //計算筆數
    setCheckeds();

    //上方查詢欄位
    var areaWidget = showCheck
      ? WG.tableLabelWidget('區域', WG2.areaField('', _areaId, 160, (value) async {
          _areaId = value;
          await showAsync();
        }, '已選擇 $_checkeds 筆'))
      : WG.iselect2('區域', _areaId, Xp.areas, (value) async {
          _areaId = value;
          await showAsync();
      });
    //body, value參數配合 projectPicksToWidgets()
    List<Widget> widgets = [
      Table(
        columnWidths: const {
          0: FlexColumnWidth(1),
          1: FlexColumnWidth(4),
        }, 
        children: [
          areaWidget,
          WG.itext2('地址', addressCtrl, required:false, 
            fnOnChange: (value)=> setState((){}))
    ])];

    //add rows
    widgets.add(WG2.vGap());
    widgetsAddRows(widgets, _rows, showCheck, editFun, fromServer);

    //add tail button if need
    if (actEnum == WoActEnum.unAssign || actEnum == WoActEnum.assigned) {
      widgets.add(WG2.centerElevBtn('領取作業', onPicksAsync));
    } else if(actEnum == WoActEnum.picked) {
      //已領取
      widgets.add(WG2.centerElevBtn('資料取消', ()=> onCancelsAsync(true)));
    } else if(actEnum == WoActEnum.unUpload) {
      //未上傳
      widgets.add(Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          WG.elevBtn('資料上傳', onUploadsAsync),
          WG2.hGap(),
          WG.elevBtn('資料取消', ()=> onCancelsAsync(false))
      ]));
    }

    return Scaffold(
      appBar: WG2.appBar(title),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(5),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: widgets
      )));    
  }

} //class