import 'package:flutter/material.dart';
import 'package:base_lib/all.dart';
import 'all_com.dart';
import 'project_images.dart';

class ProjectEdit extends StatefulWidget {
  const ProjectEdit({Key? key, required this.id, required this.areaId,
    required this.wcId, required this.isEdit}) : super(key: key);
  final String id;      //''(新增),有值表示 已領取/待審核
  final String areaId;  //for 設定預設值 if need
  final String wcId;    //input WorkClass.Id
  final bool isEdit;    //true(已領取), false(待審核)

  @override
  _ProjectEditState createState() => _ProjectEditState();
}

class _ProjectEditState extends State<ProjectEdit> {  
  bool _isOk = false;       //state variables
  late bool _isNew;     //新增
  late bool _isEdit;    //true(已領取, 可編輯),false(待審核, 唯讀)
  late ProjectTab _projectTab;
  late ConfigTab _configTab;

  final _formKey = GlobalKey<FormState>();

  //input fields
  final phoneCtrl = TextEditingController();
  final emailCtrl = TextEditingController();
  final addressCtrl = TextEditingController();
  final authCtrl = TextEditingController();
  final nameCtrl = TextEditingController();
  final latitudeCtrl = TextEditingController();
  final longitudeCtrl = TextEditingController();
  final locationCtrl = TextEditingController();
  final signalCtrl = TextEditingController();
  final noteCtrl = TextEditingController();
  final other1Ctrl = TextEditingController();
  final other2Ctrl = TextEditingController();
  final other3Ctrl = TextEditingController();
  final workDateCtrl = TextEditingController();
  final workTimeCtrl = TextEditingController();

  //select field variables
  String _wcId = '';
  String _dispatchId = '';
  String _areaId = '';
  String _closeId = '';
  String _closeDetailId = '';
  List<IdStrDto> _closeDetails = [];  //filtered by XpUt.closeDetails

  @override
  void initState() {    
    //initial variables
    _isNew = (widget.id == '');
    _isEdit = (!_isNew && widget.isEdit);

    //_wcId = Xp.workClasses.first.id;
    _wcId = widget.wcId;
    //_areaId = widget.areaId;
    //_dispatchId = Xp.dispatches.first.id;
    //_closeId = Xp.closes.first.id;
    //setCloseDetails(_closeId);

    super.initState();
    Future.delayed(Duration.zero, ()=> showAsync());
  }

  void setCloseDetails(String closeId){
    _closeDetails = Xp.closeDetails
      .where((a) => a.ext == closeId)
      .map((a) => IdStrDto(
        id: a.id,
        str: a.str,
      ))
      .toList();
  }

  Future showAsync() async {
    //get config table row
    var config = await ConfigTab.getJsonAsync();
    _configTab = (config == null)
      ? ConfigTab(id: '', 
        show_name: 1, 
        show_location: 1, 
        show_work_time: 1, 
        show_latitude: 1, 
        show_longitude: 1) 
      : ConfigTab.fromJson(config);

    //get row if need
    if (_isNew){
      _projectTab = ProjectTab(
        id: '', 
        name: '',
        save_flag: 1,
        work_class_id: _wcId,

        /*
        //temp add below
        //engineName: '工程1',
        //latitude: '100',
        //longitude: '120',
        address: '地址1',
        location: '位置1',
        signal: '訊號1',
        note: '備註1',
        other1: '其他1',
        other2: '其他2',
        other3: '其他',
        */
        work_time: DateUt.now2(),
      );

      rowToForm();
    } else {
      //先讀取本機, 如果不存在, 則讀取後端 DB 並寫入本機
      var id = widget.id;
      var project = await ProjectTab.getJsonAsync(id);

      //case of 讀取後端 DB 並寫入本機
      if (project == null){
        await HttpUt.getJsonAsync(context, 'api/Project/GetRow', false, {'id':id}, (result) async {
          var json = Xp.getResult(result);
          _projectTab = ProjectTab.fromServerJson(json);
          rowToForm();
        });
      } else {
        _projectTab = ProjectTab.fromJson(project);
        rowToForm();
      }
    }
  }

