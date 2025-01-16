import 'package:collection/collection.dart';

abstract class DataDescriptor {
  Map<String, dynamic> toJson();
}

class DataList<T extends DataDescriptor> extends DelegatingList<T> {
  DataList({required this.items}) : super(items);

  factory DataList.fromJson(
    List<dynamic> jsonList,
    T Function(Map<String, dynamic>) fromJson,
  ) =>
      DataList(
        items: jsonList.map((json) => fromJson(json)).toList(),
      );

  List<T> items;

  List<Map<String, dynamic>> toJson() =>
      items.map((item) => item.toJson()).toList();

  void addItem(T item) => items.add(item);

  void removeItem(T item) => items.remove(item);

  T? getItem(int index) {
    if (index >= 0 && index < items.length) {
      return items[index];
    }
    return null;
  }
}
