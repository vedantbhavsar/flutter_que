// ignore_for_file: must_be_immutable

import 'dart:io';

import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:que/helpers/app_logs.dart';
import 'package:que/helpers/constants.dart';
import 'package:que/providers/auth_provider.dart';
import 'package:que/resources/style_manager.dart';
import 'package:que/resources/value_manager.dart';

class UserNameProfilePicWidget extends StatefulWidget {
  final String userId;
  final Function setName;
  final Function setProfilePicUrl;
  String imageUrl;
  String displayName;
  UserNameProfilePicWidget({
    Key? key,
    required this.userId,
    required this.setName,
    required this.setProfilePicUrl,
    this.imageUrl = '',
    this.displayName = '',
    Uri? imagePicked,
  }) : super(key: key);

  @override
  State<UserNameProfilePicWidget> createState() =>
      _UserNameProfilePicWidgetState();
}

class _UserNameProfilePicWidgetState extends State<UserNameProfilePicWidget> {
  final _nameFocusNode = FocusNode();
  final _nameController = TextEditingController();

  File? imagePicked;
  final _imagePicker = ImagePicker();
  
  Future<void> pickAndStoreImage() async {
    final selectedImage =
        await _imagePicker.pickImage(source: ImageSource.gallery);
    if (selectedImage != null) {
      imagePicked = File(selectedImage.path);
      if (imagePicked != null) {
        try {
          FirebaseStorage.instance
              .ref('${ImageStorage.BASE_URL}/profilePics/${widget.userId}')
              .putFile(imagePicked!)
              .then((image) async {
            final url = await image.ref.getDownloadURL();
            widget.setProfilePicUrl(url);
          });
        } catch (error) {
          AppLogs().writeLog(Constants.USERNAME_PROFILE_PIC_WIDGET_TAG,
              'Firebase Storage Error: ${error.toString()}');
        } finally {
          setState(() {});
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    _nameController.text = widget.displayName;

    return Consumer<AuthProvider>(
      builder: (context, authProvider, child) {
        return Column(
          children: [
            GestureDetector(
              onTap: pickAndStoreImage,
              child: imagePicked == null && authProvider.photoURL.isEmpty ? Container(
                width: MediaQuery.of(context).size.width * 0.5,
                height: MediaQuery.of(context).size.height * 0.3,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  border: Border.all(
                    color: Theme.of(context).primaryColor.withOpacity(0.5),
                    width: 2.0,
                  ),
                  borderRadius: BorderRadius.all(Radius.circular(MediaQuery.of(context).size.width * 0.7)),
                  image: DecorationImage(
                    image: AssetImage('assets/images/profile_icon.jpg'),
                    fit: BoxFit.cover,
                  ),
                ),
              ) : imagePicked != null ? Container(
                width: MediaQuery.of(context).size.width * 0.7,
                height: MediaQuery.of(context).size.height * 0.4,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  border: Border.all(
                    color: Theme.of(context).primaryColor.withOpacity(0.5),
                    width: 2.0,
                  ),
                  borderRadius: BorderRadius.all(Radius.circular(MediaQuery.of(context).size.width * 0.7)),
                ),
                child: ClipRRect(borderRadius: BorderRadius.circular(MediaQuery.of(context).size.width * 0.7),
                  child: Image.file(imagePicked!, fit: BoxFit.fill,),
                ),
              ) : Container(
                width: MediaQuery.of(context).size.width * 0.7,
                height: MediaQuery.of(context).size.height * 0.4,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  border: Border.all(
                    color: Theme.of(context).primaryColor.withOpacity(0.5),
                    width: 2.0,
                  ),
                  borderRadius: BorderRadius.all(Radius.circular(MediaQuery.of(context).size.width * 0.7)),
                ),
                child: ClipRRect(borderRadius: BorderRadius.circular(MediaQuery.of(context).size.width * 0.7),
                  child: Image.network(authProvider.photoURL, fit: BoxFit.fill,),
                ),
              ),
            ),
            const SizedBox(height: AppSize.s16),
            TextFormField(
              keyboardType: TextInputType.name,
              textInputAction: TextInputAction.next,
              focusNode: _nameFocusNode,
              initialValue: widget.displayName.isEmpty ? '' : widget.displayName,
              style: getSemiBoldFont(color: Theme.of(context).primaryColor),
              decoration: InputDecoration(
                labelText: 'Name',
              ),
              validator: (value) {
                if (value!.isEmpty) {
                  return 'Enter Full Name';
                }
                if (value.split(' ').length < 1) {
                  return 'Enter First Name and Last Name.';
                }
                return null;
              },
              onChanged: (value) {
                widget.setName(value);
              },
            ),
          ],
        );
      },
    );
  }

  @override
  void dispose() {
    super.dispose();
    _nameFocusNode.dispose();
    _nameController.dispose();
  }
}
