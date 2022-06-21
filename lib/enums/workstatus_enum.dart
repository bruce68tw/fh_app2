//map to server side
class WorkStatusEnum {
  /// 新增(未指派)
  static const unAssign = 1;        
  /// 處理中(已指派)
  static const assigned = 2;      
  /// 完工待審核
  static const auditing = 4;      
  /// 結案
  static const closed = 5;      
  /// 退單
  static const refund = 6;     
  /// 待結案
  static const waitClose = 7;  
}

