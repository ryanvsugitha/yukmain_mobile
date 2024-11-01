import 'dart:convert';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

class AdminCourtDetail extends StatefulWidget {
  const AdminCourtDetail({super.key, required this.venueID, required this.courtID, required this.openTime, required this.closeTime});

  final String venueID;
  final String courtID;
  final String openTime;
  final String closeTime;

  @override
  State<AdminCourtDetail> createState() => _AdminCourtDetailState();
}

class _AdminCourtDetailState extends State<AdminCourtDetail> {

  bool isLoading = false;

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

  TextEditingController price = TextEditingController();
  String selectedStart = '';
  String selectedEnd = '';

  TextEditingController editPrice = TextEditingController();
  String selectedEditStart = '';
  String selectedEditEnd = '';

  late SharedPreferences pref;

  Future getCourt() async {
    pref = await SharedPreferences.getInstance();
    var url = Uri.parse('http://10.0.2.2/yuk_main/API/admin_get_court_detail.php');
    var request = await http.post(url, body: {
      'court_id': widget.courtID,
    });
    return request.body;
  }

  Future getSport() async {
    pref = await SharedPreferences.getInstance();
    var url = Uri.parse('http://10.0.2.2/yuk_main/API/get_venue_court.php');
    var request = await http.post(url, body: {
      'venue_id': widget.venueID,
    });
    return request.body;
  }

