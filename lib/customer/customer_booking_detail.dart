import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

class CustomerBookingDetail extends StatefulWidget {
  const CustomerBookingDetail({super.key, required this.bookingID});

  final String bookingID;

  @override
  State<CustomerBookingDetail> createState() => _CustomerBookingDetailState();
}

class _CustomerBookingDetailState extends State<CustomerBookingDetail> {

  late SharedPreferences pref;
  int rating = 0;

  TextEditingController review = TextEditingController();

  Future getBookingDetail() async {
    var url = Uri.parse('http://10.0.2.2/yuk_main/API/customer_get_booking_detail.php');
    var request = await http.post(url, body: {
      'booking_id': widget.bookingID,
    });
    return request.body;
  }

  Future submitRatingReview() async {
    var url = Uri.parse('http://10.0.2.2/yuk_main/API/customer_create_rating_review.php');
    var request = await http.post(url, body: {
      'booking_id': widget.bookingID,
      'rating': rating.toString(),
      'review': review.text,
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
                ? Column(
                  children: [
                    Center(
                      child: RatingBar.builder(
                        glow: false,
                        minRating: 1,
                        allowHalfRating: false,
                        itemCount: 5,
                        itemBuilder: (context, index) {
                          return const Icon(
                            Icons.star_rounded,
                            color: Colors.amber,  
                          );
                        }, 
                        onRatingUpdate: (value) {
                          setState(() {
                            rating = value.toInt();
                          });
                        },
                      ),
                    ),
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: review,
                      decoration: const InputDecoration(
                        labelText: 'Review'
                      ),
                    ),
                    const SizedBox(height: 8),
                    Center(
                      child: ElevatedButton(
                        onPressed: () {
                          if(review.text == '' || rating == 0){
                            showDialog(
                              context: context, 
                              builder: (context) {
                                return AlertDialog(
                                  title: const Text('Please fill all fields!'),
                                  actions: [
                                    TextButton(
                                      onPressed: (){
                                        Navigator.pop(context);
                                      }, 
                                      child: const Text('OK')
                                    )
                                  ],
                                );
                              },
                            );
                          } else {
                            submitRatingReview().then((value) {
                              Map result = jsonDecode(value) as Map;
                              showDialog(
                                context: context, 
                                builder: (context) {
                                  return AlertDialog(
                                    title: Text(result['message']),
                                    actions: [
                                      TextButton(
                                        onPressed: () {
                                          if(result['status'] == '1'){
                                            Navigator.pop(context);
                                            setState(() {});
                                          } else {
                                            Navigator.pop(context);
                                          }
                                        }, 
                                        child: const Text('OK')
                                      )
                                    ],
                                  );
                                },
                              );
                            });
                          }
                        }, 
                        child: const Text('Submit Rating & Review')
                      ),
                    ),
                  ],
                )
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