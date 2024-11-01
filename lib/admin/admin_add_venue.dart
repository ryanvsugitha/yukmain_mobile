import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:yuk_main/admin/admin_select_location.dart';

class AdminAddVenue extends StatefulWidget {
  const AdminAddVenue({super.key});

  @override
  State<AdminAddVenue> createState() => _AdminAddVenueState();
}

class _AdminAddVenueState extends State<AdminAddVenue> {

  TextEditingController venueName = TextEditingController();
  TextEditingController venueDesc = TextEditingController();
  TextEditingController venueAddress = TextEditingController();
  TextEditingController venueFacility = TextEditingController();
  TextEditingController venueSport = TextEditingController();
  String venueOpen = '';
  String venueClose = '';

  bool venueMapLocation = false;

  List selectedFacility = [];
  int selectedFacilityCount = 0;

  List selectedSport = [];
  int selectedSportCount = 0;

  List image = [];

  double venueLongitude = 0.0;
  double venueLatitude = 0.0;

  List hours = [
    '00.00',
    '01.00',
    '02.00',
    '03.00',
    '04.00',
    '05.00',
    '06.00',
    '07.00',
    '08.00',
    '09.00',
    '10.00',
    '11.00',
    '12.00',
    '13.00',
    '14.00',
    '15.00',
    '16.00',
    '17.00',
    '18.00',
    '19.00',
    '20.00',
    '21.00',
    '22.00',
    '23.00',
    '24.00',
  ];

  late SharedPreferences pref;

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

  Future addVenue() async {
    int imgCounter = 1;

    pref = await SharedPreferences.getInstance();
    var url = Uri.parse('http://10.0.2.2/yuk_main/API/admin_add_venue.php');
    var request = http.MultipartRequest('POST', url);

    request.fields['venue_admin'] = pref.getString('username')!;
    request.fields['venue_name'] = venueName.text;
    request.fields['venue_desc'] = venueDesc.text;
    request.fields['venue_open'] = venueOpen;
    request.fields['venue_close'] = venueClose;
    request.fields['venue_address'] = venueAddress.text;
    request.fields['venue_longitude'] = venueLongitude.toString();
    request.fields['venue_latitude'] = venueLatitude.toString();
    request.fields['venue_facility'] = jsonEncode(selectedFacility);
    request.fields['venue_sport'] = jsonEncode(selectedSport);
    for (var currImage in image) {
      request.files.add(await http.MultipartFile.fromPath(
        'image_$imgCounter',
        currImage.path,
      ));
      imgCounter++;
    }

    var res = await request.send();
    var body = await http.Response.fromStream(res);
    return body.body;
  }

