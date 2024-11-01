import 'package:flutter/material.dart';
import 'package:yuk_main/customer/customer_booking.dart';
import 'package:yuk_main/customer/customer_home.dart';
import 'package:yuk_main/customer/customer_profile.dart';

class CustomerMain extends StatefulWidget {
  const CustomerMain({super.key});

  @override
  State<CustomerMain> createState() => _CustomerMainState();
}

class _CustomerMainState extends State<CustomerMain> {
  int selectedNavBar = 0;

  changeSelectedNavBar(int index) {
    setState(() {
      selectedNavBar = index;
    });
  }

  final List pages = [
    const CustomerHome(),
    const CustomerBooking(),
    const CustomerProfile(),
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
            label: 'Bookings',
            icon: Icon(Icons.confirmation_number_outlined),
            activeIcon: Icon(Icons.confirmation_number),
            tooltip: 'Bookings Information'
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