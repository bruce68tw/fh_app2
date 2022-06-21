import 'package:flutter/material.dart';
import 'package:base_lib/all.dart';
import 'all_com.dart';
import 'main_tab.dart';

class Login extends StatefulWidget {  
  const Login({Key? key}) : super(key: key);

  @override
  _LoginState createState() => _LoginState();
}

class _LoginState extends State<Login> {  
  final _formKey = GlobalKey<FormState>();
  bool _isOk = false;   //status
  int _actType = 0;
  ConfigTab? _config;

  //input fields
  final accountCtrl = TextEditingController();
  final pwdCtrl = TextEditingController();

  @override
  void initState() {
    //call before rebuild()
    super.initState();

    //讀取資料, call async rebuild
    Future.delayed(Duration.zero, ()=> showAsync());
  }

  Future showAsync() async {
    //initial config table if need
    _config = await ConfigTab.getAsync();
    if (_config == null) {
      _config = ConfigTab();
      await ConfigTab.insertAsync(_config!);
    } else {
      accountCtrl.text = _config!.account;
      _actType = _config!.login_radio;
    }

    setState(()=> _isOk = true);
  }

  Future onLoginAsync() async {
    //check input
    if (accountCtrl.text == '' || pwdCtrl.text == ''){
      ToolUt.msg(context, '帳號/密碼不可空白。');
      return;
    }

    //save ConfigTab
    _config!.account = accountCtrl.text;
    _config!.login_radio = _actType;
    await ConfigTab.updateAsync(_config!);

    //配合後端model, 使用大寫屬性
    var data = {
      'EmpID': accountCtrl.text,
      'PWD': pwdCtrl.text,
    };
    await HttpUt.getJsonAsync(context, 'api/Authorize/Login', true, data, (result){
      if (!Xp.checkResultError(context, result)) return;

      HttpUt.setToken(Xp.getResult(result));  //後端包了兩層 !!
      ToolUt.openForm(context, MainTab(actType: _actType));
    });
  }

  @override
  Widget build(BuildContext context) {
    if (!_isOk) return Container();

    //TODO: temp add
    //accountCtrl.text = 'Yvonne4';
    //pwdCtrl.text = '1234';

    //return SingleChildScrollView(
    return Material(child: SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          //image
          Container(
            alignment: Alignment.center, // This is needed
            child: Image.asset('images/login.png',
              fit: BoxFit.contain,
              //width: 300,
            ),
          ),

          //input fields
          Container(
            padding: const EdgeInsets.all(20),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(left:30, right:30, bottom:10),
                    child: Table(
                      columnWidths: const {
                        0: FlexColumnWidth(2),
                        1: FlexColumnWidth(5),
                      }, 
                      children: [
                        WG.itext2('帳號', accountCtrl, required:true),
                        WG.itext2('密碼', pwdCtrl, required:true, isPwd:true),
                  ])),
                  WG.iradio(['空氣',0,'能源',1,'專案',3], _actType, (value){
                    setState(()=> _actType = value);
                  }, isCenter: true),
                  WG2.tailCenter(WG.elevBtn('登入', ()=> onLoginAsync())),
                  const Align(
                    alignment: Alignment.bottomCenter,
                    child: Text('版本:' + Xp.version,
                      style: TextStyle(fontSize: Xp.fontSize),
                    )
                  )
    ])))])));
  }
  
} //class
