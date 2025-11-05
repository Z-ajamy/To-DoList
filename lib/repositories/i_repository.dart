import '../models/base.dart';

abstract class IRepository {
  
  Future<void> save(Base obj); 
  Future<void> delete(Base obj);

  Future<Map<String, Base>> all();
  Future<Map<String, T>> getAllOfType<T extends Base>();
  Future<Base?> get(String key);

  Future<void> commit();
  Future<void> reload();
}
