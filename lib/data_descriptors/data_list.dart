import 'data_descriptor.dart';
import 'package:collection/collection.dart';
class DataList<T extends DataDescriptor> extends DelegatingList<T> {
  List<T> items;

  DataList({required this.items}) : super(items);

  factory DataList.fromJson(List<dynamic> jsonList, T Function(Map<String, dynamic>) fromJson) {
    List<T> items = jsonList.map((json) => fromJson(json)).toList();
    return DataList(items: items);
  }

  List<Map<String, dynamic>> toJson() {
    return items.map((item) => item.toJson()).toList();
  }

  void addItem(T item) {
    items.add(item);
  }

  void removeItem(T item) {
    items.remove(item);
  }

  T? getItem(int index) {
    if (index >= 0 && index < items.length) {
      return items[index];
    }
    return null;
  }
}