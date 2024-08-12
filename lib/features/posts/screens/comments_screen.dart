import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:reddit_clone/core/common/error_text.dart';
import 'package:reddit_clone/core/common/loader.dart';
import 'package:reddit_clone/core/post_card.dart';
import 'package:reddit_clone/features/auth/controller/auth_controller.dart';
import 'package:reddit_clone/features/posts/controller/post_controller.dart';
import 'package:reddit_clone/features/posts/widgets/comment_card.dart';
import 'package:reddit_clone/models/post_model.dart';

class CommentsScreen extends ConsumerStatefulWidget {
  final String postId;
  const CommentsScreen({
    super.key,
    required this.postId,
  });

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _CommentsScreenState();
}

class _CommentsScreenState extends ConsumerState<CommentsScreen> {
  final commentController = TextEditingController();

  @override
  void dispose() {
    super.dispose();
    commentController.dispose();
  }

  void addComment(Post post) {
    ref.read(postControllerProvider.notifier).addComment(
          context: context,
          text: commentController.text.trim(),
          post: post,
        );
    setState(() {
      commentController.text = '';
    });
  }

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(userProvider)!;
    final isGuest = !user.isAuthenticated;

    return Scaffold(
      resizeToAvoidBottomInset: true, // Ensures the screen adjusts when keyboard is open
      appBar: AppBar(),
      body: ref.watch(getPostsByIdProvider(widget.postId)).when(
            data: (data) {
              return Column(
                children: [
                  PostCard(post: data),
                  if (!isGuest)
                     Padding(
                        padding: const EdgeInsets.all(8.0), // Add padding to prevent overflow
                        child: TextField(
                          onSubmitted: (val) => addComment(data),
                          controller: commentController,
                          decoration: const InputDecoration(
                            hintText: 'What are your thoughts?',
                            filled: true,
                            border: InputBorder.none,
                          ),
                        ),
                      ),
                    
                  Expanded(
                    child: ref.watch(getPostCommentsProvider(widget.postId)).when(
                          data: (data) {
                            return ListView.builder(
                              itemCount: data.length,
                              itemBuilder: (BuildContext context, int index) {
                                final comment = data[index];
                                return CommentCard(comment: comment);
                              },
                            );
                          },
                          error: (error, stackTrace) {
                            return ErrorText(
                              error: error.toString(),
                            );
                          },
                          loading: () => const Loader(),
                        ),
                  ),
                ],
              );
            },
            error: (error, stackTrace) => ErrorText(
              error: error.toString(),
            ),
            loading: () => const Loader(),
          ),
    );
  }
}
