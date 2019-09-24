import 'package:flutter/foundation.dart';

class Folder {
  static final String tableName = "Folder";
  static final String columnId = "id";
  static final String columnName = "name";

  static final String collectionName = "folder";
  static final String columnUserId = "userId";

  static const String defaultId = "default";

  String id;
  String userId;
  String name;

  Folder({
    this.id = defaultId,
    this.userId,
    @required this.name,
  });

  Folder.fromMap(Map<String, dynamic> map) {
    id = map[columnId];
    userId = map[columnUserId];
    name = map[columnName];
  }

  Map<String, dynamic> toMap() {
    var map = Map<String, dynamic>();
    map[columnId] = id;
    map[columnUserId] = userId;
    map[columnName] = name;
    return map;
  }

  @override
  String toString() {
    return 'Folder{id: $id, userId: $userId, name: $name}';
  }
}
