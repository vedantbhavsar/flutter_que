// ignore_for_file: must_be_immutable

import 'package:firebase_auth/firebase_auth.dart' as firebaseAuth;
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:que/helpers/app_logs.dart';
import 'package:que/helpers/constants.dart';
import 'package:que/providers/auth_provider.dart';
import 'package:que/resources/assets_manager.dart';
import 'package:que/resources/style_manager.dart';
import 'package:que/screens/home/home_screen.dart';
import 'package:que/screens/sign_up_screen.dart';
import 'package:que/widgets/email_password_widget.dart';

class SignInScreen extends StatefulWidget {
  static const routeName = '/sign-in';

  SignInScreen({Key? key}) : super(key: key);

  @override
  State<SignInScreen> createState() => _SignInScreenState();
}

class _SignInScreenState extends State<SignInScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey();

  final _authData = {
    'email': '',
    'password': '',
  };

  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    // WidgetsBinding.instance!.addPostFrameCallback((timeStamp) {
    //   final user = FirebaseAuth.instance.currentUser;
    //   if (user != null) {
    //     Navigator.of(context).pushReplacementNamed(HomeScreen.routeName);
    //   }
    // });
  }

  void _setPassword(String password) {
    _authData['password'] = password;
  }

  void _setEmail(String email) {
    _authData['email'] = email;
  }

  Future<void> _validateEmailPasswordAndAuthenticateUser(BuildContext context) async {
    if (!_formKey.currentState!.validate()) {
      return;
    }
    _formKey.currentState!.save();
    setState(() {
      _isLoading = true;
    });
    try {
      firebaseAuth.FirebaseAuth.instance.signInWithEmailAndPassword(
        email: _authData['email']!,
        password: _authData['password']!,
      ).then((userCredential) async {
        Provider.of<AuthProvider>(context, listen: false)
            .setUser(userCredential.user!);
        await Provider.of<AuthProvider>(context, listen: false)
            .addNewUser();
        Navigator.of(context).pushReplacementNamed(HomeScreen.routeName);
      }).catchError((error) {
        setState(() {
          _isLoading = false;
        });
        _showErrorDialog(context, error.toString());
        AppLogs().writeLog(Constants.SIGN_IN_SCREEN_TAG, error.toString());
      });
    } catch (error) {
      AppLogs().writeLog(Constants.SIGN_IN_SCREEN_TAG, 'Authentication Error: ${error.toString()}');
      if (error.toString().contains('requires-recent-login')) {
        Navigator.of(context).pushReplacementNamed(SignInScreen.routeName);
      } else {
        _showErrorDialog(context, error.toString());
      }
      setState(() {
        _isLoading = false;
      });
    }
  }

  _showErrorDialog(BuildContext context, String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Error!'),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: const Text('Ok'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: SingleChildScrollView(
            child: Container(
              height: MediaQuery.of(context).size.height * 0.99,
              child: Column(children: [
                Padding(
                  padding: const EdgeInsets.only(bottom: 24.0),
                  child: Stack(
                    alignment: AlignmentDirectional.center,
                    children: [
                      Positioned(
                        child: Container(
                          child: Image.asset('${ImageAssets.splashLogo}',),
                        ),
                      ),
                      Positioned(
                        bottom: 24.0,
                        child: Text(
                          'Que',
                          style: TextStyle(
                            letterSpacing: 16.0,
                            fontWeight: FontWeight.bold,
                            fontSize: 36.0,
                            color: Colors.black,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Form(
                  key: _formKey,
                  child: EmailPasswordWidget(setEmail: _setEmail, setPassword: _setPassword,),
                ),
                const SizedBox(height: 8.0,),
                if (_isLoading)
                  Container(child: Center(child: CircularProgressIndicator(),),),
                if (!_isLoading)
                  Container(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () => _validateEmailPasswordAndAuthenticateUser(context),
                      child: const Text('Sign-In'),
                    ),
                  ),
                const SizedBox(height: 8.0,),
                Row(children: [
                  TextButton(
                    onPressed: () {
                      // TODO: Forgot password
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: const Text('Feature for next release', textAlign: TextAlign.center,),
                        ),
                      );
                    },
                    child: Text('Forgot Password?', style: getRegularFont(color: Theme.of(context).primaryColor),),
                  ),
                  TextButton(
                    onPressed: () {
                      Navigator.of(context).pushReplacementNamed(SignUpScreen.routeName);
                    },
                    child: Text('Sign Up', style: getRegularFont(color: Theme.of(context).primaryColor),),
                  ),
                ], mainAxisAlignment: MainAxisAlignment.spaceBetween,),
                const SizedBox(height: 48.0,),
                Text(
                  'by',
                  style: getSemiBoldFont(color: Colors.black, fontSize: 24.0),
                ),
                Container(
                  decoration: BoxDecoration(
                    color: Colors.red[600],
                    borderRadius: BorderRadius.all(Radius.elliptical(84.0, 32.0)),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: Text(
                      'Gurukrupa',
                      style: getSemiBoldFont(color: Colors.white, fontSize: 24.0),
                    ),
                  ),
                ),
              ],),
            ),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    super.dispose();
  }
}
