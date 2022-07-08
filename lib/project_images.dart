import 'dart:io';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:video_player/video_player.dart';
import 'package:base_lib/all.dart';
import 'all_com.dart';

//如果row.Id='' 表示新增
class ProjectImages extends StatefulWidget {
  const ProjectImages({Key? key, required this.isEdit, 
    required this.project, required this.config}) : super(key: key);
  final bool isEdit;
  final ProjectTab project;
  final ConfigTab config;

  @override
  _ProjectImagesState createState() => _ProjectImagesState();
}

class _ProjectImagesState extends State<ProjectImages> { 
  //上傳圖檔固定轉成png
  final _repaintKey = GlobalKey();
  bool _isOk = false;       //state variables
  late bool _isNew;         //true(new) or false(edit)
  late bool _isEdit;        //widget.isEdit, true(can edit) or false(readonly)
  bool _isVideo = false;    //true(image), false(video)
  late String _nowPhotoDir; //'new' or [uuid]
  final Image _noPhotoImage = Image.asset('images/noImage.png');
  final Image _noVideoImage = Image.asset('images/noVideo.png');
  final String _hasVideoImagePath = 'images/hasVideo.png';
  late Image _hasVideoImage;
  final int _photoLen = 6;
  final List<Image> _photoImages = [];
  final List<bool> _photoFlags = []; //true(image is change)
  final List<Image> _videoImages = [];
  final List<bool> _videoFlags = []; //true(video is change)
  int _nowPhtotNo = 0;  //current work photo index
  int _nowVideoNo = 0;
  //final String _tempPhoto = Xp.dirWoImage() + 'temp.png';
  final String _tempVideo = Xp.dirWoImage() + 'temp.mp4';
  CameraController? cameraCtrl;
  VideoPlayerController? videoCtrl;
  Future<void>? _videoPlayerFuture;   //for video player
  String _flashType = 'A';  //default auto

  //flash type list
  final List<IdStrDto> _flashTypeList = [
    IdStrDto(id:'A', str:'自動'),
    IdStrDto(id:'1', str:'開啟'),
    IdStrDto(id:'0', str:'關閉'),
  ];
  //flash icon list
  final Map<String, IconData> _flashIcon = {
    'A': Icons.flash_auto,
    '1': Icons.flash_on,
    '0': Icons.flash_off
  };

  //video status
  static const _videoReady = 0;
  static const _videoRecording = 1;
  static const _videoStop = 2;
  int _videoStatus = _videoReady;

  @override
  void initState() {
    //initial variables
    _isNew = (widget.project.id == '');
    _isEdit = widget.isEdit;
    _nowPhotoDir = _isNew ? Xp.dirNewImage : widget.project.id;
    _hasVideoImage = Image.asset(_hasVideoImagePath);

    //videoCtrl!.initialize();

    //reset
    //_photoImages.clear();
    //_photoFlags.clear();
    //_videoImages.clear();
    //_videoFlags.clear();
    for (var i=0; i<_photoLen; i++){
      _photoImages.add(_noPhotoImage);
      _photoFlags.add(false);
      _videoImages.add(_noVideoImage);
      _videoFlags.add(false);
    }

    //load photo/video image
    if (_isNew){
      //delete folder files if need
      FileUt.deleteDirFiles(Xp.dirWoImage(Xp.dirNewImage));
    } else if(_isEdit) {
      //get image from locale
      var dirWo = Xp.dirWoImage(widget.project.id);
      for (var i=0; i<_photoLen; i++){
        //for photo
        var path = '${dirWo}image$i.png';
        var image = FileUt.exist(path)
          ? Image.file(File(path)) 
          : _noPhotoImage;
        _photoImages[i] = image;
        //_photoFlags[i] = false;

        //for video
        path = '${dirWo}video$i.mp4';
        /*
        image = FileUt.exist(path)
          ? _hasVideoImage 
          : _noVideoImage;
        _videoImages.add(image);
        */
        setVideoImage(i, FileUt.exist(path));
        //_videoFlags.add(false);
      }
    }

    super.initState();
    Future.delayed(Duration.zero, ()=> showAsync());
  }

  void setVideoImage(int index, bool hasVideo){
    _videoImages[index] = hasVideo ? _hasVideoImage : _noVideoImage;
  }

  @override
  void dispose() {
    if (cameraCtrl != null) cameraCtrl!.dispose();
    if (videoCtrl != null) videoCtrl!.dispose();

    super.dispose();
  }

