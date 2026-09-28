import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import '../models/property_media_model.dart';
import '../repositories/media_repository.dart';

final mediaRepositoryProvider = Provider<MediaRepository>((ref) {
  return MediaRepository();
});

enum MediaUploadStatus { idle, picking, uploading, success, error }

class MediaState {
  final MediaUploadStatus status;
  final double progress;
  final String? errorMessage;
  final List<PropertyMediaModel> mediaList;

  MediaState({
    this.status = MediaUploadStatus.idle,
    this.progress = 0.0,
    this.errorMessage,
    this.mediaList = const [],
  });

  MediaState copyWith({
    MediaUploadStatus? status,
    double? progress,
    String? errorMessage,
    List<PropertyMediaModel>? mediaList,
  }) {
    return MediaState(
      status: status ?? this.status,
      progress: progress ?? this.progress,
      errorMessage: errorMessage,
      mediaList: mediaList ?? this.mediaList,
    );
  }
}

class MediaNotifier extends StateNotifier<MediaState> {
  final MediaRepository _repository;
  final ImagePicker _picker = ImagePicker();

  MediaNotifier(this._repository) : super(MediaState());

  void setInitialMedia(List<PropertyMediaModel> initialList) {
    state = state.copyWith(mediaList: initialList);
  }

  /// Sélectionne et téléverse de multiples images
  Future<bool> pickAndUploadImages(String propertyId) async {
    try {
      state = state.copyWith(status: MediaUploadStatus.picking, errorMessage: null);

      final selectedFiles = await _picker.pickMultiImage(
        imageQuality: 85,
      );

      if (selectedFiles.isEmpty) {
        state = state.copyWith(status: MediaUploadStatus.idle);
        return false;
      }

      // Validation de la taille (max 10MB par image)
      for (final file in selectedFiles) {
        final length = await file.length();
        if (length > 10 * 1024 * 1024) {
          state = state.copyWith(
            status: MediaUploadStatus.error,
            errorMessage: 'L\'image "${file.name}" dépasse 10 Mo.',
          );
          return false;
        }
      }

      state = state.copyWith(status: MediaUploadStatus.uploading, progress: 0.1);

      final newMedia = await _repository.uploadPropertyMedia(
        propertyId: propertyId,
        files: selectedFiles,
        onProgress: (p) {
          state = state.copyWith(progress: p);
        },
      );

      final updatedList = [...state.mediaList, ...newMedia];
      state = state.copyWith(
        status: MediaUploadStatus.success,
        progress: 1.0,
        mediaList: updatedList,
      );
      return true;
    } catch (e) {
      state = state.copyWith(
        status: MediaUploadStatus.error,
        errorMessage: 'Échec de l\'envoi des images: ${e.toString()}',
      );
      return false;
    }
  }

  /// Sélectionne et téléverse une vidéo
  Future<bool> pickAndUploadVideo(String propertyId) async {
    try {
      state = state.copyWith(status: MediaUploadStatus.picking, errorMessage: null);

      final selectedVideo = await _picker.pickVideo(
        source: ImageSource.gallery,
        maxDuration: const Duration(minutes: 5),
      );

      if (selectedVideo == null) {
        state = state.copyWith(status: MediaUploadStatus.idle);
        return false;
      }

      // Validation de la taille (max 100MB pour vidéo)
      final length = await selectedVideo.length();
      if (length > 100 * 1024 * 1024) {
        state = state.copyWith(
          status: MediaUploadStatus.error,
          errorMessage: 'La vidéo dépasse 100 Mo.',
        );
        return false;
      }

      state = state.copyWith(status: MediaUploadStatus.uploading, progress: 0.1);

      final newMedia = await _repository.uploadPropertyMedia(
        propertyId: propertyId,
        files: [selectedVideo],
        onProgress: (p) {
          state = state.copyWith(progress: p);
        },
      );

      final updatedList = [...state.mediaList, ...newMedia];
      state = state.copyWith(
        status: MediaUploadStatus.success,
        progress: 1.0,
        mediaList: updatedList,
      );
      return true;
    } catch (e) {
      state = state.copyWith(
        status: MediaUploadStatus.error,
        errorMessage: 'Échec de l\'envoi de la vidéo: ${e.toString()}',
      );
      return false;
    }
  }

  /// Supprime un média
  Future<void> deleteMedia(String propertyId, String mediaId) async {
    try {
      await _repository.deletePropertyMedia(propertyId: propertyId, mediaId: mediaId);
      final updatedList = state.mediaList.where((m) => m.id != mediaId).toList();
      state = state.copyWith(mediaList: updatedList);
    } catch (e) {
      state = state.copyWith(
        status: MediaUploadStatus.error,
        errorMessage: 'Échec de la suppression: ${e.toString()}',
      );
    }
  }

  /// Définit le média principal
  Future<void> setPrimaryMedia(String propertyId, String mediaId) async {
    try {
      await _repository.setPrimaryMedia(propertyId: propertyId, mediaId: mediaId);
      final updatedList = state.mediaList.map((m) {
        return m.copyWith(isPrimary: m.id == mediaId);
      }).toList();
      state = state.copyWith(mediaList: updatedList);
    } catch (e) {
      state = state.copyWith(
        status: MediaUploadStatus.error,
        errorMessage: 'Erreur lors de la définition de la photo principale: ${e.toString()}',
      );
    }
  }

  /// Réordonne les médias
  Future<void> reorderMedia(String propertyId, int oldIndex, int newIndex) async {
    if (oldIndex < 0 || oldIndex >= state.mediaList.length) return;
    if (newIndex < 0 || newIndex >= state.mediaList.length) return;

    final newList = List<PropertyMediaModel>.from(state.mediaList);
    final item = newList.removeAt(oldIndex);
    newList.insert(newIndex, item);

    final payloadItems = <Map<String, dynamic>>[];
    for (int i = 0; i < newList.length; i++) {
      payloadItems.add({'id': newList[i].id, 'order': i + 1});
    }

    state = state.copyWith(mediaList: newList);

    try {
      await _repository.reorderPropertyMedia(propertyId: propertyId, items: payloadItems);
    } catch (e) {
      // Annuler en cas d'erreur
      state = state.copyWith(
        errorMessage: 'Échec de la sauvegarde de l\'ordre: ${e.toString()}',
      );
    }
  }
}

final propertyMediaProvider =
    StateNotifierProvider.family<MediaNotifier, MediaState, String>((ref, propertyId) {
  final repo = ref.watch(mediaRepositoryProvider);
  return MediaNotifier(repo);
});
