import 'dart:io';

import 'package:flutter/services.dart';
import 'package:wurmapi/maps/tiles/tile_info.dart';
import 'package:yaml/yaml.dart';
import 'package:logging/logging.dart';

class TileInfoRepository {
  static const String defaultFile = 'packages/wurmapi/assets/config/tiles.yaml';
  static TileInfoRepository? _instance;

  final Map<int, TileInfo> _tileInfoMap = {};
  final Logger _logger = Logger('TileInfoRepository');

  TileInfoRepository._();

  factory TileInfoRepository() {
    _instance ??= TileInfoRepository._();
    return _instance!;
  }  

  TileInfo? getTileInfo(int tileId) {
    return _tileInfoMap[tileId];
  }

  Future<void> _load(String filePath) async {
    String yamlString = "";
    if (filePath.startsWith("packages/")) {
      yamlString = await rootBundle.loadString(defaultFile);
    } else {
      yamlString = File(filePath).readAsStringSync();
    }
    _logger.fine("Loaded yaml: $filePath");
    var yamlMap = loadYaml(yamlString);
    for (var tile in yamlMap["tiles"]) {
      TileInfo tileInfo = TileInfo.fromYaml(tile);
      if (_tileInfoMap.containsKey(tileInfo.id)) {
        _logger.fine("Updating tile: $tileInfo");
        tileInfo.name = _tileInfoMap[tileInfo.id]?.name ?? tileInfo.name;
      } else {
        _logger.fine("Loading tile: $tileInfo");
      }
      _tileInfoMap[tileInfo.id] = tileInfo;
    }
  }

  Future<void> loadAll({List<String>? filePaths, bool clear = false}) async {
    if (clear) {
      _tileInfoMap.clear();
    }
    await _load(defaultFile);
    for (var filePath in filePaths ?? []) {
      await _load(filePath);
    }
  }

  void updateColor(int tileId, Color color) {
    if (_tileInfoMap.containsKey(tileId)) {
      _tileInfoMap[tileId]!.color = color;
    }
  }
}