import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'package:yuk_main/admin/admin_booking_detail.dart';

class AdminHome extends StatefulWidget {
  const AdminHome({super.key});

  @override
  State<AdminHome> createState() => _AdminHomeState();
}

class _AdminHomeState extends State<AdminHome> {

  late SharedPreferences pref;

  late Future futureGetRevenue;
  Future getMonthlyRevenue() async {
    pref = await SharedPreferences.getInstance();
    var url = Uri.parse('http://10.0.2.2/yuk_main/API/admin_get_monthly_revenue.php');
    var request = await http.post(url, body: {
      'username': pref.getString('username'),
    });
    return request.body;
  }

  late Future futureGetRecentBooking;
  Future getRecentBooking() async {
    pref = await SharedPreferences.getInstance();
    var url = Uri.parse('http://10.0.2.2/yuk_main/API/admin_get_recent_booking.php');
    var request = await http.post(url, body: {
      'username': pref.getString('username'),
    });
    return request.body;
  }

  @override
  void initState() {
    super.initState();
    futureGetRevenue = getMonthlyRevenue();
    futureGetRecentBooking = getRecentBooking();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Welcome Back...'),
        centerTitle: true,
      ),
      body: ListView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.all(16),
        children: [
          const Text(
            'This Month Revenue',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 24
            ),
          ),
          const Divider(
            color: Color(0xff1CC500),
            thickness: 2,
            height: 8,
          ),
          FutureBuilder(
            future: futureGetRevenue, 
            builder: (context, snapshot) {
              if(snapshot.hasData){
                Map result = jsonDecode(snapshot.data) as Map;
                return Text(
                  result['formatted_revenue'] == null
                  ? 'Rp -'
                  : 'Rp ${result['formatted_revenue']}',
                  style: const TextStyle(
                    fontSize: 20
                  ),
                );
              } else {
                return const Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      CircularProgressIndicator(),
                      SizedBox(
                        height: 10.0,
                      ),
                      Text('Loading data...'),
                    ],
                  ),
                );
              }
            },
          ),
          const SizedBox(height: 16),
          const Text(
            'Latest Booking',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 24
            ),
          ),
          const Divider(
            color: Color(0xff1CC500),
            thickness: 2,
            height: 8,
          ),
          FutureBuilder(
            future: futureGetRecentBooking, 
            builder: (context, snapshot) {
              if(snapshot.hasData){
                List result = jsonDecode(snapshot.data) as List;
                if(result.isNotEmpty){
                  return ListView.separated(
                    physics: const BouncingScrollPhysics(),
                    shrinkWrap: true,
                    itemCount: result.length,
                    separatorBuilder: (context, index) {
                      return const SizedBox(height: 8);
                    },
                    itemBuilder: (context, index) {
                      return InkWell(
                        borderRadius: BorderRadius.circular(5.0),
                        onTap: () {
                          Navigator.push(
                            context, 
                            MaterialPageRoute(builder: (context) => AdminBookingDetail(bookingID: result[index]['booking_id']),)
                          );
                        },
                        child: Container(
                          padding: const EdgeInsets.all(8.0),
                          decoration: BoxDecoration(
                            border: Border.all(),
                            borderRadius: BorderRadius.circular(5.0)
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text('Booking No. ${result[index]['booking_id']}'),
                                  Container(
                                    padding: const EdgeInsets.all(4),
                                    decoration: BoxDecoration(
                                      color: (result[index]['payment_status']) == '0'
                                      ? Colors.red.shade300
                                      : Colors.green.shade300,
                                      borderRadius: BorderRadius.circular(5.0)
                                    ),
                                    child: Text(
                                      (result[index]['payment_status']) == '0'
                                      ? 'Not Paid'
                                      : 'Paid'
                                    ),
                                  )
                                ],
                              ),
                              const Divider(
                                color: Color(0xff1CC500),
                                thickness: 1,
                                height: 8,
                              ),
                              Text(result[index]['venue_name']),
                              Text(result[index]['court_name']),
                              Text('${result[index]['formatted_date']}, ${result[index]['start_time']} - ${result[index]['end_time']}'),
                              Text('Rp ${result[index]['formatted_price']}'),
                            ],
                          )
                        ),
                      );
                    },
                  );
                } else {
                  return Center(
                    child: Column(
                      children: [
                        Image.asset(
                          'assets/nodata.png',
                          height: MediaQuery.sizeOf(context).width * 0.2,
                          width: MediaQuery.sizeOf(context).width * 0.2,
                        ),
                        const SizedBox(height: 8,),
                        const Text(
                          'No Data',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 20
                          ),
                        )
                      ],
                    ),
                  );
                }
              } else {
                return const Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      CircularProgressIndicator(),
                      SizedBox(
                        height: 10.0,
                      ),
                      Text('Loading data...'),
                    ],
                  ),
                );
              }
            },
          )
        ],
      )
    );
  }
}