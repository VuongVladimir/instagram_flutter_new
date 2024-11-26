import 'dart:typed_data';

import 'package:flutter/material.dart';

import 'package:image_picker/image_picker.dart';
import 'package:instagram_flutter_new/models/user.dart';
import 'package:instagram_flutter_new/providers/user_provider.dart';

import 'package:instagram_flutter_new/resources/firestore_methods.dart';

import 'package:instagram_flutter_new/utils/colors.dart';
import 'package:instagram_flutter_new/utils/global_variables.dart';
import 'package:instagram_flutter_new/utils/utils.dart';
import 'package:instagram_flutter_new/widgets/text_field_input..dart';
import 'package:provider/provider.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final TextEditingController _bioController = TextEditingController();
  final TextEditingController _usernameController = TextEditingController();
  Uint8List? _newImage;
  bool _isLoading = false;

  @override
  

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    _bioController.dispose();
    _usernameController.dispose();
  }

  void selectImage() async {
    Uint8List im = await pickImage(ImageSource.gallery);
    setState(() {
      _newImage = im;
    });
  }

  @override
  Widget build(BuildContext context) {
    final User user = Provider.of<UserProvider>(context).getUser;
    return Scaffold(
      body: SafeArea(
        child: Container(
          padding: MediaQuery.of(context).size.width > webScreenSize
              ? EdgeInsets.symmetric(
                  horizontal: MediaQuery.of(context).size.width / 3)
              : const EdgeInsets.symmetric(horizontal: 32),
          width: double.infinity,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Flexible(flex: 2, child: Container()),
              Stack(
                children: [
                  _newImage != null
                      ? CircleAvatar(
                          radius: 80,
                          backgroundImage: MemoryImage(_newImage!),
                        )
                      : CircleAvatar(
                          radius: 80,
                          backgroundImage: NetworkImage(user.photoUrl),
                        ),
                  Positioned(
                    bottom: -10,
                    left: 80,
                    child: IconButton(
                      onPressed: selectImage,
                      icon: const Icon(
                        Icons.add_a_photo,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 15),
              TextFieldInput(
                textEditingController: _usernameController,
                hintText: user.username,
                textInputType: TextInputType.text,
              ),
              const SizedBox(height: 15),
              TextFieldInput(
                textEditingController: _bioController,
                hintText: user.bio,
                textInputType: TextInputType.text,
              ),
              const SizedBox(height: 15),
              InkWell(
                onTap: () async {
                  setState(() {
                    _isLoading = true;
                  });
                  await FirestoreMethods().updateProfile(user.uid,
                      _usernameController.text, _bioController.text, _newImage);
                      setState(() {
                        _isLoading = false;
                      });
                  await Provider.of<UserProvider>(context, listen: false).refreshUser();
                  Navigator.of(context).pop();
                },
                child: Container(
                  width: double.infinity,
                  alignment: Alignment.center,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  decoration: const ShapeDecoration(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.all(
                          Radius.circular(4),
                        ),
                      ),
                      color: Colors.blueAccent),
                  child: _isLoading
                      ? const Center(
                          child: CircularProgressIndicator(
                            color: primaryColor,
                          ),
                        )
                      : const Text('Save'),
                ),
              ),
              const SizedBox(height: 15),
              Flexible(flex: 2, child: Container()),
            ],
          ),
        ),
      ),
    );
  }
}
