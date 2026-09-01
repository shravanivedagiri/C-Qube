import '../models/gallery_item_model.dart';
import '../services/mock_data_store.dart';

abstract class GalleryRepository {
  Future<List<GalleryItemModel>> getClubGallery(String clubId);
  Future<GalleryItemModel> uploadMediaItem(GalleryItemModel item);
  Future<void> deleteMediaItem(String itemId);
}

class MockGalleryRepository implements GalleryRepository {
  final MockDataStore _store = MockDataStore();

  @override
  Future<List<GalleryItemModel>> getClubGallery(String clubId) async {
    await Future.delayed(const Duration(milliseconds: 150));
    return _store.galleryItems.where((g) => g.clubId == clubId).toList();
  }

  @override
  Future<GalleryItemModel> uploadMediaItem(GalleryItemModel item) async {
    await Future.delayed(const Duration(milliseconds: 300));
    _store.galleryItems.insert(0, item);
    return item;
  }

  @override
  Future<void> deleteMediaItem(String itemId) async {
    await Future.delayed(const Duration(milliseconds: 150));
    _store.galleryItems.removeWhere((g) => g.id == itemId);
  }
}
