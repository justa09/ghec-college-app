import 'dart:io';
import 'package:flutter/material.dart';
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

  List<XFile> _images = [];

  /// 📸 Camera
  Future<void> pickFromCamera() async {
    final XFile? img = await _picker.pickImage(source: ImageSource.camera);

    if (img != null) {
      setState(() {
        _images.add(img);
      });
    }
  }

  /// 🖼️ Gallery
  Future<void> pickFromGallery() async {
    final List<XFile>? imgs = await _picker.pickMultiImage();

    if (imgs != null && imgs.isNotEmpty) {
      setState(() {
        _images.addAll(imgs);
      });
    }
  }

  /// 🔥 One button → choose option
  void showPickerOptions() {
    showModalBottomSheet(
      context: context,
      builder: (_) {
        return SafeArea(
          child: Wrap(
            children: [
              ListTile(
                leading: const Icon(Icons.camera_alt),
                title: const Text("Camera"),
                onTap: () {
                  Navigator.pop(context);
                  pickFromCamera();
                },
              ),
              ListTile(
                leading: const Icon(Icons.photo),
                title: const Text("Gallery"),
                onTap: () {
                  Navigator.pop(context);
                  pickFromGallery();
                },
              ),
            ],
          ),
        );
      },
    );
  }

  /// ❌ Remove
  void removeImage(int index) {
    setState(() {
      _images.removeAt(index);
    });
  }

  /// 🔍 Full screen
  void openFullScreen(XFile img) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => FullScreenImage(imagePath: img.path)),
    );
  }

  /// 🚀 Submit
  void submitPost() {
    print("Desc: ${description.text}");
    print("Images: ${_images.length}");
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      resizeToAvoidBottomInset: true,
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
            /// HEADER
            SafeArea(
              child: Padding(
                padding: EdgeInsets.all(size.width * 0.03),
                child: Material(
                  elevation: 10,
                  borderRadius: BorderRadius.circular(18),
                  child: Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: size.width * 0.04,
                      vertical: size.height * 0.02,
                    ),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xff11998e), Color(0xff0f9b0f)],
                      ),
                      borderRadius: BorderRadius.circular(18),
                    ),
                    child: Row(
                      children: [
                        CircleAvatar(
                          radius: size.width * 0.06,
                          backgroundImage: widget.image.isNotEmpty
                              ? NetworkImage(widget.image)
                              : null,
                          child: widget.image.isEmpty
                              ? const Icon(Icons.person, color: Colors.white)
                              : null,
                        ),
                        SizedBox(width: size.width * 0.03),
                        Expanded(
                          child: Text(
                            widget.Tname,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: size.width * 0.045,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),

            /// BODY
            Expanded(
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: size.width * 0.05),
                child: Material(
                  elevation: 12,
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(30),
                  ),
                  child: Container(
                    padding: EdgeInsets.only(
                      top: size.height * 0.03,
                      bottom: MediaQuery.of(context).viewInsets.bottom + 20,
                    ),
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.vertical(
                        top: Radius.circular(30),
                      ),
                    ),
                    child: SingleChildScrollView(
                      child: Column(
                        children: [
                          /// Description
                          Padding(
                            padding: EdgeInsets.symmetric(
                              horizontal: size.width * 0.05,
                            ),
                            child: TextField(
                              controller: description,
                              decoration: InputDecoration(
                                labelText: "Post Description",
                                hintText: "Description",
                                prefixIcon: const Icon(Icons.description),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(20),
                                ),
                              ),
                            ),
                          ),

                          SizedBox(height: size.height * 0.02),

                          /// 🔥 ONE BUTTON
                          ElevatedButton.icon(
                            onPressed: showPickerOptions,
                            icon: const Icon(Icons.add_a_photo),
                            label: const Text("Add Images"),
                          ),

                          SizedBox(height: size.height * 0.02),

                          /// Preview
                          _images.isEmpty
                              ? const Text("No Images Selected")
                              : GridView.builder(
                                  shrinkWrap: true,
                                  physics: const NeverScrollableScrollPhysics(),
                                  itemCount: _images.length,
                                  gridDelegate:
                                      const SliverGridDelegateWithFixedCrossAxisCount(
                                        crossAxisCount: 3,
                                        crossAxisSpacing: 5,
                                        mainAxisSpacing: 5,
                                      ),
                                  itemBuilder: (context, index) {
                                    return Stack(
                                      children: [
                                        GestureDetector(
                                          onTap: () =>
                                              openFullScreen(_images[index]),
                                          child: Positioned.fill(
                                            child: Image.file(
                                              File(_images[index].path),
                                              fit: BoxFit.cover,
                                            ),
                                          ),
                                        ),
                                        Positioned(
                                          top: 4,
                                          right: 4,
                                          child: GestureDetector(
                                            onTap: () => removeImage(index),
                                            child: Container(
                                              decoration: const BoxDecoration(
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
                                    );
                                  },
                                ),

                          SizedBox(height: size.height * 0.03),

                          /// Submit
                          Padding(
                            padding: EdgeInsets.symmetric(
                              horizontal: size.width * 0.05,
                            ),
                            child: ElevatedButton(
                              onPressed: submitPost,
                              style: ElevatedButton.styleFrom(
                                minimumSize: const Size(double.infinity, 50),
                              ),
                              child: const Text("Submit"),
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
