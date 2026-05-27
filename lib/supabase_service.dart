import 'dart:io';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:path/path.dart' as p;
import 'package:flutter/foundation.dart';
class SupabaseService {
  final _supabase = Supabase.instance.client;
  final String bucketName = 'praktikum-images';

  Future<String?> uploadImage(File imageFile) async {
    try {
      final fileExtension = p.extension(imageFile.path);
      final fileName = '${DateTime.now().millisecondsSinceEpoch}$fileExtension';
      final path = 'plants/$fileName';

      await _supabase.storage.from(bucketName).upload(
            path,
            imageFile,
            fileOptions: const FileOptions(cacheControl: '3600', upsert: false),
          );

      final publicUrl = _supabase.storage.from(bucketName).getPublicUrl(path);
      return publicUrl;
    } catch (e) {
      debugPrint('Error uploading image: $e');
      return null;
    }
  }

  Future<List<String>> fetchImages() async {
    try {
      final List<FileObject> objects = await _supabase.storage.from(bucketName).list(path: 'plants');
      
      List<String> imageUrls = [];
      for (var object in objects) {
        if (object.name.isNotEmpty && object.name != '.emptyFolderPlaceholder') {
          final publicUrl = _supabase.storage.from(bucketName).getPublicUrl('plants/${object.name}');
          imageUrls.add(publicUrl);
        }
      }
      return imageUrls;
    } catch (e) {
      debugPrint('Error fetching images: $e');
      return [];
    }
  }
}
