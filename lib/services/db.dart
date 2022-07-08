import 'package:base_lib/services/all.dart';

/// static class
class Db {

  /// project.save_flag: 0(未儲存,表示已領取), 1(有儲存,表示未上傳)
  /// 領取時必須設定 save_flag=0
  static void init() {
    DbUt.init('FH.db', 2, ['''
Create Table project(
  id Text Primary Key, 
  name Text,
  work_order_no Text,
  save_flag Integer not null default 0,
  area_id Text,
  work_class_id Text,
  work_dispatch_id Text,
  close_reason_id Text,
  close_reason_detail_id Text,
  latitude Real,
  longitude Real,
  work_date Text,
  address Text,
  location Text,
  signal Integer,
  note Text,
  other1 Text,
  other2 Text,
  other3 Text)
''','''
Create Table config(
  id Text Primary Key, 
  show_name Integer,
  show_work_date Integer,
  show_latitude Integer,
  show_longitude Integer,
  show_address Integer,
  show_location Integer,
  show_other1 Integer,
  show_other2 Integer,
  show_other3 Integer,
  account Text,
  login_radio Integer)
''']);
  }

} //class
