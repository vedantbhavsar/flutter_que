import 'dart:math' as math;

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:que/helpers/app_logs.dart';
import 'package:que/helpers/constants.dart';
import 'package:que/helpers/db_helper.dart';
import 'package:que/helpers/functions.dart';
import 'package:que/models/que_user.dart';
import 'package:que/resources/string_manager.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthProvider with ChangeNotifier {
  static const AUTH_DATA = 'AUTH_DATA';

  User? _user;
  bool _verificationEmailSent = false;
  String _company = '';
  String _role = '';
  QueUser? queUser;
  late SharedPreferences _sharedPreferences;

  AuthProvider(SharedPreferences sharedPreferences) {
    this._sharedPreferences = sharedPreferences;
  }

  SharedPreferences get sharedPreferences => _sharedPreferences;

  void getUpdates() {
    notifyListeners();
  }

  void setUser(User user) {
    _user = user;
  }

  void reset() {
    queUser = null;
    _company = '';
    _role = '';
    _user = null;
    _sharedPreferences.setString(PrefStrings.QUE_USER_COMPANY, '');
  }

  User get user {
    return _user!;
  }

  String get displayName {
    if (_user == null) {
      return '';
    }
    if (_user!.displayName == null && queUser == null) {
      return '';
    }
    else if (_user!.displayName == null && queUser != null) {
      return queUser!.displayName;
    }
    else if (_user!.displayName!.isEmpty && queUser != null) {
      return queUser!.displayName;
    }
    else if (queUser != null) {
      return queUser!.displayName;
    }
    else {
      final q = DbHelper.getDbHelper.getQueUser(user.uid);
      if (q == null) {
        return '';
      }
      return q.displayName;
    }
  }

  String get photoURL {
    if (_user == null) {
      return '';
    }
    if (_user!.photoURL == null && queUser == null) {
      return '';
    }
    else if (_user!.photoURL == null && queUser != null) {
      return queUser!.photoUrl;
    }
    else if (_user!.photoURL!.isEmpty && queUser != null) {
      return queUser!.photoUrl;
    }
    else if (queUser != null) {
      return queUser!.photoUrl;
    }
    else {
      final q = DbHelper.getDbHelper.getQueUser(user.uid);
      if (q == null) {
        return '';
      }
      return q.photoUrl;
    }
  }

  String get email {
    if (_user == null) {
      return '';
    }
    return _user!.email ?? '';
  }

  String get phoneNumber {
    if (_user == null) {
      return '';
    }
    return _user!.phoneNumber ?? '';
  }

  bool get verificationEmailSent {
    // notifyListeners();
    return _verificationEmailSent;
  }

  String get company {
    if (_company.isEmpty) {
      final q = DbHelper.getDbHelper.getQueUser(user.uid);
      if (q == null) {
        return '';
      }
      return q.company;
    }
    return _company;
  }

  String get role {
    return _role;
  }

  void setVerificationEmailSent(bool isSent) {
    this._verificationEmailSent = isSent;
    notifyListeners();
  }
  
  Future<void> addNewUser() async {
    try {
      final docRef = await getUserCollectionRef().doc(_user!.uid).get();
      if (!docRef.exists) {
        queUser = QueUser(
          queUserId: docRef.id,
          email: email,
          displayName: displayName,
          mobileNo: phoneNumber,
          photoUrl: photoURL,
          color: (math.Random().nextDouble() * 0xFFFFFF).toInt(),
          company: '', role: '',
        );
      }
      else {
        queUser = QueUser(
          queUserId: docRef.data()?['queUserId'],
          email: docRef.data()?['email'],
          displayName: docRef.data()?['displayName'],
          mobileNo: docRef.data()?['mobileNo'],
          photoUrl: docRef.data()?['photoUrl'],
          color: docRef.data()?['color'],
          company: docRef.data()?['company'],
          role: docRef.data()?['role'],
        );
      }
      _company = docRef.data()?['company'];
      _role = docRef.data()?['role'];
      AppLogs().writeLog(Constants.AUTH_PROVIDER_TAG, '${queUser.toString()}');
      getUserCollectionRef().doc(_user!.uid)
          .withConverter(fromFirestore: QueUser.fromFirestore, toFirestore: (QueUser queUser, options) => queUser.toFirestore())
          .set(queUser!);
      _sharedPreferences.setString(PrefStrings.QUE_USER_COMPANY, queUser!.company);
      DbHelper.getDbHelper.insertQueUser(queUser!);
    }
    catch (error) {
      AppLogs().writeLog(Constants.AUTH_PROVIDER_TAG, 'Add new user exception: ${error.toString()}');
    }
  }
}
