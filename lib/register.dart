import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:yuk_main/login.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final _formKey = GlobalKey<FormState>();

  TextEditingController username = TextEditingController();
  TextEditingController password = TextEditingController();
  TextEditingController checkPassword = TextEditingController();

  bool showPassword = true;

  bool isLoading = false;

  Future register() async {
    var url = Uri.parse('http://10.0.2.2/yuk_main/API/register.php');
    var request = await http.post(url, body: { 
      "username": username.text,
      "password": password.text,
    });
    return request.body;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Form(
          key: _formKey,
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
              const Text('Register',
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
                obscureText: true,
                controller: password,
                decoration: const InputDecoration(
                  labelText: 'Password',
                ),
              ),
              const SizedBox(
                height: 16,
              ),
              TextFormField(
                obscureText: showPassword,
                controller: checkPassword,
                decoration: InputDecoration(
                  labelText: 'Reenter Password',
                  suffixIcon: IconButton(
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
                  Navigator.pop(context);
                },
                child: const Text(
                  'Have an account? login instead', 
                  textAlign: TextAlign.end,
                ),
              ),
              const SizedBox(
                height: 16,
              ),
              ElevatedButton(
                onPressed: (isLoading) 
                  ? null 
                  : (){
                  if(username.text.isEmpty || password.text.isEmpty || checkPassword.text.isEmpty){
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
                  } else if(password.text != checkPassword.text){
                    showDialog(
                      context: context, 
                      builder: (context) {
                        return AlertDialog(
                          actionsAlignment: MainAxisAlignment.center,
                          title: const Text('Password does not match!'),
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
                    register().then((value){
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
                                    Navigator.pop(context);
                                    Navigator.pushReplacement(
                                      context, 
                                      MaterialPageRoute(builder: (context) => const LoginPage(),)
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
                child: (isLoading) 
                ? const SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(),
                  )
                : const Text('Register'),
              )
            ],
          ),
        ),
      ),
    );
  }
}