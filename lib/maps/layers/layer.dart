import 'package:wurmapi/extensions/color_convert.dart';
import 'package:wurmapi/maps/layers/layer_type.dart';
import 'package:wurmapi/maps/layers/readers/tile_reader.dart';
import 'package:wurmapi/maps/layers/validation_exception.dart';
import 'package:wurmapi/maps/tiles/tile.dart';
import 'package:image/image.dart' as img;

class Layer {
  final LayerType type;
  final String mapFolder;
  final TileReader reader;

  int get size => reader.size;
  String get layerFilePath => "$mapFolder/${type.fileName}";

  Layer(this.type, this.mapFolder) : reader = TileReader.create(type);

  void openSync() {
    reader.openSync(layerFilePath);
  }

  Future<void> open() async {
    await reader.open(layerFilePath);
  }

  void closeSync() {
    reader.closeSync();
  }

  Future<void> close() async {
    await reader.close();
  }

  bool validateSync() {
    if (reader.magicNumber != type.magicNumber) {
      throw ValidationException(
          "Magic number mismatch. Expected: ${type.magicNumber}, got: ${reader.magicNumber}");
    }
    if (reader.version != type.version) {
      throw ValidationException(
          "Version mismatch. Expected: ${type.version}, got: ${reader.version}");
    }
    return true;
  }

  Future<bool> validate() async {
    if (reader.magicNumber != type.magicNumber) {
      throw ValidationException(
          "Magic number mismatch. Expected: ${type.magicNumber}, got: ${reader.magicNumber}");
    }
    if (reader.version != type.version) {
      throw ValidationException(
          "Version mismatch. Expected: ${type.version}, got: ${reader.version}");
    }
    return true;
  }

  List<Tile> tilesSync(int x, int y, int width, int height) {
    validateSync();
    var tiles = <Tile>[];
    for (var i = x; i < x + width; i++) {
      for (var j = y; j < y + height; j++) {
        tiles.add(reader.readTileSync(i, j));
      }
    }
    return tiles;
  }

  Stream<Tile> tiles(int x, int y, int width, int height) async* {
    await validate();
    for (var i = x; i < x + width; i++) {
      for (var j = y; j < y + height; j++) {
        yield await reader.readTile(i, j);
      }
    }
  }

  Tile tileSync(int x, int y) {
    validateSync();
    return reader.readTileSync(x, y);
  }

  Future<Tile> tile(int x, int y) async {
    await validate();
    return await reader.readTile(x, y);
  }

  Future<img.Image> image(int x, int y, int width, int height) async {
    var image = img.Image(width: width, height: height);
    await tiles(x, y, width, height).forEach((tile) {
      image.setPixel(
          tile.x - x, tile.y - y, ColorConvert.toImageColor(tile.info.color));
    });
    return image;
  }

  img.Image imageSync(int x, int y, int width, int height) {
    var image = img.Image(width: width, height: height);
    tilesSync(x, y, width, height).forEach((tile) {
      image.setPixel(
          tile.x - x, tile.y - y, ColorConvert.toImageColor(tile.info.color));
    });
    return image;
  }
}
