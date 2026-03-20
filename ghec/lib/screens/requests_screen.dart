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
    await ApiService.handleRequest(id, action);
    fetchRequests(); // refresh list
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xff11998e), Color(0xff38ef7d)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              /// Header with Back button
              Container(
                width: double.infinity,
                padding: EdgeInsets.symmetric(
                  vertical: size.height * 0.02,
                  horizontal: size.width * 0.04,
                ),
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Color(0xff11998e), Color(0xff0f9b0f)],
                  ),
                  borderRadius: BorderRadius.vertical(
                    bottom: Radius.circular(18),
                  ),
                ),
                child: Row(
                  children: [
                    /// Back button
                    InkWell(
                      borderRadius: BorderRadius.circular(30),
                      onTap: () => Navigator.pop(context),
                      child: const Padding(
                        padding: EdgeInsets.all(8.0),
                        child: Icon(
                          Icons.arrow_back,
                          color: Colors.white,
                          size: 28,
                        ),
                      ),
                    ),
                    SizedBox(width: size.width * 0.02),

                    /// Title
                    Expanded(
                      child: Center(
                        child: Text(
                          "Requests",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: size.width * 0.05,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),

                    /// Empty space to balance row
                    SizedBox(width: size.width * 0.1),
                  ],
                ),
              ),

              /// Body
              Expanded(
                child: Padding(
                  padding: EdgeInsets.all(size.width * 0.03),
                  child: isLoading
                      ? Center(
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 3,
                          ),
                        )
                      : requests.isEmpty
                      ? Center(
                          child: Text(
                            "No Requests Found..!",
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: size.width * 0.045,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        )
                      : ListView.builder(
                          itemCount: requests.length,
                          itemBuilder: (context, index) {
                            final req = requests[index];

                            return Card(
                              elevation: 6,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(18),
                              ),
                              margin: const EdgeInsets.symmetric(
                                vertical: 8,
                                horizontal: 4,
                              ),
                              child: Padding(
                                padding: const EdgeInsets.all(12),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      "Roll No: ${req['roll_no']}",
                                      style: TextStyle(
                                        fontSize: size.width * 0.042,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    Text(
                                      "Field: ${req['field_name']}",
                                      style: TextStyle(
                                        fontSize: size.width * 0.04,
                                      ),
                                    ),
                                    Text(
                                      "New Value: ${req['new_value']}",
                                      style: TextStyle(
                                        fontSize: size.width * 0.04,
                                      ),
                                    ),
                                    SizedBox(height: size.height * 0.015),

                                    /// Buttons
                                    Row(
                                      children: [
                                        Expanded(
                                          child: Container(
                                            height: size.height * 0.055,
                                            decoration: BoxDecoration(
                                              borderRadius:
                                                  BorderRadius.circular(12),
                                              gradient: const LinearGradient(
                                                colors: [
                                                  Colors.greenAccent,
                                                  Colors.green,
                                                ],
                                              ),
                                            ),
                                            child: Material(
                                              color: Colors.transparent,
                                              child: InkWell(
                                                borderRadius:
                                                    BorderRadius.circular(12),
                                                onTap: () => handle(
                                                  req['id'],
                                                  "approve",
                                                ),
                                                child: Center(
                                                  child: Text(
                                                    "Approve",
                                                    style: TextStyle(
                                                      color: Colors.white,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      fontSize:
                                                          size.width * 0.045,
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ),
                                        ),
                                        SizedBox(width: size.width * 0.03),
                                        Expanded(
                                          child: Container(
                                            height: size.height * 0.055,
                                            decoration: BoxDecoration(
                                              borderRadius:
                                                  BorderRadius.circular(12),
                                              gradient: const LinearGradient(
                                                colors: [
                                                  Colors.redAccent,
                                                  Colors.red,
                                                ],
                                              ),
                                            ),
                                            child: Material(
                                              color: Colors.transparent,
                                              child: InkWell(
                                                borderRadius:
                                                    BorderRadius.circular(12),
                                                onTap: () =>
                                                    handle(req['id'], "reject"),
                                                child: Center(
                                                  child: Text(
                                                    "Reject",
                                                    style: TextStyle(
                                                      color: Colors.white,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      fontSize:
                                                          size.width * 0.045,
                                                    ),
                                                  ),
                                                ),
                                              ),
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
            ],
          ),
        ),
      ),
    );
  }
}
