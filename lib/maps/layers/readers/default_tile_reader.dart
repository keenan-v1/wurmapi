import 'dart:io';
import 'dart:typed_data';

import 'package:wurmapi/maps/layers/readers/tile_reader.dart';
import 'package:wurmapi/maps/tiles/tile.dart';
import 'package:wurmapi/maps/tiles/tile_info_repository.dart';

class DefaultTileReader extends TileReader {
  static const _headerBytes = 1024;
  static const _tileDataBytes = 4;
  RandomAccessFile? _raf;
  int? _size;
  int? _version;
  int? _magicNumber;

  T _checkFileOpen<T>(T? value) {
    if (_raf == null || value == null) {
      throw Exception("File not opened");
    }
    return value;
  }

  @override
  int get size => _checkFileOpen(_size);
  @override
  int get version => _checkFileOpen(_version);
  @override
  int get magicNumber => _checkFileOpen(_magicNumber);


  @override
  void openSync(String layerFilePath) {
    _raf?.closeSync();
    _raf = File(layerFilePath).openSync();
    _raf!.setPositionSync(0);
    _magicNumber = Uint8List.fromList(_raf!.readSync(8))
        .buffer
        .asByteData()
        .getInt64(0, Endian.big);
    _raf!.setPositionSync(8);
    _version = _raf!.readByteSync();
    _raf!.setPositionSync(9);
    _size = 1 << _raf!.readByteSync();
  }

  @override
  Future<void> open(String layerFilePath) async {
    await _raf?.close();
    _raf = await File(layerFilePath).open();
    await _raf!.setPosition(0);
    _magicNumber = Uint8List.fromList(await _raf!.read(8))
        .buffer
        .asByteData()
        .getInt64(0, Endian.big);
    await _raf!.setPosition(8);
    _version = (await _raf!.read(1)).first;
    await _raf!.setPosition(9);
    _size = 1 << (await _raf!.read(1)).first;
  }

  @override
  Future<void> close() async {
    _size = null;
    _version = null;
    _magicNumber = null;
    _raf = null;
    await _raf?.close();
  }

  @override
  void closeSync() {
    _raf?.closeSync();
    _size = null;
    _version = null;
    _magicNumber = null;
    _raf = null;
  }

  int _tilePosition(int x, int y) {
    return _headerBytes + (x + y * size) * _tileDataBytes;
  }

  int _tileInfoId(int tileData) {
    return (tileData >> 24) & 0xff;
  }

  @override
  Tile readTileSync(int x, int y) {
    _checkFileOpen(true);
    final position = _tilePosition(x, y);
    if (position < 0 || position >= _raf!.lengthSync()) {
      throw Exception("Tile position out of file bounds");
    }
    _raf!.setPositionSync(position);
    final tileData = _raf!
        .readSync(_tileDataBytes)
        .buffer
        .asByteData()
        .getInt32(0, Endian.big);
    return Tile(x, y, TileInfoRepository().getTileInfo(_tileInfoId(tileData))!);
  }

  @override
  Future<Tile> readTile(int x, int y) async {
    _checkFileOpen(true);
    final position = _tilePosition(x, y);
    if (position < 0 || position >= await _raf!.length()) {
      throw Exception("Tile position out of file bounds");
    }
    await _raf!.setPosition(position);
    final tileData = (await _raf!.read(_tileDataBytes))
        .buffer
        .asByteData()
        .getInt32(0, Endian.big);
    return Tile(x, y, TileInfoRepository().getTileInfo(_tileInfoId(tileData))!);
  }
}
