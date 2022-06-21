//workOrder action
class WoActEnum {
  /// 新增(未指派)
  static const unAssign = 1;        
  /// 處理中(已指派)
  static const assigned = 2;      
  /// 已領取
  static const picked = 3;      
  /// 未上傳
  static const unUpload = 4;      
  /// 當日完工待審核
  static const auditing = 5;      
  /*
  /// 結案
  static const Closed = 5;      
  /// 退單
  static const Refund = 6;     
  /// 待結案
  static const WaitClose = 7;  
  */
}