  emptyAlert(String str) {
    showDialog(
      context: context, 
      builder: (context) {
        return AlertDialog(
          title: Text(str),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              }, 
              child: const Text('Close')
            )
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add New Venue'),
        centerTitle: true,
        actions: [
          IconButton(
            onPressed: (){

            }, 
            icon: const Icon(Icons.question_mark_rounded)
          )
        ],
      ),
      body: FutureBuilder(
        future: Future.wait([getFacility(), getSport()]), 
        builder: (context, snapshot) {
          if(snapshot.hasData){
            List result = jsonDecode(snapshot.data![0]) as List;
            List sport = jsonDecode(snapshot.data![1]) as List;

            selectedFacility = List.generate(result.length, (index) => false);
            selectedSport = List.generate(sport.length, (index) => false);

            selectedFacilityCount = 0;
            for (var element in selectedFacility) {
              if(element == true){
                selectedFacilityCount++;
              }
            }
            venueFacility.text = '$selectedFacilityCount of ${selectedFacility.length} Selected';
            
            selectedSportCount = 0;
            for (var element in selectedSport) {
              if(element == true){
                selectedSportCount++;
              }
            }
            venueSport.text = '$selectedSportCount of ${selectedSport.length} Selected';

            return ListView(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.all(16.0),
              children: [
                StatefulBuilder(
                  builder: (context, innerSetState) {
                    return Row(
                      children: [
                        Expanded(
                          child: Text('${image.length} image(s) selected')
                        ),
                        ElevatedButton(
                          onPressed: () async {
                            image = await ImagePicker().pickMultiImage(
                              imageQuality: 80,
                            );
                            if(image.length > 10){
                              emptyAlert('Maximum 10 Images');
                            } else if (image.isNotEmpty){
                              innerSetState(() {
                              });
                            }
                          }, 
                          child: const Text('Select Image')
                        ),
                      ],
                    );
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: venueName,
                  decoration: const InputDecoration(
                    labelText: 'Venue Name'
                  ),
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: venueDesc,
                  decoration: const InputDecoration(
                    labelText: 'Venue Description'
                  ),
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: venueFacility,
                  decoration: const InputDecoration(
                    labelText: 'Venue Facility'
                  ),
                  readOnly: true,
                  onTap: () {
                    showModalBottomSheet(
                      shape: const RoundedRectangleBorder(
                        borderRadius: BorderRadiusDirectional.vertical(top: Radius.circular(10))
                      ),
                      context: context, 
                      builder: (context) {
                        return StatefulBuilder(
                          builder: (context, innerSetState) {
                            return ListView.separated(
                              separatorBuilder: (context, index) {
                                return const SizedBox(height: 8.0,);
                              },
                              padding: const EdgeInsets.all(16.0),
                              itemCount: result.length,
                              itemBuilder: (context, index) {
                                return CheckboxListTile(
                                  dense: true,
                                  title: Text(result[index]['facility_name']),
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
                                      venueFacility.text = '$selectedFacilityCount of ${selectedFacility.length} Selected';
                                    });
                                  },
                                );
                              },
                            );
                          },
                        );
                      },
                    );
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: venueSport,
                  decoration: const InputDecoration(
                    labelText: 'Venue Sports'
                  ),
                  readOnly: true,
                  onTap: () {
                    showModalBottomSheet(
                      shape: const RoundedRectangleBorder(
                        borderRadius: BorderRadiusDirectional.vertical(top: Radius.circular(10))
                      ),
                      context: context, 
                      builder: (context) {
                        return StatefulBuilder(
                          builder: (context, innerSetState) {
                            return ListView.separated(
                              separatorBuilder: (context, index) {
                                return const SizedBox(height: 8.0,);
                              },
                              padding: const EdgeInsets.all(16.0),
                              itemCount: sport.length,
                              itemBuilder: (context, index) {
                                return CheckboxListTile(
                                  dense: true,
                                  title: Text(sport[index]['sport_name']),
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
                                      venueSport.text = '$selectedSportCount of ${selectedSport.length} Selected';
                                    });
                                  },
                                );
                              },
                            );
                          },
                        );
                      },
                    );
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: venueAddress,
                  decoration: const InputDecoration(
                    labelText: 'Venue Address'
                  ),
                ),
                const SizedBox(height: 16),
                StatefulBuilder(
                  builder: (context, innerSetState) {
                    return Row(
                      children: [
                        Expanded(
                          child: Text(venueMapLocation
                            ? 'Location Set!'
                            : 'Location Not Set!'
                          )
                        ),
                        ElevatedButton(
                          onPressed: () async {
                            List selected = await Navigator.push(
                              // ignore: use_build_context_synchronously
                              context, 
                              MaterialPageRoute(builder: (context) => const AdminSelectLocation(),)
                            );
                            if(selected.isNotEmpty) {
                              innerSetState(() {
                                venueMapLocation = true;
                                venueLatitude = selected[0];
                                venueLongitude = selected[1];
                              });
                            }
                          }, 
                          child: const Text('Select Location')
                        )
                      ],
                    );
                  },
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: DropdownButtonFormField(
                        decoration: const InputDecoration(
                          labelText: 'Venue Open Time'
                        ),
                        items: [
                          for(String hour in hours)
                          DropdownMenuItem(
                            value: hour,
                            child: Text(hour)
                          )
                        ], 
                        onChanged: (value) {
                          if(value != null){
                            venueOpen = value;
                          }
                        },
                      ),
                    ),
                    const SizedBox(width: 8,),
                    Expanded(
                      child: DropdownButtonFormField(
                        decoration: const InputDecoration(
                          labelText: 'Venue Close Time'
                        ),
                        items: [
                          for(String hour in hours)
                          DropdownMenuItem(
                            value: hour,
                            child: Text(hour)
                          )
                        ], 
                        onChanged: (value) {
                          if(value != null){
                            venueClose = value;
                          }
                        },
                      ),
                    )
                  ],
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () {
                    if(image.isEmpty){
                      emptyAlert('Please select at least one image!');
                    } else if(selectedFacilityCount == 0) {
                      emptyAlert('Please select at least one facility!');
                    } else if(selectedSportCount == 0) {
                      emptyAlert('Please select at least one sport!');
                    } else if (venueName.text.isEmpty || venueAddress.text.isEmpty || venueDesc.text.isEmpty){
                      emptyAlert('Please input field(s)!');
                    } else if (venueOpen == '' || venueClose == ''){
                      emptyAlert('Please input operational time!');
                    } else {
                      addVenue().then((value) {
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
                      },);
                    }
                  }, 
                  child: const Text('Add venue')
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
      )
    );
  }
}