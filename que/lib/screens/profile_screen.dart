import 'package:firebase_auth/firebase_auth.dart' as firebaseAuth;
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:que/helpers/app_logs.dart';
import 'package:que/helpers/constants.dart';
import 'package:que/helpers/functions.dart';
import 'package:que/models/que_user.dart';
import 'package:que/providers/auth_provider.dart';
import 'package:que/providers/connection_provider.dart';
import 'package:que/resources/style_manager.dart';
import 'package:que/widgets/no_wifi_widget.dart';
import 'package:que/widgets/user_name_profile_pic_widget.dart';

class ProfileScreen extends StatefulWidget {
  static const String routeName = '/profile';

  const ProfileScreen({Key? key}) : super(key: key);

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _emailFocusNode = FocusNode();
  final _mobileFocusNode = FocusNode();
  String name = '';
  String profilePicUrl = '';
  String email = '';
  String mobileNo = '';
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
  }

  void setName(String name) {
    this.name = name;
  }

  void setProfileUrl(String profilePicUrl) {
    this.profilePicUrl = profilePicUrl;
  }

  Future<bool> _onBackPress() async {
    return true;
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final GlobalKey<FormState> _formKey = GlobalKey();
    final isConnected = Provider.of<ConnectionProvider>(context).isConnected;

    if (!isConnected) {
      return const NoWifiWidget();
    }

    return WillPopScope(
      onWillPop: _onBackPress,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Set Profile'),
        ),
        body: Form(
          key: _formKey,
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: _isLoading ? const Center(child: CircularProgressIndicator(),) : Column(
                children: [
                  const SizedBox(height: 12.0,),
                  UserNameProfilePicWidget(
                    userId: authProvider.user.uid,
                    setName: setName,
                    setProfilePicUrl: setProfileUrl,
                    imageUrl: authProvider.photoURL,
                    displayName: authProvider.displayName,
                  ),
                  const SizedBox(height: 24.0,),
                  if (authProvider.phoneNumber.isNotEmpty)
                    Container(
                      alignment: Alignment.centerLeft,
                      child: Text('Mobile No: ${authProvider.phoneNumber}', style: getRegularFont(color: Colors.black, fontSize: 16.0),),
                    ),
                  const SizedBox(height: 24.0,),
                  Container(
                    alignment: Alignment.centerLeft,
                    child: Text('Company: ${authProvider.company}', style: getSemiBoldFont(color: Colors.black, fontSize: 16.0),),
                  ),
                  const SizedBox(height: 24.0,),
                  Container(
                    alignment: Alignment.centerLeft,
                    child: Text('Role: ${authProvider.queUser!.role}', style: getSemiBoldFont(color: Colors.black, fontSize: 16.0),),
                  ),
                  if (authProvider.email.isNotEmpty || authProvider.user.emailVerified)
                    Column(children: [
                      const SizedBox(height: 24.0,),
                      Container(
                          child: Text('Email', style: getSemiBoldFont(color: Colors.black, fontSize: 16.0),)
                      ),
                      Row(children: [
                        Expanded(
                          child: Container(
                              child: Text(authProvider.email, style: getSemiBoldFont(color: Colors.black, fontSize: 16.0),)
                          ),
                        ),
                        if (!authProvider.verificationEmailSent && !authProvider.user.emailVerified)
                          TextButton(
                            onPressed: () {
                              firebaseAuth.FirebaseAuth.instance.currentUser!.sendEmailVerification().then((value) {
                                authProvider.setVerificationEmailSent(true);
                                ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(content: const Text('Verification mail sent.'))
                                );
                              }).catchError((error) {
                                AppLogs().writeLog(Constants.PROFILE_SCREEN_TAG, 'Send Email Verification Exception: ${error.toString()}');
                                authProvider.setVerificationEmailSent(false);
                                ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(content: const Text('Verification mail was not sent.'))
                                );
                              });
                            },
                            child: Text('Verify', style: getBoldFont(color: Theme.of(context).primaryColor, fontSize: 18.0),),
                          ),
                      ],),
                    ], crossAxisAlignment: CrossAxisAlignment.start,),
                  const Spacer(),
                  Container(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _isLoading ? () {} : () async {
                        final user = firebaseAuth.FirebaseAuth.instance.currentUser!;
                        try {
                          setState(() {
                            _isLoading = true;
                          });
                          await user.updateDisplayName(name.isNotEmpty ? name : authProvider.displayName);
                          await user.updatePhotoURL(profilePicUrl);
                          getUserCollectionRef().doc(user.uid)
                              .withConverter(fromFirestore: QueUser.fromFirestore, toFirestore: (QueUser queUser, options) => queUser.toFirestore())
                              .update({
                            QueUserFields.photoUrl.name: profilePicUrl,
                            QueUserFields.displayName.name: name.isNotEmpty ? name : authProvider.displayName,
                          });
                          await user.reload();
                          authProvider.setUser(firebaseAuth.FirebaseAuth.instance.currentUser!);
                          setState(() {
                            _isLoading = false;
                          });
                        } catch (error) {
                          AppLogs().writeLog(Constants.PROFILE_SCREEN_TAG, error.toString());
                        }
                      },
                      child: _isLoading ? const Center(child: CircularProgressIndicator(),)
                          : const Text('Update'),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _emailFocusNode.dispose();
    _mobileFocusNode.dispose();
    super.dispose();
  }
}
