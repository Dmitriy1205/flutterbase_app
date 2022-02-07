import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:social_media_app/screens/sign_up_screen.dart';

class CreatePostScreen extends StatefulWidget {
  static const String id = 'create_post_screen';

  const CreatePostScreen({Key? key}) : super(key: key);

  @override
  _CreatePostScreenState createState() => _CreatePostScreenState();
}

class _CreatePostScreenState extends State<CreatePostScreen> {
  String _description = '';

  Future<void> _submit({required File image}) async {
    if (_description.trim().isNotEmpty) {
      late String imageUrl;
      firebase_storage.FirebaseStorage storage =
          firebase_storage.FirebaseStorage.instance;
      await storage
          .ref('images/${UniqueKey().toString()}.png')
          .putFile(image)
          .then((taskSnapshot) async {
        imageUrl = await taskSnapshot.ref.getDownloadURL();
      });
      FirebaseFirestore.instance.collection('avatars').add({
        'timestamp': Timestamp.now(),
        'description': _description,
        'imageUrl': imageUrl,
      }).then(
        (value) => value.update(
          {'postId': value.id},
        ),
      );
      Navigator.of(context).pushNamed(SignUpScreen.id);
    }
  }

  @override
  Widget build(BuildContext context) {
    final File imageFile = ModalRoute.of(context)!.settings.arguments as File;
    return Scaffold(
      appBar: AppBar(),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            children: [
              Container(
                width: MediaQuery.of(context).size.width,
                height: MediaQuery.of(context).size.height / 1.4,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  image: DecorationImage(
                    image: FileImage(imageFile),
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              TextButton(
                onPressed: () {
                  _submit(image: imageFile);
                },
                child: Text('Ok'),
              ),
              // TextField(
              //   inputFormatters: [
              //     LengthLimitingTextInputFormatter(180),
              //   ],
              //   decoration: const InputDecoration(
              //     hintText: 'Enter the description',
              //   ),
              //   textInputAction: TextInputAction.done,
              //   onChanged: (value) {
              //     _description = value;
              //   },
              //   onEditingComplete: () {
              //     _submit(image: imageFile);
              //   },
              // ),
            ],
          ),
        ),
      ),
    );
  }
}
