import 'package:collection/collection.dart';

typedef Json = Map<String, dynamic>;

abstract class ToJson<T> {
  T toJson();
}

abstract class DataDescriptor extends ToJson<Json> {}

class DataList<T extends DataDescriptor> extends DelegatingList<T>
    implements ToJson<List<Json>> {
  DataList({required this.items}) : super(items);

  factory DataList.fromJson(
    List<dynamic> jsonList,
    T Function(Json) fromJson,
  ) =>
      DataList(
        items: jsonList.map((json) => fromJson(json)).toList(),
      );

  List<T> items;

  @override
  List<Json> toJson() => items.map((item) => item.toJson()).toList();

  void addItem(T item) => items.add(item);

  void removeItem(T item) => items.remove(item);

  T? getItem(int index) {
    if (index >= 0 && index < items.length) {
      return items[index];
    }
    return null;
  }
}
