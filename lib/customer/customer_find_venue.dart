import 'dart:convert';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'package:yuk_main/customer/customer_venue_detail.dart';

class CustomerFindVenue extends StatefulWidget {
  const CustomerFindVenue({super.key});

  @override
  State<CustomerFindVenue> createState() => _CustomerFindVenueState();
}

class _CustomerFindVenueState extends State<CustomerFindVenue> {

  late SharedPreferences pref;

  TextEditingController search = TextEditingController();

  Future getVenueList() async {
    pref = await SharedPreferences.getInstance();
    var url = Uri.parse('http://10.0.2.2/yuk_main/API/customer_get_venue_list.php');
    var request = await http.post(url, body: {
      'search': search.text,
      'facility': jsonEncode(selectedFacility),
      'sport': jsonEncode(selectedSport),
    });
    return request.body;
  }

  Future getFacility() async {
    var url = Uri.parse('http://10.0.2.2/yuk_main/API/get_facility_list.php');
    var request = await http.post(url, body: {});
    return request.body;
  }

  Future getSport() async {
    var url = Uri.parse('http://10.0.2.2/yuk_main/API/get_sport_list.php');
    var request = await http.post(url, body: {});
    return request.body;
  }

  List selectedFacility = [];
  int selectedFacilityCount = 0;

  List selectedSport = [];
  int selectedSportCount = 0;

  late Future getSportList;
  late Future getFacilityList;

  @override
  void initState() {
    super.initState();
    
    getSportList = getSport();
    getFacilityList = getFacility();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Search Venue'),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: search,
                    decoration: const InputDecoration(
                      hintText: 'Search',
                      isDense: true,
                      prefixIcon: Icon(Icons.search)
                    ),
                    onChanged: (value) {
                      setState(() {});
                    },
                  ),
                ),
                const SizedBox(width: 16),
                ElevatedButton(
                  onPressed: (){
                    showModalBottomSheet(
                      context: context, 
                      builder: (context) {
                        return FutureBuilder(
                          future: Future.wait([getFacilityList, getSportList]), 
                          builder: (context, snapshot) {
                            if(snapshot.hasData){
                              List facilityList = jsonDecode(snapshot.data![0]) as List;
                              List sportList = jsonDecode(snapshot.data![1]) as List;

                              if(selectedFacility.isEmpty && selectedSport.isEmpty){
                                selectedFacility = List.generate(facilityList.length, (index) => false);
                                selectedFacilityCount = 0;
                                for (var element in selectedFacility) {
                                  if(element == true){
                                    selectedFacilityCount++;
                                  }
                                }

                                selectedSport = List.generate(sportList.length, (index) => false);
                                selectedSportCount = 0;
                                for (var element in selectedSport) {
                                  if(element == true){
                                    selectedSportCount++;
                                  }
                                }
                              }

                              return StatefulBuilder(
                                builder: (context, innerSetState) {
                                  return ListView(
                                    padding: const EdgeInsets.all(16),
                                    physics: const BouncingScrollPhysics(),
                                    children: [
                                      const Text(
                                        'Venue Sport',
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 16,
                                        ),
                                      ),
                                      const Divider(
                                        color: Color(0xff1CC500),
                                        thickness: 2,
                                      ),
                                      ListView.separated(
                                        shrinkWrap: true,
                                        physics: const NeverScrollableScrollPhysics(),
                                        itemCount: facilityList.length,
                                        separatorBuilder: (context, index) {
                                          return const SizedBox(height: 8);
                                        }, 
                                        itemBuilder: (context, index) {
                                          return CheckboxListTile(
                                            dense: true,
                                            title: Text(sportList[index]['sport_name']),
                                            value: selectedSport[index], 
                                            onChanged: (value) {
                                              innerSetState(() {
                                                selectedSport[index] = value;
                                                selectedSportCount = 0;
                                                for (var element in selectedSport) {
                                                  if(element == true){
                                                    selectedSportCount++;
                                                  }
                                                }
                                              });
                                            },
                                          );
                                        }, 
                                      ),
                                      const SizedBox(height: 16),
                                      const Text(
                                        'Venue Facility',
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 16,
                                        ),
                                      ),
                                      const Divider(
                                        color: Color(0xff1CC500),
                                        thickness: 2,
                                      ),
                                      ListView.separated(
                                        shrinkWrap: true,
                                        physics: const NeverScrollableScrollPhysics(),
                                        itemCount: facilityList.length,
                                        separatorBuilder: (context, index) {
                                          return const SizedBox(height: 8);
                                        },
                                        itemBuilder: (context, index) {
                                          return CheckboxListTile(
                                            dense: true,
                                            title: Text(facilityList[index]['facility_name']),
                                            value: selectedFacility[index], 
                                            onChanged: (value) {
                                              innerSetState(() {
                                                selectedFacility[index] = value;
                                                selectedFacilityCount = 0;
                                                for (var element in selectedFacility) {
                                                  if(element == true){
                                                    selectedFacilityCount++;
                                                  }
                                                }
                                              });
                                            },
                                          );
                                        },
                                      ),
                                      const SizedBox(height: 16),
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                                        children: [
                                          ElevatedButton(
                                            style: ElevatedButton.styleFrom(
                                              backgroundColor: Colors.red
                                            ),
                                            onPressed: () {
                                              innerSetState(() {
                                                selectedSportCount = 0;
                                                selectedFacilityCount = 0;
                                                for (int i=0; i < selectedFacility.length; i++) {
                                                  selectedFacility[i] = false;
                                                }
                                                for (int i=0; i < selectedSport.length; i++) {
                                                  selectedSport[i] = false;
                                                }
                                              });
                                            }, 
                                            child: const Text('Reset')
                                          ),
                                          ElevatedButton(
                                            onPressed: () {
                                              Navigator.pop(context);
                                              setState(() {});
                                            }, 
                                            child: const Text('Apply')
                                          )
                                        ],
                                      ),
                                    ],
                                  );
                                },
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
                        );
                      },
                    );
                  }, 
                  child: const Text('Filter')
                )
              ],
            ),
            const SizedBox(height: 16,),
            Expanded(
              child: FutureBuilder(
                future: getVenueList(), 
                builder: (context, snapshot) {
                  if(snapshot.hasData){
                    List result = jsonDecode(snapshot.data) as List;
                    return ListView.separated(
                      physics: const BouncingScrollPhysics(),
                      itemCount: result.length,
                      separatorBuilder: (context, index) {
                        return const SizedBox(height: 8,);
                      },
                      itemBuilder: (context, index) {
                        return InkWell(
                          onTap: () {
                            Navigator.push(
                              context, 
                              MaterialPageRoute(builder: (context) => CustomerVenueDetail(venueID: result[index]['venue_id']),)
                            );
                          },
                          child: Container(
                            padding: const EdgeInsets.all(8.0),
                            decoration: BoxDecoration(
                              border: Border.all(),
                              borderRadius: BorderRadius.circular(5.0)
                            ),
                            child: Row(
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
                                const SizedBox(width: 8.0,),
                                Column(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(result[index]['venue_name'])
                                  ],
                                ),
                              ],
                            ),
                          ),
                        );
                      }, 
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
            ),
          ],
        ),
      ),
    );
  }
}