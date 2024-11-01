import 'dart:convert';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:yuk_main/customer/customer_booking_detail.dart';
import 'package:yuk_main/customer/customer_find_venue.dart';
import 'package:http/http.dart' as http;
import 'package:yuk_main/customer/customer_venue_detail.dart';

class CustomerHome extends StatefulWidget {
  const CustomerHome({super.key});

  @override
  State<CustomerHome> createState() => _CustomerHomeState();
}

class _CustomerHomeState extends State<CustomerHome> {

  late SharedPreferences pref;
  String? username;

  Future getProfile() async {
    pref = await SharedPreferences.getInstance();
    setState(() {
      username = pref.getString('username');
    });
  }

  Future getNearVenue() async {

    LocationPermission permission;

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }
    Position position = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.bestForNavigation);

    var url = Uri.parse('http://10.0.2.2/yuk_main/API/customer_near_venue.php');
    var request = await http.post(url, body: {
      'latitude': position.latitude.toString(),
      'longitude': position.longitude.toString(),
    });
    return request.body;
  }
  
  Future getRecentBooking() async {
    pref = await SharedPreferences.getInstance();
    var url = Uri.parse('http://10.0.2.2/yuk_main/API/customer_get_recent_booking.php');
    var request = await http.post(url, body: {
      'username': pref.getString('username'),
    });
    return request.body;
  }

  @override
  void initState() {
    super.initState();
    getProfile();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Welcome, $username'),
        actions: [
          IconButton(
            onPressed: (){
              Navigator.push(
                context, 
                MaterialPageRoute(builder: (context) => const CustomerFindVenue(),)
              );
            }, 
            icon: const Icon(Icons.search)
          )
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        physics: const BouncingScrollPhysics(),
        children: [
          const Text(
            'Venue Near You',
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
          const SizedBox(height: 8),
          FutureBuilder(
            future: getNearVenue(), 
            builder: (context, snapshot) {
              if(snapshot.hasData){
                List result = jsonDecode(snapshot.data) as List;
                if(result.isNotEmpty){
                  return SizedBox(
                    height: 150,
                    width: 150,
                    child: ListView.separated(
                      scrollDirection: Axis.horizontal,
                      physics: const BouncingScrollPhysics(),
                      itemCount: result.length,
                      separatorBuilder: (context, index) {
                        return const SizedBox(width: 8);
                      },
                      itemBuilder: (context, index) {
                        return InkWell(
                          borderRadius: BorderRadius.circular(5),
                          onTap: () {
                            Navigator.push(
                              context, 
                              MaterialPageRoute(builder: (context) => CustomerVenueDetail(venueID: result[index]['venue_id']),)
                            );
                          },
                          child: Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              border: Border.all(),
                              borderRadius: BorderRadius.circular(5)
                            ),
                            child: Column(
                              children: [
                                SizedBox(
                                  height: 100,
                                  width: 100,
                                  child: CachedNetworkImage(
                                    imageUrl: 'http://10.0.2.2/yuk_main/venue_image/${result[index]['image_name']}',
                                    progressIndicatorBuilder: (context, url, progress) => Center(
                                      child: CircularProgressIndicator(value: progress.progress),
                                    ),
                                    imageBuilder: (context, imageProvider) => Container(
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(5),
                                        image: DecorationImage(
                                          image: imageProvider,
                                          fit: BoxFit.cover
                                        )
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 8),
                                SizedBox(
                                  width: 100,
                                  child: Center(
                                    child: Text(
                                      '${result[index]['venue_name']}', 
                                      style: const TextStyle(
                                        overflow: TextOverflow.ellipsis,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
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
                        const SizedBox(height: 8),
                        const Text(
                          'Sorry, no venue near you',
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
                      SizedBox(height: 10),
                      Text('Loading data...'),
                    ],
                  ),
                );
              }
            },
          ),
          const SizedBox(height: 16),
          const Text(
            'Recent Booking',
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
          const SizedBox(height: 8),
          FutureBuilder(
            future: getRecentBooking(), 
            builder: (context, snapshot) {
              if(snapshot.hasData){
                List result = jsonDecode(snapshot.data) as List;
                if(result.isNotEmpty){
                  return SizedBox(
                    height: 200,
                    width: 150,
                    child: ListView.separated(
                      scrollDirection: Axis.horizontal,
                      physics: const BouncingScrollPhysics(),
                      itemCount: result.length,
                      separatorBuilder: (context, index) {
                        return const SizedBox(width: 8);
                      },
                      itemBuilder: (context, index) {
                        return InkWell(
                          borderRadius: BorderRadius.circular(5),
                          onTap: () {
                            Navigator.push(
                              context, 
                              MaterialPageRoute(builder: (context) => CustomerBookingDetail(bookingID: result[index]['booking_id'],),)
                            );
                          },
                          child: Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              border: Border.all(),
                              borderRadius: BorderRadius.circular(5)
                            ),
                            child: Column(
                              children: [
                                SizedBox(
                                  height: 100,
                                  width: 100,
                                  child: CachedNetworkImage(
                                    imageUrl: 'http://10.0.2.2/yuk_main/court_image/${result[index]['court_image']}',
                                    progressIndicatorBuilder: (context, url, progress) => Center(
                                      child: CircularProgressIndicator(value: progress.progress),
                                    ),
                                    imageBuilder: (context, imageProvider) => Container(
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(5),
                                        image: DecorationImage(
                                          image: imageProvider,
                                          fit: BoxFit.cover
                                        )
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 8),
                                SizedBox(
                                  width: 100,
                                  child: Column(
                                    children: [
                                      Text(
                                        '${result[index]['venue_name']}', 
                                        style: const TextStyle(
                                          overflow: TextOverflow.ellipsis,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      Text(result[index]['booking_date']),
                                      Text(result[index]['court_name']),
                                      Text('${result[index]['start_time']} - ${result[index]['end_time']}')
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
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
                        const SizedBox(height: 8),
                        const Text(
                          'Sorry, no recent booking',
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
                      SizedBox(height: 10),
                      Text('Loading data...'),
                    ],
                  ),
                );
              }
            },
          ),
          const SizedBox(height: 16),
          const Text(
            'Discover More Venue',
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
          const SizedBox(height: 8),
        ],
      )
    );
  }
}