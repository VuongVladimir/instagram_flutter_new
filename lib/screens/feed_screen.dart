import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:instagram_flutter_new/utils/colors.dart';
import 'package:instagram_flutter_new/utils/global_variables.dart';
import 'package:instagram_flutter_new/widgets/post_card.dart';

class FeedScreen extends StatelessWidget {
  const FeedScreen({super.key});

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
              actions: [
                IconButton(
                  onPressed: () {},
                  icon: const Icon(
                    Icons.messenger_outline,
                  ),
                ),
              ],
            ),
      body: StreamBuilder(
        stream: FirebaseFirestore.instance
            .collection('posts')
            .orderBy('datePublished', descending: true)
            .snapshots(),
        builder: (context,
            AsyncSnapshot<QuerySnapshot<Map<String, dynamic>>> snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Đã xảy ra lỗi: ${snapshot.error}'));
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text('Không có bài viết nào'));
          }
          return ListView.builder(
            itemCount: snapshot.data!.docs.length,
            itemBuilder: (context, index) => PostCard(
              snapshot.data!.docs[index].data(),
              false,
            ),
          );
        },
      ),
    );
  }
}
