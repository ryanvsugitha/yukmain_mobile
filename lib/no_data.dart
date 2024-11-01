import 'package:flutter/material.dart';

class NoData extends StatelessWidget {
  const NoData({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
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
}