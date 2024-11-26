import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:instagram_flutter_new/models/user.dart';
import 'package:instagram_flutter_new/providers/user_provider.dart';
import 'package:instagram_flutter_new/resources/firestore_methods.dart';
import 'package:instagram_flutter_new/screens/show_users.dart';
import 'package:instagram_flutter_new/screens/profile_screen.dart';
import 'package:instagram_flutter_new/utils/colors.dart';
import 'package:instagram_flutter_new/utils/global_variables.dart';
import 'package:instagram_flutter_new/widgets/like_animation.dart';

import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

class CommentCard extends StatefulWidget {
  final snap;
  const CommentCard(this.snap, {super.key});

  @override
  State<CommentCard> createState() => _CommentCardState();
}

class _CommentCardState extends State<CommentCard> {
  int likeCount = 0;
  Stream<int> getLikesCountStream() {
    return FirebaseFirestore.instance
        .collection('posts')
        .doc(widget.snap['postID'])
        .collection('comments')
        .doc(widget.snap['commentId'])
        .snapshots()
        .map((snapshot) => snapshot.data()?['likes'].length);
  }

  @override
  Widget build(BuildContext context) {
    final User user = Provider.of<UserProvider>(context).getUser;
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 16),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          InkWell(
            onTap: () => Navigator.of(context).push(
              MaterialPageRoute(
                builder: (context) => ProfileScreen(uid: widget.snap['uid']),
              ),
            ),
            child: CircleAvatar(
              backgroundImage: NetworkImage(widget.snap['profilePics']),
              radius: 18,
            ),
          ),
          (MediaQuery.of(context).size.width > webScreenSize)
              ? Container(
                  margin: const EdgeInsets.only(left: 12, right: 25),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      RichText(
                        text: TextSpan(
                            style: const TextStyle(color: Colors.white),
                            children: [
                              TextSpan(
                                text: widget.snap['name'] + ' ',
                                style: const TextStyle(
                                    fontWeight: FontWeight.bold),
                              ),
                              TextSpan(
                                text: widget.snap['text'],
                              ),
                            ]),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(top: 4),
                        child: Text(
                          DateFormat.yMMMd()
                              .format(widget.snap['datePublished'].toDate()),
                          style: const TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                      ),
                    ],
                  ),
                )
              : Expanded(
                  child: Padding(
                    padding: const EdgeInsets.only(left: 12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        RichText(
                          text: TextSpan(
                            style: const TextStyle(color: Colors.white),
                            children: [
                            TextSpan(
                              text: widget.snap['name'] + ' ',
                              style:
                                  const TextStyle(fontWeight: FontWeight.bold),
                            ),
                            TextSpan(
                              text: widget.snap['text'],
                            ),
                          ]),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(top: 4),
                          child: Text(
                            DateFormat.yMMMd()
                                .format(widget.snap['datePublished'].toDate()),
                            style: const TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
          LikeAnimation(
            isAnimating: (widget.snap['likes'] != null &&
                widget.snap['likes'].contains(user.uid)),
            smallLike: true,
            child: GestureDetector(
              onTap: () async {
                await FirestoreMethods().likeComment(
                  widget.snap['postID'],
                  widget.snap['commentId'],
                  user.uid,
                  widget.snap['likes'],
                );
              },
              child: (widget.snap['likes'] != null &&
                      widget.snap['likes'].contains(user.uid))
                  ? const Icon(
                      Icons.favorite_outlined,
                      size: 20,
                      color: Colors.redAccent,
                    )
                  : const Icon(
                      Icons.favorite_border_outlined,
                      size: 20,
                      color: Colors.white,
                    ),
            ),
          ),
          Container(
            padding: const EdgeInsets.only(left: 4),
            child: StreamBuilder<int>(
              stream: getLikesCountStream(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting ||
                    snapshot.hasError) {
                  return Container();
                }
                likeCount = snapshot.data ?? 0;
                return (likeCount == 0)
                    ? Container()
                    : InkWell(
                        onTap: () async {
                          DocumentSnapshot commentDoc = await FirebaseFirestore
                              .instance
                              .collection('posts')
                              .doc(widget.snap['postID'])
                              .collection('comments')
                              .doc(widget.snap['commentId'])
                              .get();
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (context) => ShowUsers(
                                snapUser: commentDoc['likes'],
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
                          likeCount.toString(),
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                      );
              },
            ),
          ),
        ],
      ),
    );
  }
}
