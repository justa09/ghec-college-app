import 'package:flutter/material.dart';
import 'package:ghec/api/apiServices.dart';

class RequestsScreen extends StatefulWidget {
  const RequestsScreen({super.key});

  @override
  State<RequestsScreen> createState() => _RequestsScreenState();
}

class _RequestsScreenState extends State<RequestsScreen> {
  List requests = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchRequests();
  }

  Future<void> fetchRequests() async {
    final data = await ApiService.getAllRequests();

    setState(() {
      requests = data;
      isLoading = false;
    });
  }

  Future<void> handle(int id, String action) async {
    await ApiService.handleRequest(id, action, );
    fetchRequests();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final width = size.width;

    final isSmall = width < 380;
    final horizontalPadding = width < 420 ? 14.0 : 20.0;
    final maxContentWidth = width >= 720 ? 640.0 : double.infinity;

    return Scaffold(
      backgroundColor: const Color(0xfff5f8f6),
      body: Stack(
        children: [
          Container(
            height: 230,
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
            child: Column(
              children: [
                Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: horizontalPadding,
                    vertical: isSmall ? 14 : 18,
                  ),
                  child: Row(
                    children: [
                      Material(
                        color: Colors.transparent,
                        child: InkWell(
                          borderRadius: BorderRadius.circular(16),
                          onTap: () => Navigator.pop(context),
                          child: Ink(
                            height: isSmall ? 42 : 46,
                            width: isSmall ? 42 : 46,
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(.18),
                              borderRadius: BorderRadius.circular(16),
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
                            child: const Icon(
                              Icons.arrow_back,
                              color: Colors.white,
                              size: 26,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      const Expanded(
                        child: Text(
                          "Requests",
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 28,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                      ),
                      SizedBox(width: isSmall ? 42 : 46),
                    ],
                  ),
                ),
                Expanded(
                  child: Center(
                    child: ConstrainedBox(
                      constraints: BoxConstraints(maxWidth: maxContentWidth),
                      child: Padding(
                        padding: EdgeInsets.fromLTRB(
                          horizontalPadding,
                          8,
                          horizontalPadding,
                          18,
                        ),
                        child: Container(
                          width: double.infinity,
                          padding: EdgeInsets.all(isSmall ? 14 : 18),
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
                          child: isLoading
                              ? Center(
                                  child: CircularProgressIndicator(
                                    color: Colors.green.shade700,
                                    strokeWidth: 3,
                                  ),
                                )
                              : requests.isEmpty
                                  ? Center(
                                      child: Text(
                                        "No Requests Found..!",
                                        style: TextStyle(
                                          color: const Color(0xff111827),
                                          fontSize: isSmall ? 16 : 18,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    )
                                  : ListView.builder(
                                      physics: const BouncingScrollPhysics(),
                                      itemCount: requests.length,
                                      itemBuilder: (context, index) {
                                        final req = requests[index];

                                        return Container(
                                          margin: EdgeInsets.only(
                                            bottom: isSmall ? 12 : 14,
                                          ),
                                          decoration: BoxDecoration(
                                            color: const Color(0xfff7fbf8),
                                            borderRadius:
                                                BorderRadius.circular(22),
                                            border: Border.all(
                                              color:
                                                  Colors.green.withOpacity(.12),
                                              width: 1.2,
                                            ),
                                            boxShadow: [
                                              BoxShadow(
                                                color: Colors.green
                                                    .withOpacity(.08),
                                                blurRadius: 18,
                                                offset: const Offset(0, 8),
                                              ),
                                            ],
                                          ),
                                          child: Padding(
                                            padding: EdgeInsets.all(
                                              isSmall ? 12 : 14,
                                            ),
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                _infoText(
                                                  "Roll No: ${req['roll_no']}",
                                                  isSmall,
                                                  true,
                                                ),
                                                const SizedBox(height: 6),
                                                _infoText(
                                                  "Field: ${req['field_name']}",
                                                  isSmall,
                                                  false,
                                                ),
                                                const SizedBox(height: 5),
                                                _infoText(
                                                  "New Value: ${req['new_value']}",
                                                  isSmall,
                                                  false,
                                                ),
                                                SizedBox(
                                                  height: isSmall ? 14 : 16,
                                                ),
                                                Row(
                                                  children: [
                                                    Expanded(
                                                      child: _actionButton(
                                                        isSmall: isSmall,
                                                        text: "Approve",
                                                        colors: const [
                                                          Color(0xff047857),
                                                          Color(0xff10b981),
                                                          Color(0xff34d399),
                                                        ],
                                                        onTap: () => handle(
                                                          req['id'],
                                                          "approve",
                                                        ),
                                                      ),
                                                    ),
                                                    const SizedBox(width: 12),
                                                    Expanded(
                                                      child: _actionButton(
                                                        isSmall: isSmall,
                                                        text: "Reject",
                                                        colors: const [
                                                          Color(0xffb91c1c),
                                                          Color(0xffef4444),
                                                        ],
                                                        onTap: () => handle(
                                                          req['id'],
                                                          "reject",
                                                        ),
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ],
                                            ),
                                          ),
                                        );
                                      },
                                    ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _infoText(String text, bool isSmall, bool isTitle) {
    return Text(
      text,
      maxLines: isTitle ? 1 : 2,
      overflow: TextOverflow.ellipsis,
      style: TextStyle(
        fontSize: isTitle
            ? isSmall
                ? 15
                : 16
            : isSmall
                ? 13.5
                : 14.5,
        fontWeight: isTitle ? FontWeight.w900 : FontWeight.w600,
        color: isTitle ? const Color(0xff111827) : const Color(0xff4b5563),
        height: 1.3,
      ),
    );
  }

  Widget _actionButton({
    required bool isSmall,
    required String text,
    required List<Color> colors,
    required VoidCallback onTap,
  }) {
    return Container(
      height: isSmall ? 46 : 50,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(15),
        gradient: LinearGradient(
          colors: colors,
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(
            color: colors.first.withOpacity(.28),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(15),
          splashColor: Colors.white.withOpacity(.16),
          highlightColor: Colors.white.withOpacity(.10),
          onTap: onTap,
          child: Center(
            child: Text(
              text,
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w900,
                fontSize: isSmall ? 15 : 16,
              ),
            ),
          ),
        ),
      ),
    );
  }
}