import 'dart:ui';

import 'package:flutter_test/flutter_test.dart';
import 'package:wurmapi/maps/tiles/tile_info_repository.dart';
// import 'package:wurmapi/utils/test_utils.dart';

void main() async {
  // Before Tests
  TestWidgetsFlutterBinding.ensureInitialized();
  // TestUtils.enableLogging();

  group('TileInfoRepository', () {
    TileInfoRepository tileInfoRepository = TileInfoRepository();

    setUp(() {
      tileInfoRepository = TileInfoRepository();
    });

    test('test loading default tiles', () async {
      await tileInfoRepository.loadAll(clear: true);
      Color color = const Color(0xff470233);
      expect(tileInfoRepository.getTileInfo(10), isNotNull);
      expect(tileInfoRepository.getTileInfo(10)!.color, color);
      expect(tileInfoRepository.getTileInfo(10)!.name, "Mycelium");
    });

    test('test loading override tiles', () async {
      await tileInfoRepository
          .loadAll(filePaths: ["test/assets/test_tiles.yaml"], clear: true);
      Color color = const Color(0xff00ff00);
      expect(tileInfoRepository.getTileInfo(38), isNotNull);
      expect(tileInfoRepository.getTileInfo(38)!.color, color);
      expect(tileInfoRepository.getTileInfo(38)!.name, "Lawn");
    });

    test('test updating tile color', () async {
      await tileInfoRepository.loadAll(clear: true);
      Color color = const Color(0xff00ff00);
      tileInfoRepository.updateColor(10, color);
      expect(tileInfoRepository.getTileInfo(10)!.color, color);
    });
  });
}