  Future showAsync() async {
    //initial camera if need
    if (_isEdit) {
        await initCamera();
    } else {
        if (!_isEdit) await showWebMediaAsync(widget.project.id);

        setState(()=> _isOk = true);
    }
  }

  /// show web photo & vidoe
  Future showWebMediaAsync(String woId) async {
    //photo
    ToolUt.openWait(context);

    for(var i=0; i<_photoLen; i++){
      var data = { 'woId': woId, 'index': i.toString() };
      var image = await HttpUt.getImageAsync(context, 'api/Project/WoImage', data, false);
      if (image != null){
        _photoImages[i] = image;
      }
    }

    //video
    await HttpUt.getJsonAsync(context, 'api/Project/WoVideos', false, { 'woId':woId }, (result){
      String data = Xp.getResult(result);
      if (data == '' || !Xp.checkResultError(context, result)){
        ToolUt.closeWait(context);
        return;
      } 

      var sortList = data.split(',');
      for(var i=0; i<sortList.length; i++){
        var index = int.parse(sortList[i]) - 1;
        setVideoImage(index, true);
      }

      ToolUt.closeWait(context);
    }, null, false);

    //ToolUt.closeWait(context);
  }

  Future initCamera() async {
    //initial camera
    var cameras = await availableCameras();
    if(cameras.isEmpty){
      ToolUt.msg(context, 'No Camera !!');
    } else {
      cameraCtrl = CameraController(cameras[0], ResolutionPreset.max);            
      cameraCtrl!.initialize().then((_) {
        if (mounted) {
          setState(()=> _isOk = true);
        }        
      });
    }        
  }

  /// 傳回camera image
  Widget getPhotoImage(int index){
    return Material(
      child: InkWell(
        child: _photoImages[index],
        onTap: _isEdit 
          ? (){
            _isVideo = false;
            _nowPhtotNo = index;
            openCameraDlg();
          }
          : null
    ));
  }

  /// 傳回 video image
  Widget getVideoImage(int index){
    return Material(
      child: InkWell(
        child: _videoImages[index],
        onTap: _isEdit 
          ? (){
            _isVideo = true;
            _nowVideoNo = index;
            openCameraDlg();
          }
          : null
    ));
  }

  /// 拍照或選取圖片時寫入文字
  /// param context : 相機預覽畫面
  Future onTakePhotoAsync(BuildContext context2, XFile? file) async {
    if (file == null) return;

    //加上文字, 然後寫入暫存圖檔
    //photoAddText(file, _tempPhoto);

    //關閉相機預覽
    ToolUt.closeForm(context2);

    //開啟另一個 dialog
    openPhotoDlg(file.path);
    //ToolUt.openForm(context, ProjectPhoto(project:widget.project, config:widget.config, imagePath:file.path));
  }

  /// 從相簿選擇照片
  Future onPickPhotoAsync(BuildContext context2) async {
    var file = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (file == null) return;

    //copy file
    await copyPhotoAsync(file.path);  //調整圖檔大小?
    ToolUt.closeForm(context2);
  }

  /// 從相簿選擇影片
  Future onPickVideoAsync(BuildContext context2) async {
    var file = await ImagePicker().pickVideo(source: ImageSource.gallery);
    if (file == null) return;

    //copy file
    await copyVideoAsync(file.path, context2);
  }

  //get current image path, 上傳壓縮時才改成正確檔名
  //image format fixed to .png
  String getNowPhotoPath(){
    return Xp.dirWoImage(_nowPhotoDir, true) + 'image$_nowPhtotNo.png';
    //return Xp.dirWoImage(_nowPhotoDir, true) + StrUt.uuid() + '.png';
  }

  String getNowVideoPath(){
    return Xp.dirWoImage(_nowPhotoDir, true) + 'video$_nowVideoNo.mp4';
    //return Xp.dirWoImage(_nowPhotoDir, true) + StrUt.uuid() + '.mp4';
  }

  /// copy image to wo image folder
  /// 確定上傳圖檔
  Future copyPhotoAsync(String fromPath) async {
    //copy file
    var newPath = getNowPhotoPath();
    await File(fromPath).copy(newPath);
    
    _photoImages[_nowPhtotNo] = ImageUt.reload(newPath);
    _photoFlags[_nowPhtotNo] = true;
    setState((){});
  }

