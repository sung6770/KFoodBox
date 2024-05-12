import 'package:flutter/material.dart';
import '../translate/language_detect.dart';
import 'language_setting.dart';
import '../home/bottom.dart';
import 'user_info.dart';
import '../home/on_item_tap.dart';
import '../globals.dart' as globals;
import '../home/main_screen.dart';
import '../login/service/login_service.dart';
import '../bookmark/foods_bookmark/foods_bookmark_data.dart';
import '../bookmark/community_bookmark/community_bookmark_data.dart';

class MyPageYes extends StatefulWidget {
  @override
  _MyPageYesState createState() => _MyPageYesState();
}

class _MyPageYesState extends State<MyPageYes> {
  int _currentIndex = 0; // bottomnavigation index 번호 
  
  Map<String, List<String>> items = {
    globals.getText('community'): CommunityBookmarkData.getBookmarkNames(),
    globals.getText('custom recipes'): ['Article title 1', 'Article title 2', 'Article title 1', 'Article title 2'],
    globals.getText('foods'): FoodBookmarkData.getBookmarkNames(),
  };
  // 일단 북마크 했다고 가정하고 임시 자료

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false, // 위치 고정하는거 -> 이거 x일시 만약 키보드 올라올때 각각들도 따라 올라옴 
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => KFoodBoxHome()),
            );
          },
        ),
        title: Text(globals.getText('myPageTitle')),
        centerTitle: true,
        actions: [
          IconButton(
            icon: Icon(Icons.language),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => LanguageSelectScreen(
                    onLanguageSelected: (selectedCode) {
                    },
                  ),
                ),
              );
            },
          ),
        ],
      ),
      body: ListView(
        children: <Widget>[
          Container(
            padding: EdgeInsets.all(16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                //Icon(Icons.bookmark),
                InkWell( // Text를 InkWell로 감싸 클릭 가능하게
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => UserInfoScreen()),
                    );
                  },
                  child: Text(
                    globals.user_email ?? 'No email set',  // This will use the globally stored email or a default string if null
                    style: TextStyle(
                      fontSize: 15.0,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.logout),
                  onPressed: () {
                    LoginService.logout(context);
                  },
                ),
              ],
            ),
          ),
          Divider(),
          Container(
            padding: EdgeInsets.all(16.0),
            child: Row(
              children: [
                Icon(Icons.bookmark),
                SizedBox(width: 8),
                Text(
                  globals.getText('bookmark list'),
                  style: TextStyle(
                    fontSize: 20.0,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          ...items.entries.map((entry) => _buildExpansionTile(title: entry.key, children: entry.value)).toList(),
        ],
      ),
      bottomNavigationBar: BottomNav(
        currentIndex: _currentIndex,
        onTap: (index) => onItemTapped(context, index),
      ),
      // lib/home/bottom.dart에서 bottomNavigation 불러오기 
    );
  }

  Widget _buildExpansionTile({required String title, required List<String> children}) {
    return ExpansionTile(
      title: Text(title),
      children: children.map((String item) {
        return ListTile(
          title: FutureBuilder<String>(
            future: translateText(item),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.done) {
                if (snapshot.hasError) {
                  return Text(
                    'Error',
                    style: TextStyle(
                      color: Colors.red,
                      fontSize: 16.0,
                      fontWeight: FontWeight.bold,
                    ),
                  );
                } else {
                  return Text(
                    snapshot.data ?? 'Translation error',  // 번역 실패시 대체 텍스트
                    style: TextStyle(
                      fontSize: 16.0,
                    ),
                  );
                }
              } else {
                return CircularProgressIndicator();  // 로딩 중 표시
              }
            },
          ),
          trailing: IconButton(
            icon: Icon(Icons.delete),
            onPressed: () => _deleteItem(title, item),
          ),
        );
      }).toList(),
    );
  }

  void _deleteItem(String category, String item) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(globals.getText('Are you sure you want to delete it?')),
          actions: <Widget>[
            TextButton(
              child: Text(globals.getText('Cancel')),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: Text(globals.getText('Delete')),
              style: TextButton.styleFrom(
                backgroundColor: Colors.red,
              ),
              onPressed: () {
                  setState(() {
                  if (category == globals.getText('foods')) {
                    FoodBookmarkData.deleteBookmark(item);
                  } else if (category == globals.getText('community')) {
                    CommunityBookmarkData.deleteBookmark(item);
                  }
                  items[category]?.remove(item);
                  if (items[category]?.isEmpty ?? true) {
                    items.remove(category);
                  }
                  Navigator.of(context).pop();
                });
              },
            ),
          ],
        );
      },
    );
  }
}