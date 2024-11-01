import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'package:yuk_main/customer/customer_main.dart';

class CustomerPayment extends StatefulWidget {
  const CustomerPayment({super.key, required this.scheduleID, required this.date});

  final String scheduleID;
  final DateTime date;

  @override
  State<CustomerPayment> createState() => _CustomerPaymentState();
}

class _CustomerPaymentState extends State<CustomerPayment> {

  late SharedPreferences pref;

  var paymentType = '';

  late Future getBookingDetail;
  late Future getPaymentType;

  String courtID = '';

  Future getData() async {
    pref = await SharedPreferences.getInstance();
    var url = Uri.parse('http://10.0.2.2/yuk_main/API/customer_get_payment_detail.php');
    var request = await http.post(url, body: {
      'schedule_id': widget.scheduleID,
    });
    return request.body;
  }

  Future getPayment() async {
    pref = await SharedPreferences.getInstance();
    var url = Uri.parse('http://10.0.2.2/yuk_main/API/get_payment_type.php');
    var request = await http.post(url, body: {});
    return request.body;
  }

  Future createBooking() async {
    pref = await SharedPreferences.getInstance();
    var url = Uri.parse('http://10.0.2.2/yuk_main/API/customer_create_booking.php');
    var request = await http.post(url, body: {
      'schedule_id': widget.scheduleID,
      'date': '${widget.date.year.toString()}-${widget.date.month.toString().padLeft(2, '0')}-${widget.date.day.toString().padLeft(2, '0')}',
      'payment_type_id': paymentType,
      'booker_id': pref.getString('username'),
      'court_id': courtID,
    });
    return request.body;
  }

  @override
  void initState() {
    super.initState();
    getBookingDetail = getData();
    getPaymentType = getPayment();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Payment'),
        centerTitle: true,
      ),
      body: FutureBuilder(
        future: Future.wait([getBookingDetail, getPaymentType]), 
        builder: (context, snapshot) {
          if(snapshot.hasData){
            Map result = jsonDecode(snapshot.data![0]) as Map;
            List paymentTypeList = jsonDecode(snapshot.data![1]) as List;

            courtID = result['court_id'];

            return ListView(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.all(16),
              children: [
                const Text(
                  'Payment Detail',
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
                      width: 56,
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
                      width: 56,
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
                      width: 56,
                      child: Text('Date')
                    ),
                    const SizedBox(
                      width: 16,
                      child: Text(':')
                    ),
                    Expanded(
                      child: Text('${widget.date.day.toString().padLeft(2, '0')} - ${widget.date.month.toString().padLeft(2, '0')} - ${widget.date.year.toString()}'),
                    )
                  ],
                ),
                Row(
                  children: [
                    const SizedBox(
                      width: 56,
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
                      width: 56,
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
                const SizedBox(
                  height: 16,
                ),
                const Text(
                  'Payment Option',
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
                for(int i = 0; i<paymentTypeList.length; i++)
                RadioListTile(
                  title: Text(paymentTypeList[i]['payment_type_name']),
                  value: paymentTypeList[i]['payment_type_id'], 
                  groupValue: paymentType, 
                  onChanged: (value) {
                    setState(() {
                      paymentType = value.toString();
                    });
                  },
                ),
                const SizedBox(
                  height: 16,
                ),
                ElevatedButton(
                  onPressed: () {
                    if(paymentType == ''){
                      showDialog(
                        context: context, 
                        builder: (context) {
                          return AlertDialog(
                            title: const Text('Please Select Payment Type!'),
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
                      createBooking().then((value) {
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
                                      Navigator.pushAndRemoveUntil(
                                        context, 
                                        MaterialPageRoute(
                                          builder: (context) => const CustomerMain(),
                                        ),
                                        (route) => false,
                                      );
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
                  child: const Text('Confirm Payment')
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