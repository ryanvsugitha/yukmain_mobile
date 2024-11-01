import 'package:flutter/material.dart';
import 'package:yuk_main/admin/admin_home.dart';
import 'package:yuk_main/admin/admin_profile.dart';
import 'package:yuk_main/admin/admin_venue_list.dart';

class AdminMain extends StatefulWidget {
  const AdminMain({super.key});

  @override
  State<AdminMain> createState() => _AdminMainState();
}

class _AdminMainState extends State<AdminMain> {

  int selectedNavBar = 0;

  changeSelectedNavBar(int index) {
    setState(() {
      selectedNavBar = index;
    });
  }

  final List pages = [
    const AdminHome(),
    const AdminVenueList(),
    const AdminProfile(),
  ];
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: pages.elementAt(selectedNavBar),
      bottomNavigationBar: BottomNavigationBar(
        items: const [
          BottomNavigationBarItem(
            label: 'Home',
            icon: Icon(Icons.home_outlined),
            activeIcon: Icon(Icons.home),
            tooltip: 'Main Menu'
          ),
          BottomNavigationBarItem(
            label: 'Venue',
            icon: Icon(Icons.sports_basketball_outlined),
            activeIcon: Icon(Icons.sports_basketball),
            tooltip: 'Your Venue List'
          ),
          BottomNavigationBarItem(
            label: 'Profile',
            icon: Icon(Icons.person_outline),
            activeIcon: Icon(Icons.person),
            tooltip: 'Profile Information'
          ),
        ],
        currentIndex: selectedNavBar,
        onTap: changeSelectedNavBar,
      ),
    );
  }
}