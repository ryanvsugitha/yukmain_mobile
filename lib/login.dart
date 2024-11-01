import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:yuk_main/admin/admin_main.dart';
import 'package:yuk_main/customer/customer_main.dart';
import 'package:yuk_main/register.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {

  bool showPassword = true;
  bool isLoading = false;

  late SharedPreferences pref;

  TextEditingController username = TextEditingController();
  TextEditingController password = TextEditingController();

  Future login() async {
    var url = Uri.parse('http://10.0.2.2/yuk_main/API/login.php');
    var request = await http.post(url, body: { 
      "username": username.text,
      "password": password.text,
    });
    return request.body;
  }

  Future setLogIn(String role, String username) async {
    pref = await SharedPreferences.getInstance();
    await pref.setBool('status', true);
    await pref.setString('role', role);
    await pref.setString('username', username);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(16.0),
          children: [
            Hero(
              tag: 'splashart', 
              child: Center(
                child: Image.asset(
                  'assets/splashart.png',
                  width: MediaQuery.of(context).size.width * 0.7,
                )
              )
            ),
            const SizedBox(
              height: 16,
            ), 
            const Text('Login',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(
              height: 16,
            ),
            TextFormField(
              controller: username,
              decoration: const InputDecoration(
                labelText: 'Username',
              ),
            ),
            const SizedBox(
              height: 16,
            ),
            TextFormField(
              controller: password,
              obscureText: showPassword,
              decoration: InputDecoration(
                labelText: 'Password',
                suffixIcon: IconButton(
                  splashRadius: 24,
                  onPressed: (){
                    setState(() {
                      showPassword = !showPassword;
                    });
                  },
                  icon: showPassword
                  ? const Icon(Icons.visibility_sharp)
                  : const Icon(Icons.visibility_off_sharp)
                ),
              ),
            ),
            const SizedBox(
              height: 16,
            ),
            InkWell(
              onTap: (){
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const RegisterPage(),)
                );
              },
              child: const Text(
                'Don\'t have an account? register instead', 
                textAlign: TextAlign.end,
              ),
            ),
            const SizedBox(
              height: 16,
            ),
            ElevatedButton(
              onPressed: isLoading
              ? null
              : (){
                if(username.text.isEmpty || password.text.isEmpty){
                  showDialog(
                    context: context, 
                    builder: (context) {
                      return AlertDialog(
                        actionsAlignment: MainAxisAlignment.center,
                        title: const Text('Please input fields!'),
                        actions: [
                          TextButton(
                            onPressed: (){
                              Navigator.pop(context);
                            }, 
                            child: const Text('Ok'),
                          )
                        ],
                      );
                    },
                  );
                } else {
                  setState(() {
                    isLoading = !isLoading;
                  });
                  login().then((value) {
                    setState(() {
                      isLoading = !isLoading;
                    });
                    Map result = jsonDecode(value) as Map;
                    showDialog(
                      context: context, 
                      builder: (context) {
                        return AlertDialog(
                          actionsAlignment: MainAxisAlignment.center,
                          title: Text(result['message']),
                          actions: [
                            TextButton(
                              onPressed: (){
                                if(result['status'] == '0'){
                                  Navigator.pop(context);
                                } else {
                                  setLogIn(result['role'], username.text);
                                  Navigator.pop(context);
                                  Navigator.pushReplacement(
                                    context, 
                                    MaterialPageRoute(builder: (context) => result['role'] == '0'
                                    ? const AdminMain()
                                    : const CustomerMain())
                                  );
                                }
                              }, 
                              child: const Text('Ok'),
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
              : const Text('Login')
            )
          ],
        ),
      ),
    );
  }
}