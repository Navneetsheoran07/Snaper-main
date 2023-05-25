import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:snapper/Pages/AddPage/addPage.dart';
import 'package:snapper/Pages/MainPages/ChatScreen/chatScreen.dart';
import 'package:snapper/Pallete.dart';
import 'package:snapper/UI/ListStyleStatus.dart';
import 'package:snapper/UI/shared/AppBarConstWidget.dart';
import 'package:snapper/UI/shared/CustomCircleAvatarOpacity.dart';
import 'dart:math' as math;

import 'package:snapper/services/chatServices.dart';

class Chats extends StatelessWidget {
  const Chats({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: CustomScrollView(
        slivers: <Widget>[
          SliverAppBar(
            pinned: true,
            forceElevated: false,
            leadingWidth: 150.0,
            leading: Padding(
              padding: const EdgeInsets.only(left: 8.0),
              child: AppBarConstWidget(
                specificColor: white,
              ),
            ),
            backgroundColor: Colors.white,
            centerTitle: true,
            title: Text(
              "Chat",
              style: TextStyle(
                fontSize: 22.0,
                fontWeight: FontWeight.bold,
              ),
            ),
            elevation: 1.0,
            actions: [
              Padding(
                padding: const EdgeInsets.only(left: 8.0),
                child: TrailingAppBarChat(),
              ),
            ],
          ),
          StreamBuilder(
            stream: userSnapshot(),
            builder: (BuildContext context, AsyncSnapshot snapshot) {
              if (!snapshot.hasData)
                return SliverToBoxAdapter(
                  child: Text(""),
                );
              return SliverFixedExtentList(
                itemExtent: 70.0, // I'm forcing item heights
                delegate: SliverChildBuilderDelegate(
                  (context, index) => Padding(
                    padding: const EdgeInsets.only(left: 8.0),
                    child: ChatListTile(
                      status: 'videoSnapReceived',
                      chat_room_key: snapshot.data['chat_rooms'][index],
                    ),
                  ),
                  childCount: snapshot.data['chat_rooms'].length,
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}

class ChatListTile extends StatelessWidget {
  final String chat_room_key;
  final String status;
  ChatListTile({Key key, this.status, this.chat_room_key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    ListStyleStatus listStyleStatus = getListStyleStatus(status);
    return StreamBuilder<QuerySnapshot>(
      stream: chatroomsnapsnapshot(chat_room_key),
      builder: (BuildContext context, AsyncSnapshot snapshot) {
        if (!snapshot.hasData) return CircularProgressIndicator();
        // print(snapshot.data.docs[0].get('seen'));
        return ListTile(
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(
              builder: (BuildContext context) => snapshot.data.docs.length > 0
                  ? SnapViewer(
                      img_src: snapshot.data.docs[0].get('image_src'),
                    )
                  : ChatScreen(
                      chat_room_key: chat_room_key,
                    ),
            ),
          ),
          leading: CircleAvatar(
            radius: 25.0,
          ),
          title: Text(
            "Person Name",
            style: TextStyle(
                fontWeight: FontWeight.w800,
                fontSize: 15.0,
                color: Colors.black87),
          ),
          subtitle: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisSize: MainAxisSize.max,
            children: [
              snapshot.data.docs.length > 0
                  ? Icon(
                      newSnap.squareIcon,
                      color: newSnap.squareColor,
                      size: 12.0,
                    )
                  : Icon(
                      listStyleStatus.squareIcon,
                      size: 12.0,
                    ),
              hspace5,
              Text(
                snapshot.data.docs.length > 0 && snapshot.data.docs[0]['seen']
                    ? "connect"
                    : "not connect",
                style: TextStyle(
                  color: listStyleStatus.fontColor ?? Colors.grey,
                  fontSize: 10.5,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          contentPadding: EdgeInsets.symmetric(horizontal: 5.0, vertical: 0.0),
          trailing: Transform(
            transform: Matrix4.rotationY(math.pi),
            child: Icon(
              Icons.chat_bubble_outline,
              color: Colors.black45,
              size: 18.0,
            ),
          ),
        );
      },
    );
  }
}

class TrailingAppBarChat extends StatelessWidget {
  const TrailingAppBarChat({
    Key key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        BuildOpacityButton(
          function: () => Navigator.of(context).push(MaterialPageRoute(
              builder: (context) => AddPage(), fullscreenDialog: true)),
          iconData: Icons.person_add_alt_1,
          color: white,
        ),
        hspace10,
        BuildOpacityButton(
          function: () {},
          iconData: Icons.chat_bubble_rounded,
          color: white,
        ),
        hspace10,
      ],
    );
  }
}

class SnapViewer extends StatelessWidget {
  final String img_src;
  const SnapViewer({Key key, this.img_src}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        height: double.infinity,
        width: double.infinity,
        child: FittedBox(
            fit: BoxFit.cover,
            child: Image.network(img_src)) /* add child content here */,
      ),
    );
  }
}
