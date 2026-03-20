// import 'package:flutter/material.dart';
// import 'package:ghec/api/apiServices.dart';

// class AdminRequestsPage extends StatefulWidget {
//   final String teacherId; // admin/teacher id jo approve karega
//   const AdminRequestsPage({super.key, required this.teacherId});

//   @override
//   State<AdminRequestsPage> createState() => _AdminRequestsPageState();
// }

// class _AdminRequestsPageState extends State<AdminRequestsPage> {
//   List<dynamic> requests = [];
//   bool isLoading = true;

//   @override
//   void initState() {
//     super.initState();
//     fetchRequests();
//   }

//   Future<void> fetchRequests() async {
//     setState(() => isLoading = true);
//     final data = await ApiService.getAllRequests();
//     setState(() {
//       requests = data;
//       isLoading = false;
//     });
//   }

//   Future<void> handleRequest(int requestId, String action) async {
//     setState(() => isLoading = true);
//     final res = await ApiService.handleRequest(requestId, action);

//     if (res.containsKey("error")) {
//       ScaffoldMessenger.of(
//         context,
//       ).showSnackBar(SnackBar(content: Text(res["error"])));
//     } else {
//       ScaffoldMessenger.of(
//         context,
//       ).showSnackBar(SnackBar(content: Text("Request ${action}d")));
//       await fetchRequests();
//     }
//   }

//   Color getStatusColor(String status) {
//     switch (status) {
//       case 'pending':
//         return Colors.orange;
//       case 'approved':
//         return Colors.green;
//       case 'rejected':
//         return Colors.red;
//       default:
//         return Colors.grey;
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     final size = MediaQuery.of(context).size;

//     return Scaffold(
//       /// Gradient background similar to teacher dashboard
//       body: Container(
//         decoration: const BoxDecoration(
//           gradient: LinearGradient(
//             colors: [Color(0xff11998e), Color(0xff38ef7d)],
//             begin: Alignment.topLeft,
//             end: Alignment.bottomRight,
//           ),
//         ),
//         child: SafeArea(
//           child: Column(
//             children: [
//               /// AppBar replacement with gradient
//               Container(
//                 padding: EdgeInsets.symmetric(
//                   horizontal: size.width * 0.04,
//                   vertical: size.height * 0.02,
//                 ),
//                 width: double.infinity,
//                 decoration: const BoxDecoration(
//                   gradient: LinearGradient(
//                     colors: [Color(0xff11998e), Color(0xff0f9b0f)],
//                   ),
//                   borderRadius: BorderRadius.vertical(
//                     bottom: Radius.circular(18),
//                   ),
//                 ),
//                 child: Center(
//                   child: Text(
//                     "Profile Update Requests",
//                     style: TextStyle(
//                       color: Colors.white,
//                       fontSize: size.width * 0.05,
//                       fontWeight: FontWeight.bold,
//                     ),
//                   ),
//                 ),
//               ),

//               /// Body content
//               Expanded(
//                 child: Padding(
//                   padding: EdgeInsets.all(size.width * 0.03),
//                   child: isLoading
//                       ? Center(
//                           child: CircularProgressIndicator(
//                             color: Colors.white,
//                             strokeWidth: 3,
//                           ),
//                         )
//                       : requests.isEmpty
//                       ? Center(
//                           child: Text(
//                             "No requests available..!",
//                             style: TextStyle(
//                               color: Colors.white,
//                               fontSize: size.width * 0.045,
//                               fontWeight: FontWeight.bold,
//                             ),
//                           ),
//                         )
//                       : ListView.builder(
//                           itemCount: requests.length,
//                           itemBuilder: (context, index) {
//                             final req = requests[index];
//                             final status = req["status"] ?? "pending";
//                             final statusColor = getStatusColor(status);

