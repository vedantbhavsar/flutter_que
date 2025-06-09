import 'package:firebase_auth/firebase_auth.dart' as firebaseAuth;
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:que/providers/auth_provider.dart';
import 'package:que/providers/task_provider.dart';
import 'package:que/resources/string_manager.dart';
import 'package:que/resources/style_manager.dart';
import 'package:que/screens/profile_screen.dart';
import 'package:que/screens/sign_in_screen.dart';

class AppDrawer extends StatelessWidget {
  const AppDrawer({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final appName = authProvider.sharedPreferences.getString(PrefStrings.APP_NAME);
    final appVersion = authProvider.sharedPreferences.getString(PrefStrings.APP_VERSION);

    return SafeArea(
      child: Drawer(
        child: Column(children: [
          AppBar(
            leading: authProvider.photoURL.isNotEmpty ? Padding(
              padding: const EdgeInsets.all(4.0),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(30.0),
                child: Image.network(authProvider.photoURL, fit: BoxFit.cover,),
              ),
            ) : Container(),
            title: Text(firebaseAuth.FirebaseAuth.instance.currentUser!.displayName ?? 'Welcome'),
          ),
          ListTile(
            leading: Icon(Icons.account_circle_rounded, color: Colors.black,),
            title: Text('Profile', style: getSemiBoldFont(color: Colors.black, fontSize: 16.0),),
            onTap: () {
              Navigator.of(context).pop();
              Navigator.of(context).pushNamed(ProfileScreen.routeName);
            },
          ),
          Divider(color: Colors.black,),
          ListTile(
            leading: Icon(Icons.logout,color: Colors.black,),
            title: Text('Logout', style: getSemiBoldFont(color: Colors.black, fontSize: 16.0),),
            onTap: () async {
              await firebaseAuth.FirebaseAuth.instance.signOut();
              Provider.of<AuthProvider>(context, listen: false).reset();
              Provider.of<TaskProvider>(context, listen: false).reset();
              Navigator.of(context).pop();
              Navigator.of(context).pushReplacementNamed(SignInScreen.routeName);
            },
          ),
          Divider(color: Colors.black,),
          const Spacer(),
          Text('${appName!.toUpperCase()} $appVersion',
            style: getMediumFont(
              color: Theme.of(context).primaryColor,
              fontSize: 20.0,
            ),
          ),
          const SizedBox(height: 12.0,),
        ],),
      ),
    );
  }
}