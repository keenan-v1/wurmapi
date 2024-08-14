import 'dart:ui';

import 'package:wurmapi/extensions/color_convert.dart';
import 'package:yaml/yaml.dart';

class TileInfo {
  int id;
  String name;
  Color color;

  TileInfo(this.id, this.name, this.color);

  factory TileInfo.fromYaml(YamlMap yaml) {
    return TileInfo(
      yaml['id'],
      yaml['name'] ?? "",
      ColorConvert.from(yaml['color']),
    );
  }

  @override
  String toString() {
    return 'TileInfo(id: $id, name: $name, color: $color)';
  }
}