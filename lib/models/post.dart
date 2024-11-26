import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/rendering.dart';

class Post {
  final String description;
  final String uid;
  final String username;
  final String postID;
  final datePublished;
  final String postUrl;
  final String profImage;
  final likes;
  final bookMark;
  final hide;
  const Post({
    required this.description,
    required this.uid,
    required this.username,
    required this.postID,
    required this.datePublished,
    required this.postUrl,
    required this.profImage,
    required this.likes,
    required this.bookMark,
    required this.hide,
  });

  Map<String, dynamic> toJson() => {
        'username': username,
        'uid': uid,
        'description': description,
        'postID': postID,
        'datePublished': datePublished,
        'postUrl': postUrl,
        'profImage': profImage,
        'likes': likes,
        'bookMark': bookMark,
        'hide': hide,
      };
  static Post fromSnap(DocumentSnapshot snap) {
    var snapshot = snap.data() as Map<String, dynamic>;
    return Post(
      username: snapshot['username'],
      uid: snapshot['uid'],
      description: snapshot['description'],
      postID: snapshot['postID'],
      datePublished: snapshot['datePublished'],
      postUrl: snapshot['postUrl'],
      profImage: snapshot['profImage'],
      likes: snapshot['likes'],
      bookMark: snapshot['bookMark'],
      hide: snapshot['hide'],
    );
  }
}
