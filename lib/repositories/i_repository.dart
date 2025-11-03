import '../models/base.dart';

abstract class IRepository{

  Future<void> save(Base obj);// save on obj
  Future<void>  delete(Base obj);// delete one obj
  Future<Map<String, Base>> all(); // get all objs
  Future<Map<String, T>> getAllOfType<T extends Base>();// get on type
  Future<Base?> get(String key);// get on obj

}