  //table row into form field
  rowToForm(){
    //input fields
    nameCtrl.text = _projectTab.name;
    latitudeCtrl.text = _projectTab.latitude ?? '';
    longitudeCtrl.text = _projectTab.longitude ?? '';
    addressCtrl.text = _projectTab.address ?? '';
    locationCtrl.text = _projectTab.location ?? '';
    signalCtrl.text = _projectTab.signal ?? '';
    noteCtrl.text = _projectTab.note ?? '';
    other1Ctrl.text = _projectTab.other1 ?? '';
    other2Ctrl.text = _projectTab.other2 ?? '';
    other3Ctrl.text = _projectTab.other3 ?? '';

    //get date, time
    if (StrUt.isEmpty(_projectTab.work_time)){
      workDateCtrl.text = '';
      workTimeCtrl.text = '';
    } else {
      var nowCols = _projectTab.work_time!.split(' ');
      workDateCtrl.text = nowCols[0];
      workTimeCtrl.text = nowCols[1];
    }

    //variables
    if (_isNew){
      _areaId = widget.areaId;
      _dispatchId = Xp.dispatches.first.id;
      _closeId = Xp.closes.first.id;
      setCloseDetails(_closeId);
      _closeDetailId = _closeDetails.first.id;
    } else {
      _areaId = _projectTab.area_id ?? '';
      _dispatchId = _projectTab.work_dispatch_id ?? '';
      _closeId = _projectTab.close_reason_id ?? '';
      setCloseDetails(_closeId);
      _closeDetailId = _projectTab.close_reason_detail_id ?? '';
    }

    _isOk = true;
    setState((){});
  }

  /// onclick 下一步
  Future<void> onNextAsync() async {
    //check input validation
    if (!_formKey.currentState!.validate()) return;

    //form to entity
    var project = ProjectTab(
      //id: const Uuid().v4(),
      id: widget.id,
      name: nameCtrl.text,
      save_flag: 1,
      work_dispatch_id: _dispatchId,
      work_class_id: _wcId,
      work_time: workDateCtrl.text + ' ' + workTimeCtrl.text,
      area_id: _areaId,
      latitude: latitudeCtrl.text,
      longitude: longitudeCtrl.text,
      address: addressCtrl.text,
      location: locationCtrl.text,
      signal: signalCtrl.text,
      close_reason_id: _closeId,
      close_reason_detail_id: _closeDetailId,
      note: noteCtrl.text,
      other1: other1Ctrl.text,
      other2: other2Ctrl.text,
      other3: other3Ctrl.text
    );
    
    var msg = await ToolUt.openFormAsync(context, 
      ProjectImages(isEdit: widget.isEdit, project:project, config:_configTab)) ?? '';
    if (msg == 'Back'){
      ToolUt.closeForm(context);  //回上一頁, 不必重整頁面
    } else if (msg != ''){
      ToolUt.closeForm(context, msg);
    }
  }

  /// 照片資訊
  /// 開啟組態視窗(Dialog)
  void openConfig() {
    showModalBottomSheet<int>(
      context: context,
      builder: (context2) {
        //使用 StatefulBuilder 才能更新 checkbox 狀態
        return StatefulBuilder(
          builder: (context3, setState) {
            return Column(
              children: [
                Padding(
                  //設定 padding bottom 會出現截斷 !!
                  padding: const EdgeInsets.only(left: 15, right: 15, top: 10),
                  child: Table(
                    columnWidths: const {
                      0: FlexColumnWidth(1),
                      1: FlexColumnWidth(1),
                    }, 
                    children: [
                      TableRow(children: [
                        WG.icheck('工程名稱', IntUt.toBool(_configTab.show_name), (value){                  
                          setState((){_configTab.show_name = value ? 1 : 0;});
                        }),
                        WG.icheck('設備位置', IntUt.toBool(_configTab.show_location), (value){                  
                          setState((){_configTab.show_location = value ? 1 : 0;});
                        }),
                      ]),
                      TableRow(children: [
                        WG.icheck('作業時間', IntUt.toBool(_configTab.show_work_time), (value){                  
                          setState((){_configTab.show_work_time = value ? 1 : 0;});
                        }),
                        WG.icheck('其他1', IntUt.toBool(_configTab.show_other1), (value){                  
                          setState((){_configTab.show_other1 = value ? 1 : 0;});
                        }),
                      ]),
                      TableRow(children: [
                        WG.icheck('緯度', IntUt.toBool(_configTab.show_latitude), (value){                  
                          setState((){_configTab.show_latitude = value ? 1 : 0;});
                        }),
                        WG.icheck('其他2', IntUt.toBool(_configTab.show_other2), (value){                  
                          setState((){_configTab.show_other2 = value ? 1 : 0;});
                        }),
                      ]),
                      TableRow(children: [
                        WG.icheck('經度', IntUt.toBool(_configTab.show_longitude), (value){                  
                          setState((){_configTab.show_longitude = value ? 1 : 0;});
                        }),
                        WG.icheck('其他3', IntUt.toBool(_configTab.show_other3), (value){                  
                          setState((){_configTab.show_other3 = value ? 1 : 0;});
                        }),
                      ]),
                      TableRow(children: [
                        WG.icheck('地址', IntUt.toBool(_configTab.show_address), (value){                  
                          setState((){_configTab.show_address = value ? 1 : 0;});
                        }),
                        const Text(''),
                      ]),
                ])),

                WG.elevBtn('確認', () async {
                  //save config table
                  if (_configTab.id == ''){
                    ConfigTab.insertAsync(_configTab);
                    _configTab.id = '1';  //change to update
                  } else {
                    ConfigTab.updateAsync(_configTab);
                  }
                  ToolUt.closeForm(context3);
                  ToolUt.msg(context, '儲存成功。');
                }),
    ]);});});
  }

