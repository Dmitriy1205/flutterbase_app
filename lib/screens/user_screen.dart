import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:social_media_app/bloc/auth_cubit.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:social_media_app/models/user_model.dart';
import 'package:social_media_app/screens/sign_in_screen.dart';

import 'chat_screen.dart';
import 'create_post_screen.dart';

class UserScreen extends StatefulWidget {
  static const String id = 'user_screen';

  @override
  _UserScreenState createState() => _UserScreenState();
}

class _UserScreenState extends State<UserScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        actions: [
          IconButton(
              onPressed: () {
                context.read<AuthCubit>().signOut().then((_) =>
                    Navigator.of(context)
                        .pushReplacementNamed(SignInScreen.id));
              },
              icon: const Icon(Icons.logout))
        ],
      ),
      body: StreamBuilder<QuerySnapshot>(
          stream: FirebaseFirestore.instance.collection('users').snapshots(),
          builder: (context, snapshot) {
            if (snapshot.hasError) {
              return const Center(
                child: Text('Error'),
              );
            }
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(
                child: Text('Loading'),
              );
            }
            return ListView.builder(
                itemCount: snapshot.data!.docs.length,
                itemBuilder: (context, index) {
                  final QueryDocumentSnapshot doc = snapshot.data!.docs[index];
                  final UserModel userModel = UserModel(
                    userId: doc['userID'],
                    email: doc['email'],
                    userName: doc['userName'],
                    image: doc['imageUrl'],
                  );
                  if(userModel.userId == FirebaseAuth.instance.currentUser!.uid){
                    return Container();
                  }
                  return GestureDetector(
                    onTap: () {
                      Navigator.of(context)
                          .pushNamed(ChatScreen.id);
                    },
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(5, 2, 5, 1),
                      child: Column(
                        children: [
                          Card(
                            child: Row(
                              children: [
                                Padding(
                                  padding: EdgeInsets.all(5.0),
                                  child: CircleAvatar(
                                    backgroundImage:
                                        NetworkImage(userModel.image),
                                  ),
                                ),
                                const SizedBox(
                                  width: 18,
                                ),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(userModel.userName),
                                    Text(userModel.email),
                                  ],

                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                });
          }),
    );
  }
}