  /// copy video file, 確定上傳影片
  Future<void> copyVideoAsync(String filePath, [BuildContext? context2]) async {
    //check 
    var newPath = getNowVideoPath();
    if(filePath == newPath){
      if (context2 != null){
        ToolUt.closeForm(context2);
      }
      ToolUt.msg(context, '已完成。');
      return;
    }
    
    //copy file
    await File(filePath).copy(newPath);

    _videoImages[_nowVideoNo] = await ImageUt.reloadAssetAsync(_hasVideoImagePath);
    _videoFlags[_nowVideoNo] = true;

    if (context2 != null){
      ToolUt.closeForm(context2);
    }
    ToolUt.msg(context, '已完成。');
    setState((){});
  }

  //repaint screen widget to image file
  Future repaintToImageAsync() async {
    //copy file
    var newPath = getNowPhotoPath();
    await ImageUt.repaintToImageAsync(_repaintKey, newPath);
    
    _photoImages[_nowPhtotNo] = ImageUt.reload(newPath);
    _photoFlags[_nowPhtotNo] = true;
    setState((){});
  }

  /// 設定閃光燈模式
  void setFlashMode(String type){
    var mode = (type == 'A') ? FlashMode.auto :
      (type == '1') ? FlashMode.always :
      FlashMode.off;
    cameraCtrl!.setFlashMode(mode);
  }

  /// 下拉式欄位 for 閃光燈
  Widget iselect2(String value, IconData icon, List<IdStrDto> rows, Function fnOnChange){
    return Padding(
      padding: const EdgeInsets.only(left:10),
      child: DropdownButton(
        value: value,
        //icon: const Icon(Icons.flag),
        icon: Icon(icon, color: Colors.blue),
        style: const TextStyle(fontSize:18, color: Colors.blue),
        items: rows.map((IdStrDto row) {
          return DropdownMenuItem<String>(
            child: Text(row.str),
            value: row.id,
          );
        }).toList(),
        onChanged: (value2)=> fnOnChange(value2),
    ));
  }

  /// 開始錄影/停止錄影
  Future onRecordVideoAsync(BuildContext context) async{
    if (_videoStatus == _videoRecording){
      //copy video file 到暫存檔案
      final file = await cameraCtrl!.stopVideoRecording();
      await File(file.path).copy(_tempVideo);
    } else {
      await cameraCtrl!.startVideoRecording();
    }
  }

