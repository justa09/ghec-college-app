import 'dart:io';
import 'package:flutter/material.dart';
import 'package:ghec/api/post_service.dart';
import 'package:image_picker/image_picker.dart';
class MakePost extends StatefulWidget {
  final String Tid;
  final String Tname;
  final String image;

  const MakePost({
    super.key,
    required this.Tid,
    required this.Tname,
    required this.image,
  });

  @override
  State<MakePost> createState() => _MakePostState();
}

class _MakePostState extends State<MakePost> {
  final TextEditingController description = TextEditingController();
  final ImagePicker _picker = ImagePicker();

  final List<XFile> _images = [];
  bool isLoading = false;

  Future<void> pickFromCamera() async {
    final XFile? img = await _picker.pickImage(source: ImageSource.camera);

    if (img != null) {
      setState(() {
        _images.add(img);
      });
    }
  }

  Future<void> pickFromGallery() async {
    final List<XFile> imgs = await _picker.pickMultiImage();

    if (imgs.isNotEmpty) {
      setState(() {
        _images.addAll(imgs);
      });
    }
  }

  void showPickerOptions() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (_) {
        return Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(26)),
          ),
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(14, 12, 14, 18),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 42,
                    height: 5,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade300,
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                  const SizedBox(height: 12),
                  ListTile(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    leading: Container(
                      height: 42,
                      width: 42,
                      decoration: BoxDecoration(
                        color: Colors.green.shade50,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        Icons.camera_alt,
                        color: Colors.green.shade700,
                      ),
                    ),
                    title: const Text(
                      "Camera",
                      style: TextStyle(fontWeight: FontWeight.w700),
                    ),
                    onTap: () {
                      Navigator.pop(context);
                      pickFromCamera();
                    },
                  ),
                  ListTile(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    leading: Container(
                      height: 42,
                      width: 42,
                      decoration: BoxDecoration(
                        color: Colors.green.shade50,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        Icons.photo,
                        color: Colors.green.shade700,
                      ),
                    ),
                    title: const Text(
                      "Gallery",
                      style: TextStyle(fontWeight: FontWeight.w700),
                    ),
                    onTap: () {
                      Navigator.pop(context);
                      pickFromGallery();
                    },
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  void removeImage(int index) {
    setState(() {
      _images.removeAt(index);
    });
  }

  void openFullScreen(XFile img) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => FullScreenImage(imagePath: img.path)),
    );
  }

  Future<void> submitPost() async {
    if (description.text.trim().isEmpty && _images.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text("Description"),
          behavior: SnackBarBehavior.floating,
          backgroundColor: const Color(0xff111827),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
        ),
      );
      return;
    }

    try {
      setState(() {
        isLoading = true;
      });

      await PostService.createPost(
        teacherId: widget.Tid,
        description: description.text.trim(),
        images: _images,
      );

      description.clear();

      setState(() {
        _images.clear();
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text("Post created successfully"),
          behavior: SnackBarBehavior.floating,
          backgroundColor: const Color(0xff059669),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.toString()),
          behavior: SnackBarBehavior.floating,
          backgroundColor: const Color(0xff111827),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
        ),
      );
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final width = size.width;

    final bool isSmall = width < 380;
    final double horizontalPadding = width < 420 ? 16 : 22;
    final double maxContentWidth = width >= 760 ? 620 : double.infinity;

    return Scaffold(
      resizeToAvoidBottomInset: true,
      backgroundColor: const Color(0xfff5f8f6),
      body: Stack(
        children: [
          Container(
            height: size.height < 650 ? 220 : 260,
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
                bottomLeft: Radius.circular(34),
                bottomRight: Radius.circular(34),
              ),
            ),
          ),
          SafeArea(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: Center(
                child: ConstrainedBox(
                  constraints: BoxConstraints(maxWidth: maxContentWidth),
                  child: Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: horizontalPadding,
                      vertical: 18,
                    ),
                    child: Column(
                      children: [
                        Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: width < 420 ? 14 : 18,
                            vertical: width < 420 ? 14 : 16,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(.18),
                            borderRadius: BorderRadius.circular(22),
                            border: Border.all(
                              color: Colors.white.withOpacity(.30),
                              width: 1.1,
                            ),
                          ),
                          child: Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(3),
                                decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(.18),
                                  borderRadius: BorderRadius.circular(18),
                                  border: Border.all(
                                    color: Colors.white.withOpacity(.35),
                                  ),
                                ),
                                child: CircleAvatar(
                                  radius: isSmall ? 25 : 30,
                                  backgroundColor: Colors.white,
                                  backgroundImage: widget.image.isNotEmpty
                                      ? NetworkImage(widget.image)
                                      : null,
                                  child: widget.image.isEmpty
                                      ? Icon(
                                          Icons.person,
                                          color: Colors.green.shade700,
                                          size: isSmall ? 26 : 30,
                                        )
                                      : null,
                                ),
                              ),
                              SizedBox(width: isSmall ? 10 : 14),
                              Expanded(
                                child: Text(
                                  widget.Tname,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    fontSize: isSmall ? 18 : 21,
                                    fontWeight: FontWeight.w900,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 22),
                        Container(
                          width: double.infinity,
                          padding: EdgeInsets.all(width < 420 ? 18 : 22),
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
                            children: [
                              TextField(
                                controller: description,
                                minLines: 4,
                                maxLines: 7,
                                cursorColor: Colors.green.shade700,
                                style: const TextStyle(
                                  color: Color(0xff111827),
                                  fontWeight: FontWeight.w500,
                                ),
                                decoration: InputDecoration(
                                  labelText: "Post Description",
                                  hintText: "Description",
                                  alignLabelWithHint: true,
                                  prefixIcon: Padding(
                                    padding: const EdgeInsets.only(bottom: 70),
                                    child: Icon(
                                      Icons.description,
                                      color: Colors.green.shade700,
                                    ),
                                  ),
                                  filled: true,
                                  fillColor: const Color(0xfff7fbf8),
                                  labelStyle: TextStyle(
                                    color: Colors.grey.shade700,
                                    fontWeight: FontWeight.w500,
                                  ),
                                  hintStyle: TextStyle(
                                    color: Colors.grey.shade500,
                                    fontWeight: FontWeight.w500,
                                  ),
                                  enabledBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(18),
                                    borderSide: BorderSide(
                                      color: Colors.grey.shade200,
                                      width: 1.2,
                                    ),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(18),
                                    borderSide: BorderSide(
                                      color: Colors.green.shade600,
                                      width: 1.8,
                                    ),
                                  ),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(18),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 20),
                              SizedBox(
                                width: double.infinity,
                                height: isSmall ? 50 : 54,
                                child: Container(
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(16),
                                    gradient: const LinearGradient(
                                      colors: [
                                        Color(0xff047857),
                                        Color(0xff10b981),
                                      ],
                                      begin: Alignment.topLeft,
                                      end: Alignment.bottomRight,
                                    ),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.green.withOpacity(.25),
                                        blurRadius: 18,
                                        offset: const Offset(0, 8),
                                      ),
                                    ],
                                  ),
                                  child: ElevatedButton.icon(
                                    onPressed:
                                        isLoading ? null : showPickerOptions,
                                    style: ElevatedButton.styleFrom(
                                      elevation: 0,
                                      backgroundColor: Colors.transparent,
                                      shadowColor: Colors.transparent,
                                      foregroundColor: Colors.white,
                                      disabledBackgroundColor:
                                          Colors.transparent,
                                      disabledForegroundColor: Colors.white,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(16),
                                      ),
                                    ),
                                    icon: const Icon(Icons.add_a_photo),
                                    label: const Text(
                                      "Add Images",
                                      style: TextStyle(
                                        fontWeight: FontWeight.w800,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 20),
                              _images.isEmpty
                                  ? Text(
                                      "No Images Selected",
                                      style: TextStyle(
                                        color: Colors.grey.shade700,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    )
                                  : GridView.builder(
                                      shrinkWrap: true,
                                      physics:
                                          const NeverScrollableScrollPhysics(),
                                      itemCount: _images.length,
                                      gridDelegate:
                                          SliverGridDelegateWithFixedCrossAxisCount(
                                        crossAxisCount: width < 380 ? 2 : 3,
                                        crossAxisSpacing: 8,
                                        mainAxisSpacing: 8,
                                      ),
                                      itemBuilder: (context, index) {
                                        return ClipRRect(
                                          borderRadius:
                                              BorderRadius.circular(16),
                                          child: Stack(
                                            fit: StackFit.expand,
                                            children: [
                                              GestureDetector(
                                                onTap: () => openFullScreen(
                                                  _images[index],
                                                ),
                                                child: Image.file(
                                                  File(_images[index].path),
                                                  fit: BoxFit.cover,
                                                ),
                                              ),
                                              Positioned(
                                                top: 6,
                                                right: 6,
                                                child: GestureDetector(
                                                  onTap: isLoading
                                                      ? null
                                                      : () =>
                                                          removeImage(index),
                                                  child: Container(
                                                    padding:
                                                        const EdgeInsets.all(4),
                                                    decoration:
                                                        const BoxDecoration(
                                                      color: Colors.black54,
                                                      shape: BoxShape.circle,
                                                    ),
                                                    child: const Icon(
                                                      Icons.close,
                                                      color: Colors.white,
                                                      size: 18,
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        );
                                      },
                                    ),
                              const SizedBox(height: 24),
                              SizedBox(
                                width: double.infinity,
                                height: isSmall ? 52 : 56,
                                child: ElevatedButton(
                                  onPressed: isLoading ? null : submitPost,
                                  style: ElevatedButton.styleFrom(
                                    elevation: 0,
                                    backgroundColor: const Color(0xff059669),
                                    foregroundColor: Colors.white,
                                    disabledBackgroundColor:
                                        const Color(0xff059669),
                                    disabledForegroundColor: Colors.white,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(16),
                                    ),
                                  ),
                                  child: isLoading
                                      ? const SizedBox(
                                          height: 22,
                                          width: 22,
                                          child: CircularProgressIndicator(
                                            strokeWidth: 2.4,
                                            color: Colors.white,
                                          ),
                                        )
                                      : const Text(
                                          "Submit",
                                          style: TextStyle(
                                            fontSize: 18,
                                            fontWeight: FontWeight.w900,
                                            letterSpacing: .3,
                                          ),
                                        ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class FullScreenImage extends StatelessWidget {
  final String imagePath;

  const FullScreenImage({super.key, required this.imagePath});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(backgroundColor: Colors.black),
      body: Center(child: Image.file(File(imagePath))),
    );
  }
}