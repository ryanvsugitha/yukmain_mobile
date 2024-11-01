import 'dart:convert';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:yuk_main/admin/admin_add_venue.dart';
import 'package:http/http.dart' as http;
import 'package:yuk_main/admin/admin_venue_detail.dart';

class AdminVenueList extends StatefulWidget {
  const AdminVenueList({super.key});

  @override
  State<AdminVenueList> createState() => _AdminVenueListState();
}

class _AdminVenueListState extends State<AdminVenueList> {

  TextEditingController search = TextEditingController();

  late SharedPreferences pref;

  Future getVenue() async {
    pref = await SharedPreferences.getInstance();
    var url = Uri.parse('http://10.0.2.2/yuk_main/API/admin_get_venue_list.php');
    var request = await http.post(url, body: {
      'admin_id': pref.getString('username'),
      'search': search.text,
    });
    return request.body;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Venue List'),
        centerTitle: true,
        actions: [
          IconButton(
            onPressed: (){
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const AdminAddVenue(),)
              ).then((value) {
                setState(() {});
              },);
            }, 
            icon: const Icon(Icons.add)
          )
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 16.0, right: 16.0, top: 16.0),
            child: TextFormField(
              controller: search,
              decoration: const InputDecoration(
                labelText: 'Search'
              ),
              onChanged: (value) {
                setState(() {});
              },
            ),
          ),
          Expanded(
            child: FutureBuilder(
              future: getVenue(), 
              builder: (context, snapshot) {
                if(snapshot.hasData) {
                  List result = jsonDecode(snapshot.data) as List;
                  if(result.isNotEmpty){
                    return ListView.separated(
                      physics: const BouncingScrollPhysics(),
                      padding: const EdgeInsets.all(16.0),
                      itemCount: result.length,
                      separatorBuilder: (context, index) {
                        return const SizedBox(height: 8.0);
                      }, 
                      itemBuilder: (context, index) {
                        return InkWell(
                          borderRadius: BorderRadius.circular(5),
                          onTap: () {
                            Navigator.push(
                              context, 
                              MaterialPageRoute(builder: (context) => AdminVenueDetail(venueID: result[index]['venue_id'],),)
                            ).then((value) {
                              setState(() {});
                            },);
                          },
                          child: Container(
                            decoration: BoxDecoration(
                              border: Border.all(),
                              borderRadius: BorderRadius.circular(5)
                            ),
                            padding: const EdgeInsets.all(8.0),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              crossAxisAlignment: CrossAxisAlignment.start,
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
                                Expanded(
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        result[index]['venue_name'],
                                        overflow: TextOverflow.ellipsis,
                                        style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 20
                                        ),
                                      ),
                                      Row(
                                        children: [
                                          const Icon(Icons.location_on),
                                          const SizedBox(width: 8,),
                                          Expanded(
                                            child: Text(
                                              result[index]['venue_address'], 
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          )
                                        ],
                                      ),
                                      Row(
                                        children: [
                                          const Icon(Icons.description_outlined),
                                          const SizedBox(width: 8,),
                                          Expanded(
                                            child: Text(
                                              result[index]['venue_desc'],
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          ),
                                        ],
                                      )
                                    ],
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
    );
  }
}