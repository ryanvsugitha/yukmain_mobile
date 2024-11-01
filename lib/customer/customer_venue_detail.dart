import 'dart:convert';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:http/http.dart' as http;
import 'package:latlong2/latlong.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:yuk_main/customer/customer_court_detail.dart';
import 'package:yuk_main/image_full_screen.dart';

class CustomerVenueDetail extends StatefulWidget {
  const CustomerVenueDetail({super.key, required this.venueID});

  final String venueID;

  @override
  State<CustomerVenueDetail> createState() => _CustomerVenueDetailState();
}

class _CustomerVenueDetailState extends State<CustomerVenueDetail> {
  int currIndex = 0;

  late SharedPreferences pref;

  Future getVenueDetail() async {
    pref = await SharedPreferences.getInstance();
    var url = Uri.parse('http://10.0.2.2/yuk_main/API/customer_get_venue_detail.php');
    var request = await http.post(url, body: {
      'venue_id': widget.venueID,
    });
    return request.body;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Venue Detail'),
        centerTitle: true,
      ),
      body: FutureBuilder(
        future: getVenueDetail(), 
        builder: (context, snapshot) {
          if(snapshot.hasData){
            Map result = jsonDecode(snapshot.data) as Map;
            return ListView(
              padding: const EdgeInsets.all(16.0),
              physics: const BouncingScrollPhysics(),
              children: [
                CarouselSlider.builder(
                  itemCount: result['venue_images'].length, 
                  options: CarouselOptions(
                    enableInfiniteScroll: false,
                    scrollDirection: Axis.horizontal,
                    viewportFraction: 1.0,
                    autoPlay: false,
                    autoPlayInterval: const Duration(seconds: 3),
                    onPageChanged: (index, reason) {
                      setState(() {
                        currIndex = index;
                      });
                    },
                  ),
                  itemBuilder: (context, index, realIndex) {
                    return InkWell(
                      borderRadius: BorderRadius.circular(10),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => ImageFullScreen(image: result['venue_images'], index: currIndex),
                          ),
                        );
                      },
                      child: CachedNetworkImage(
                        imageUrl: 'http://10.0.2.2/yuk_main/venue_image/${result['venue_images'][index]['image_name']}',
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
                      )
                    );
                  }, 
                ),
                const SizedBox(height: 8.0,),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    for(int i = 0; i<result['venue_images'].length; i++)
                    Container(
                      margin: const EdgeInsets.only(right: 2.0, left: 2.0),
                      width: 9,
                      height: 9,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: (currIndex == i)
                                ? const Color(0xff1CC500)
                                : const Color.fromRGBO(0, 0, 0, 0.2),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8.0,),
                const Text(
                  'Venue Detail',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 24,
                  ),
                ),
                const Divider(
                  color: Color(0xff1CC500),
                  thickness: 2,
                ),
                Row(
                  children: [
                    const Icon(Icons.abc),
                    const SizedBox(width: 8.0,),
                    Expanded(
                      child: Text(
                        result['venue_name'],
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 20,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8,),
                Row(
                  children: [
                    const Icon(Icons.description_outlined),
                    const SizedBox(width: 8,),
                    Expanded(
                      child: Text(
                        result['venue_desc'],
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 20,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8,),
                Row(
                  children: [
                    const Icon(Icons.location_on_outlined),
                    const SizedBox(width: 8.0,),
                    Expanded(
                      child: Text(
                        result['venue_address'],
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 20,
                        ),
                      )
                    ),
                  ],
                ),
                const SizedBox(height: 8,),
                Row(
                  children: [
                    const Icon(Icons.schedule),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        '${result['venue_open']} - ${result['venue_close']}',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 20,
                        ),
                      )
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                SizedBox(
                  height: 200,
                  child: FlutterMap(
                    mapController: MapController(),
                    options: MapOptions(
                      initialCenter: LatLng(double.parse(result['venue_latitude']), double.parse(result['venue_longitude'])),
                      initialZoom: 16,
                      interactionOptions: const InteractionOptions(
                        // flags: InteractiveFlag.none,
                      ),
                    ),
                    children: [
                      TileLayer(
                        urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                        userAgentPackageName: 'dev.fleaflet.flutter_map.example',
                      ),
                      MarkerLayer(
                        markers: [
                          Marker(
                            rotate: true,
                            alignment: Alignment.topCenter,
                            point: LatLng(double.parse(result['venue_latitude']), double.parse(result['venue_longitude'])), 
                            child: const Icon(
                              Icons.location_on,
                              color: Colors.red,
                              size: 40,
                            )
                          )
                        ]
                      )
                    ],
                  )
                ),
                const SizedBox(height: 16),
                const Text(
                  'Sports List',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 24,
                  ),
                ),
                const Divider(
                  color: Color(0xff1CC500),
                  thickness: 2,
                ),
                for(int i=0; i<result['venue_sports'].length; i++)
                Row(
                  children: [
                    Icon( result['venue_sports'][i]['sport_id'] == '1'
                      ? Icons.sports_soccer_outlined
                      : result['venue_sports'][i]['sport_id'] == '2'
                      ? Icons.sports_soccer_outlined
                      : result['venue_sports'][i]['sport_id'] == '3'
                      ? Icons.sports_soccer_outlined
                      : result['venue_sports'][i]['sport_id'] == '4'
                      ? Icons.sports_tennis_outlined
                      : result['venue_sports'][i]['sport_id'] == '5'
                      ? Icons.sports_volleyball_outlined
                      : result['venue_sports'][i]['sport_id'] == '6'
                      ? Icons.sports_basketball_outlined
                      : Icons.sports_tennis_outlined
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        result['venue_sports'][i]['sport_name'],
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 20,
                        ),
                      )
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                const Text(
                  'Facility List',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 24,
                  ),
                ),
                const Divider(
                  color: Color(0xff1CC500),
                  thickness: 2,
                ),
                for(int i=0; i<result['venue_facility'].length; i++)
                Row(
                  children: [
                    Icon( result['venue_facility'][i]['facility_id'] == '1'
                      ? Icons.wc_outlined
                      : result['venue_facility'][i]['facility_id'] == '2'
                      ? Icons.inventory_2_outlined
                      : result['venue_facility'][i]['facility_id'] == '3'
                      ? Icons.shower_outlined
                      : result['venue_facility'][i]['facility_id'] == '4'
                      ? Icons.local_parking_outlined
                      : result['venue_facility'][i]['facility_id'] == '5'
                      ? Icons.flatware_outlined
                      : Icons.storefront_outlined
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        result['venue_facility'][i]['facility_name'],
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 20,
                        ),
                      )
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                const Text(
                  'Court List',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 24,
                  ),
                ),
                const Divider(
                  color: Color(0xff1CC500),
                  thickness: 2,
                ),
                (result['venue_courts'].isNotEmpty)
                ? ListView.separated(
                  physics: const NeverScrollableScrollPhysics(),
                  shrinkWrap: true,
                  itemCount: result['venue_courts'].length,
                  separatorBuilder: (context, index) {
                    return const SizedBox(height: 8,);
                  }, 
                  itemBuilder: (context, index) {
                    return InkWell(
                      onTap: (){
                        Navigator.push(
                          context, 
                          MaterialPageRoute(builder: (context) => CustomerCourtDetail(courtID: result['venue_courts'][index]['court_id']),)
                        );
                      },
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          border: Border.all(),
                          borderRadius: BorderRadius.circular(5)
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            SizedBox(
                              height: 100,
                              width: 100,
                              child: CachedNetworkImage(
                                imageUrl: 'http://10.0.2.2/yuk_main/court_image/${result['venue_courts'][index]['court_image']}',
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
                            const SizedBox(
                              width: 8.0,
                            ),
                            Expanded(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.start,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    result['venue_courts'][index]['court_name'],
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 20
                                    ),  
                                  ),
                                  const Divider(
                                    color: Color(0xff1CC500),
                                    height: 4,
                                    thickness: 1,
                                  ),
                                  Row(
                                    children: [
                                      Icon( result['venue_courts'][index]['sport_id'] == '1'
                                        ? Icons.sports_soccer_outlined
                                        : result['venue_courts'][index]['sport_id'] == '2'
                                        ? Icons.sports_soccer_outlined
                                        : result['venue_courts'][index]['sport_id'] == '3'
                                        ? Icons.sports_soccer_outlined
                                        : result['venue_courts'][index]['sport_id'] == '4'
                                        ? Icons.sports_tennis_outlined
                                        : result['venue_courts'][index]['sport_id'] == '5'
                                        ? Icons.sports_volleyball_outlined
                                        : result['venue_courts'][index]['sport_id'] == '6'
                                        ? Icons.sports_basketball_outlined
                                        : Icons.sports_tennis_outlined
                                      ),
                                      const SizedBox(width: 8),
                                      Expanded(
                                        child: Text(result['venue_courts'][index]['sport_name'])
                                      ),
                                    ],
                                  ),
                                  Row(
                                    children: [
                                      const Icon(Icons.description_outlined),
                                      const SizedBox(width: 8,),
                                      Expanded(
                                        child: Text(
                                          result['venue_courts'][index]['court_description'],
                                          overflow: TextOverflow.ellipsis,  
                                        ),
                                      ),
                                    ],
                                  ),
                                  Row(
                                    children: [
                                      const Icon(Icons.attach_money),
                                      const SizedBox(width: 8,),
                                      Expanded(
                                        child: result['venue_courts'][index]['min_price'] != null
                                        ? Text('Rp ${result['venue_courts'][index]['min_price']} - Rp ${result['venue_courts'][index]['max_price']}')
                                        : const Text('Schedule and Price not Set')
                                      ),
                                    ],
                                  ),
                                ],
                              )
                            )
                          ],
                        )
                      ),
                    );
                  }, 
                )
                : Center(
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
                ),
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