  /// 開啟相機預覽視窗(Dialog), 含選取圖片按鈕
  /// 選取後關閉
  void openCameraDlg() {
    _videoStatus = _videoReady;
    
    showGeneralDialog(
      context: context,
      barrierDismissible: false,
      pageBuilder: (context2, animation, secondaryAnimation) {
        return StatefulBuilder(
          builder: (context3, setState) {
            return Material(
              child: Stack(
                fit: StackFit.expand,
              children: [
                //解決影像失真的問題
                MaterialApp(
                  home: CameraPreview(cameraCtrl!),
                ),
                Align(
                  alignment: FractionalOffset.bottomCenter,
                  child: Padding(
                    padding: const EdgeInsets.only(bottom: 10.0),
                    child: 
                      //image
                      !_isVideo ? Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          WG.elevBtn('拍照', () async {
                            var file = await cameraCtrl!.takePicture();
                            await onTakePhotoAsync(context2, file);
                          }),
                          WG2.hGap(),
                          WG.elevBtn('從相簿選擇', () async {
                            await onPickPhotoAsync(context2);
                          }),
                          WG2.hGap(),
                          SizedBox(
                            width: 80,
                            child: iselect2(_flashType, _flashIcon[_flashType]!, _flashTypeList, (value){
                              setFlashMode(value);
                              setState(() { _flashType = value; });
                        }))]) :   

                      //video-level1
                      (_videoStatus == _videoReady) ? Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          WG.elevBtn('開始錄影', () async {
                            await onRecordVideoAsync(context2);
                            setState(()=> _videoStatus = _videoRecording);  //only inline workable
                          }),
                          WG2.hGap(),

                          //has video
                          (_videoFlags[_nowVideoNo])
                            ? Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  WG.elevBtn('播放', () async {
                                    setState((){
                                      ToolUt.closeForm(context2);
                                      playVideo(true, getNowVideoPath());
                                  });}),
                                  WG2.hGap(),
                              ])
                            : Container(),

                        WG.elevBtn('從相簿選擇', () async {
                          await onPickVideoAsync(context2);
                        })
                      ]) :

                      //video-level1(after video start) 開始錄影
                      (_videoStatus == _videoRecording) ?
                        WG.elevBtn('停止錄影', () async {
                          await onRecordVideoAsync(context2);
                          setState(()=> _videoStatus = _videoStop);  //only inline workable
                        }) : 

                      //video-level1(after video stop) 停止錄影
                      Column(
                        mainAxisAlignment: MainAxisAlignment.end,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              WG.elevBtn('確定上傳影片', () async {
                                await copyVideoAsync(_tempVideo, context2);
                              }),
                              WG2.hGap(),
                              WG.elevBtn('重新錄影', () async {
                                ToolUt.closeForm(context2);
                                openCameraDlg();
                              }),
                          ]),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              WG.elevBtn('從相簿選擇', () async {
                                await onPickVideoAsync(context2);
                              }),
                              WG2.hGap(),
                              WG.elevBtn('播放', () async {
                                setState((){
                                  ToolUt.closeForm(context2);
                                  playVideo(true, _tempVideo);
                                });
                      })])])
    ))]));});});
  }

  void playVideo(bool init, String path){
    openPlayerDlg(path);

    if (init){
      videoCtrl = VideoPlayerController.file(File(path));
      _videoPlayerFuture = videoCtrl!.initialize();
    }
    videoCtrl!.play();
  }

  /// 開啟影片播放畫面
  void openPlayerDlg(String filePath) {
    showGeneralDialog(
      context: context,
      barrierDismissible: false,
      pageBuilder: (context2, animation, secondaryAnimation) {
        return Stack(
          children: [
            //解決影像失真的問題
            FutureBuilder(
              future: _videoPlayerFuture,
              builder: (context3, snapshot) {
                return Center(
                  child: VideoPlayer(videoCtrl!)
                );
              }
            ),
            Align(
              alignment: FractionalOffset.bottomCenter,
              child: Padding(
                padding: const EdgeInsets.only(bottom: 10.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      WG.elevBtn('確定上傳影片', () async {
                        await copyVideoAsync(filePath, context2);
                      }),
                      WG2.hGap(),
                      WG.elevBtn('重新錄影', () async {
                        ToolUt.closeForm(context2);
                        openCameraDlg();
                    })],
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      WG.elevBtn('從相簿選擇', () async {
                        await onPickVideoAsync(context2);
                      }),
                      WG2.hGap(),
                      WG.elevBtn('重新播放', () async {
                        //videoCtrl!.play();
                        playVideo(false, filePath);
                  })])
    ])))]);});
  }

  /// 開啟相機預覽視窗(Dialog), 含選取圖片按鈕
  /// 選取後關閉
  void openPhotoDlg(String imagePath) {
    showGeneralDialog(
      context: context,
      barrierDismissible: false,
      //barrierColor: Colors.red,
      pageBuilder: (context2, animation, secondaryAnimation) {
        return Stack(
          children: [
            //圖檔內容
            RepaintBoundary(
              key: _repaintKey,
              //Material for remove text underline
              child: Material(child:
                Stack(
                  //set fit type, or will be cut !!
                  fit: StackFit.expand,
                  children: [
                    //ImageUt.reload(imagePath),
                    Image.file(File(imagePath)),
                    FittedBox(
                      fit: BoxFit.fill,
                      child: Image.file(File(imagePath)),
                    ),
                    Align(
                      alignment: FractionalOffset.bottomLeft,
                      child: Padding(
                        padding: const EdgeInsets.only(bottom:10, left:10),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.end,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: getPhotoWords()
                  )))]
            ))),

            //功能按鈕
            Align(
              alignment: FractionalOffset.bottomCenter,
              child: Padding(
                padding: const EdgeInsets.only(bottom: 10.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      WG.elevBtn('確定上傳照片', () async {
                        await repaintToImageAsync();
                        ToolUt.closeForm(context2);
                      }),
                      WG2.hGap(),
                      WG.elevBtn('重新拍照', () async {
                        ToolUt.closeForm(context2);
                        openCameraDlg();
                      }),
                    ],
                  ),
                  WG.elevBtn('從相簿選擇', () async {
                    await onPickPhotoAsync(context2);
          })])))
      ]);
    });
  }

  /// 圖檔加上文字同時寫入手機disk
  List<Widget> getPhotoWords(){

    const fontSize = 18.0;
    const color = Colors.red;

    List<Widget> result = [];
    //寫入文字, 由下到上
    var config = widget.config;
    var project = widget.project;
    if (config.show_name == 1 && StrUt.notEmpty(project.name)){
      result.add(Text(project.name, style: const TextStyle(fontSize:fontSize, color:color)));
    }
    if (config.show_work_date == 1 && StrUt.notEmpty(project.work_date)){
      result.add(Text(project.work_date!, style: const TextStyle(fontSize:fontSize, color:color)));
    }
    if (config.show_location == 1 && StrUt.notEmpty(project.location)){
      result.add(Text(project.location!, style: const TextStyle(fontSize:fontSize, color:color)));
    }
    if (config.show_longitude == 1 && StrUt.notEmpty(project.longitude)){
      result.add(Text('Lon: '+project.longitude!, style: const TextStyle(fontSize:fontSize, color:color)));
    }
    if (config.show_latitude == 1 && StrUt.notEmpty(project.latitude)){
      result.add(Text('Lat: '+project.latitude!, style: const TextStyle(fontSize:fontSize, color:color)));
    }
    if (config.show_address == 1 && StrUt.notEmpty(project.address)){
      result.add(Text(project.address!, style: const TextStyle(fontSize:fontSize, color:color)));
    }
    if (config.show_other1 == 1 && StrUt.notEmpty(project.other1)){
      result.add(Text(project.other1!, style: const TextStyle(fontSize:fontSize, color:color)));
    }
    if (config.show_other2 == 1 && StrUt.notEmpty(project.other2)){
      result.add(Text(project.other2!, style: const TextStyle(fontSize:fontSize, color:color)));
    }
    if (config.show_other3 == 1 && StrUt.notEmpty(project.other3)){
      result.add(Text(project.other3!, style: const TextStyle(fontSize:fontSize, color:color)));
    }

    return result;       
  }

  bool checkInput(){
    for(var i=0; i<3; i++){
      if (_photoImages[i] == _noPhotoImage && _videoImages[i] == _noVideoImage){
        ToolUt.msg(context, '施工前、施工中、施工後的圖檔/影片必須擇一上傳。');
        return false;
      }
    }

    //case of ok
    return true;
  }

  /// 離線儲存
  Future onOffSaveAsync() async {
    if (!checkInput()) return;

    var ok = false;
    var row = widget.project;
    //var uuid = '';
    if (_isNew){
      //uuid = StrUt.uuid();
      //widget.project.id = uuid;
      row.id = StrUt.uuid();
      ok = await ProjectTab.insertAsync(row);
    } else {
      ok = await ProjectTab.updateAsync(row);
    }

    if (ok){
      //修改目錄名稱 if new row
      if (_isNew){
        var dirWo = Xp.dirWoImage();
        FileUt.renameDir(dirWo + Xp.dirNewImage, dirWo + row.id);
      }

      ToolUt.closeForm(context, '資料儲存完成。');
    } else {
      ToolUt.msg(context, '儲存失敗。');
    }
  }

  //完工送審核
  Future onAuditAsync() async {
    if (!checkInput()) return;

    await Xp.sendAuditRowAsync(context, _isNew, widget.project, true, (){
      //close form with return true
      ToolUt.closeForm(context, '資料送出審核。');
    });    
  }

  @override
  Widget build(BuildContext context) {
    if (!_isOk) return Container();

    return Scaffold(
      appBar: WG2.appBar('設定照片&影像'),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(5),
        child: Table(
          columnWidths: const {
            0: FlexColumnWidth(2),
            1: FlexColumnWidth(4),
            2: FlexColumnWidth(4)
          }, 
          children: [
            //head btns
            TableRow(children: [
              const Text(''), 
              WG.centerText('拍照'),
              WG.centerText('影像'),
            ]),

            //pic/video body
            TableRow(children: [WG.reqLabel('施工前'), getPhotoImage(0), getVideoImage(0)]),
            TableRow(children: [WG.reqLabel('施工中'), getPhotoImage(1), getVideoImage(1)]),
            TableRow(children: [WG.reqLabel('施工後'), getPhotoImage(2), getVideoImage(2)]),
            TableRow(children: [WG.getLabel('其他1'), getPhotoImage(3), getVideoImage(3)]),
            TableRow(children: [WG.getLabel('其他2'), getPhotoImage(4), getVideoImage(4)]),
            TableRow(children: [WG.getLabel('其他3'), getPhotoImage(5), getVideoImage(5)]),

            //tail btns
            _isEdit
              ? TableRow(children: [
                  const Text(''),
                  Padding(
                    padding: const EdgeInsets.only(left:5, right:5),
                    child: WG.elevBtn('離線儲存', ()=> onOffSaveAsync())
                  ),
                  Padding(
                    padding: const EdgeInsets.only(left:5, right:2),
                    child: WG.elevBtn('完工送審核', ()=> onAuditAsync())     
                )])
              : TableRow(children: [
                  const Text(''),
                  Padding(
                    padding: const EdgeInsets.only(left:5, right:5),
                    child: WG.elevBtn('返回清單', ()=> ToolUt.closeForm(context, 'Back'))
                  ),
                  Container()
                ])
    ])));
  }
  
} //class