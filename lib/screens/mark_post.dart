import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:instagram_flutter_new/utils/colors.dart';
import 'package:instagram_flutter_new/utils/global_variables.dart';
import 'package:instagram_flutter_new/widgets/post_card.dart';

class MarkPost extends StatelessWidget {
  const MarkPost({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: MediaQuery.of(context).size.width > webScreenSize
          ? null
          : AppBar(
              backgroundColor: newBackgroundColor,
              title: SvgPicture.asset(
                'assets/ic_instagram.svg',
                colorFilter:
                    const ColorFilter.mode(Colors.white60, BlendMode.srcIn),
                height: 32,
              ),
              
            ),
      body: StreamBuilder(
        stream: FirebaseFirestore.instance.collection('posts').where('bookMark', arrayContains: FirebaseAuth.instance.currentUser!.uid).snapshots(),
        builder: (context,
            AsyncSnapshot<QuerySnapshot<Map<String, dynamic>>> snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          return ListView.builder(
            itemCount: snapshot.data!.docs.length,
            itemBuilder: (context, index) => PostCard(
              snapshot.data!.docs[index].data(),
              true,
            ),
          );
        },
      ),
    );
  }
}
