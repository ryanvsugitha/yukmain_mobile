import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

class AdminBookingDetail extends StatefulWidget {
  const AdminBookingDetail({super.key, required this.bookingID});

  final String bookingID;

  @override
  State<AdminBookingDetail> createState() => _AdminBookingDetailState();
}

class _AdminBookingDetailState extends State<AdminBookingDetail> {

  late SharedPreferences pref;

  Future getBookingDetail() async {
    var url = Uri.parse('http://10.0.2.2/yuk_main/API/customer_get_booking_detail.php');
    var request = await http.post(url, body: {
      'booking_id': widget.bookingID,
    });
    return request.body;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Booking Detail'),
        centerTitle: true,
      ),
      body: FutureBuilder(
        future: getBookingDetail(), 
        builder: (context, snapshot) {
          if(snapshot.hasData){
            Map result = jsonDecode(snapshot.data) as Map;
            return ListView(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.all(16),
              children: [
                const Text(
                  'Booking Detail',
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
                Row(
                  children: [
                    const SizedBox(
                      width: 104,
                      child: Text('Booking No.')
                    ),
                    const SizedBox(
                      width: 16,
                      child: Text(':')
                    ),
                    Expanded(
                      child: Text(result['booking_id']),
                    )
                  ],
                ),
                Row(
                  children: [
                    const SizedBox(
                      width: 104,
                      child: Text('Venue')
                    ),
                    const SizedBox(
                      width: 16,
                      child: Text(':')
                    ),
                    Expanded(
                      child: Text(result['venue_name']),
                    )
                  ],
                ),
                Row(
                  children: [
                    const SizedBox(
                      width: 104,
                      child: Text('Court')
                    ),
                    const SizedBox(
                      width: 16,
                      child: Text(':')
                    ),
                    Expanded(
                      child: Text(result['court_name']),
                    )
                  ],
                ),
                Row(
                  children: [
                    const SizedBox(
                      width: 104,
                      child: Text('Date')
                    ),
                    const SizedBox(
                      width: 16,
                      child: Text(':')
                    ),
                    Expanded(
                      child: Text(result['formatted_date']),
                    )
                  ],
                ),
                Row(
                  children: [
                    const SizedBox(
                      width: 104,
                      child: Text('Time')
                    ),
                    const SizedBox(
                      width: 16,
                      child: Text(':')
                    ),
                    Expanded(
                      child: Text('${result['start_time']} - ${result['end_time']}'),
                    )
                  ],
                ),
                Row(
                  children: [
                    const SizedBox(
                      width: 104,
                      child: Text('Price')
                    ),
                    const SizedBox(
                      width: 16,
                      child: Text(':')
                    ),
                    Expanded(
                      child: Text('Rp ${result['formatted_price']}'),
                    )
                  ],
                ),
                Row(
                  children: [
                    const SizedBox(
                      width: 104,
                      child: Text('Payment Status')
                    ),
                    const SizedBox(
                      width: 16,
                      child: Text(':')
                    ),
                    Container(
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: (result['payment_status']) == '0'
                        ? Colors.red.shade300
                        : Colors.green.shade300,
                        borderRadius: BorderRadius.circular(5.0)
                      ),
                      child: Text(
                        (result['payment_status']) == '0'
                        ? 'Not Paid'
                        : 'Paid'
                      ),
                    )
                  ],
                ),
                Row(
                  children: [
                    const SizedBox(
                      width: 104,
                      child: Text('Payment Type')
                    ),
                    const SizedBox(
                      width: 16,
                      child: Text(':')
                    ),
                    Expanded(
                      child: Text(result['payment_type_name']),
                    )
                  ],
                ),
                const SizedBox(height: 16),
                const Text(
                  'Rating & Review',
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
                result['rating'] == null
                ? const Text('Rating not yet Submitted')
                : Column(
                  children: [
                    Center(
                      child: RatingBarIndicator(
                        rating: double.parse(result['rating']),
                        itemBuilder: (context, index) {
                          return const Icon(
                            Icons.star_rate_rounded,
                            color: Colors.amber,
                          );
                        },
                      ),
                    ),
                    const SizedBox(height: 8),
                    TextFormField(
                      readOnly: true,
                      decoration: const InputDecoration(
                        labelText: 'Review'
                      ),
                      initialValue: result['review'],
                    ),
                    const SizedBox(height: 8),
                    Text('Rating submitted ${result['rating_submit_date']}')
                  ],
                )
              ],
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
    );
  }
}