//                             return Card(
//                               elevation: 6,
//                               shape: RoundedRectangleBorder(
//                                 borderRadius: BorderRadius.circular(18),
//                               ),
//                               margin: const EdgeInsets.symmetric(vertical: 8),
//                               child: Padding(
//                                 padding: const EdgeInsets.all(12),
//                                 child: Column(
//                                   crossAxisAlignment: CrossAxisAlignment.start,
//                                   children: [
//                                     /// Student name + roll no
//                                     Row(
//                                       mainAxisAlignment:
//                                           MainAxisAlignment.spaceBetween,
//                                       children: [
//                                         Expanded(
//                                           child: Text(
//                                             "${req['student']} (${req['roll_no']})",
//                                             style: TextStyle(
//                                               fontWeight: FontWeight.bold,
//                                               fontSize: size.width * 0.045,
//                                             ),
//                                             overflow: TextOverflow.ellipsis,
//                                           ),
//                                         ),
//                                         Container(
//                                           padding: const EdgeInsets.symmetric(
//                                             horizontal: 8,
//                                             vertical: 4,
//                                           ),
//                                           decoration: BoxDecoration(
//                                             color: statusColor.withOpacity(0.2),
//                                             borderRadius: BorderRadius.circular(
//                                               8,
//                                             ),
//                                           ),
//                                           child: Text(
//                                             status.toUpperCase(),
//                                             style: TextStyle(
//                                               color: statusColor,
//                                               fontWeight: FontWeight.bold,
//                                             ),
//                                           ),
//                                         ),
//                                       ],
//                                     ),
//                                     SizedBox(height: size.height * 0.015),

//                                     /// Field info
//                                     Text(
//                                       "Field: ${req['field']}",
//                                       style: TextStyle(
//                                         fontSize: size.width * 0.04,
//                                       ),
//                                     ),
//                                     Text(
//                                       "Old Value: ${req['old']}",
//                                       style: TextStyle(
//                                         fontSize: size.width * 0.04,
//                                       ),
//                                     ),
//                                     Text(
//                                       "New Value: ${req['new']}",
//                                       style: TextStyle(
//                                         fontSize: size.width * 0.04,
//                                       ),
//                                     ),
//                                     SizedBox(height: size.height * 0.02),

//                                     /// Buttons (Only pending requests)
//                                     if (status == 'pending')
//                                       Row(
//                                         mainAxisAlignment:
//                                             MainAxisAlignment.end,
//                                         children: [
//                                           Expanded(
//                                             child: Container(
//                                               height: size.height * 0.055,
//                                               decoration: BoxDecoration(
//                                                 borderRadius:
//                                                     BorderRadius.circular(12),
//                                                 gradient: const LinearGradient(
//                                                   colors: [
//                                                     Colors.greenAccent,
//                                                     Colors.green,
//                                                   ],
//                                                 ),
//                                               ),
//                                               child: Material(
//                                                 color: Colors.transparent,
//                                                 child: InkWell(
//                                                   borderRadius:
//                                                       BorderRadius.circular(12),
//                                                   onTap: () => handleRequest(
//                                                     req['id'],
//                                                     "approve",
//                                                   ),
//                                                   child: Center(
//                                                     child: Text(
//                                                       "Approve",
//                                                       style: TextStyle(
//                                                         color: Colors.white,
//                                                         fontWeight:
//                                                             FontWeight.bold,
//                                                         fontSize:
//                                                             size.width * 0.045,
//                                                       ),
//                                                     ),
//                                                   ),
//                                                 ),
//                                               ),
//                                             ),
//                                           ),
//                                           SizedBox(width: size.width * 0.03),
//                                           Expanded(
//                                             child: Container(
//                                               height: size.height * 0.055,
//                                               decoration: BoxDecoration(
//                                                 borderRadius:
//                                                     BorderRadius.circular(12),
//                                                 gradient: const LinearGradient(
//                                                   colors: [
//                                                     Colors.redAccent,
//                                                     Colors.red,
//                                                   ],
//                                                 ),
//                                               ),
//                                               child: Material(
//                                                 color: Colors.transparent,
//                                                 child: InkWell(
//                                                   borderRadius:
//                                                       BorderRadius.circular(12),
//                                                   onTap: () => handleRequest(
//                                                     req['id'],
//                                                     "reject",
//                                                   ),
//                                                   child: Center(
//                                                     child: Text(
//                                                       "Reject",
//                                                       style: TextStyle(
//                                                         color: Colors.white,
//                                                         fontWeight:
//                                                             FontWeight.bold,
//                                                         fontSize:
//                                                             size.width * 0.045,
//                                                       ),
//                                                     ),
//                                                   ),
//                                                 ),
//                                               ),
//                                             ),
//                                           ),
//                                         ],
//                                       ),
//                                   ],
//                                 ),
//                               ),
//                             );
//                           },
//                         ),
//                 ),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }
