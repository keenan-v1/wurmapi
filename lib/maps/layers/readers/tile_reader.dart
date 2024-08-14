import 'package:wurmapi/maps/layers/layer_type.dart';
import 'package:wurmapi/maps/layers/readers/default_tile_reader.dart';
import 'package:wurmapi/maps/tiles/tile.dart';

abstract class TileReader {
  int get size;
  int get version;
  int get magicNumber;

  // Sync methods
  void openSync(String layerFilePath);
  void closeSync();
  Tile readTileSync(int x, int y);

  // Async/Stream methods
  Future<Tile> readTile(int x, int y);
  Future<void> open(String layerFilePath);
  Future<void> close();

  TileReader();

  factory TileReader.create(LayerType type) => switch (type) {
        _ => DefaultTileReader(),
      };
}
