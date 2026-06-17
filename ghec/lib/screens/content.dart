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

  void openFullScreenImage(String imageUrl) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => FullScreenNetworkImage(imageUrl: imageUrl),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHight = MediaQuery.of(context).size.height;

    final bool isSmall = screenWidth < 380;
    final double horizontalPadding = screenWidth < 420 ? 16 : 22;
    final double maxContentWidth =
        screenWidth >= 760 ? 620 : double.infinity;
    final double headerHeight = screenHight < 650 ? 150 : 175;

    return Scaffold(
      backgroundColor: const Color(0xfff5f8f6),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(.10),
              blurRadius: 24,
              offset: const Offset(0, -8),
            ),
          ],
        ),
        child: BottomNavigationBar(
          currentIndex: currentIndex,
          backgroundColor: Colors.white,
          elevation: 0,
          type: BottomNavigationBarType.fixed,
          selectedItemColor: const Color(0xff047857),
          unselectedItemColor: Colors.grey.shade500,
          selectedLabelStyle: const TextStyle(fontWeight: FontWeight.w900),
          unselectedLabelStyle: const TextStyle(fontWeight: FontWeight.w700),
          showUnselectedLabels: true,
          onTap: (index) {
            setState(() {
              currentIndex = index;
            });
          },
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
      ),
      body: Stack(
        children: [
          Container(
            height: headerHeight,
            width: double.infinity,
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Color(0xff047857),
                  Color(0xff10b981),
                  Color(0xff34d399),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(36),
                bottomRight: Radius.circular(36),
              ),
            ),
          ),
          SafeArea(
            child: Center(
              child: ConstrainedBox(
                constraints: BoxConstraints(maxWidth: maxContentWidth),
                child: Column(
                  children: [
                    Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: horizontalPadding,
                        vertical: isSmall ? 14 : 20,
                      ),
                      child: _buildHeader(screenWidth, isSmall),
                    ),
                    Expanded(
                      child: isLoading
                          ? const Center(
                              child: CircularProgressIndicator(
                                color: Color(0xff047857),
                              ),
                            )
                          : RefreshIndicator(
                              color: const Color(0xff047857),
                              onRefresh: loadPosts,
                              child: ListView.builder(
                                physics: const BouncingScrollPhysics(
                                  parent: AlwaysScrollableScrollPhysics(),
                                ),
                                padding: EdgeInsets.symmetric(
                                  horizontal: horizontalPadding,
                                  vertical: isSmall ? 10 : 16,
                                ),
                                itemCount: posts.length,
                                itemBuilder: (context, index) {
                                  final post = posts[index];
                                  return _buildPostCard(
                                    post,
                                    screenWidth,
                                    screenHight,
                                    isSmall,
                                  );
                                },
                              ),
                            ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(double screenWidth, bool isSmall) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: isSmall ? 14 : 16,
        vertical: isSmall ? 12 : 14,
      ),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(.20),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color: Colors.white.withOpacity(.35),
          width: 1.2,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(.12),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(3),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(.18),
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: Colors.white.withOpacity(.35)),
            ),
            child: CircleAvatar(
              radius: isSmall ? 24 : 28,
              backgroundColor: Colors.white,
              backgroundImage: const AssetImage("assets/images/logo.jpg"),
            ),
          ),
          SizedBox(width: isSmall ? 10 : 14),
          Expanded(
            child: Text(
              "GHEC",
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: isSmall ? 22 : 26,
                fontWeight: FontWeight.w900,
                color: Colors.white,
              ),
            ),
          ),
          _buildHeaderButton(
            text: "Todo",
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => TodoScreen()),
              );
            },
            isSmall: isSmall,
          ),
          SizedBox(width: isSmall ? 8 : 10),
          Material(
            color: Colors.transparent,
            child: InkWell(
              borderRadius: BorderRadius.circular(16),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => LoginPage()),
                );
              },
              child: Ink(
                height: isSmall ? 42 : 46,
                width: isSmall ? 42 : 46,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(.20),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: Colors.white.withOpacity(.35),
                    width: 1.2,
                  ),
                ),
                child: const Icon(
                  Icons.account_circle,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeaderButton({
    required String text,
    required VoidCallback onTap,
    required bool isSmall,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: Ink(
          padding: EdgeInsets.symmetric(
            horizontal: isSmall ? 12 : 14,
            vertical: isSmall ? 11 : 13,
          ),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(.20),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: Colors.white.withOpacity(.35),
              width: 1.2,
            ),
          ),
          child: Text(
            text,
            style: TextStyle(
              color: Colors.white,
              fontSize: isSmall ? 13 : 14,
              fontWeight: FontWeight.w900,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPostCard(
    dynamic post,
    double screenWidth,
    double screenHight,
    bool isSmall,
  ) {
    final List images = post["images"] ?? [];

    return Container(
      margin: EdgeInsets.only(bottom: screenHight * 0.02),
      padding: EdgeInsets.all(isSmall ? 16 : 18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(.12),
            blurRadius: 35,
            offset: const Offset(0, 18),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                height: isSmall ? 44 : 48,
                width: isSmall ? 44 : 48,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [
                      Color(0xff047857),
                      Color(0xff10b981),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.green.withOpacity(.22),
                      blurRadius: 14,
                      offset: const Offset(0, 7),
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.person_rounded,
                  color: Colors.white,
                ),
              ),
              SizedBox(width: isSmall ? 12 : 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      post["username"].toString(),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: isSmall ? 17 : 19,
                        fontWeight: FontWeight.w900,
                        color: const Color(0xff111827),
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      post["created_at"].toString(),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: Colors.grey.shade600,
                        fontWeight: FontWeight.w600,
                        fontSize: isSmall ? 12 : 13,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: screenHight * 0.016),
          Text(
            post["description"].toString(),
            style: TextStyle(
              fontSize: isSmall ? 14 : 15,
              height: 1.45,
              fontWeight: FontWeight.w600,
              color: const Color(0xff111827),
            ),
          ),
          if (images.isNotEmpty) ...[
            SizedBox(height: screenHight * 0.016),
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: images.length,
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: screenWidth < 380 ? 2 : 3,
                crossAxisSpacing: 8,
                mainAxisSpacing: 8,
              ),
              itemBuilder: (context, index) {
                final imageUrl = images[index].toString();

                return GestureDetector(
                  onTap: () => openFullScreenImage(imageUrl),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(16),
                    child: Image.network(
                      imageUrl,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          color: const Color(0xfff5f8f6),
                          child: Icon(
                            Icons.broken_image,
                            color: Colors.grey.shade500,
                          ),
                        );
                      },
                    ),
                  ),
                );
              },
            ),
          ],
        ],
      ),
    );
  }
}

class FullScreenNetworkImage extends StatelessWidget {
  final String imageUrl;

  const FullScreenNetworkImage({super.key, required this.imageUrl});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(backgroundColor: Colors.black),
      body: Center(
        child: InteractiveViewer(
          minScale: 0.8,
          maxScale: 4,
          child: Image.network(
            imageUrl,
            fit: BoxFit.contain,
          ),
        ),
      ),
    );
  }
}