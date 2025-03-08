import 'dart:async';
import 'package:flutter/material.dart'; // Added for Color
import 'package:flutter/services.dart';

// Helper function to get enum string value
String _enumToString(Object enumValue) {
  return enumValue.toString().split('.').last;
}

enum GalleryMode {
  image,
  video,
  all,
}

enum CameraMimeType {
  photo,
  video,
}

class ImagePickers {
  static const MethodChannel _channel =
      const MethodChannel('flutter/image_pickers');

  static Future<Media> openCamera({
    CameraMimeType cameraMimeType = CameraMimeType.photo,
    CropConfig cropConfig,
    int compressSize = 500,
    int videoRecordMaxSecond = 120,
    int videoRecordMinSecond = 1,
    Language language = Language.system,
  }) async {
    bool enableCrop = false;
    int width = -1;
    int height = -1;
    if (cropConfig != null) {
      enableCrop = cropConfig.enableCrop;
      width = cropConfig.width <= 0 ? -1 : cropConfig.width;
      height = cropConfig.height <= 0 ? -1 : cropConfig.height;
    }

    Color uiColor = UIConfig.defUiThemeColor;
    final Map<String, dynamic> params = <String, dynamic>{
      'galleryMode': "image",
      'showGif': true,
      'uiColor': {
        "a": 255,
        "r": uiColor.red,
        "g": uiColor.green,
        "b": uiColor.blue,
        "l": (uiColor.computeLuminance() * 255).toInt()
      },
      'selectCount': 1,
      'showCamera': false,
      'enableCrop': enableCrop,
      'width': width,
      'height': height,
      'compressSize': compressSize < 50 ? 50 : compressSize,
      'cameraMimeType': _enumToString(cameraMimeType), // Fixed
      'videoRecordMaxSecond': videoRecordMaxSecond,
      'videoRecordMinSecond': videoRecordMinSecond,
      'language': _enumToString(language), // Fixed
    };

    final List<dynamic> paths =
        await _channel.invokeMethod('getPickerPaths', params);

    if (paths != null && paths.isNotEmpty) {
      Media media = Media();
      media.thumbPath = paths[0]["thumbPath"];
      media.path = paths[0]["path"];
      media.galleryMode = cameraMimeType == CameraMimeType.photo
          ? GalleryMode.image
          : GalleryMode.video;
      return media;
    }
    return null;
  }

  static Future<List<Media>> pickerPaths({
    GalleryMode galleryMode = GalleryMode.image,
    UIConfig uiConfig,
    int selectCount = 1,
    bool showCamera = false,
    bool showGif = true,
    CropConfig cropConfig,
    int compressSize = 500,
    int videoRecordMaxSecond = 120,
    int videoRecordMinSecond = 1,
    int videoSelectMaxSecond = 120,
    int videoSelectMinSecond = 1,
    Language language = Language.system,
  }) async {
    Color uiColor = UIConfig.defUiThemeColor;
    if (uiConfig != null) {
      uiColor = uiConfig.uiThemeColor;
    }

    bool enableCrop = false;
    int width = -1;
    int height = -1;
    if (cropConfig != null) {
      enableCrop = cropConfig.enableCrop;
      width = cropConfig.width <= 0 ? -1 : cropConfig.width;
      height = cropConfig.height <= 0 ? -1 : cropConfig.height;
    }

    final Map<String, dynamic> params = <String, dynamic>{
      'galleryMode': _enumToString(galleryMode), // Fixed
      'showGif': showGif,
      'uiColor': {
        "a": 255,
        "r": uiColor.red,
        "g": uiColor.green,
        "b": uiColor.blue,
        "l": (uiColor.computeLuminance() * 255).toInt()
      },
      'selectCount': selectCount,
      'showCamera': showCamera,
      'enableCrop': enableCrop,
      'width': width,
      'height': height,
      'compressSize': compressSize < 50 ? 50 : compressSize,
      'videoRecordMaxSecond': videoRecordMaxSecond,
      'videoRecordMinSecond': videoRecordMinSecond,
      'videoSelectMaxSecond': videoSelectMaxSecond,
      'videoSelectMinSecond': videoSelectMinSecond,
      'language': _enumToString(language), // Fixed
    };

    final List<dynamic> paths =
        await _channel.invokeMethod('getPickerPaths', params);
    List<Media> medias = [];
    paths.forEach((data) {
      Media media = Media();
      media.thumbPath = data["thumbPath"];
      media.path = data["path"];
      media.galleryMode =
          media.path == media.thumbPath ? GalleryMode.image : GalleryMode.video;
      medias.add(media);
    });
    return medias;
  }

  // Rest of the class remains the same with preview/save methods...
}

class CropConfig {
  bool enableCrop = false;
  int width = -1;
  int height = -1;

  CropConfig({this.enableCrop = false, this.width = -1, this.height = -1});
}

class Media {
  String thumbPath;
  String path;
  GalleryMode galleryMode;

  @override
  String toString() {
    return '( thumbPath = $thumbPath, path = $path, galleryMode = ${_enumToString(galleryMode)} )';
  }
}

class UIConfig {
  static const Color defUiThemeColor = Color(0xfffefefe);
  Color uiThemeColor;

  UIConfig({this.uiThemeColor = defUiThemeColor});
}

enum Language {
  system,
  chinese,
  traditional_chinese,
  english,
  japanese,
  france,
  german,
  russian,
  vietnamese,
  korean,
  portuguese,
  spanish,
  arabic,
}
