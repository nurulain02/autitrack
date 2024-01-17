// home_screen.dart
import 'dart:developer';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../bottomNavigationMenu.dart';
import '../constants/constants.dart';
import 'apis.dart';
import 'chat_screen.dart';
import 'chat_user.dart';
import 'chat_user_card.dart';
import '../model/educatorModel.dart';

class HomeScreen extends StatefulWidget {
  final String? currentUserId;

  const HomeScreen({Key? key,  this.currentUserId}) : super(key: key);

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<ChatUser> _list = [];
  List<ChatUser> _searchList = [];
  List<EducatorModel> _educatorsList = [];
  bool _isSearching = false;
  TextEditingController _searchController = TextEditingController();
  Size? mq;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    mq = MediaQuery.of(context).size;
  }

  @override
  void initState() {
    super.initState();
    _fetchEducatorsList();
    APIs.getSelfInfo();
    SystemChannels.lifecycle.setMessageHandler((message) {
      log('Message: $message');
      if (APIs.auth.currentUser != null) {
        if (message.toString().contains('resume')) {
          APIs.updateActiveStatus(true);
        }
        if (message.toString().contains('pause')) {
          APIs.updateActiveStatus(false);
        }
      }
      return Future.value(message);
    });
  }

  void _fetchEducatorsList() async {
    try {
      List<EducatorModel> educators = await APIs.getEducatorsList();
      setState(() {
        _educatorsList = educators;
      });
    } catch (e) {
      print('Error fetching educators: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: WillPopScope(
        onWillPop: () {
          if (_isSearching) {
            setState(() {
              _isSearching = !_isSearching;
              _searchController.clear();
              _searchList.clear();
            });
            return Future.value(false);
          } else {
            return Future.value(true);
          }
        },
        child: Scaffold(
          backgroundColor: Colors.green[50],
          appBar: AppBar(
            backgroundColor: AutiTrackColor2,
            title: _isSearching
                ? TextField(
              controller: _searchController,
              decoration: InputDecoration(
                border: InputBorder.none,
                hintText: 'Search by Name or Email...',
                hintStyle: TextStyle(color: Colors.black),
              ),
              autofocus: true,
              style: const TextStyle(fontSize: 17, letterSpacing: 0.5),
              onChanged: (val) {
                _searchList.clear();
                for (var user in _list) {
                  if (user.name
                      .toLowerCase()
                      .contains(val.toLowerCase()) ||
                      user.email
                          .toLowerCase()
                          .contains(val.toLowerCase())) {
                    _searchList.add(user);
                  }
                }
                setState(() {});
              },
            )
                : const Text('Message'),
            actions: [
              IconButton(
                onPressed: () {
                  setState(() {
                    _isSearching = !_isSearching;
                    if (_isSearching) {
                      _searchController.clear();
                    }
                  });
                },
                icon: Icon(
                  _isSearching
                      ? CupertinoIcons.clear_circled_solid
                      : Icons.search,
                  color: Colors.black,
                ),
              ),
            ],
          ),

          body: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                height: 130,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: _educatorsList.length,
                  itemBuilder: (context, index) {
                    return GestureDetector(
                      onTap: () {
                        _navigateToChatScreen(_educatorsList[index]);
                      },
                      child: Padding(
                        padding: const EdgeInsets.all(15.0),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            CircleAvatar(
                              backgroundImage: NetworkImage(
                                _educatorsList[index].educatorProfilePicture ?? "",
                              ),
                              radius: 30,
                            ),
                            SizedBox(height: 2),
                            Text(
                              _educatorsList[index].educatorName,
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),

              Expanded(
                child: ListView.builder(
                  scrollDirection: Axis.vertical,
                  itemCount: _educatorsList.length,
                  itemBuilder: (context, index) {
                    return GestureDetector(
                      onTap: () {
                        _navigateToChatScreen(_educatorsList[index]);
                      },
                      child: Padding(
                        padding: const EdgeInsets.all(20.0),
                        child: Container(
                          height: 100.0, // Set your desired height
                          child: Card(
                            elevation: 2.0,
                            child: ListTile(
                              leading: CircleAvatar(
                                backgroundImage: NetworkImage(
                                  _educatorsList[index].educatorProfilePicture ?? "",
                                ),
                                radius: 30,
                              ),
                              title: Text(
                                _educatorsList[index].educatorName,
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),

                              onTap: () {
                                _navigateToChatScreen(_educatorsList[index]);
                              },
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),

              Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: StreamBuilder(
                      stream: APIs.getMyUsersId(),
                      builder: (context, snapshot) {
                        switch (snapshot.connectionState) {
                          case ConnectionState.waiting:
                          case ConnectionState.none:
                            return const Center(child: CircularProgressIndicator());
                          case ConnectionState.active:
                          case ConnectionState.done:
                            return StreamBuilder(
                              stream: APIs.getAllUsers(
                                snapshot.data?.docs.map((e) => e.id).toList() ?? [],
                              ),
                              builder: (context, snapshot) {
                                switch (snapshot.connectionState) {
                                  case ConnectionState.waiting:
                                  case ConnectionState.none:
                                    return const Center(child: CircularProgressIndicator());
                                  case ConnectionState.active:
                                  case ConnectionState.done:
                                    if (mq == null) {
                                      mq = MediaQuery.of(context).size;
                                    }
                                    final data = snapshot.data?.docs;
                                    _list = data
                                        ?.map((e) => ChatUser.fromJson(e.data()))
                                        .toList() ??
                                        [];
                                    if (_list.isNotEmpty) {
                                      return ListView.builder(
                                        itemCount: _isSearching
                                            ? _searchList.length
                                            : _list.length,
                                        padding: EdgeInsets.only(top: mq?.height ?? 0.01),
                                        physics: const BouncingScrollPhysics(),
                                        itemBuilder: (context, index) {
                                          final user = _isSearching ? _searchList[index] : _list[index];

                                          final hasLastMessage = user.lastMessage != null && user.lastMessage.isNotEmpty;
                                          final isChattingWithCurrentUser = user.id == APIs.auth.currentUser?.uid;

                                          return GestureDetector(
                                            onTap: () {
                                              _navigateToChatScreen(user as EducatorModel);
                                            },
                                            child: ChatUserCard(
                                              user: user,
                                              showNameAndImage: hasLastMessage && isChattingWithCurrentUser,
                                            ),
                                          );
                                        },
                                      );
                                    } else {
                                      return const Center(
                                        child: Text(
                                          '',
                                          style: TextStyle(fontSize: 20),
                                        ),
                                      );
                                    }
                                }
                              },
                            );
                        }
                      },
                    ),
                  ),
                ),
            ],
          ),
          bottomNavigationBar: BottomNavigationMenu(
            selectedIndex: 1,
            onItemTapped: (index) {
              if (index == 0) {
                Navigator.pushReplacementNamed(context, '/mainScreen');
              } else if (index == 2) {
                Navigator.pushReplacementNamed(context, '/graph');
              } else if (index == 3) {
                Navigator.pushReplacementNamed(context, '/activity');
              } else if (index == 4) {
                Navigator.pushReplacementNamed(context, '/feedParent');
              }
            },
          ),
        ),
      ),
    );
  }




  void _navigateToChatScreen(EducatorModel educator) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ChatScreen(
          user: ChatUser(
            id: educator.id ?? '',
            name: educator.educatorName,
            image: educator.educatorProfilePicture,
            // Add other properties you need
            createdAt: DateTime.now().toIso8601String(),
            email: '',  // Provide a default value for email
            isOnline: false,  // Provide a default value for isOnline
            lastActive: DateTime.now().toIso8601String(),  // Provide a default value for lastActive
            pushToken: '', lastMessage: '',  // Provide a default value for pushToken
          ),

        ),
      ),
    );
  }


}



