import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

class AdminAddCourt extends StatefulWidget {
  const AdminAddCourt({super.key, required this.venueID});

  final String venueID;

  @override
  State<AdminAddCourt> createState() => _AdminAddCourtState();
}

class _AdminAddCourtState extends State<AdminAddCourt> {

  late SharedPreferences pref;

  TextEditingController courtName = TextEditingController();
  TextEditingController courtDesc = TextEditingController();
  String sportSelected = '';

  String imageSelected = '';

  String courtScheduling = '';

  Future addCourt() async {
    pref = await SharedPreferences.getInstance();
    var url = Uri.parse('http://10.0.2.2/yuk_main/API/admin_add_court.php');
    var request = http.MultipartRequest('POST', url);

    request.fields['venue_id'] = widget.venueID;
    request.fields['court_name'] = courtName.text;
    request.fields['court_desc'] = courtDesc.text;
    request.fields['sport_selected'] = sportSelected;
    request.files.add(await http.MultipartFile.fromPath(
      'court_image',
      imageSelected,
    ));

    var res = await request.send();
    var body = await http.Response.fromStream(res);
    return body.body;
  }

  late Future futureGetData;
  Future getSport() async {
    pref = await SharedPreferences.getInstance();
    var url = Uri.parse('http://10.0.2.2/yuk_main/API/get_venue_court.php');
    var request = await http.post(url, body: {
      'venue_id': widget.venueID,
    });
    return request.body;
  }

  @override
  void initState() { 
    super.initState();
    futureGetData = getSport();
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
        title: const Text('Add Court'),
        centerTitle: true,
      ),
      body: FutureBuilder(
        future: futureGetData, 
        builder: (context, snapshot) {
          if(snapshot.hasData){
            List result = jsonDecode(snapshot.data) as List;
            return ListView(
              padding: const EdgeInsets.all(16.0),
              physics: const BouncingScrollPhysics(),
              children: [
                InkWell(
                  borderRadius: BorderRadius.circular(5.0),
                  onTap: () async {
                    final image = await ImagePicker().pickImage(
                      source: ImageSource.gallery,
                      imageQuality: 80,
                    );
                    if(image == null){
                      return;
                    }
                    setState(() {
                      imageSelected = image.path;
                    });
                  },
                  child: imageSelected != ''
                  ? Image.file(
                      File(imageSelected)
                    )
                  : Container(
                    decoration: BoxDecoration(
                      border: Border.all(),
                      borderRadius: BorderRadius.circular(5.0)
                    ),
                    height: MediaQuery.sizeOf(context).width * 0.25,
                    child: const Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.image_outlined, 
                          size: 48,
                        ),
                        SizedBox(height: 8),
                        Text('Add Image')
                      ],
                    )
                  ),
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: courtName,
                  decoration: const InputDecoration(
                    labelText: 'Court Name'
                  ),
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: courtDesc,
                  decoration: const InputDecoration(
                    labelText: 'Court Description'
                  ),
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField(
                  items: [
                    for(int i=0; i<result.length; i++)
                    DropdownMenuItem(
                      value: result[i]['sport_id'],
                      child: Text(result[i]['sport_name'])
                    )
                  ],
                  decoration: const InputDecoration(
                    labelText: 'Court Sport'
                  ),
                  onChanged: (value) {
                    sportSelected = value.toString();
                  },
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: (){
                    if(imageSelected == ''){
                      emptyAlert('Please select 1 image!');
                    } else if (courtName.text == '' || courtDesc.text == '' || sportSelected == '') {
                      emptyAlert('Please input fields!');
                    } else {
                      addCourt().then((value) {
                        Map result = jsonDecode(value) as Map;
                        showDialog(
                          context: context, 
                          builder: (context) {
                            return AlertDialog(
                              title: Text(result['message']),
                              actions: [
                                TextButton(
                                  onPressed: (){
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
                      });
                    }
                  }, 
                  child: const Text('Submit')
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
      )
    );
  }
}