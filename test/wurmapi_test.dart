import 'package:flutter_test/flutter_test.dart';
import 'package:image/image.dart';
import 'package:wurmapi/wurmapi.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  TileInfoRepository().loadAll(clear: true);
    
  group('Test integrating with library sync:', () {
    test('test create image of the top layer', () {
      var layer = Layer(LayerType.top, "test/assets/happy_map");
      layer.openSync();
      var image = layer.imageSync(0, 0, layer.size, layer.size);
      expect(image.width, layer.size);
      expect(image.height, layer.size);
      var x = 128, y = 128;
      var tile = layer.tileSync(x, y);
      var pixel = image.getPixel(tile.x, tile.y);
      expect(
          pixel,
          predicate<Pixel>((p) =>
              p.r == tile.info.color.red &&
              p.g == tile.info.color.green &&
              p.b == tile.info.color.blue));
    });
  });
}
