// ignore_for_file: must_be_immutable

import 'package:flutter/material.dart';
import 'package:que/resources/style_manager.dart';
import 'package:que/screens/login_screen.dart';

class AuthMobileModeWidget extends StatefulWidget {
  final Function setMobileNo;
  final Function switchAuthType;
  final Function sendVerificationCode;
  bool isNewUser;

  AuthMobileModeWidget({
    Key? key,
    required this.setMobileNo,
    required this.switchAuthType,
    required this.sendVerificationCode,
    this.isNewUser = false,
  }) : super(key: key);

  @override
  State<AuthMobileModeWidget> createState() => _AuthMobileModeWidgetState();
}

class _AuthMobileModeWidgetState extends State<AuthMobileModeWidget> {
  final _phoneFocusNode1 = FocusNode();
  final _phoneFocusNode2 = FocusNode();
  final _phoneFocusNode3 = FocusNode();
  final _phoneFocusNode4 = FocusNode();
  final _phoneFocusNode5 = FocusNode();
  final _phoneFocusNode6 = FocusNode();
  final _phoneFocusNode7 = FocusNode();
  final _phoneFocusNode8 = FocusNode();
  final _phoneFocusNode9 = FocusNode();
  final _phoneFocusNode10 = FocusNode();

  String mobileNo = '+91';

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        children: [
          Text(
            'Enter Mobile No',
            style: getRegularFont(
                color: Theme.of(context).primaryColor, fontSize: 12.0),
          ),
          const SizedBox(
            height: 12.0,
          ),
          Row(
            children: [
              Container(
                width: 30.0,
                child: TextFormField(
                  focusNode: _phoneFocusNode1,
                  keyboardType: TextInputType.number,
                  textInputAction: TextInputAction.next,
                  style: getMediumFont(color: Theme.of(context).indicatorColor),
                  decoration: InputDecoration(
                    enabledBorder: UnderlineInputBorder(
                      borderSide: BorderSide(width: 0.0),
                    ),
                  ),
                  validator: (value) {
                    if (value!.isEmpty) {
                      return 'Enter valid mobile number.';
                    }
                    return null;
                  },
                  onChanged: (value) {
                    if (value.length == 1) {
                      FocusScope.of(context).requestFocus(_phoneFocusNode2);
                      mobileNo += value;
                    }
                  },
                  onFieldSubmitted: (value) {
                    FocusScope.of(context).requestFocus(_phoneFocusNode2);
                  },
                ),
              ),
              Container(
                width: 30.0,
                child: TextFormField(
                  focusNode: _phoneFocusNode2,
                  keyboardType: TextInputType.number,
                  textInputAction: TextInputAction.next,
                  style: getMediumFont(color: Theme.of(context).indicatorColor),
                  decoration: InputDecoration(
                    enabledBorder: UnderlineInputBorder(
                      borderSide: BorderSide(width: 0.0),
                    ),
                  ),
                  validator: (value) {
                    if (value!.isEmpty) {
                      return 'Enter valid mobile number.';
                    }
                    return null;
                  },
                  onFieldSubmitted: (value) {
                    FocusScope.of(context).requestFocus(_phoneFocusNode3);
                  },
                  onChanged: (value) {
                    if (value.length == 1) {
                      mobileNo += value;
                      FocusScope.of(context).requestFocus(_phoneFocusNode3);
                    }
                  },
                ),
              ),
              Container(
                width: 30.0,
                child: TextFormField(
                  focusNode: _phoneFocusNode3,
                  keyboardType: TextInputType.number,
                  textInputAction: TextInputAction.next,
                  style: getMediumFont(color: Theme.of(context).indicatorColor),
                  decoration: InputDecoration(
                    enabledBorder: UnderlineInputBorder(
                      borderSide: BorderSide(width: 0.0),
                    ),
                  ),
                  validator: (value) {
                    if (value!.isEmpty) {
                      return 'Enter valid mobile number.';
                    }
                    return null;
                  },
                  onFieldSubmitted: (value) {
                    FocusScope.of(context).requestFocus(_phoneFocusNode4);
                  },
                  onChanged: (value) {
                    if (value.length == 1) {
                      FocusScope.of(context).requestFocus(_phoneFocusNode4);
                      mobileNo += value;
                    }
                  },
                ),
              ),
              Container(
                width: 30.0,
                child: TextFormField(
                  focusNode: _phoneFocusNode4,
                  keyboardType: TextInputType.number,
                  textInputAction: TextInputAction.next,
                  style: getMediumFont(color: Theme.of(context).indicatorColor),
                  decoration: InputDecoration(
                    enabledBorder: UnderlineInputBorder(
                      borderSide: BorderSide(width: 0.0),
                    ),
                  ),
                  validator: (value) {
                    if (value!.isEmpty) {
                      return 'Enter valid mobile number.';
                    }
                    return null;
                  },
                  onFieldSubmitted: (value) {
                    FocusScope.of(context).requestFocus(_phoneFocusNode5);
                  },
                  onChanged: (value) {
                    if (value.length == 1) {
                      FocusScope.of(context).requestFocus(_phoneFocusNode5);
                      mobileNo += value;
                    }
                  },
                ),
              ),
              Container(
                width: 30.0,
                child: TextFormField(
                  focusNode: _phoneFocusNode5,
                  keyboardType: TextInputType.number,
                  textInputAction: TextInputAction.next,
                  style: getMediumFont(color: Theme.of(context).indicatorColor),
                  decoration: InputDecoration(
                    enabledBorder: UnderlineInputBorder(
                      borderSide: BorderSide(width: 0.0),
                    ),
                  ),
                  validator: (value) {
                    if (value!.isEmpty) {
                      return 'Enter valid mobile number.';
                    }
                    return null;
                  },
                  onFieldSubmitted: (value) {
                    FocusScope.of(context).requestFocus(_phoneFocusNode6);
                  },
                  onChanged: (value) {
                    if (value.length == 1) {
                      FocusScope.of(context).requestFocus(_phoneFocusNode6);
                      mobileNo += value;
                    }
                  },
                ),
              ),
              Container(
                width: 30.0,
                child: TextFormField(
                  focusNode: _phoneFocusNode6,
                  keyboardType: TextInputType.number,
                  textInputAction: TextInputAction.next,
                  style: getMediumFont(color: Theme.of(context).indicatorColor),
                  decoration: InputDecoration(
                    enabledBorder: UnderlineInputBorder(
                      borderSide: BorderSide(width: 0.0),
                    ),
                  ),
                  validator: (value) {
                    if (value!.isEmpty) {
                      return 'Enter valid mobile number.';
                    }
                    return null;
                  },
                  onFieldSubmitted: (value) {
                    FocusScope.of(context).requestFocus(_phoneFocusNode7);
                  },
                  onChanged: (value) {
                    if (value.length == 1) {
                      FocusScope.of(context).requestFocus(_phoneFocusNode7);
                      mobileNo += value;
                    }
                  },
                ),
              ),
              Container(
                width: 30.0,
                child: TextFormField(
                  focusNode: _phoneFocusNode7,
                  keyboardType: TextInputType.number,
                  textInputAction: TextInputAction.next,
                  style: getMediumFont(color: Theme.of(context).indicatorColor),
                  decoration: InputDecoration(
                    enabledBorder: UnderlineInputBorder(
                      borderSide: BorderSide(width: 0.0),
                    ),
                  ),
                  validator: (value) {
                    if (value!.isEmpty) {
                      return 'Enter valid mobile number.';
                    }
                    return null;
                  },
                  onFieldSubmitted: (value) {
                    FocusScope.of(context).requestFocus(_phoneFocusNode8);
                  },
                  onChanged: (value) {
                    if (value.length == 1) {
                      FocusScope.of(context).requestFocus(_phoneFocusNode8);
                      mobileNo += value;
                    }
                  },
                ),
              ),
              Container(
                width: 30.0,
                child: TextFormField(
                  focusNode: _phoneFocusNode8,
                  keyboardType: TextInputType.number,
                  textInputAction: TextInputAction.next,
                  style: getMediumFont(color: Theme.of(context).indicatorColor),
                  decoration: InputDecoration(
                    enabledBorder: UnderlineInputBorder(
                      borderSide: BorderSide(width: 0.0),
                    ),
                  ),
                  validator: (value) {
                    if (value!.isEmpty) {
                      return 'Enter valid mobile number.';
                    }
                    return null;
                  },
                  onChanged: (value) {
                    if (value.length == 1) {
                      FocusScope.of(context).requestFocus(_phoneFocusNode9);
                      mobileNo += value;
                    }
                  },
                  onFieldSubmitted: (value) {
                    FocusScope.of(context).requestFocus(_phoneFocusNode9);
                  },
                ),
              ),
              Container(
                width: 30.0,
                child: TextFormField(
                  focusNode: _phoneFocusNode9,
                  keyboardType: TextInputType.number,
                  textInputAction: TextInputAction.next,
                  style: getMediumFont(color: Theme.of(context).indicatorColor),
                  decoration: InputDecoration(
                    enabledBorder: UnderlineInputBorder(
                      borderSide: BorderSide(width: 0.0),
                    ),
                  ),
                  validator: (value) {
                    if (value!.isEmpty) {
                      return 'Enter valid mobile number.';
                    }
                    return null;
                  },
                  onChanged: (value) {
                    if (value.length == 1) {
                      FocusScope.of(context).requestFocus(_phoneFocusNode10);
                      mobileNo += value;
                    }
                  },
                  onFieldSubmitted: (value) {
                    FocusScope.of(context).requestFocus(_phoneFocusNode10);
                  },
                ),
              ),
              Container(
                width: 30.0,
                child: TextFormField(
                  focusNode: _phoneFocusNode10,
                  keyboardType: TextInputType.number,
                  textInputAction: TextInputAction.done,
                  style: getMediumFont(color: Theme.of(context).indicatorColor),
                  decoration: InputDecoration(
                    enabledBorder: UnderlineInputBorder(
                      borderSide: BorderSide(width: 0.0),
                    ),
                  ),
                  validator: (value) {
                    if (value!.isEmpty) {
                      return 'Enter valid mobile number.';
                    }
                    return null;
                  },
                  onChanged: (value) {
                    if (value.length == 1) {
                      FocusScope.of(context).unfocus();
                      mobileNo += value;
                      widget.setMobileNo(mobileNo);
                    }
                  },
                ),
              ),
            ],
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
          ),
          const SizedBox(
            height: 12.0,
          ),
          ElevatedButton(
            onPressed: mobileNo.length != 13
                ? () {}
                : () {
                    showDialog(
                      context: context,
                      builder: (context) {
                        return AlertDialog(
                          title: Text(
                            'Confirm', style: getBoldFont(color: Theme.of(context).primaryColor, fontSize: 16.0),
                          ),
                          titlePadding: const EdgeInsets.only(left: 12.0, top: 12.0, right: 12.0, bottom: 8.0),
                          content: Text('Please confirm your mobile no $mobileNo before proceeding.',
                            style: getSemiBoldFont(color: Colors.black, fontSize: 14.0),
                          ),
                          contentPadding: const EdgeInsets.only(left: 12.0, top: 12.0, right: 12.0, bottom: 8.0),
                          actions: [
                            TextButton(
                              onPressed: () {
                                widget.sendVerificationCode();
                                widget.switchAuthType(AuthType.UPDATE_PHONE_AUTH);
                                Navigator.of(context).pop();
                              },
                              child: Text('Yes', style: getSemiBoldFont(color: Theme.of(context).primaryColor, fontSize: 16.0),),
                            ),
                            TextButton(
                              onPressed: () {
                                Navigator.of(context).pop();
                              },
                              child: Text('No', style: getSemiBoldFont(color: Theme.of(context).primaryColor, fontSize: 16.0),),
                            ),
                          ],
                        );
                      },
                    );
                  },
            child: Text(
              'Send Verification Code',
              style: getMediumFont(color: Colors.white, fontSize: 16),
            ),
          ),
          if (widget.isNewUser)
            Row(
              children: [
                Text(
                  'Login using email instead?',
                  style: getMediumFont(color: Colors.black, fontSize: 14.0),
                ),
                TextButton(
                  onPressed: () {
                    widget.switchAuthType(AuthType.SIGN_IN_AUTH);
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
        crossAxisAlignment: CrossAxisAlignment.start,
      ),
    );
  }

  @override
  void dispose() {
    super.dispose();
    _phoneFocusNode1.dispose();
    _phoneFocusNode2.dispose();
    _phoneFocusNode3.dispose();
    _phoneFocusNode4.dispose();
    _phoneFocusNode5.dispose();
    _phoneFocusNode6.dispose();
    _phoneFocusNode7.dispose();
    _phoneFocusNode8.dispose();
    _phoneFocusNode9.dispose();
    _phoneFocusNode10.dispose();
  }
}
