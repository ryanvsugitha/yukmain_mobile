import 'dart:convert';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'package:yuk_main/customer/customer_payment.dart';

class CustomerCourtDetail extends StatefulWidget {
  const CustomerCourtDetail({super.key, required this.courtID});

  final String courtID;

  @override
  State<CustomerCourtDetail> createState() => _CustomerCourtDetailState();
}

class _CustomerCourtDetailState extends State<CustomerCourtDetail> {

  TextEditingController selectedDateString = TextEditingController();
  DateTime selectedDate = DateTime.now();
  DateTime todayDate = DateTime.now();

  late SharedPreferences pref;

  late Future courtData;
  late Future scheduleData;

  Future getCourt() async {
    pref = await SharedPreferences.getInstance();
    var url = Uri.parse('http://10.0.2.2/yuk_main/API/customer_get_court_detail.php');
    var request = await http.post(url, body: {
      'court_id': widget.courtID,
    });
    return request.body;
  }

  Future getSchedule() async {
    pref = await SharedPreferences.getInstance();
    var url = Uri.parse('http://10.0.2.2/yuk_main/API/customer_get_court_schedule.php');
    var request = await http.post(url, body: {
      'date': '${selectedDate.year.toString()}-${selectedDate.month.toString().padLeft(2, '0')}-${selectedDate.day.toString().padLeft(2, '0')}',
      'court_id': widget.courtID,
    });
    return request.body;
  }

  @override
  void initState() {
    super.initState();
    selectedDateString.text = '${selectedDate.day.toString().padLeft(2, '0')} - ${selectedDate.month.toString().padLeft(2, '0')} - ${selectedDate.year.toString()}';
    courtData = getCourt();
    scheduleData = getSchedule();
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Court Detail'),
        centerTitle: true,
      ),
      body: ListView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.all(16.0),
        shrinkWrap: true,
        children: [
          FutureBuilder(
            future: courtData, 
            builder: (context, snapshot) {
              if(snapshot.hasData){
                Map result = jsonDecode(snapshot.data) as Map;
                return Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(
                      height: MediaQuery.sizeOf(context).width * 0.50,
                      child: CachedNetworkImage(
                        imageUrl: 'http://10.0.2.2/yuk_main/court_image/${result['court_image']}',
                        progressIndicatorBuilder: (context, url, progress) => Center(
                          child: CircularProgressIndicator(value: progress.progress),
                        ),
                        imageBuilder: (context, imageProvider) => Container(
                          decoration: BoxDecoration(
                            borderRadius: const BorderRadius.all(Radius.circular(10.0)),
                            image: DecorationImage(
                              image: imageProvider,
                              fit: BoxFit.cover
                            )
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Court Detail',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 32
                      ),
                    ),
                    const Divider(
                      color: Color(0xff1CC500),
                      thickness: 2,
                      height: 8,
                    ),
                    Row(
                      children: [
                        Icon( result['sport_id'] == '1'
                          ? Icons.sports_soccer_outlined
                          : result['sport_id'] == '2'
                          ? Icons.sports_soccer_outlined
                          : result['sport_id'] == '3'
                          ? Icons.sports_soccer_outlined
                          : result['sport_id'] == '4'
                          ? Icons.sports_tennis_outlined
                          : result['sport_id'] == '5'
                          ? Icons.sports_volleyball_outlined
                          : result['sport_id'] == '6'
                          ? Icons.sports_basketball_outlined
                          : Icons.sports_tennis_outlined
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            result['sport_name'],
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 20,
                            ),
                          )
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        const Icon(Icons.abc),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            result['court_name'],
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 20
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        const Icon(Icons.description_outlined),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            result['court_description'],
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 20,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                  ],
                );
              } else {
                return const Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      CircularProgressIndicator(),
                      SizedBox(
                        height: 10,
                      ),
                      Text('Loading data...'),
                    ],
                  ),
                );
              }
            },
          ),
          const Text(
            'Schedule',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 32
            ),
          ),
          const Divider(
            color: Color(0xff1CC500),
            thickness: 2,
            height: 8,
          ),
          const SizedBox(height: 8),
          TextFormField(
            controller: selectedDateString,
            readOnly: true,
            decoration: const InputDecoration(
              labelText: 'Select Date',
              suffixIcon: Icon(Icons.calendar_month)
            ),
            onTap: () async {
              final DateTime? picked = await showDatePicker(
                  context: context,
                  initialDate: selectedDate,
                  firstDate: todayDate,
                  lastDate: DateTime(2101));
              if (picked != null && picked != selectedDate) {
                setState(() {
                  selectedDate = picked;
                  selectedDateString.text = '${selectedDate.day.toString().padLeft(2, '0')} - ${selectedDate.month.toString().padLeft(2, '0')} - ${selectedDate.year.toString()}';
                  scheduleData = getSchedule();
                });
              }
            },
          ),
          const SizedBox(height: 16),
          FutureBuilder(
            future: scheduleData, 
            builder: (context, snapshot) {
              if (snapshot.hasData){
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
                        onTap: result[index]['status'] == '1'
                          ? (){
                            Navigator.push(
                              context, 
                              MaterialPageRoute(builder: (context) => CustomerPayment(scheduleID: result[index]['schedule_id'], date: selectedDate),)
                            );
                          }
                          : null,
                        child: Container(
                          padding: const EdgeInsets.all(8.0),
                          decoration: BoxDecoration(
                            border: Border.all(
                              color: result[index]['status'] == '1'
                              ? Colors.black
                              : Colors.grey
                            ),
                            borderRadius: BorderRadius.circular(5)
                          ),
                          child: Row(
                            children: [
                              Expanded(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      '${result[index]['start_time']} - ${result[index]['end_time']}',
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16,
                                        color: result[index]['status'] == '1'
                                        ? Colors.black
                                        : Colors.grey
                                      ),
                                    ),
                                    Text(
                                      'Rp ${result[index]['formatted_price']}',
                                      style: TextStyle(
                                        fontSize: 16,
                                        color: result[index]['status'] == '1'
                                        ? Colors.black
                                        : Colors.grey
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Text(
                                result[index]['status'] == '1'
                                ? 'Available'
                                : 'Not Available',
                                style: TextStyle(
                                  color: result[index]['status'] == '1'
                                  ? Colors.green
                                  : Colors.red
                                ),
                              ),
                            ],
                          ),
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
                        height: 10,
                      ),
                      Text('Loading data...'),
                    ],
                  ),
                );
              }
            },
          )
        ],
      ),
    );
  }
}