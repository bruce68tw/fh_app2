import 'dart:io';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
//import 'package:image_picker/image_picker.dart';
import 'package:video_player/video_player.dart';
import 'package:base_lib/all.dart';
import 'all_com.dart';

//如果row.Id='' 表示新增
class ProjectPhoto extends StatefulWidget {
  const ProjectPhoto({Key? key, required this.project, required this.config, required this.imagePath}) 
    : super(key: key);
  final ProjectTab project;   //input WorkClass.Id
  final ConfigTab config; //input WorkClass.Id
  final String imagePath;

  @override
  _ProjectPhotoState createState() => _ProjectPhotoState();
}

class _ProjectPhotoState extends State<ProjectPhoto> {  
  final _repaintKey = GlobalKey();
  bool _isOk = false;       //state variables
  late String _nowPhotoDir; //'new' or [uuid]
  final Image _noPhotoImage = Image.asset('images/noImage.png');
  final Image _noVideoImage = Image.asset('images/noVideo.png');
  final String _hasVideoImagePath = 'images/hasVideo.png';
  late Image _hasVideoImage;
  final int _photoLen = 6;
  final List<Image> _photoImages = [];
  final List<bool> _photoFlags = []; //true(image is change)
  final List<Image> _videoImages = [];
  final List<bool> _videoFlags = []; //true(image is change)
  int _nowPhtotNo = 0;
  int _nowVideoNo = 0;
  final String _tempPhoto = Xp.dirWoImage() + 'temp.png';
  final String _tempVideo = Xp.dirWoImage() + 'temp.mp4';
  CameraController? cameraCtrl;
  VideoPlayerController? videoCtrl;


  /// 從相簿選擇
  Future onPickAsync(BuildContext context2, bool isVideo) async {
  }

  /// 確定上傳圖檔
  Future copyPhotoAsync(String filePath) async {
    //copy file
    var newPath = Xp.dirWoImage(_nowPhotoDir, true) + 'image$_nowPhtotNo.jpg';
    await File(filePath).copy(newPath);
    
    _photoImages[_nowPhtotNo] = ImageUt.reload(newPath);
    _photoFlags[_nowPhtotNo] = true;

    setState((){});
  }

  String getNowVideoPath(){
    return Xp.dirWoImage(_nowPhotoDir, true) + 'video$_nowVideoNo.mp4';
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
    if (config.show_work_time == 1 && StrUt.notEmpty(project.work_time)){
      result.add(Text(project.work_time!, style: const TextStyle(fontSize:fontSize, color:color)));
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

  @override
  Widget build(BuildContext context) {
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
                    ImageUt.reload(widget.imagePath),
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
                        await copyPhotoAsync(_tempPhoto);
                        ToolUt.closeForm(context);
                      }),
                      WG2.hGap(),
                      WG.elevBtn('重新拍照', () async {
                        ToolUt.closeForm(context);
                        //openCameraDlg();
                      }),
                    ],
                  ),
                  WG.elevBtn('從相簿選擇', () async {
                    await onPickAsync(context, false);
          })])))
      ]);  
  }
  
} //class