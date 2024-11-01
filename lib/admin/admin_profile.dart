import 'dart:convert';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'package:yuk_main/splashscreen.dart';

class AdminProfile extends StatefulWidget {
  const AdminProfile({super.key});

  @override
  State<AdminProfile> createState() => _AdminProfileState();
}

class _AdminProfileState extends State<AdminProfile> {

  late SharedPreferences pref;

  Future getProfile() async {
    pref = await SharedPreferences.getInstance();
    var url = Uri.parse('http://10.0.2.2/yuk_main/API/get_profile.php');
    var request = await http.post(url, body: {
      'username': pref.getString('username'),
    });
    return request.body;
  }

  Future setLogOut() async {
    pref = await SharedPreferences.getInstance();
    await pref.setBool('status', false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
        centerTitle: true,  
      ),
      body: SafeArea(
        child: FutureBuilder(
          future: getProfile(), 
          builder: (context, snapshot) {
            if(snapshot.hasData){
              Map result = jsonDecode(snapshot.data) as Map;
              return Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      children: [
                        Center(
                          child: SizedBox(
                            width: MediaQuery.of(context).size.width * 0.4,
                            height: MediaQuery.of(context).size.width * 0.4,
                            child: CachedNetworkImage(
                              imageUrl: (result['picture'] != null)
                              ? 'http://10.0.2.2/yuk_main/profile_picture/${result['picture']}'
                              : 'http://10.0.2.2/yuk_main/profile_picture/default_profile.png',
                              progressIndicatorBuilder: (context, url, progress) => Center(
                                child: CircularProgressIndicator(value: progress.progress),
                              ),
                              imageBuilder: (context, imageProvider) => Container(
                                decoration: BoxDecoration(
                                  // borderRadius: BorderRadius.circular(80.0),
                                  shape: BoxShape.circle,
                                  image: DecorationImage(
                                    image: imageProvider,
                                    fit: BoxFit.cover
                                  )
                                ),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(
                          height: 8,
                        ),
                        Text(
                          '@${result['username']}',
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold
                          ),
                        ),
                      ],
                    ),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red
                      ),
                      onPressed: (){
                        showDialog(
                          barrierDismissible: false,
                          context: context,
                          builder: (context) {
                            return AlertDialog(
                              title: const Text('Are you sure to log out?'),
                              actions: [
                                TextButton(
                                  onPressed: (){
                                    Navigator.pop(context);
                                  },
                                  child: const Text('Cancel'),
                                ),
                                TextButton(
                                  onPressed: (){
                                    setLogOut();
                                    Navigator.pushAndRemoveUntil(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => const SplashScreen(),
                                      ),
                                      (route) => false,
                                    );
                                  },
                                  child: const Text('Yes'),
                                ),
                              ],
                            );
                          },
                        );
                      }, 
                      child: const Text('Log Out')
                    )
                    // Image.network(result['picture'] == null
                    //   ? 'http://10.0.2.2/yuk_main/profile_picture/default_profile.png'
                    //   : 'http://10.0.2.2/yuk_main/profile_picture/${result['picture']}'
                    // ),
                  ],
                ),
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
      )
    );
  }
}