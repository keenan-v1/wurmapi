import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:image/image.dart' as img;
import 'package:wurmapi/extensions/color_convert.dart';
import 'package:wurmapi/maps/layers/layer.dart';
import 'package:wurmapi/maps/layers/layer_type.dart';
import 'package:wurmapi/maps/layers/validation_exception.dart';
import 'package:wurmapi/maps/tiles/tile.dart';
import 'package:wurmapi/maps/tiles/tile_info.dart';
import 'package:wurmapi/maps/tiles/tile_info_repository.dart';

void main() async {
  TestWidgetsFlutterBinding.ensureInitialized();
  TileInfoRepository().loadAll(clear: true);
  Layer? layer;
  Tile emptyTile =
      Tile(-1, -1, TileInfo(-1, 'Unknown', ColorConvert.from("#000")));

  group('Layer sync:', () {
    setUp(() {
      TileInfoRepository().loadAll(clear: true);
    });

    tearDown(() {
      layer?.closeSync();
    });

    test('test validateSync on valid map file', () {
      layer = Layer(LayerType.top, "test/assets/happy_map");
      layer?.openSync();
      expect(layer?.validateSync(), true);
    });

    test('test validateSync throwing an exception on a bad magic number', () {
      layer = Layer(LayerType.top, "test/assets/bad_magic_number_map");
      layer?.openSync();
      expect(() {
        layer?.validateSync();
      },
          throwsA(predicate((e) =>
              e is ValidationException &&
              e.message.contains("Magic number mismatch"))));
    });

    test('test validateSync throwing an exception on a bad version', () {
      layer = Layer(LayerType.top, "test/assets/bad_version_map");
      layer?.openSync();
      expect(
          () => layer?.validateSync(),
          throwsA(predicate((e) =>
              e is ValidationException &&
              e.message.contains("Version mismatch"))));
    });

    test('test tilesSync', () {
      layer = Layer(LayerType.top, "test/assets/happy_map");
      layer?.openSync();
      var tiles = layer?.tilesSync(0, 0, 1, 1) ?? [];
      expect(tiles.length, 1);
      expect(tiles[0].x, 0);
      expect(tiles[0].y, 0);
      expect(tiles[0].info.name, 'Rock');
    });

    test('test tilesSync with multiple tiles', () {
      layer = Layer(LayerType.top, "test/assets/happy_map");
      layer?.openSync();
      var tiles = layer?.tilesSync(0, 0, 2, 2) ?? [];
      expect(tiles.length, 4);
      expect(tiles[0].x, 0);
      expect(tiles[0].y, 0);
      expect(tiles[0].info.name, 'Rock');
      expect(tiles[1].x, 0);
      expect(tiles[1].y, 1);
      expect(tiles[1].info.name, 'Rock');
      expect(tiles[2].x, 1);
      expect(tiles[2].y, 0);
      expect(tiles[2].info.name, 'Rock');
      expect(tiles[3].x, 1);
      expect(tiles[3].y, 1);
      expect(tiles[3].info.name, 'Dirt');
    });

    test('test tilesSync with a bad magic number', () {
      layer = Layer(LayerType.top, "test/assets/bad_magic_number_map");
      layer?.openSync();
      expect(
          () => layer?.tilesSync(0, 0, 1, 1),
          throwsA(predicate((e) =>
              e is ValidationException &&
              e.message.contains("Magic number mismatch"))));
    });

    test('test tilesSync with a bad version', () {
      layer = Layer(LayerType.top, "test/assets/bad_version_map");
      layer?.openSync();
      expect(
          () => layer?.tilesSync(0, 0, 1, 1),
          throwsA(predicate((e) =>
              e is ValidationException &&
              e.message.contains("Version mismatch"))));
    });

    test('test tileSync', () {
      layer = Layer(LayerType.top, "test/assets/happy_map");
      layer?.openSync();
      var tile = layer?.tileSync(0, 0) ?? emptyTile;
      expect(tile.x, 0);
      expect(tile.y, 0);
      expect(tile.info.name, 'Rock');
    });

    test('test create image from tiles', () {
      layer = Layer(LayerType.top, "test/assets/happy_map");
      layer?.openSync();
      var x = 8, y = 8, width = 16, height = 16;
      var image = layer?.imageSync(0, 0, width, height);
      var tile = layer?.tileSync(x, y) ?? emptyTile;
      expect(
          image?.getPixel(x, y),
          predicate<img.Pixel>((p) =>
              p.r == tile.info.color.red &&
              p.g == tile.info.color.green &&
              p.b == tile.info.color.blue &&
              p.a == tile.info.color.alpha));
      expect(image, isNotNull);
      expect(image?.width, width);
      expect(image?.height, height);
    });

    test('test create file from image', () {
      layer = Layer(LayerType.top, "test/assets/happy_map");
      layer?.openSync();
      var x = 8, y = 8, width = 16, height = 16;
      var image = layer?.imageSync(0, 0, width, height);
      var file = File("test/assets/happy_map.png");
      file.writeAsBytesSync(img.encodePng(image!));
      expect(file.existsSync(), true);
      var savedImage = img.decodeImage(file.readAsBytesSync())!;
      expect(savedImage, isNotNull);
      expect(savedImage.width, width);
      expect(savedImage.height, height);
      expect(savedImage.getPixel(x, y), image.getPixel(x, y));
      file.deleteSync();
    });
  });

  group('Layer async:', () {
    setUp(() {
      TileInfoRepository().loadAll(clear: true);
    });

    tearDown(() async {
      await layer?.close();
    });

    test('test validate on valid map file', () async {
      layer = Layer(LayerType.top, "test/assets/happy_map");
      await layer?.open();
      expect(await layer?.validate(), true);
    });

    test('test validate throwing an exception on a bad magic number', () async {
      layer = Layer(LayerType.top, "test/assets/bad_magic_number_map");
      await layer?.open();
      expect(
          () => layer?.validate(),
          throwsA(predicate((e) =>
              e is ValidationException &&
              e.message.contains("Magic number mismatch"))));
    });

    test('test validate throwing an exception on a bad version', () async {
      layer = Layer(LayerType.top, "test/assets/bad_version_map");
      await layer?.open();
      expect(
          () => layer?.validate(),
          throwsA(predicate((e) =>
              e is ValidationException &&
              e.message.contains("Version mismatch"))));
    });

    test('test tiles', () async {
      layer = Layer(LayerType.top, "test/assets/happy_map");
      await layer?.open();
      await layer?.tiles(0, 0, 1, 1).forEach((tile) {
        expect(tile.x, 0);
        expect(tile.y, 0);
        expect(tile.info.name, 'Rock');
      });
    });

    test('test tiles with multiple tiles', () async {
      layer = Layer(LayerType.top, "test/assets/happy_map");
      await layer?.open();
      var tileStream = layer?.tiles(0, 0, 2, 2);
      var count = 0;
      await tileStream?.forEach((tile) {
        count++;
        expect(tile, isNotNull);
      });
      expect(count, 4);
    });

    test('test tiles outside of bounds', () async {
      layer = Layer(LayerType.top, "test/assets/happy_map");
      await layer?.open();
      expect(() => layer?.tiles(256, 256, 1, 1).first, throwsException);
    });

    test('test tile', () async {
      layer = Layer(LayerType.top, "test/assets/happy_map");
      await layer?.open();
      var tile = await layer?.tile(0, 0) ?? emptyTile;
      expect(tile.x, 0);
      expect(tile.y, 0);
      expect(tile.info.name, 'Rock');
    });

    test('test tile outside of bounds', () async {
      layer = Layer(LayerType.top, "test/assets/happy_map");
      await layer?.open();
      expect(() => layer?.tile(256, 256), throwsException);
    });

    test('test create image from tiles', () async {
      layer = Layer(LayerType.top, "test/assets/happy_map");
      await layer?.open();
      var x = 8, y = 8, width = 16, height = 16;
      var image = await layer?.image(0, 0, width, height);
      var tile = await layer?.tile(x, y) ?? emptyTile;
      expect(
          image?.getPixel(x, y),
          predicate<img.Pixel>((p) =>
              p.r == tile.info.color.red &&
              p.g == tile.info.color.green &&
              p.b == tile.info.color.blue &&
              p.a == tile.info.color.alpha));
      expect(image, isNotNull);
      expect(image?.width, width);
      expect(image?.height, height);
    });

    test('test create file from image', () async {
      layer = Layer(LayerType.top, "test/assets/happy_map");
      await layer?.open();
      var x = 8, y = 8, width = 16, height = 16;
      var image = await layer?.image(0, 0, width, height);
      var file = File("test/assets/happy_map.png");
      await file.writeAsBytes(img.encodePng(image!));
      expect(await file.exists(), true);
      var savedImage = img.decodeImage(await file.readAsBytes())!;
      expect(savedImage, isNotNull);
      expect(savedImage.width, width);
      expect(savedImage.height, height);
      expect(savedImage.getPixel(x, y), image.getPixel(x, y));
      await file.delete();
    });
  });
}
