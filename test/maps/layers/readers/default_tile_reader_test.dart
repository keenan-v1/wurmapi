
import 'package:flutter_test/flutter_test.dart';
import 'package:wurmapi/maps/layers/layer_type.dart';
import 'package:wurmapi/maps/layers/readers/default_tile_reader.dart';
import 'package:wurmapi/maps/tiles/tile.dart';
import 'package:wurmapi/maps/tiles/tile_info_repository.dart';

void main() async {
  group('DefaultTileReader synchronous: ', () {
    TestWidgetsFlutterBinding.ensureInitialized();
    DefaultTileReader tileReader = DefaultTileReader();
    TileInfoRepository().loadAll(clear: true);

    setUp(() {
      tileReader = DefaultTileReader();
    });

    test('test opening an existing map', () {
      tileReader.openSync("test/assets/happy_map/top_layer.map");
      expect(tileReader.size, 256);
      expect(tileReader.version, LayerType.top.version);
      expect(tileReader.magicNumber, LayerType.top.magicNumber);
    });

    test('test accessing properties of unopened file', () {
      expect(() => tileReader.size, throwsException);
      expect(() => tileReader.version, throwsException);
      expect(() => tileReader.magicNumber, throwsException);
    });

    test('test closing an opened file', () {
      tileReader.openSync("test/assets/happy_map/top_layer.map");
      tileReader.closeSync();
      expect(() => tileReader.size, throwsException);
      expect(() => tileReader.version, throwsException);
      expect(() => tileReader.magicNumber, throwsException);
    });

    test('test opening a non-existing map', () {
      expect(() => tileReader.openSync("test/assets/happy_map/does_not_exist.map"), throwsException);
    });

    test('test reading a tile', () {
      tileReader.openSync("test/assets/happy_map/top_layer.map");
      Tile tile = tileReader.readTileSync(0, 0);
      expect(tile, isNotNull);
      expect(tile.x, 0);
      expect(tile.y, 0);
      expect(tile.info.name, 'Rock');
    });

    test('test reading a tile outside of bounds', () {
      tileReader.openSync("test/assets/happy_map/top_layer.map");
      expect(() => tileReader.readTileSync(256, 256), throwsException);
    });

    test('test reading a tile from an unopened file', () {
      expect(() => tileReader.readTileSync(0, 0), throwsException);
    });
  });

  group('DefaultTileReader async:', () {
    test('test opening an existing map', () async {
      DefaultTileReader tileReader = DefaultTileReader();
      await tileReader.open("test/assets/happy_map/top_layer.map");
      expect(tileReader.size, 256);
      expect(tileReader.version, LayerType.top.version);
      expect(tileReader.magicNumber, LayerType.top.magicNumber);
    });

    test('test accessing properties of unopened file', () async {
      DefaultTileReader tileReader = DefaultTileReader();
      expect(() => tileReader.size, throwsException);
      expect(() => tileReader.version, throwsException);
      expect(() => tileReader.magicNumber, throwsException);
    });

    test('test closing an opened file', () async {
      DefaultTileReader tileReader = DefaultTileReader();
      await tileReader.open("test/assets/happy_map/top_layer.map");
      await tileReader.close();
      expect(() => tileReader.size, throwsException);
      expect(() => tileReader.version, throwsException);
      expect(() => tileReader.magicNumber, throwsException);
    });

    test('test opening a non-existing map', () async {
      DefaultTileReader tileReader = DefaultTileReader();
      expect(() => tileReader.open("test/assets/happy_map/does_not_exist.map"), throwsException);
    });

    test('test reading a tile', () async {
      DefaultTileReader tileReader = DefaultTileReader();
      await tileReader.open("test/assets/happy_map/top_layer.map");
      Tile tile = await tileReader.readTile(0, 0);
      expect(tile, isNotNull);
      expect(tile.x, 0);
      expect(tile.y, 0);
      expect(tile.info.name, 'Rock');
    });

    test('test reading a tile outside of bounds', () async {
      DefaultTileReader tileReader = DefaultTileReader();
      await tileReader.open("test/assets/happy_map/top_layer.map");
      expect(() => tileReader.readTile(256, 256), throwsException);
    });

    test('test reading a tile from an unopened file', () async {
      DefaultTileReader tileReader = DefaultTileReader();
      expect(() => tileReader.readTile(0, 0), throwsException);
    });
  });
}
