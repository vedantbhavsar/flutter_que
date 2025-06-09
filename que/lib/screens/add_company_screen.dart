import 'dart:math' as math;

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart' as firebaseAuth;
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:que/helpers/functions.dart';
import 'package:que/models/company.dart';
import 'package:que/models/role.dart';
import 'package:que/providers/auth_provider.dart';
import 'package:que/providers/connection_provider.dart';
import 'package:que/resources/color_manager.dart';
import 'package:que/resources/style_manager.dart';
import 'package:que/resources/value_manager.dart';
import 'package:que/screens/home/home_screen.dart';
import 'package:que/widgets/no_wifi_widget.dart';
import 'package:que/widgets/user_name_profile_pic_widget.dart';

class AddCompanyScreen extends StatefulWidget {
  static const routeName = '/add-company';

  const AddCompanyScreen({Key? key}) : super(key: key);

  @override
  State<AddCompanyScreen> createState() => _AddCompanyScreenState();
}

class _AddCompanyScreenState extends State<AddCompanyScreen> {
  bool _isLoading = false;
  String _selectedCompany = '';
  String _selectedRole = '';
  String _displayName = '';
  String _imageUrl = '';

  @override
  void initState() {
    super.initState();
    Provider.of<AuthProvider>(context, listen: false).addNewUser();
  }

  void _setName(String name) {
    _displayName = name;
  }

  void _setProfileUrl(String profileUrl) {
    _imageUrl = profileUrl;
  }

  void _setCompany(String company) {
    setState(() {
      _selectedCompany = company;
    });
  }

  void _setRole(String role) {
    setState(() {
      _selectedRole = role;
    });
  }

