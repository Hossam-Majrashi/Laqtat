import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/project.dart';

class ProjectService extends ChangeNotifier {
  static const String _webProjectsKey = 'laqtat_saved_projects';
  final List<Project> _projects = [];

  List<Project> get projects => List.unmodifiable(_projects);

  Future<void> init() async {
    await loadProjects();
  }

  Future<String?> _getStorageDir() async {
    if (kIsWeb) return null;
    try {
      final dir = await getApplicationDocumentsDirectory();
      final projectsDir = Directory('${dir.path}/laqtat_projects');
      if (!await projectsDir.exists()) {
        await projectsDir.create(recursive: true);
      }
      return projectsDir.path;
    } catch (e) {
      debugPrint('Error getting storage dir: $e');
      return null;
    }
  }

  Future<void> loadProjects() async {
    _projects.clear();
    if (kIsWeb) {
      final prefs = await SharedPreferences.getInstance();
      final rawList = prefs.getStringList(_webProjectsKey) ?? [];
      for (final raw in rawList) {
        try {
          final map = jsonDecode(raw) as Map<String, dynamic>;
          _projects.add(Project.fromJson(map));
        } catch (e) {
          debugPrint('Error parsing web project: $e');
        }
      }
    } else {
      final dirPath = await _getStorageDir();
      if (dirPath != null) {
        final indexFile = File('$dirPath/projects.json');
        if (await indexFile.exists()) {
          try {
            final raw = await indexFile.readAsString();
            final list = jsonDecode(raw) as List<dynamic>;
            for (final item in list) {
              final project = Project.fromJson(item as Map<String, dynamic>);
              if (project.gridImagePath.isNotEmpty) {
                final imgFile = File(project.gridImagePath);
                if (await imgFile.exists()) {
                  project.gridImageBytes = await imgFile.readAsBytes();
                }
              }
              _projects.add(project);
            }
          } catch (e) {
            debugPrint('Error reading projects.json: $e');
          }
        }
      }
    }
    // Sort newest first
    _projects.sort((a, b) => b.dateCreated.compareTo(a.dateCreated));
    notifyListeners();
  }

  Future<void> saveProject(Project project) async {
    final existingIndex = _projects.indexWhere((p) => p.id == project.id);

    if (kIsWeb) {
      if (existingIndex >= 0) {
        _projects[existingIndex] = project;
      } else {
        _projects.insert(0, project);
      }
      final prefs = await SharedPreferences.getInstance();
      final list = _projects.map((p) => jsonEncode(p.toJson())).toList();
      await prefs.setStringList(_webProjectsKey, list);
    } else {
      final dirPath = await _getStorageDir();
      if (dirPath != null && project.gridImageBytes != null) {
        final imgFile = File('$dirPath/${project.id}_grid.${project.exportFormat}');
        await imgFile.writeAsBytes(project.gridImageBytes!);
        final updatedProject = Project(
          id: project.id,
          title: project.title,
          videoName: project.videoName,
          videoPath: project.videoPath,
          dateCreated: project.dateCreated,
          durationSeconds: project.durationSeconds,
          gridImagePath: imgFile.path,
          timestamps: project.timestamps,
          quality: project.quality,
          exportFormat: project.exportFormat,
          gridImageBytes: project.gridImageBytes,
          videoBytes: project.videoBytes,
        );

        if (existingIndex >= 0) {
          _projects[existingIndex] = updatedProject;
        } else {
          _projects.insert(0, updatedProject);
        }

        final indexFile = File('$dirPath/projects.json');
        final jsonList = _projects.map((p) => p.toJson()).toList();
        await indexFile.writeAsString(jsonEncode(jsonList));
      } else {
        if (existingIndex >= 0) {
          _projects[existingIndex] = project;
        } else {
          _projects.insert(0, project);
        }
      }
    }
    notifyListeners();
  }

  Future<void> deleteProject(String id) async {
    final index = _projects.indexWhere((p) => p.id == id);
    if (index >= 0) {
      final project = _projects[index];
      if (!kIsWeb && project.gridImagePath.isNotEmpty) {
        final file = File(project.gridImagePath);
        if (await file.exists()) {
          try {
            await file.delete();
          } catch (_) {}
        }
      }
      _projects.removeAt(index);

      if (kIsWeb) {
        final prefs = await SharedPreferences.getInstance();
        final list = _projects.map((p) => jsonEncode(p.toJson())).toList();
        await prefs.setStringList(_webProjectsKey, list);
      } else {
        final dirPath = await _getStorageDir();
        if (dirPath != null) {
          final indexFile = File('$dirPath/projects.json');
          final jsonList = _projects.map((p) => p.toJson()).toList();
          await indexFile.writeAsString(jsonEncode(jsonList));
        }
      }
      notifyListeners();
    }
  }

  Future<void> clearAll() async {
    if (!kIsWeb) {
      final dirPath = await _getStorageDir();
      if (dirPath != null) {
        final dir = Directory(dirPath);
        if (await dir.exists()) {
          try {
            await dir.delete(recursive: true);
          } catch (_) {}
        }
      }
    } else {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_webProjectsKey);
    }
    _projects.clear();
    notifyListeners();
  }
}
