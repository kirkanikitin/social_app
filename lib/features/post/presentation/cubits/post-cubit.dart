import 'dart:typed_data';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:social_app/features/post/domain/entities/comment.dart';
import 'package:social_app/features/post/presentation/cubits/post-states.dart';
import 'package:social_app/features/storage/domain/storage-repo.dart';
import '../../domain/entities/post.dart';
import '../../domain/repos/post-repo.dart';

class PostCubit extends Cubit<PostState> {
  final PostRepo postRepo;
  final StorageRepo storageRepo;

  PostCubit({
    required this.postRepo,
    required this.storageRepo,
  }) : super(PostsInitial());

  Future<void> createPost(Post post, {String? imagePath, Uint8List? imageBytes}) async {
      String? imageUrl;

    try {
      if (imagePath != null) {
        emit(PostUploading());
        imageUrl =
          await storageRepo.uploadPostImageMobile(imagePath, post.id);
      }
      else if (imageBytes != null) {
        emit(PostUploading());
        imageUrl = await storageRepo.uploadPostImageWeb(imageBytes, post.id);
      }

      final newPost = post.copyWith(imageUrl: imageUrl);
      postRepo.createPost(newPost);
      fetchAllPosts();
    } catch (e) {
      emit(PostsError('Failed to create post: $e'));
    }
  }

  Future<void> fetchAllPosts() async {
    try {
      emit(PostsLoading());
      final posts = await postRepo.fetchAllPosts();
      emit(PostsLoaded(posts));
    } catch (e) {
      emit(PostsError('Failed to fetch posts: $e'));
    }
  }

  Future<void> deletePost(String postId) async {
    try {
      await postRepo.deletePost(postId);
    } catch (e) {}
  }

  void updatePostInState(Post updatedPost) {
    final currentState = state;
    if (currentState is PostsLoaded) {
      final updatedPosts = currentState.posts.map((post) {
        return post.id == updatedPost.id ? updatedPost : post;
      }).toList();

      emit(PostsLoaded(updatedPosts));
    }
  }

  Future<void> toggleLikePost(String postId, String userId) async {
    try {
      final updatedPost = await postRepo.toggleLikePost(postId, userId);

      updatePostInState(updatedPost);
    } catch (e) {
      emit(PostsError('Failed to toggle like: $e'));
    }
  }

  Future<void> addComment(String postId, Comment comment) async {
    try {
      await postRepo.addComment(postId, comment);

      await fetchAllPosts();
    } catch (e) {
      emit(PostsError('Failed to add comment: $e'));
    }
  }

  Future<void> deleteComment(String postId, String commentId) async {
    try {
      await postRepo.deleteComment(postId, commentId);

      await fetchAllPosts();
    } catch (e) {
      emit(PostsError('Failed to delete comment: $e'));
    }
  }
}