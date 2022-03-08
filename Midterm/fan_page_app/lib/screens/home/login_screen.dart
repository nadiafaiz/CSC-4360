import 'package:cloud_functions/cloud_functions.dart';
import 'package:email_validator/email_validator.dart';
import 'package:fan_page_app/screens/screens.dart';
import 'package:fan_page_app/theme.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:stream_chat_flutter_core/stream_chat_flutter_core.dart'
    as stream;
import 'package:stream_chat_flutter_core/stream_chat_flutter_core.dart';

class LoginScreen extends StatefulWidget {
  static Route route() => MaterialPageRoute(
        builder: (context) => const LoginScreen(),
      );
  const LoginScreen({Key? key}) : super(key: key);

  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  // Form key
  final _formKey = GlobalKey<FormState>();

  // Firebase auth
  final _auth = FirebaseAuth.instance;
  final functions = FirebaseFunctions.instance;

  // Login input controllers
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    // Email input field
    final emailField = TextFormField(
      autofocus: false,
      controller: emailController,
      keyboardType: TextInputType.emailAddress,
      validator: (value) {
        if (value!.isEmpty) {
          return ("Email is required to log in");
        }

        if (!EmailValidator.validate(value)) {
          return ("Please enter a valid email address");
        }
      },
      onSaved: (value) {
        emailController.text = value!;
      },
      textInputAction: TextInputAction.next,
      decoration: InputDecoration(
        prefixIcon: const Icon(Icons.mail),
        contentPadding: const EdgeInsets.fromLTRB(20, 15, 20, 15),
        hintText: "Email",
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
        ),
      ),
    );

    // Password input field
    final passwordField = TextFormField(
      autofocus: false,
      controller: passwordController,
      validator: (value) {
        if (value!.isEmpty) {
          return ("Password is required to log in");
        }
      },
      onSaved: (value) {
        passwordController.text = value!;
      },
      obscureText: true,
      textInputAction: TextInputAction.done,
      decoration: InputDecoration(
        prefixIcon: const Icon(Icons.vpn_key),
        contentPadding: const EdgeInsets.fromLTRB(20, 15, 20, 15),
        hintText: "Password",
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
        ),
      ),
    );

    // Login button
    final loginButton = Material(
      elevation: 5,
      borderRadius: BorderRadius.circular(30),
      color: Colors.blueAccent,
      child: MaterialButton(
        padding: const EdgeInsets.fromLTRB(20, 15, 20, 15),
        minWidth: MediaQuery.of(context).size.width,
        onPressed: () => {
          _logIn(emailController.text, passwordController.text),
        },
        child: const Text(
          "Login",
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );

    return Scaffold(
      body: Center(
        child: SingleChildScrollView(
          child: Container(
            padding: const EdgeInsets.all(48.0),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  SizedBox(
                    height: 200,
                    child: Image.asset(
                      "assets/home.png",
                      fit: BoxFit.contain,
                    ),
                  ),
                  const SizedBox(height: 30),
                  emailField,
                  const SizedBox(height: 30),
                  passwordField,
                  const SizedBox(height: 30),
                  loginButton,
                  const SizedBox(height: 30),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      const Text("Don't have an account? "),
                      GestureDetector(
                        onTap: () => {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) =>
                                    const RegistrationScreen(),
                              )),
                        },
                        child: const Text("Create one here!",
                            style: TextStyle(
                              color: Colors.blueAccent,
                              fontWeight: FontWeight.bold,
                              fontSize: 15,
                            )),
                      )
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _logIn(final String email, final String password) async {
    if (_formKey.currentState!.validate()) {
      await _auth
          .signInWithEmailAndPassword(email: email, password: password)
          .then(
            (userCredential) async => {
              Fluttertoast.showToast(msg: "Login successful!"),
              await _getStreamUser(userCredential),
              await Navigator.of(context).pushReplacement(HomeScreen.route),
            },
          )
          .catchError(
            (error) => {
              Fluttertoast.showToast(
                  msg:
                      "That account does not exist. Enter a different account or create a new one."),
            },
          );
    }
  }

  _getStreamUser(UserCredential userCredential) async {
    final callable = functions.httpsCallable('getStreamUserToken');
    final results = await callable();

    final client = StreamChatCore.of(context).client;
    await client.connectUser(
      stream.User(id: userCredential.user!.uid),
      results.data,
    );
  }
}