  Future submitSchedule() async {
    pref = await SharedPreferences.getInstance();
    var url = Uri.parse('http://10.0.2.2/yuk_main/API/admin_submit_court_schedule.php');
    var request = await http.post(url, body: {
      'court_id': widget.courtID,
      'price': price.text,
      'start': selectedStart,
      'end': selectedEnd,
    });
    return request.body;
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
        title: const Text('Court Detail'),
        centerTitle: true,
      ),
      body: FutureBuilder(
        future: getCourt(), 
        builder: (context, snapshot) {
          if(snapshot.hasData){
            Map result = jsonDecode(snapshot.data) as Map;
            return ListView(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.all(16.0),
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
                const SizedBox(height: 8.0,),
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
                    const SizedBox(width: 8),
                    ElevatedButton(
                      onPressed: (){
                        showModalBottomSheet(
                          context: context, 
                          builder: (context) {
                            return FutureBuilder(
                              future: getSport(), 
                              builder: (context, snapshot) {
                                if(snapshot.hasData){
                                  List sportList = jsonDecode(snapshot.data) as List;
                                  return ListView(
                                    physics: const BouncingScrollPhysics(),
                                    shrinkWrap: true,
                                    padding: const EdgeInsets.all(16),
                                    children: [
                                      const Text(
                                        'Change Court Sport?',
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 24
                                        ),
                                      ),
                                      const Divider(
                                        color: Color(0xff1CC500),
                                        thickness: 1,
                                        height: 8,
                                      ),
                                      const SizedBox(height: 8),
                                      DropdownButtonFormField(
                                        items: [
                                          for(int i=0; i<sportList.length; i++)
                                          DropdownMenuItem(
                                            value: sportList[i]['sport_id'],
                                            child: Text(sportList[i]['sport_name'])
                                          )
                                        ],
                                        decoration: const InputDecoration(
                                          labelText: 'Court Sport'
                                        ),
                                        onChanged: (value) {
                                          // sportSelected = value.toString();
                                        },
                                      ),
                                      const SizedBox(height: 8),
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                                        children: [
                                          ElevatedButton(
                                            style: ElevatedButton.styleFrom(
                                              backgroundColor: Colors.red
                                            ),
                                            onPressed: (){
                                              Navigator.pop(context);
                                            }, 
                                            child: const Text('Cancel')
                                          ),
                                          ElevatedButton(
                                            onPressed: (){
                                              Navigator.pop(context);
                                            }, 
                                            child: const Text('Update')
                                          ),
                                        ],
                                      ),
                                    ],
                                  );
                                } else {
                                  return Text('123');
                                }
                              },
                            );
                          },
                        );
                      }, 
                      child: const Icon(Icons.edit)
                    )
                  ],
                ),
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
                    const SizedBox(width: 8),
                    ElevatedButton(
                      onPressed: (){
                        showDialog(
                          context: context, 
                          builder: (context) {
                            return AlertDialog(
                              title: const Text('Change Court Name?'),
                              content: TextFormField(
                                decoration: const InputDecoration(
                                  labelText: 'New Court Name'
                                ),
                              ),
                              actionsAlignment: MainAxisAlignment.spaceAround,
                              actions: [
                                ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.red
                                  ),
                                  onPressed: (){
                                    Navigator.pop(context);
                                  }, 
                                  child: const Text('Cancel')
                                ),
                                ElevatedButton(
                                  onPressed: (){
                                    Navigator.pop(context);
                                  }, 
                                  child: const Text('Update')
                                ),
                              ],
                            );
                          },
                        );
                      }, 
                      child: const Icon(Icons.edit)
                    )
                  ],
                ),
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
                    const SizedBox(width: 8),
                    ElevatedButton(
                      onPressed: (){
                        showDialog(
                          context: context, 
                          builder: (context) {
                            return AlertDialog(
                              title: const Text('Change Court Description?'),
                              content: TextFormField(
                                decoration: const InputDecoration(
                                  labelText: 'New Court Description'
                                ),
                              ),
                              actionsAlignment: MainAxisAlignment.spaceAround,
                              actions: [
                                ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.red
                                  ),
                                  onPressed: (){
                                    Navigator.pop(context);
                                  }, 
                                  child: const Text('Cancel')
                                ),
                                ElevatedButton(
                                  onPressed: (){
                                    Navigator.pop(context);
                                  }, 
                                  child: const Text('Update')
                                ),
                              ],
                            );
                          },
                        );
                      }, 
                      child: const Icon(Icons.edit)
                    )
                  ],
                ),
                const SizedBox(height: 16.0,),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Schedule Pricing',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 32
                      ),
                    ),
                    const SizedBox(width: 8),
                    ElevatedButton(
                      onPressed: (){
                        selectedStart = '';
                        selectedEnd = '';
                        price.text = '';
                        showDialog(
                          context: context, 
                          builder: (context) {
                            return StatefulBuilder(
                              builder: (context, innerSetState) {
                                return AlertDialog(
                                  title: const Text('Add Schedule'),
                                  actionsAlignment: MainAxisAlignment.spaceAround,
                                  content: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Row(
                                        children: [
                                          Expanded(
                                            child: DropdownButtonFormField(
                                              decoration: const InputDecoration(
                                                labelText: 'Start Time'
                                              ),
                                              items: [
                                                for (String hour in hours)
                                                DropdownMenuItem(
                                                  value: hour,
                                                  child: Text(hour)
                                                )
                                              ], 
                                              onChanged: (value) {
                                                if(value != null){
                                                  selectedStart = value;
                                                }
                                              },
                                            ),
                                          ),
                                          const SizedBox(width: 16,),
                                          Expanded(
                                            child: DropdownButtonFormField(
                                              decoration: const InputDecoration(
                                                labelText: 'End Time'
                                              ),
                                              items: [
                                                for (String hour in hours)
                                                DropdownMenuItem(
                                                  value: hour,
                                                  child: Text(hour)
                                                )
                                              ], 
                                              onChanged: (value) {
                                                if(value != null){
                                                  selectedEnd = value;
                                                }
                                              },
                                            ),
                                          )
                                        ],
                                      ),
                                      const SizedBox(height: 16,),
                                      TextFormField(
                                        controller: price,
                                        decoration: const InputDecoration(
                                          labelText: 'Price',
                                          prefixText: 'Rp '
                                        ),
                                        keyboardType: TextInputType.number,
                                      )
                                    ],
                                  ),
                                  actions: [
                                    ElevatedButton(
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: Colors.red
                                      ),
                                      onPressed: (){
                                        Navigator.pop(context);
                                      }, 
                                      child: const Text('Cancel')
                                    ),
                                    ElevatedButton(
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: const Color(0xff1CC500)
                                      ),
                                      onPressed: isLoading
                                      ? null
                                      : (){
                                        int openIndex = hours.indexWhere((element) => element.contains(widget.openTime),);
                                        int closeIndex = hours.indexWhere((element) => element.contains(widget.closeTime),);
                                        int startIndex = hours.indexWhere((element) => element.contains(selectedStart),);
                                        int endIndex = hours.indexWhere((element) => element.contains(selectedEnd),);
                                        if(selectedStart == '' || selectedEnd == '' || price.text.isEmpty){
                                          emptyAlert('Please input fields!');
                                        } else if(startIndex >= endIndex){
                                          emptyAlert('End Time cannot before Start Time!');
                                        } else if(startIndex < openIndex){
                                          emptyAlert('Start time cannot before Venue Open Time!\nVenue Open Time: ${widget.openTime}');
                                        } else if(endIndex > closeIndex){
                                          emptyAlert('Start time cannot before Venue Open Time!\nVenue Close Time: ${widget.closeTime}');
                                        } else {
                                          innerSetState(() {
                                            isLoading = !isLoading;
                                          });
                                          submitSchedule().then((value) {
                                            innerSetState(() {
                                              isLoading = !isLoading;
                                            });
                                            Map result = jsonDecode(value) as Map;
                                            return showDialog(
                                              barrierDismissible: false,
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
                                                      child: const Text('Close')
                                                    )
                                                  ],
                                                );
                                              },
                                            );
                                          });
                                        }
                                      },
                                      child: isLoading
                                      ? const SizedBox(
                                          height: 20,
                                          width: 20,
                                          child: CircularProgressIndicator(),
                                        )
                                      : const Text('Submit')
                                    ),
                                  ],
                                );
                              },
                            );
                          },
                        );
                      }, 
                      child: const Icon(Icons.add)
                    )
                  ],
                ),
                const Divider(
                  color: Color(0xff1CC500),
                  thickness: 2,
                  height: 8,
                ),
                const SizedBox(height: 8,),
                (result['court_schedule'].isNotEmpty)
                ? ListView.separated(
                  physics: const NeverScrollableScrollPhysics(),
                  shrinkWrap: true,
                  itemCount: result['court_schedule'].length,
                  separatorBuilder: (context, index) {
                    return const SizedBox(height: 8,);
                  }, 
                  itemBuilder: (context, index) {
                    return Container(
                      padding: const EdgeInsets.all(8.0),
                      decoration: BoxDecoration(
                        border: Border.all(),
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
                                  '${result['court_schedule'][index]['start_time']} - ${result['court_schedule'][index]['end_time']}',
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16
                                  ),
                                ),
                                Text(
                                  'Rp ${result['court_schedule'][index]['formatted_price']}',
                                  style: const TextStyle(
                                    fontSize: 16
                                  ),
                                ),
                              ],
                            ),
                          ),
                          ElevatedButton(
                            onPressed: () {
                              showDialog(
                                context: context, 
                                builder: (context) {
                                  return StatefulBuilder(
                                    builder: (context, innerSetState) {
                                      innerSetState(() {
                                        selectedEditStart = result['court_schedule'][index]['start_time'];
                                        selectedEditEnd = result['court_schedule'][index]['end_time'];
                                        editPrice.text = result['court_schedule'][index]['price'];
                                      });
                                      return AlertDialog(
                                        title: const Text('Edit Schedule'),
                                        content: Column(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            Row(
                                              children: [
                                                Expanded(
                                                  child: DropdownButtonFormField(
                                                    value: selectedEditStart,
                                                    decoration: const InputDecoration(
                                                      labelText: 'Start Time'
                                                    ),
                                                    items: [
                                                      for (String hour in hours)
                                                      DropdownMenuItem(
                                                        value: hour,
                                                        child: Text(hour)
                                                      )
                                                    ], 
                                                    onChanged: (value) {
                                                      if(value != null){
                                                        selectedEditStart = value;
                                                      }
                                                    },
                                                  ),
                                                ),
                                                const SizedBox(width: 16,),
                                                Expanded(
                                                  child: DropdownButtonFormField(
                                                    value: selectedEditEnd,
                                                    decoration: const InputDecoration(
                                                      labelText: 'End Time'
                                                    ),
                                                    items: [
                                                      for (String hour in hours)
                                                      DropdownMenuItem(
                                                        value: hour,
                                                        child: Text(hour)
                                                      )
                                                    ], 
                                                    onChanged: (value) {
                                                      if(value != null){
                                                        selectedEditEnd = value;
                                                      }
                                                    },
                                                  ),
                                                )
                                              ],
                                            ),
                                            const SizedBox(height: 16,),
                                            TextFormField(
                                              controller: editPrice,
                                              decoration: const InputDecoration(
                                                labelText: 'Price',
                                                prefixText: 'Rp '
                                              ),
                                              keyboardType: TextInputType.number,
                                            )
                                          ],
                                        ),
                                        actionsAlignment: MainAxisAlignment.spaceAround,
                                        actions: [
                                          ElevatedButton(
                                            style: ElevatedButton.styleFrom(
                                              backgroundColor: Colors.red
                                            ),
                                            onPressed: (){
                                              Navigator.pop(context);
                                            }, 
                                            child: const Text('Cancel')
                                          ),
                                          ElevatedButton(
                                            style: ElevatedButton.styleFrom(
                                              backgroundColor: const Color(0xff1CC500)
                                            ),
                                            onPressed: (){

                                            }, 
                                            child: const Text('Edit')
                                          )
                                        ],
                                      );
                                    });
                                }
                              );
                            }, 
                            child: const Icon(Icons.edit)
                          )
                        ],
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
      )
    );
  }
}