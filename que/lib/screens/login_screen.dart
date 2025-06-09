import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart' as firebaseAuth;
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:que/helpers/app_logs.dart';
import 'package:que/helpers/constants.dart';
import 'package:que/providers/auth_provider.dart';
import 'package:que/resources/string_manager.dart';
import 'package:que/resources/style_manager.dart';
import 'package:que/screens/home/home_screen.dart';
import 'package:que/widgets/auth_mobile_mode_widget.dart';
import 'package:que/widgets/email_password_widget.dart';
import 'package:que/widgets/user_name_profile_pic_widget.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LoginScreen extends StatelessWidget {
  static const routeName = '/login-screen';

  final AuthType authType;
  final bool isNewUser;
  LoginScreen({
    Key? key,
    this.authType = AuthType.ADD_PHONE_AUTH,
    this.isNewUser = true,
  }) : super(key: key);

  final _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  Widget build(BuildContext context) {
    final deviceSize = MediaQuery.of(context).size;

    return Scaffold(
      key: _scaffoldKey,
      body: Stack(
        children: [
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.blueAccent, Colors.blueGrey],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                stops: [0, 1],
              ),
            ),
          ),
          SingleChildScrollView(
            child: Container(
              height: deviceSize.height,
              width: deviceSize.width,
              child: Column(
                children: [
                  Flexible(
                    child: Container(
                      margin: const EdgeInsets.only(
                        bottom: 20.0,
                      ),
                      padding: const EdgeInsets.symmetric(
                        vertical: 16.0,
                        horizontal: 16.0,
                      ),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(16.0),
                      ),
                      child: Text(
                        'Q',
                        style: getRegularFont(
                          color: Colors.black54,
                          fontSize: 50.0,
                        ),
                      ),
                    ),
                  ),
                  Flexible(
                    flex: deviceSize.width > 600 ? 2 : 1,
                    child: AuthCard(
                      authType: authType,
                      isNewUser: isNewUser,
                    ),
                  ),
                ],
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class AuthCard extends StatefulWidget {
  final AuthType authType;
  final bool isNewUser;

  const AuthCard({
    Key? key,
    required this.authType,
    required this.isNewUser,
  }) : super(key: key);

  @override
  State<AuthCard> createState() => _AuthCardState();
}

class _AuthCardState extends State<AuthCard>
    with SingleTickerProviderStateMixin {
  final GlobalKey<FormState> _formKey = GlobalKey();
  late AuthType _authType;
  late bool _isNewUser;
  Map<String, String> _authData = {
    'email': '',
    'password': '',
    'phone': '',
    'profilePicUrl': '',
    'name': '',
    'userId': '',
  };
  bool _isLoading = false;
  String mobileNo = '+91';
  String _verificationCode = '';
  String _smsCode = '';
  bool _passwordVisible = true;

  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _otpController = TextEditingController();
  final _nameController = TextEditingController();

  AnimationController? _animationController;

  void _sendVerificationCode() async {
    await firebaseAuth.FirebaseAuth.instance.verifyPhoneNumber(
      phoneNumber: _authData['phone']!,
      verificationCompleted: (credentials) async {
        // FirebaseAuth.instance.currentUser!.updatePhoneNumber(credentials);
        firebaseAuth.FirebaseAuth.instance.currentUser!.linkWithPhoneNumber(_authData['phone']!).then((value) {
          return value.confirm(_smsCode);
        });
      },
      verificationFailed: (exception) async {},
      codeSent: (verificationId, resendToken) {
        _verificationCode = verificationId;
      },
      codeAutoRetrievalTimeout: (verificationId) {},
    );
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
      firebaseAuth.UserCredential userCredential;
      if (_authType == AuthType.SIGN_IN_AUTH) {
        if (_isNewUser) {
          userCredential =
              await firebaseAuth.FirebaseAuth.instance.signInWithEmailAndPassword(
            email: _authData['email']!,
            password: _authData['password']!,
          );
          Provider.of<AuthProvider>(context, listen: false)
              .setUser(userCredential.user!);
          Navigator.of(context).pushReplacementNamed(HomeScreen.routeName);
        } else {
          await firebaseAuth.FirebaseAuth.instance.currentUser!
              .updateEmail(_authData['email']!);
          await firebaseAuth.FirebaseAuth.instance.currentUser!
              .updatePassword(_authData['password']!);
          await firebaseAuth.FirebaseAuth.instance.currentUser!.reload();
          Navigator.of(context).pushReplacementNamed(HomeScreen.routeName);
        }
      } else {
        userCredential =
            await firebaseAuth.FirebaseAuth.instance.createUserWithEmailAndPassword(
          email: _authData['email']!,
          password: _authData['password']!,
        );
        Provider.of<AuthProvider>(context, listen: false)
            .setUser(userCredential.user!);
      }
      Provider.of<AuthProvider>(context, listen: false)
          .getUpdates();
    } catch (error) {
      AppLogs().writeLog(Constants.LOGIN_SCREEN_TAG, error.toString());
      if (error.toString().contains('requires-recent-login')) {
        switchAuthType(AuthType.ADD_PHONE_AUTH);
      } else {
        _showErrorDialog(context, error.toString());
      }
    } finally {
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

  void _verifyOtpCode() {
    if (!_formKey.currentState!.validate()) {
      return;
    }
    _formKey.currentState!.save();
    // if (_otpController.text.length != 4) {
    //   return;
    // }
  }

  @override
  void initState() {
    super.initState();

    _authType = widget.authType;
    _isNewUser = widget.isNewUser;

    if (!_isNewUser) {
      final user = firebaseAuth.FirebaseAuth.instance.currentUser;
      if (user != null) {
        _authData = {
          'email': user.email ?? '',
          'password': '',
          'phone': user.phoneNumber ?? '',
          'profilePicUrl': user.photoURL ?? '',
          'name': user.displayName ?? '',
          'userId': user.uid,
        };
      }
    }

    _animationController = AnimationController(
      vsync: this,
      duration: Duration(
        milliseconds: 300,
      ),
    );

    Tween<Size>(
      begin: Size(double.infinity, 260),
      end: Size(double.infinity, 320),
    ).animate(CurvedAnimation(
      parent: _animationController!,
      curve: Curves.linear,
    ));

    Tween<Offset>(
      begin: Offset(0, -1.5),
      end: Offset(0.0, 0.0),
    ).animate(CurvedAnimation(
      parent: _animationController!,
      curve: Curves.linear,
    ));

    Tween(begin: 0.0, end: 1.0).animate(CurvedAnimation(
      parent: _animationController!,
      curve: Curves.easeIn,
    ));
  }

  @override
  Widget build(BuildContext context) {
    final deviceSize = MediaQuery.of(context).size;

    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.0)),
      elevation: 8.0,
      child: AnimatedContainer(
        duration: Duration(milliseconds: 300),
        curve: Curves.easeIn,
        width: deviceSize.width * 0.9,
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: _isLoading
              ? const Center(child: CircularProgressIndicator())
              : getAuthTypeWidget(context, _authType),
        ),
      ),
    );
  }

  void switchAuthType(AuthType authType) {
    setState(() {
      _authType = authType;
    });
  }

  void setMobileNo(String mobileNo) {
    _authData['phone'] = mobileNo;
  }

  void setEmail(String email) {
    _authData['email'] = email;
  }

  void setPassword(String password) {
    _authData['password'] = password;
  }

  void setName(String name) {
    _authData['name'] = name;
  }

  void setProfileUrl(String profilePicUrl) {
    _authData['profilePicUrl'] = profilePicUrl;
  }

  Uri? _imagePicked;
  final _imagePicker = ImagePicker();
  Future<void> pickAndStoreImage() async {
    final selectedImage =
        await _imagePicker.pickImage(source: ImageSource.gallery);
    if (selectedImage != null) {
      final imageFile = File(selectedImage.path);
      _imagePicked = imageFile.uri;
      _authData['profilePicUrl'] = _imagePicked!.path;
      try {
        FirebaseStorage.instance
            .ref('${ImageStorage.BASE_URL}/profilePics/${_authData['userId']}')
            .putFile(File(_imagePicked!.path))
            .then((image) async {
          _authData['profilePicUrl'] = await image.ref.getDownloadURL();
        });
      } catch (error) {
        AppLogs().writeLog(Constants.LOGIN_SCREEN_TAG, 'Firebase Storage Error: ${error.toString()}');
      }
      setState(() {});
    }
  }

  Widget getAuthTypeWidget(BuildContext context, AuthType authType) {
    switch (authType) {
      case AuthType.ADD_PHONE_AUTH:
        return AuthMobileModeWidget(
          setMobileNo: setMobileNo,
          switchAuthType: switchAuthType,
          sendVerificationCode: _sendVerificationCode,
          isNewUser: _isNewUser,
        );
      case AuthType.UPDATE_PHONE_AUTH:
        return Column(
          children: [
            Text(
              'Enter Verification Code',
              style: getRegularFont(color: Colors.black, fontSize: 20.0),
            ),
            const SizedBox(
              height: 12.0,
            ),
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    keyboardType: TextInputType.number,
                    controller: _otpController,
                    textInputAction: TextInputAction.done,
                    style:
                        getMediumFont(color: Theme.of(context).indicatorColor),
                    validator: (value) {
                      if (value!.isEmpty) {
                        return 'Enter OTP';
                      }
                      return null;
                    },
                    onSaved: (value) => _verifyOtpCode,
                    onChanged: (value) {
                      _smsCode = value;
                    },
                  ),
                ),
                Expanded(
                  child: TextButton(
                    onPressed: _authData['phone']!.length != 13
                        ? () {}
                        : () {
                            _sendVerificationCode();
                            switchAuthType(AuthType.UPDATE_PHONE_AUTH);
                          },
                    child: Text(
                      'Re-send Code',
                      style: getMediumFont(
                          color: Theme.of(context).primaryColor, fontSize: 16),
                    ),
                  ),
                ),
              ],
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
            ),
            const SizedBox(
              height: 12.0,
            ),
            ElevatedButton(
              onPressed: () async {
                setState(() {
                  _isLoading = true;
                });
                firebaseAuth.PhoneAuthCredential credentials = firebaseAuth.PhoneAuthProvider.credential(
                  verificationId: _verificationCode,
                  smsCode: _otpController.text,
                );
                final authProvider = Provider.of<AuthProvider>(context, listen: false);
                if (firebaseAuth.FirebaseAuth.instance.currentUser != null) {
                  firebaseAuth.FirebaseAuth.instance.currentUser!.updatePhoneNumber(
                      credentials
                  ).then((value) {
                    if (authProvider.displayName.isEmpty) {
                      switchAuthType(AuthType.ADD_USER_PROFILE);
                    }
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: const Text('Your mobile number registered.'),
                      ),
                    );
                  });
                }
                else {
                  firebaseAuth.UserCredential userCredentials = await firebaseAuth.FirebaseAuth.instance
                      .signInWithCredential(credentials);
                  if (userCredentials.additionalUserInfo!.isNewUser) {
                    _authData['userId'] = userCredentials.user!.uid;
                    switchAuthType(AuthType.ADD_USER_PROFILE);
                  }
                  Navigator.of(context).pushReplacementNamed(HomeScreen.routeName);
                }
                setState(() {
                  _isLoading = false;
                });
              },
              child: const Text('Verify'),
            ),
            const SizedBox(
              height: 12.0,
            ),
            Row(
              children: [
                Text(
                  'Login with email instead?',
                  style: getRegularFont(
                    color: Colors.black,
                    fontSize: 12.0,
                  ),
                ),
                const SizedBox(
                  width: 4.0,
                ),
                TextButton(
                  onPressed: () {
                    switchAuthType(AuthType.SIGN_IN_AUTH);
                  },
                  child: Text(
                    'Email',
                    style: getRegularFont(
                      color: Theme.of(context).primaryColor,
                      fontSize: 12.0,
                    ),
                  ),
                ),
              ],
            ),
          ],
          mainAxisAlignment: MainAxisAlignment.center,
        );
      case AuthType.SIGN_IN_AUTH:
        return Column(
          children: [
            EmailPasswordWidget(
              setEmail: setEmail,
              setPassword: setPassword,
            ),
            const SizedBox(
              height: 12.0,
            ),
            ElevatedButton(
              onPressed: () =>
                  _validateEmailPasswordAndAuthenticateUser(context),
              child: _isNewUser
                  ? const Text('Login')
                  : const Text('Add Email and Set Password'),
            ),
            const SizedBox(
              height: 12.0,
            ),
            if (_isNewUser)
              Row(
                children: [
                  Text(
                    'Not a member?',
                    style: getMediumFont(color: Colors.black, fontSize: 14.0),
                  ),
                  TextButton(
                    onPressed: () {
                      switchAuthType(AuthType.SIGN_UP_AUTH);
                    },
                    child: Text(
                      'Sign Up',
                      style: getMediumFont(
                          color: Theme.of(context).primaryColor,
                          fontSize: 14.0),
                    ),
                  ),
                ],
              ),
            if (_isNewUser)
              Row(
                children: [
                  Text(
                    'OR Sign-In with ',
                    style: getMediumFont(color: Colors.black, fontSize: 14.0),
                  ),
                  TextButton(
                    onPressed: () {
                      switchAuthType(AuthType.ADD_PHONE_AUTH);
                    },
                    child: Text(
                      'Mobile No',
                      style: getMediumFont(
                          color: Theme.of(context).primaryColor,
                          fontSize: 14.0),
                    ),
                  ),
                ],
              ),
          ],
        );
      case AuthType.SIGN_UP_AUTH:
        return Column(
          children: [
            EmailPasswordWidget(
              setEmail: setEmail,
              setPassword: setPassword,
            ),
            const SizedBox(
              height: 12.0,
            ),
            TextFormField(
              initialValue: '',
              obscureText: _passwordVisible,
              textInputAction: TextInputAction.done,
              style: getMediumFont(color: Theme.of(context).indicatorColor),
              decoration: InputDecoration(
                labelText: 'Confirm Password',
                suffixIcon: IconButton(
                  onPressed: () {
                    setState(() {
                      _passwordVisible = !_passwordVisible;
                    });
                  },
                  icon: Icon(
                    !_passwordVisible ? Icons.visibility : Icons.visibility_off,
                  ),
                ),
              ),
              validator: (value) {
                if (_authData['password'] != value!) {
                  return 'Password does not match.';
                }
                return null;
              },
              onSaved: (value) {
                _authData['password'] = value!;
              },
            ),
            const SizedBox(
              height: 12.0,
            ),
            ElevatedButton(
              onPressed: () =>
                  _validateEmailPasswordAndAuthenticateUser(context),
              child: const Text('Sign Up'),
            ),
            const SizedBox(
              height: 12.0,
            ),
            Row(
              children: [
                Text(
                  'Already a member?',
                  style: getMediumFont(color: Colors.black, fontSize: 14.0),
                ),
                TextButton(
                  onPressed: () {
                    switchAuthType(AuthType.SIGN_IN_AUTH);
                  },
                  child: Text(
                    'Sign-In',
                    style: getMediumFont(
                        color: Theme.of(context).primaryColor, fontSize: 14.0),
                  ),
                ),
              ],
            ),
          ],
        );
      case AuthType.ADD_USER_PROFILE:
        return Column(
          children: [
            if (!_isNewUser)
              UserNameProfilePicWidget(
                userId: _authData['userId']!,
                setName: setName,
                setProfilePicUrl: setProfileUrl,
              ),
            const SizedBox(height: 12.0),
            // if (user.email == null || user.email!.isEmpty)
            //   EmailPasswordWidget(
            //     setEmail: setEmail,
            //     setPassword: setPassword,
            //   ),
            // if (user.phoneNumber == null || user.phoneNumber!.isEmpty)
            //   TextFormField(
            //     keyboardType: TextInputType.number,
            //     decoration: InputDecoration(
            //       labelText: 'Mobile No',
            //     ),
            //     validator: (value) {
            //       if (_authData['phone']!.isEmpty) {
            //         return 'Enter Mobile No';
            //       } else if (_authData['phone'] != 13) {
            //         return 'Enter valid Mobile No';
            //       }
            //       return null;
            //     },
            //     onChanged: (value) {
            //       setMobileNo(value);
            //     },
            //   ),
            const Spacer(),
            Container(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () async {
                  final user = firebaseAuth.FirebaseAuth.instance.currentUser!;
                  try {
                    setState(() {
                      _isLoading = true;
                    });
                    await user.updateDisplayName(_authData['name']);
                    if (user.email == null || user.email!.isEmpty) {
                      await user.updateEmail(_authData['email']!);
                      await user.updatePassword(_authData['password']!);
                    }
                    await user.updatePhotoURL(_authData['profilePicUrl']);
                    await user.reload();
                    setState(() {
                      _isLoading = false;
                    });
                    // Navigator.of(context)
                    //     .pushReplacementNamed(HomeScreen.routeName);
                    Provider.of<AuthProvider>(context, listen: false).getUpdates();
                  } catch (error) {
                    AppLogs().writeLog(Constants.LOGIN_SCREEN_TAG, error.toString());
                  }
                },
                child: const Text('Update'),
              ),
            ),
          ],
        );
      case AuthType.VERIFY_EMAIL:
        final user = Provider.of<AuthProvider>(context, listen: false).user;
        return Column(
          children: [
            Text(
              'Please your email',
              style: getRegularFont(
                color: Colors.black,
                fontSize: 18.0,
              ),
            ),
            const SizedBox(
              height: 20.0,
            ),
            Text(
              user.email ?? '',
              style: getBoldFont(
                color: Colors.black,
                fontSize: 15.0,
              ),
            ),
            const Spacer(),
            Row(
              children: [
                TextButton(
                  onPressed: () {
                    Provider.of<AuthProvider>(context, listen: false)
                        .user
                        .sendEmailVerification();
                    // ActionCodeSettings(
                    //   url: 'auth.example.com/',
                    //   dynamicLinkDomain: 'auth.example.com',
                    //   androidPackageName: 'com.vedantbhavsar1997.que.que',
                    //   androidInstallApp: true,
                    //   androidMinimumVersion: '12',
                    //   iOSBundleId: 'com.example.ios',
                    //   handleCodeInApp: true,
                    // )
                    Provider.of<AuthProvider>(context, listen: false)
                        .user
                        .reload();
                    Navigator.of(context)
                        .pushReplacementNamed(HomeScreen.routeName);
                  },
                  child: Text(
                    'Verify',
                    style: getMediumFont(
                      color: Theme.of(context).primaryColor,
                      fontSize: 18.0,
                    ),
                  ),
                ),
                TextButton(
                  onPressed: () async {
                    final pref = await SharedPreferences.getInstance();
                    await pref.setBool(PrefStrings.EMAIL_VERIFY_SKIP, true);
                    Navigator.of(context)
                        .pushReplacementNamed(HomeScreen.routeName);
                  },
                  child: Text(
                    'Skip',
                    style: getMediumFont(
                      color: Theme.of(context).primaryColor,
                      fontSize: 18.0,
                    ),
                  ),
                ),
              ],
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
            ),
          ],
        );
      default:
        return Container();
    }
  }

  @override
  void dispose() {
    _animationController!.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _nameController.dispose();
    _otpController.dispose();
    super.dispose();
  }
}

enum AuthType {
  SIGN_IN_AUTH,
  SIGN_UP_AUTH,
  ADD_PHONE_AUTH,
  UPDATE_PHONE_AUTH,
  ADD_USER_PROFILE,
  VERIFY_EMAIL,
}
