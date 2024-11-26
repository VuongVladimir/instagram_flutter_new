import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:instagram_flutter_new/resources/auth_methods.dart';
import 'package:instagram_flutter_new/resources/firestore_methods.dart';
import 'package:instagram_flutter_new/screens/edit_profile.dart';
import 'package:instagram_flutter_new/screens/login_screen.dart';
import 'package:instagram_flutter_new/screens/show_users.dart';

import 'package:instagram_flutter_new/utils/colors.dart';
import 'package:instagram_flutter_new/utils/utils.dart';
import 'package:instagram_flutter_new/widgets/follow_button.dart';

class ProfileScreen extends StatefulWidget {
  final String uid;
  const ProfileScreen({super.key, required this.uid});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  var userData = {};
  int postLen = 0;
  int followers = 0;
  int following = 0;
  bool isFollowing = false;
  bool _isLoading = false;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getData();
  }

  getData() async {
    try {
      setState(() {
        _isLoading = true;
      });
      var userSnap = await FirebaseFirestore.instance
          .collection('users')
          .doc(widget.uid)
          .get();
      userData = userSnap.data()!;
      var postSnap = await FirebaseFirestore.instance
          .collection('posts')
          .where('uid', isEqualTo: widget.uid)
          .get();
      postLen = postSnap.docs.length;
      followers = userData['followers'].length;
      following = userData['following'].length;
      isFollowing = userData['followers']
          .contains(FirebaseAuth.instance.currentUser!.uid);
    } catch (e) {
      showSnackBar(e.toString(), context);
    }
    setState(() {
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return _isLoading
        ? const Center(
            child: CircularProgressIndicator(),
          )
        : Scaffold(
            appBar: AppBar(
              backgroundColor: newBackgroundColor,
              title: Text(userData['username']),
              actions: [
                PopupMenuButton(
                  onSelected: (String select) async {
                    switch (select) {
                      case 'Sign out':
                        await AuthMethods().signOut();
                        Navigator.of(context).pushReplacement(
                          MaterialPageRoute(
                            builder: (context) => const LoginScreen(),
                          ),
                        );
                        break;
                      default:
                        break;
                    }
                  },
                  itemBuilder: (context) => <PopupMenuEntry<String>>[
                    const PopupMenuItem(
                      value: 'Sign out',
                      child: Text('Sign out'),
                    ),
                  ],
                  icon: const Icon(Icons.menu),
                ),
              ],
            ),
            body: ListView(
              children: [
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          CircleAvatar(
                            backgroundImage: NetworkImage(userData['photoUrl']),
                            radius: 50,
                          ),
                          Expanded(
                            flex: 1,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Row(
                                  mainAxisSize: MainAxisSize.max,
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceEvenly,
                                  children: [
                                    buildStatColumn(postLen, 'posts'),
                                    buildStatColumn(followers, 'followers'),
                                    buildStatColumn(following, 'following'),
                                  ],
                                ),
                                (FirebaseAuth.instance.currentUser!.uid ==
                                        widget.uid)
                                    ? FollowButton(
                                        backgroundColor: Colors.blueAccent,
                                        borderColor: Colors.blueGrey,
                                        text: 'Edit Profile',
                                        textColor: primaryColor,
                                        function: () async {
                                          await Navigator.of(context).push(
                                            MaterialPageRoute(
                                              builder: (context) =>
                                                  const EditProfileScreen(),
                                            ),
                                          );
                                          var userSnap = await FirebaseFirestore
                                              .instance
                                              .collection('users')
                                              .doc(widget.uid)
                                              .get();
                                          setState(() {
                                            userData = userSnap.data()!;
                                          });
                                        },
                                      )
                                    : isFollowing
                                        ? FollowButton(
                                            backgroundColor: Colors.blueAccent,
                                            borderColor: Colors.blueGrey,
                                            text: 'Unfollow',
                                            textColor: Colors.black54,
                                            function: () async {
                                              await FirestoreMethods().follow(
                                                widget.uid,
                                                FirebaseAuth
                                                    .instance.currentUser!.uid,
                                              );
                                              setState(() {
                                                followers--;
                                                isFollowing = false;
                                              });
                                            },
                                          )
                                        : FollowButton(
                                            backgroundColor: Colors.blueAccent,
                                            borderColor: Colors.blueGrey,
                                            text: 'Following',
                                            textColor: Colors.white,
                                            function: () async {
                                              await FirestoreMethods().follow(
                                                widget.uid,
                                                FirebaseAuth
                                                    .instance.currentUser!.uid,
                                              );

                                              setState(() {
                                                followers++;
                                                isFollowing = true;
                                              });
                                            },
                                          )
                              ],
                            ),
                          ),
                        ],
                      ),
                      Container(
                        alignment: Alignment.centerLeft,
                        padding: const EdgeInsets.only(top: 12),
                        child: Text(
                          userData['username'],
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                      Container(
                        alignment: Alignment.centerLeft,
                        padding: const EdgeInsets.only(top: 1),
                        child: Text(
                          userData['bio'],
                        ),
                      ),
                      const Divider(),
                      FutureBuilder(
                        future: FirebaseFirestore.instance
                            .collection('posts')
                            .where('uid', isEqualTo: widget.uid)
                            .get(),
                        builder: (context, snapshot) {
                          if (snapshot.connectionState ==
                              ConnectionState.waiting) {
                            return const Center(
                              child: CircularProgressIndicator(),
                            );
                          }
                          return GridView.builder(
                            shrinkWrap: true,
                            gridDelegate:
                                const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 3,
                              crossAxisSpacing: 5,
                              mainAxisSpacing: 1.5,
                              childAspectRatio: 1,
                            ),
                            itemCount: (snapshot.data! as dynamic).docs.length,
                            itemBuilder: (context, index) {
                              return Image(
                                image: NetworkImage((snapshot.data! as dynamic)
                                    .docs[index]['postUrl']),
                                fit: BoxFit.cover,
                              );
                            },
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
  }

  Column buildStatColumn(int num, String label) {
    return Column(
      children: [
        InkWell(
          onTap: () {
            if (label != 'posts') {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => ShowUsers(
                    snapUser: userData[label],
                    text: label,
                  ),
                ),
              );
            }
          },
          child: Text(
            num.toString(),
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        Text(
          label,
          style: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w400,
            color: Colors.grey,
          ),
        ),
      ],
    );
  }
}
