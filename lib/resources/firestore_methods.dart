import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:instagram_flutter_new/models/post.dart';
import 'package:instagram_flutter_new/resources/storage_methods.dart';
import 'package:uuid/uuid.dart';

class FirestoreMethods {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // upload post
  Future<String> uploadPost(
    String description,
    Uint8List file,
    String uid,
    String username,
    String profImage,
  ) async {
    String res = "Some error occurred";
    try {
      String photoUrl =
          await StorageMethods().uploadImageToStorage('posts', file, true);
      String postID = const Uuid().v1();
      Post post = Post(
        description: description,
        uid: uid,
        username: username,
        postID: postID,
        datePublished: DateTime.now(),
        postUrl: photoUrl,
        profImage: profImage,
        likes: [],
        bookMark: [],
        hide: [],
      );
      _firestore.collection('posts').doc(postID).set(
            post.toJson(),
          );
      res = "success";
    } catch (err) {
      res = err.toString();
    }
    return res;
  }

  Future<void> likePost(String postID, String uid, List likes) async {
    try {
      if (likes.contains(uid)) {
        await _firestore.collection('posts').doc(postID).update({
          'likes': FieldValue.arrayRemove([uid]),
        });
      } else {
        await _firestore.collection('posts').doc(postID).update({
          'likes': FieldValue.arrayUnion([uid]),
        });
      }
    } catch (e) {
      print(e.toString());
    }
  }

  Future<void> markPost(String postID, String uid, List bookMark) async {
    try {
      if (bookMark.contains(uid)) {
        await _firestore.collection('posts').doc(postID).update({
          'bookMark': FieldValue.arrayRemove([uid]),
        });
      } else {
        await _firestore.collection('posts').doc(postID).update({
          'bookMark': FieldValue.arrayUnion([uid]),
        });
      }
    } catch (e) {
      print(e.toString());
    }
  }

  Future<void> postComment(String postID, String text, String uid, String name,
      String profilePics) async {
    try {
      if (text.isNotEmpty) {
        String commentId = const Uuid().v1();
        await _firestore
            .collection('posts')
            .doc(postID)
            .collection('comments')
            .doc(commentId)
            .set({
          'profilePics': profilePics,
          'name': name,
          'uid': uid,
          'text': text,
          'commentId': commentId,
          'datePublished': DateTime.now(),
          'likes': [],
          'postID': postID,
        });
      } else {
        print('Text is empty');
      }
    } catch (e) {
      print(e.toString());
    }
  }

  Future<void> likeComment(
      String postID, String commentId, String uid, List likes) async {
    try {
      if (likes.contains(uid)) {
        await _firestore
            .collection('posts')
            .doc(postID)
            .collection('comments')
            .doc(commentId)
            .update({
          'likes': FieldValue.arrayRemove([uid]),
        });
      } else {
        await _firestore
            .collection('posts')
            .doc(postID)
            .collection('comments')
            .doc(commentId)
            .update({
          'likes': FieldValue.arrayUnion([uid]),
        });
      }
    } catch (e) {
      print(e.toString());
    }
  }

  // Delete Post
  Future<void> deletePost(String postID) async {
    try {
      await _firestore.collection('posts').doc(postID).delete();
    } catch (e) {
      print(e.toString());
    }
  }

  // Hide Post
  Future<void> hidePost(String postID, String uid) async {
    try {
      await _firestore.collection('posts').doc(postID).update({
        'hide': FieldValue.arrayUnion([uid]),
      });
    } catch (e) {
      print(e.toString());
    }
  }

  // Follow
  Future<void> follow(String uid, String currentUid) async {
    try {
      DocumentSnapshot snap =
          await _firestore.collection('users').doc(uid).get();
      List followers = (snap.data()! as dynamic)['followers'];
      if (followers.contains(currentUid)) {
        await _firestore.collection('users').doc(uid).update({
          'followers': FieldValue.arrayRemove([currentUid]),
        });
        await _firestore.collection('users').doc(currentUid).update({
          'following': FieldValue.arrayRemove([uid]),
        });
      } else {
        await _firestore.collection('users').doc(uid).update({
          'followers': FieldValue.arrayUnion([currentUid]),
        });
        await _firestore.collection('users').doc(currentUid).update({
          'following': FieldValue.arrayUnion([uid]),
        });
      }
    } catch (e) {
      print(e.toString());
    }
  }

  // Edit profile
  Future<void> updateProfile(
      String uid, String newUsername, String newBio, Uint8List? file) async {
    try {
      if (newUsername.isNotEmpty || newBio.isNotEmpty || file != null) {
        Map<String, dynamic> dataUpdate = {};
        if (newUsername.isNotEmpty) {
          dataUpdate['username'] = newUsername;
        }
        if (newBio.isNotEmpty) {
          dataUpdate['bio'] = newBio;
        }
        if (file != null) {
          String photoUrl = await StorageMethods()
              .uploadImageToStorage('profilePics', file, false);
          dataUpdate['photoUrl'] = photoUrl;
        }
        if (dataUpdate.isNotEmpty) {
          await _firestore.collection('users').doc(uid).update(dataUpdate);
        }
      }
    } catch (e) {
      print(e.toString());
    }
  }
}
