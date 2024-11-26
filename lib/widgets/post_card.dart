import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:instagram_flutter_new/models/user.dart';
import 'package:instagram_flutter_new/providers/user_provider.dart';
import 'package:instagram_flutter_new/resources/firestore_methods.dart';
import 'package:instagram_flutter_new/screens/comments_screen.dart';
import 'package:instagram_flutter_new/screens/show_users.dart';
import 'package:instagram_flutter_new/screens/profile_screen.dart';
import 'package:instagram_flutter_new/utils/colors.dart';
import 'package:instagram_flutter_new/utils/global_variables.dart';

import 'package:instagram_flutter_new/widgets/like_animation.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

class PostCard extends StatefulWidget {
  final snap;
  final bool isBookmark;
  const PostCard(this.snap, this.isBookmark, {super.key});

  @override
  State<PostCard> createState() => _PostCardState();
}

class _PostCardState extends State<PostCard> {
  bool isLikeAnimating = false;
  int commentCount = 0;
  bool _isHovering = false;

  Stream<int> getCommentsCountStream() {
    return FirebaseFirestore.instance
        .collection('posts')
        .doc(widget.snap['postID'])
        .collection('comments')
        .snapshots()
        .map((snapshot) => snapshot.docs.length);
  }

  @override
  Widget build(BuildContext context) {
    final User user = Provider.of<UserProvider>(context).getUser;

    return (widget.snap['hide'] != null &&
            widget.snap['hide'].contains(user.uid))
        ? Container()
        : Container(
            decoration: BoxDecoration(
              border: Border.all(
                  color: MediaQuery.of(context).size.width > webScreenSize
                      ? secondaryColor
                      : newBackgroundColor),
            ),
            margin: EdgeInsets.symmetric(
              horizontal: MediaQuery.of(context).size.width > webScreenSize
                  ? MediaQuery.of(context).size.width * 0.3
                  : 0,
              vertical:
                  MediaQuery.of(context).size.width > webScreenSize ? 15 : 0,
            ),
            padding: const EdgeInsets.symmetric(
              vertical: 10,
            ),
            child: Column(
              children: [
                // HEADER SECTION
                Container(
                  padding: const EdgeInsets.symmetric(
                    vertical: 4,
                    horizontal: 16,
                  ).copyWith(right: 0),
                  child: Row(
                    children: [
                      InkWell(
                        onTap: () => Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (context) =>
                                ProfileScreen(uid: widget.snap['uid']),
                          ),
                        ),
                        child: CircleAvatar(
                          radius: 16,
                          backgroundImage:
                              NetworkImage(widget.snap['profImage']),
                        ),
                      ),
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.only(left: 8),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              InkWell(
                                onTap: () => Navigator.of(context).push(
                                  MaterialPageRoute(
                                    builder: (context) =>
                                        ProfileScreen(uid: widget.snap['uid']),
                                  ),
                                ),
                                child: MouseRegion(
                                  onEnter: (_) {
                                    setState(() {
                                      _isHovering = true;
                                    });
                                  },
                                  onExit: (_) {
                                    setState(() {
                                      _isHovering = false;
                                    });
                                  },
                                  child: Text(
                                    widget.snap['username'],
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      decoration: _isHovering
                                          ? TextDecoration.underline
                                          : TextDecoration.none,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      widget.isBookmark
                          ? Container()
                          : IconButton(
                              onPressed: () {
                                showDialog(
                                    context: context,
                                    builder: (context) {
                                      return SimpleDialog(
                                        children: [
                                          (widget.snap['uid'] != user.uid)
                                              ? SimpleDialogOption(
                                                  padding:
                                                      const EdgeInsets.all(13),
                                                  child:
                                                      const Text('Hide post'),
                                                  onPressed: () async {
                                                    await FirestoreMethods()
                                                        .hidePost(
                                                            widget
                                                                .snap['postID'],
                                                            user.uid);
                                                    Navigator.of(context).pop();
                                                  },
                                                )
                                              : SimpleDialogOption(
                                                  padding:
                                                      const EdgeInsets.all(13),
                                                  child:
                                                      const Text('Delete post'),
                                                  onPressed: () async {
                                                    await FirestoreMethods()
                                                        .deletePost(widget
                                                            .snap['postID']);
                                                    Navigator.of(context).pop();
                                                  },
                                                ),
                                        ],
                                      );
                                    });
                              },
                              icon: const Icon(Icons.more_vert),
                            ),
                    ],
                  ),
                ),
                // IMAGE SECTION
                GestureDetector(
                  onDoubleTap: () async {
                    await FirestoreMethods().likePost(
                      widget.snap['postID'],
                      user.uid,
                      widget.snap['likes'],
                    );
                    setState(() {
                      isLikeAnimating = true;
                    });
                  },
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      SizedBox(
                        height: MediaQuery.of(context).size.height * 0.4,
                        width: double.infinity,
                        child: Image.network(
                          widget.snap['postUrl'],
                          fit: BoxFit.cover,
                        ),
                      ),
                      AnimatedOpacity(
                        duration: const Duration(milliseconds: 200),
                        opacity: isLikeAnimating ? 1 : 0,
                        child: LikeAnimation(
                          isAnimating: isLikeAnimating,
                          duration: const Duration(milliseconds: 400),
                          onEnd: () {
                            setState(() {
                              isLikeAnimating = false;
                            });
                          },
                          child: widget.snap['likes'].contains(user.uid)
                              ? const Icon(Icons.favorite,
                                  color: Colors.red, size: 100)
                              : const Icon(Icons.favorite,
                                  color: Colors.white, size: 100),
                        ),
                      ),
                    ],
                  ),
                ),
                // LIKE COMMENT SECTION
                Row(
                  children: [
                    LikeAnimation(
                      isAnimating: widget.snap['likes'].contains(user.uid),
                      smallLike: true,
                      child: IconButton(
                        onPressed: () async {
                          await FirestoreMethods().likePost(
                            widget.snap['postID'],
                            user.uid,
                            widget.snap['likes'],
                          );
                        },
                        icon: widget.snap['likes'].contains(user.uid)
                            ? const Icon(Icons.favorite, color: Colors.red)
                            : const Icon(Icons.favorite_border),
                      ),
                    ),
                    IconButton(
                      onPressed: () => Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) => CommentsScreen(
                            widget.snap,
                          ),
                        ),
                      ),
                      icon: const Icon(Icons.comment_outlined),
                    ),
                    IconButton(
                      onPressed: () {},
                      icon: const Icon(Icons.send),
                    ),
                    Expanded(
                      child: Align(
                        alignment: Alignment.bottomRight,
                        child: LikeAnimation(
                          isAnimating:
                              widget.snap['bookMark'].contains(user.uid),
                          smallLike: true,
                          child: IconButton(
                            onPressed: () async {
                              await FirestoreMethods().markPost(
                                widget.snap['postID'],
                                user.uid,
                                widget.snap['bookMark'],
                              );
                            },
                            icon: (widget.snap['bookMark'] != null &&
                                    widget.snap['bookMark'].contains(user.uid))
                                ? const Icon(
                                    Icons.bookmark,
                                    color: Colors.amber,
                                  )
                                : const Icon(Icons.bookmark_border),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                // DESCRIPTION AND NUMBER OF COMMENTS...
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      DefaultTextStyle(
                        style: Theme.of(context).textTheme.titleSmall!.copyWith(
                              fontWeight: FontWeight.w800,
                            ),
                        child: InkWell(
                          onTap: () async {
                            DocumentSnapshot postDoc = await FirebaseFirestore
                                .instance
                                .collection('posts')
                                .doc(widget.snap['postID'])
                                .get();
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (context) => ShowUsers(
                                  snapUser: postDoc['likes'],
                                  text: 'People who liked',
                                  icon: const Icon(
                                    Icons.favorite_outlined,
                                    color: Colors.red,
                                  ),
                                ),
                              ),
                            );
                          },
                          child: Text(
                            '${widget.snap['likes'].length} likes',
                            style: Theme.of(context).textTheme.bodyMedium,
                          ),
                        ),
                      ),
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.only(top: 8),
                        child: RichText(
                          text: TextSpan(
                            style: const TextStyle(color: primaryColor),
                            children: [
                              TextSpan(
                                text: widget.snap['username'] + '\t',
                                style: const TextStyle(
                                    fontWeight: FontWeight.bold),
                              ),
                              TextSpan(
                                text: widget.snap['description'],
                              )
                            ],
                          ),
                        ),
                      ),
                      InkWell(
                        onTap: () => Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (context) => CommentsScreen(
                              widget.snap,
                            ),
                          ),
                        ),
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 4),
                          child: StreamBuilder<int>(
                            stream: getCommentsCountStream(),
                            builder: (context, snapshot) {
                              if (snapshot.connectionState ==
                                  ConnectionState.waiting) {
                                return const Text(
                                  'Loading comments...',
                                  style: TextStyle(
                                      fontSize: 12, color: secondaryColor),
                                );
                              } else if (snapshot.hasError) {
                                return const Text(
                                  'Error loading comments',
                                  style: TextStyle(
                                      fontSize: 12, color: secondaryColor),
                                );
                              } else {
                                int commentCount = snapshot.data ?? 0;
                                return Text(
                                  'View all $commentCount comments',
                                  style: const TextStyle(
                                      fontSize: 12, color: secondaryColor),
                                );
                              }
                            },
                          ),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(vertical: 4),
                        child: Text(
                          DateFormat.yMMMd()
                              .format(widget.snap['datePublished'].toDate()),
                          style: const TextStyle(
                              fontSize: 12, color: secondaryColor),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
  }
}