  Future<void> _validateAndAddCompanyOrRole() async {
    if (_selectedCompany.isEmpty) {
      return;
    }
    if (_selectedRole.isEmpty) {
      return;
    }
    setState(() {
      _isLoading = true;
    });
    final user = firebaseAuth.FirebaseAuth.instance.currentUser!;
    await user.updateDisplayName(_displayName);
    await user.updatePhotoURL(_imageUrl);
    await user.reload();
    Provider.of<AuthProvider>(context, listen: false).getUpdates();
    getUserCollectionRef().doc(user.uid).update({
      'photoUrl': _imageUrl,
      'displayName': _displayName,
      'company': _selectedCompany,
      'role': _selectedRole,
    });
    await Provider.of<AuthProvider>(context, listen: false).addNewUser();
    Navigator.of(context).pushReplacementNamed(HomeScreen.routeName);
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final isConnected = Provider.of<ConnectionProvider>(context).isConnected;

    if (!isConnected) {
      return const NoWifiWidget();
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Your Organization'),
        centerTitle: false,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(children: [
            UserNameProfilePicWidget(
              userId: authProvider.user.uid,
              setName: _setName,
              setProfilePicUrl: _setProfileUrl,
            ),
            const SizedBox(height: 24.0,),
            _companyDropdownWidget(),
            const SizedBox(height: 24.0,),
            _roleDropdownWidget(),
            const SizedBox(height: 12.0,),
            if (_isLoading)
              Center(child: CircularProgressIndicator(),),
            if (!_isLoading)
              Container(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _validateAndAddCompanyOrRole,
                  child: Text(
                    'Save',
                    style: getSemiBoldFont(color: Colors.white),
                  ),
                ),
              ),
          ], crossAxisAlignment: CrossAxisAlignment.start,),
        ),
      ),
    );
  }

  Widget _companyDropdownWidget() {
    return StreamBuilder(
        stream: getCompanyCollectionRef()
            .withConverter(fromFirestore: Company.fromFirestore, toFirestore: (Company company, options) => company.toFirestore())
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator(),);
          }
          final companyDocs = (snapshot.data as QuerySnapshot<Company>).docs;
          final companyNames = companyDocs.map((companyDoc) => companyDoc.data().companyName).toList();

          return Container(
            decoration: BoxDecoration(
              border: Border.all(color: ColorManager.black,),
              borderRadius: BorderRadius.all(Radius.circular(AppSize.s8,),),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  flex: 10,
                  child: InkWell(
                    onTap: () => dropdownSearchPopup(context, companyNames, _setCompany, true),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: AppPadding.p8, vertical: AppPadding.p12),
                      child: Text(
                        _selectedCompany.isEmpty ? 'Your Company' : _selectedCompany,
                        style: _selectedCompany.isEmpty ? getMediumFont(
                          color: ColorManager.black,
                        ) : getSemiBoldFont(
                          color: Theme.of(context).primaryColor,
                        ),
                      ),
                    ),
                  ),
                ),
                Expanded(
                  flex: 2,
                  child: InkWell(
                    onTap: _selectedCompany.isEmpty ? null : () => _setCompany(''),
                    child: Icon(
                      Icons.clear,
                      color: ColorManager.black,
                    ),
                  ),
                ),
              ],
            ),
          );
        }
    );
  }

  Widget _roleDropdownWidget() {
    return StreamBuilder(
        stream: getRoleCollectionRef().withConverter(fromFirestore: Role.fromFirestore, toFirestore: (Role role, options) => role.toFirestore())
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator(),);
          }

          final roleDocs = (snapshot.data as QuerySnapshot<Role>).docs;
          final roleNames = roleDocs.map((doc) => doc.data().role).toList();

          return Container(
            decoration: BoxDecoration(
              border: Border.all(color: ColorManager.black,),
              borderRadius: BorderRadius.all(Radius.circular(AppSize.s8,),),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  flex: 10,
                  child: InkWell(
                    onTap: () => dropdownSearchPopup(context, roleNames, _setRole, false),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: AppPadding.p8, vertical: AppPadding.p12),
                      child: Text(
                        _selectedRole.isEmpty ? 'Your Role' : _selectedRole,
                        style: _selectedRole.isEmpty ? getMediumFont(
                          color: ColorManager.black,
                        ) : getSemiBoldFont(
                          color: Theme.of(context).primaryColor,
                        ),
                      ),
                    ),
                  ),
                ),
                Expanded(
                  flex: 2,
                  child: InkWell(
                    onTap: _selectedRole.isEmpty ? null : () => _setRole(''),
                    child: Icon(
                      Icons.clear,
                      color: ColorManager.black,
                    ),
                  ),
                ),
              ],
            ),
          );
        }
    );
  }

  Future<void> dropdownSearchPopup(BuildContext context, List<String> dataList, Function setValueFunc, bool isCompany) async {
    FocusScope.of(context).unfocus();
    final _controller = TextEditingController();
    final _focusNode = FocusNode();
    List<String> filterList = dataList;
    await showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          content: StatefulBuilder(
            builder: (context, setState) => SizedBox(
              width: MediaQuery.of(context).size.width * 0.9,
              height: MediaQuery.of(context).size.width * 0.9,
              child: Column(
                children: [
                  TextFormField(
                    controller: _controller,
                    focusNode: _focusNode,
                    style: getSemiBoldFont(color: Theme.of(context).primaryColor),
                    textCapitalization: TextCapitalization.words,
                    decoration: InputDecoration(
                      hintText: 'Select your company',
                      hintStyle: getMediumFont(color: ColorManager.grey,),
                      suffixIcon: IconButton(
                        onPressed: () {
                          setState(() {
                            _controller.text = '';
                            filterList = dataList;
                          });
                        },
                        icon: Icon(Icons.clear, color: ColorManager.black,),
                      ),
                    ),
                    onChanged: (value) {
                      setState(() {
                        filterList = dataList;
                        if (value.isNotEmpty) {
                          filterList = filterList.where((element) {
                            return element.contains(value);
                          }).toList();
                        }
                      });
                    },
                  ),
                  const SizedBox(height: AppSize.s16,),
                  Flexible(
                    child: ListView.builder(
                      itemCount: filterList.length,
                      itemBuilder: (context, index) {
                        final name = filterList.elementAt(index);
                        return ListTile(
                          title: Text(
                            name,
                            style: getMediumFont(color: ColorManager.black,),
                          ),
                          onTap: () {
                            Navigator.of(context).pop();
                            setValueFunc(name);
                          },
                        );
                      },
                    ),
                  ),
                  if (filterList.isEmpty) ...[
                    const Spacer(),
                    Text(
                      isCompany ? 'Verify the entered name and add your organization' : 'Verify the entered name and add your role',
                    ),
                    TextButton(
                      onPressed: () {
                        if (isCompany) {
                          final docRef = getCompanyCollectionRef().doc();
                          final company = Company(
                            companyId: docRef.id,
                            companyName: _controller.text,
                            color: (math.Random().nextDouble() * 0xFFFFFF).toInt(),
                          );
                          docRef.withConverter(fromFirestore: Company.fromFirestore, toFirestore: (Company company, options) => company.toFirestore())
                              .set(company);
                        }
                        else {
                          final docRef = getRoleCollectionRef().doc();
                          final role = Role(
                            roleId: docRef.id,
                            role: _controller.text,
                          );
                          docRef.withConverter(fromFirestore: Role.fromFirestore, toFirestore: (Role role, options) => role.toFirestore())
                              .set(role);
                        }
                        Navigator.of(context).pop();
                        setValueFunc(_controller.text);
                      },
                      child: Text(
                        'Add',
                        style: getSemiBoldFont(color: Theme.of(context).primaryColor,),
                      ),
                    ),
                  ]
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  @override
  void dispose() {
    super.dispose();
  }
}
