import '../models/post_model.dart';
import '../services/mock_data_store.dart';

abstract class PostRepository {
  Future<List<PostModel>> getFeedPosts();
  Future<List<PostModel>> getClubPosts(String clubId);
  Future<PostModel> createPost(PostModel post);
  Future<void> deletePost(String postId);
}

class MockPostRepository implements PostRepository {
  final MockDataStore _store = MockDataStore();

  @override
  Future<List<PostModel>> getFeedPosts() async {
    await Future.delayed(const Duration(milliseconds: 150));
    final list = List<PostModel>.from(_store.posts);
    list.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return list;
  }

  @override
  Future<List<PostModel>> getClubPosts(String clubId) async {
    await Future.delayed(const Duration(milliseconds: 150));
    return _store.posts.where((p) => p.clubId == clubId).toList();
  }

  @override
  Future<PostModel> createPost(PostModel post) async {
    await Future.delayed(const Duration(milliseconds: 250));
    _store.posts.insert(0, post);
    return post;
  }

  @override
  Future<void> deletePost(String postId) async {
    await Future.delayed(const Duration(milliseconds: 200));
    _store.posts.removeWhere((p) => p.id == postId);
  }
}
