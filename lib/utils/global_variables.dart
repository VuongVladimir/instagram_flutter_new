import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:instagram_flutter_new/screens/add_post_screen.dart';
import 'package:instagram_flutter_new/screens/mark_post.dart';
import 'package:instagram_flutter_new/screens/feed_screen.dart';
import 'package:instagram_flutter_new/screens/profile_screen.dart';
import 'package:instagram_flutter_new/screens/search_screen.dart';

const webScreenSize = 600;

List<Widget> homeScreenItems = [
  const FeedScreen(),
  const SearchScreen(),
  const AddPostScreen(),
  const MarkPost(),
  ProfileScreen(uid: FirebaseAuth.instance.currentUser!.uid,),
];
