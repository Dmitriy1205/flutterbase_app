import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:social_media_app/models/chat_model.dart';
import 'package:social_media_app/models/post_model.dart';

class ChatScreen extends StatefulWidget {
  static const String id = 'chat_screen';

  const ChatScreen({Key? key}) : super(key: key);

  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  String _message = '';
  late TextEditingController _textEditingController;

  @override
  void initState() {
    _textEditingController = TextEditingController();
    super.initState();
  }

  @override
  void dispose() {
    _textEditingController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final Post post = ModalRoute.of(context)!.settings.arguments as Post ;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Chat'),
      ),
      body: Column(
        children: [
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('posts')
                  .doc(post.id)
                  .collection('comments')
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return const Center(
                    child: Text('Error'),
                  );
                }
                if (snapshot.connectionState == ConnectionState.waiting ||
                    snapshot.connectionState == ConnectionState.none) {
                  return const Center(
                    child: Text('Loading...'),
                  );
                }
                return ListView.builder(
                    itemCount: snapshot.data?.docs.length ?? 0,
                    itemBuilder: (context, index) {
                      final QueryDocumentSnapshot doc =
                          snapshot.data!.docs[index];
                      final ChatModel chatModel = ChatModel(
                          userName: doc['userName'],
                          userId: doc['userId'],
                          message: doc['message'],
                          timestamp: doc['timestamp']);
                      return Container(
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Column(
                            children: [
                              Text(
                                'By ${chatModel.userName}',
                              ),
                              const SizedBox(
                                height: 4,
                              ),
                              Text(
                                chatModel.message,
                              ),
                            ],
                          ),
                        ),
                      );
                    });
              },
            ),
          ),
          Container(
            height: 50,
            child: Row(
              children: [
                Expanded(
                  child: Padding(
                    padding: EdgeInsets.all(4.0),
                    child: TextField(
                      controller: _textEditingController,
                      maxLines: 2,
                      decoration: InputDecoration(hintText: 'Enter message'),
                      onChanged: (value) {
                        _message = value;
                      },
                    ),
                  ),
                ),
                IconButton(
                    onPressed: () {
                      FirebaseFirestore.instance
                          .collection('posts')
                          .doc(post.id)
                          .collection('comments')
                          .add({
                            'userID': FirebaseAuth.instance.currentUser!.uid,
                            'userName':
                                FirebaseAuth.instance.currentUser!.displayName,
                            'message': _message,
                            'timestamp': Timestamp.now(),
                          })
                          .then((value) => print('chat doc added'))
                          .catchError((onError) => print('Error has occured'));
                      _textEditingController.clear();
                      setState(() {
                        _message = '';
                      });
                    },
                    icon: const Icon(Icons.arrow_back_ios_new_rounded))
              ],
            ),
          ),
        ],
      ),
    );
  }
}
