/// Represents the type of a layer in the map.
/// 
/// This class provides constants for different types of layers that can be used in a map.
/// Each layer type has a unique identifier and a display name.
/// 
/// Example usage:
/// ```dart
/// LayerType type = LayerType.top;
/// print(type.fileName); // Output: "top_layer.map"
/// ```
/// 
/// See also:
/// - [Layer], the base class for all layers in the map.
enum LayerType {
  /// The top layer of the map.
  top(fileName: "top_layer.map", magicNumber: 0x474A2198B2781B9D, version: 0),
  /// The rock layer of the map.
  rock(fileName: "rock_layer.map", magicNumber: 0x474A2198B2781B9D, version: 0),
  /// The resources layer of the map.
  resources(fileName: "resources.map", magicNumber: 0x474A2198B2781B9D, version: 0),
  /// The cave layer of the map.
  cave(fileName: "map_cave.map", magicNumber: 0x474A2198B2781B9D, version: 0),
  /// The flags layer of the map.
  flags(fileName: "flags.map", magicNumber: 0x474A2198B2781B9D, version: 0);

  /// The name of the file that contains the layer.
  final String fileName;
  /// The magic number that identifies the layer.
  final int magicNumber;
  /// The version of the layer.
  final int version;
  
  const LayerType({required this.fileName, required this.magicNumber, required this.version});
}