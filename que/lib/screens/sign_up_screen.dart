import 'dart:math' as math;

import 'package:firebase_auth/firebase_auth.dart' as firebaseAuth;
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:que/helpers/app_logs.dart';
import 'package:que/helpers/constants.dart';
import 'package:que/helpers/functions.dart';
import 'package:que/providers/auth_provider.dart';
import 'package:que/resources/assets_manager.dart';
import 'package:que/resources/style_manager.dart';
import 'package:que/screens/add_company_screen.dart';
import 'package:que/screens/sign_in_screen.dart';
import 'package:que/widgets/email_password_widget.dart';

class SignUpScreen extends StatefulWidget {
  static const routeName = '/sign-up';

  SignUpScreen({Key? key}) : super(key: key);

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey();
  final _authData = {
    'email': '',
    'password': '',
  };
  
  bool _isLoading = false;

  void _setPassword(String password) {
    _authData['password'] = password;
  }

  void _setEmail(String email) {
    _authData['email'] = email;
  }

  Future<void> _validateEmailPasswordAndAuthenticateUser(
      BuildContext context) async {
    if (!_formKey.currentState!.validate()) {
      return;
    }
    _formKey.currentState!.save();
    setState(() {
      _isLoading = true;
    });
    try {
      firebaseAuth.UserCredential userCredential = await firebaseAuth.FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: _authData['email']!,
        password: _authData['password']!,
      );
      Provider.of<AuthProvider>(context, listen: false)
          .setUser(userCredential.user!);
      getUserCollectionRef().doc(userCredential.user!.uid).set({
        'queUserId': userCredential.user!.uid,
        'email': userCredential.user!.email ?? '',
        'photoUrl': userCredential.user!.photoURL ?? '',
        'displayName': userCredential.user!.displayName ?? '',
        'mobileNo': userCredential.user!.phoneNumber ?? '',
        'company': '',
        'role': '',
        'color': (math.Random().nextDouble() * 0xFFFFFF).toInt(),
      });
      await firebaseAuth.FirebaseAuth.instance.currentUser!.reload();
      Provider.of<AuthProvider>(context, listen: false)
          .getUpdates();
      Navigator.of(context).pushReplacementNamed(AddCompanyScreen.routeName);
    } catch (error) {
      AppLogs().writeLog(Constants.SIGN_UP_SCREEN_TAG, error.toString());
      if (error.toString().contains('requires-recent-login')) {
        Navigator.of(context).pushReplacementNamed(SignInScreen.routeName);
      } else {
        _showErrorDialog(context, error.toString());
      }
    }
    setState(() {
      _isLoading = false;
    });
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
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: SingleChildScrollView(
            child: Container(
              height: MediaQuery.of(context).size.height * 1.0,
              child: Column(children: [
                Padding(
                  padding: const EdgeInsets.only(bottom: 24.0),
                  child: Stack(
                    alignment: AlignmentDirectional.center,
                    children: [
                      Positioned(
                        child: Container(
                          width: double.infinity,
                          height: MediaQuery.of(context).size.height > 800 ? 300 : 220,
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
                  child: EmailPasswordWidget(
                    setEmail: _setEmail, setPassword: _setPassword,
                    isSignUp: true,
                  ),
                ),
                const SizedBox(height: 8.0,),
                if (_isLoading)
                  Center(
                    child: CircularProgressIndicator(),
                  ),
                if (!_isLoading)
                  Container(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () => _validateEmailPasswordAndAuthenticateUser(context),
                      child: const Text('Sign Up'),
                    ),
                  ),
                const SizedBox(height: 8.0,),
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pushReplacementNamed(SignInScreen.routeName);
                  },
                  child: Text('Already a member? Sign-In', style: getRegularFont(color: Theme.of(context).primaryColor),),
                ),
                SizedBox(height: MediaQuery.of(context).size.height > 800 ? 48.0 : 24.0,),
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
}
