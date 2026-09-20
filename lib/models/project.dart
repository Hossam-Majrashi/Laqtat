import 'dart:convert';
import 'dart:typed_data';

class Project {
  final String id;
  final String title;
  final String videoName;
  final String videoPath;
  final DateTime dateCreated;
  final double durationSeconds;
  final String gridImagePath;
  final List<double> timestamps;
  final String quality;
  final String exportFormat;
  Uint8List? gridImageBytes;
  Uint8List? videoBytes;

  Project({
    required this.id,
    required this.title,
    required this.videoName,
    required this.videoPath,
    required this.dateCreated,
    required this.durationSeconds,
    required this.gridImagePath,
    required this.timestamps,
    this.quality = 'standard',
    this.exportFormat = 'png',
    this.gridImageBytes,
    this.videoBytes,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'videoName': videoName,
      'videoPath': videoPath,
      'dateCreated': dateCreated.toIso8601String(),
      'durationSeconds': durationSeconds,
      'gridImagePath': gridImagePath,
      'timestamps': timestamps,
      'quality': quality,
      'exportFormat': exportFormat,
      if (gridImageBytes != null) 'gridImageBase64': base64Encode(gridImageBytes!),
      if (videoBytes != null) 'videoBase64': base64Encode(videoBytes!),
    };
  }

  factory Project.fromJson(Map<String, dynamic> json) {
    Uint8List? gridBytes;
    if (json['gridImageBase64'] != null) {
      try {
        gridBytes = base64Decode(json['gridImageBase64']);
      } catch (_) {}
    }

    Uint8List? vidBytes;
    if (json['videoBase64'] != null) {
      try {
        vidBytes = base64Decode(json['videoBase64']);
      } catch (_) {}
    }

    return Project(
      id: json['id'] as String,
      title: json['title'] as String,
      videoName: json['videoName'] as String,
      videoPath: json['videoPath'] as String? ?? '',
      dateCreated: DateTime.tryParse(json['dateCreated'] as String? ?? '') ?? DateTime.now(),
      durationSeconds: (json['durationSeconds'] as num?)?.toDouble() ?? 0.0,
      gridImagePath: json['gridImagePath'] as String? ?? '',
      timestamps: (json['timestamps'] as List<dynamic>?)
              ?.map((e) => (e as num).toDouble())
              .toList() ??
          [],
      quality: json['quality'] as String? ?? 'standard',
      exportFormat: json['exportFormat'] as String? ?? 'png',
      gridImageBytes: gridBytes,
      videoBytes: vidBytes,
    );
  }

  String get formattedDuration {
    final minutes = durationSeconds ~/ 60;
    final seconds = (durationSeconds % 60).toInt();
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }
}