  Future onReadLatLongAsync() async {
    ToolUt.openWait(context);
    var info = await DeviceUt.getGpsAsync(6);
    latitudeCtrl.text = info.latitude;
    longitudeCtrl.text = info.longitude;
    ToolUt.closeWait(context);
  }

  @override
  Widget build(BuildContext context) {
    if (!_isOk) return Container();

    var title = _isNew ? '新增' :
      _isEdit ? '已領取' :
      '當日完工待審核';

    //專案工單類別
    var isFix = (_wcId == Xp.prjFixWcId);     //維修
    var isCheck = (_wcId == Xp.prjCheckWcId); //巡檢
    var fixOrCheck = (isFix || isCheck);
    var isEdit = widget.isEdit;
    var dispatchStatus = isEdit && isFix;     //派工原因狀態
    var closeStatus = isEdit && fixOrCheck;   //結案原因/結案細節狀態
    //closeStatus = true;

    return Scaffold(
      appBar: WG2.appBar(title),
      body: SingleChildScrollView(
        padding: WG2.pagePad,
        child: Column(
          children: [
            Form(
              key: _formKey,
              child: Column(
                children: [
                  Table(
                    columnWidths: const {
                      0: FlexColumnWidth(3),
                      1: FlexColumnWidth(6),
                    }, 
                    children: [
                      WG.itext2('工程名稱', nameCtrl, required:true, status:isEdit),
                      WG.iselect2('作業類別', _wcId, Xp.workClasses, (value){                    
                        setState(() { _wcId = value; });
                      }, required:true, status:isEdit && _isNew),
                      //iselect2 value='' not work !!
                      WG.iselect2('派工原因', dispatchStatus ? _dispatchId : '', Xp.dispatches, (value){                    
                        setState(() { _dispatchId = value; });
                      }, required:true, status:dispatchStatus),
                      WG.idate2(context, '作業日期', workDateCtrl, (value)=>setState((){}), required:true, status:isEdit),
                      WG.itime2(context, '作業時間', workTimeCtrl, (value)=>setState((){}), required:true, status:isEdit),
                      WG.iselect2('區域', _areaId, Xp.areas, (value){                    
                        setState(() { _areaId = value; });
                      }, required:true, status:isEdit),
                      WG.itext2('緯度', latitudeCtrl, required:true, status:isEdit),
                      WG.itext2('經度', longitudeCtrl, required:true, status:isEdit),
                      WG.tableLabelWidget('', WG.elevBtn('讀取經緯度', isEdit ? onReadLatLongAsync : null)),

                      WG.itext2('地址', addressCtrl, status:isEdit),
                      WG.itext2('設備位置', locationCtrl, status:isEdit),
                      WG.itext2('現場訊號', signalCtrl, status:isEdit),
                      WG.iselect2('結案原因', _closeId, Xp.closes, (value){                    
                        setCloseDetails(value);
                        setState(() { _closeId = value; });
                      }, required:true, status:closeStatus),
                      WG.iselect2('結案細節', _closeDetailId, _closeDetails, (value){                    
                        setState(() { _closeDetailId = value; });
                      }, required:true, status:closeStatus),
                      WG.itext2('備註', noteCtrl, status:isEdit),
                      WG.itext2('其他1', other1Ctrl, status:isEdit),
                      WG.itext2('其他2', other2Ctrl, status:isEdit),
                      WG.itext2('其他3', other3Ctrl, status:isEdit),
                  ]),                  

                  Row(
                    children: [
                      (_isNew || _isEdit)
                        ? WG.elevBtn('照片資訊', openConfig)
                        : Container(),
                      const SizedBox(width: 5),
                      WG.elevBtn('下一步', onNextAsync)
                  ])])
    )])));
  }
  
} //class