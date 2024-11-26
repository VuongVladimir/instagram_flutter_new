
import 'package:flutter/material.dart';
import 'package:instagram_flutter_new/screens/profile_screen.dart';
import 'package:instagram_flutter_new/utils/colors.dart';
import 'package:instagram_flutter_new/utils/utils.dart';

class ShowUsers extends StatefulWidget {
  final List snapUser;
  final String text;
  final Icon ? icon;
  const ShowUsers({super.key, required this.snapUser, required this.text, this.icon});

  @override
  State<ShowUsers> createState() => _ShowUsersState();
}

class _ShowUsersState extends State<ShowUsers> {
  

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: newBackgroundColor,
        title: Text(widget.text),
        centerTitle: true,
      ),
      body: FutureBuilder(
        future: getUserDoc(widget.snapUser),
        builder: (context, snapshot) {
          if (!snapshot.hasData ||
              snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }
          List<Map<String, dynamic>> likeList = snapshot.data!;
          return ListView.builder(
            itemCount: likeList.length,
            itemBuilder: (context, index) {
              return ListTile(
                onTap: () => Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => ProfileScreen(
                      uid: likeList[index]['uid'],
                    ),
                  ),
                ),
                leading: CircleAvatar(
                  backgroundImage: NetworkImage(likeList[index]['photoUrl']),
                ),
                title: Text(likeList[index]['username']),
                trailing: widget.icon,
                
              );
            },
          );
        },
      ),
    );
  }
}
