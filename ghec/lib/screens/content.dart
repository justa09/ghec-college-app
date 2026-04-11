import 'package:flutter/material.dart';
import 'package:ghec/api/post_service.dart';
import 'login.dart';
import 'todo.dart';

class Content extends StatefulWidget {
  const Content({super.key});

  @override
  State<Content> createState() => _Content();
}

class _Content extends State<Content> {
  int currentIndex = 0;

  List posts = [];
  bool isLoading = true;

  // ✅ FIX: correct base URL for images
  String baseMediaUrl = "http://192.168.43.46:8000";

  @override
  void initState() {
    super.initState();
    loadPosts();
  }

  Future<void> loadPosts() async {
    try {
      final data = await PostService.fetchPosts();
      setState(() {
        posts = data;
        isLoading = false;
      });
    } catch (e) {
      print(e);
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHight = MediaQuery.of(context).size.height;

    return Scaffold(
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: currentIndex,
        onTap: (index) {
          setState(() {
            currentIndex = index;
          });
        },
        selectedItemColor: Colors.black,
        unselectedItemColor: Colors.grey,
        showUnselectedLabels: true,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.info), label: "About"),
          BottomNavigationBarItem(
            icon: Icon(Icons.account_tree),
            label: "Branches",
          ),
          BottomNavigationBarItem(icon: Icon(Icons.school), label: "Faculty"),
          BottomNavigationBarItem(
            icon: Icon(Icons.help_outline),
            label: "Query",
          ),
        ],
      ),

      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xff11998e), Color(0xff38ef7d)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Column(
          children: [
            // 🔝 HEADER
            SafeArea(
              child: Padding(
                padding: EdgeInsets.all(screenWidth * 0.03),
                child: Material(
                  elevation: screenWidth * 0.02,
                  borderRadius: BorderRadius.circular(screenWidth * 0.04),
                  child: Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: screenWidth * 0.05,
                      vertical: screenHight * 0.01,
                    ),
                    child: Row(
                      children: [
                        CircleAvatar(
                          radius: screenWidth * 0.05,
                          backgroundImage: const AssetImage(
                            "assets/images/logo.jpg",
                          ),
                        ),
                        SizedBox(width: screenWidth * 0.02),
                        Text(
                          "GHEC",
                          style: TextStyle(
                            fontSize: screenWidth * 0.05,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const Spacer(),

                        TextButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => TodoScreen(),
                              ),
                            );
                          },
                          child: Text("Todo"),
                        ),
                        const SizedBox(width: 12),
                        IconButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => LoginPage(),
                              ),
                            );
                          },
                          icon: Icon(
                            Icons.account_circle,
                            size: screenWidth * 0.10,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),

            // 📦 POSTS
            Expanded(
              child: isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : ListView.builder(
                      itemCount: posts.length,
                      itemBuilder: (context, index) {
                        final post = posts[index];

                        return Container(
                          margin: EdgeInsets.only(bottom: screenHight * 0.02),
                          padding: EdgeInsets.symmetric(
                            horizontal: screenWidth * 0.03,
                          ),
                          child: Material(
                            elevation: 6,
                            borderRadius: BorderRadius.circular(
                              screenWidth * 0.04,
                            ),
                            child: Container(
                              padding: EdgeInsets.all(screenWidth * 0.04),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  // 👤 Username
                                  Text(
                                    post["username"].toString(),
                                    style: TextStyle(
                                      fontSize: screenWidth * 0.045,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),

                                  const SizedBox(height: 5),

                                  // 🕒 Date
                                  Text(
                                    post["created_at"].toString(),
                                    style: const TextStyle(color: Colors.grey),
                                  ),

                                  SizedBox(height: screenHight * 0.015),

                                  // 📝 Description
                                  Text(post["description"].toString()),

                                  SizedBox(height: screenHight * 0.015),

                                  // 🖼️ Image
                                  if (post["image"] != null)
                                    ClipRRect(
                                      borderRadius: BorderRadius.circular(
                                        screenWidth * 0.03,
                                      ),
                                      child: Image.network(
                                        "$baseMediaUrl${post["image"]}",
                                        height: screenHight * 0.2,
                                        width: double.infinity,
                                        fit: BoxFit.cover,
                                      ),
                                    ),
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
