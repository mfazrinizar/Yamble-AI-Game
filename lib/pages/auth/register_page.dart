import 'dart:io';

import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';
import 'package:flutter_svg/flutter_svg.dart';

import 'package:image_picker/image_picker.dart';
import 'package:yamble_yap_to_gamble_ai_game/db/auth/register_api.dart';
import 'package:yamble_yap_to_gamble_ai_game/pages/auth/login_page.dart';
import 'package:yamble_yap_to_gamble_ai_game/utils/file_picking.dart';
import 'package:yamble_yap_to_gamble_ai_game/utils/form_validator.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  RegisterState createState() => RegisterState();
}

class RegisterState extends State<RegisterPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController userNameController = TextEditingController();
  final TextEditingController nameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController rePasswordController = TextEditingController();
  bool passwordVisible = false, rePasswordVisible = false, isProcessing = false;
  File? _profileImage;
  final filePicking = FilePicking();

  @override
  Widget build(BuildContext context) {
    // double width = MediaQuery.of(context).size.width;
    double height = MediaQuery.of(context).size.height;

    return Scaffold(
      backgroundColor: Theme.of(context).primaryColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        leading: BackButton(
          color: Colors.white,
          onPressed: () {
            if (Navigator.canPop(context)) {
              Navigator.pop(context);
            } else {
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(
                  builder: (context) => const LoginPage(),
                ),
                (Route<dynamic> route) => false,
              );
            }
          },
        ),
        title: const Text('Register', style: TextStyle(color: Colors.white)),
      ),
      body: Column(children: [
        Expanded(
          child: Stack(
            children: [
              Positioned(
                left: 0,
                right: 0,
                child: Center(
                  child: SvgPicture.asset(
                    'assets/images/register.svg',
                    height: height * 0.25,
                    fit: BoxFit.fill,
                  ),
                ),
              ),
              Positioned(
                top: height * 0.25,
                left: 0,
                right: 0,
                bottom: 0,
                child: Container(
                  decoration: const ShapeDecoration(
                    color: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.only(
                          topRight: Radius.circular(50),
                          topLeft: Radius.circular(50)),
                    ),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: SingleChildScrollView(
                      child: Form(
                        key: _formKey,
                        child: Column(
                          children: [
                            GestureDetector(
                              onTap: () async {
                                final action = await showDialog<String>(
                                  context: context,
                                  builder: (BuildContext context) =>
                                      AlertDialog(
                                    title: const Text('Choose an action'),
                                    content: const Text(
                                        'Pick an image from the gallery or take a new photo?'),
                                    actions: <Widget>[
                                      TextButton(
                                        onPressed: () =>
                                            Navigator.pop(context, 'Gallery'),
                                        child: const Text(
                                          'Gallery',
                                        ),
                                      ),
                                      TextButton(
                                        onPressed: () =>
                                            Navigator.pop(context, 'Camera'),
                                        child: const Text(
                                          'Camera',
                                        ),
                                      ),
                                    ],
                                  ),
                                );

                                ImageSource source;
                                if (action == 'Gallery') {
                                  source = ImageSource.gallery;
                                } else if (action == 'Camera') {
                                  source = ImageSource.camera;
                                } else {
                                  // The user cancelled the dialog
                                  return;
                                }

                                final pickedImage =
                                    await filePicking.pickImage(source);
                                if (pickedImage != null) {
                                  setState(() {
                                    _profileImage = pickedImage;
                                  });
                                }
                              },
                              // This method opens the file picker
                              child: ClipOval(
                                child: _profileImage != null
                                    ? kIsWeb
                                        ? Image.network(
                                            _profileImage!.path,
                                            width: 100,
                                            height: 100,
                                            fit: BoxFit.cover,
                                          )
                                        : Image.file(
                                            _profileImage!,
                                            width: 100,
                                            height: 100,
                                            fit: BoxFit.cover,
                                          )
                                    : Container(
                                        color: Colors.grey,
                                        width: 100,
                                        height: 100,
                                        child: const Icon(Icons.camera_alt,
                                            color: Colors.white),
                                      ),
                              ),
                            ),
                            const SizedBox(height: 10),
                            TextFormField(
                              controller: userNameController,
                              validator: FormValidator.validateUserName,
                              decoration: const InputDecoration(
                                hintText: 'progambler01',
                                labelText: 'Username',
                                prefixIcon: Icon(Icons.person),
                              ),
                            ),
                            TextFormField(
                              controller: nameController,
                              validator: FormValidator.validateName,
                              decoration: const InputDecoration(
                                hintText: 'Name',
                                labelText: 'Name',
                                prefixIcon: Icon(Icons.person_2),
                              ),
                            ),
                            TextFormField(
                              controller: emailController,
                              validator: FormValidator.validateEmail,
                              decoration: const InputDecoration(
                                hintText: 'email@name.domain',
                                labelText: 'Email',
                                prefixIcon: Icon(Icons.email),
                              ),
                            ),
                            StatefulBuilder(
                              builder:
                                  (BuildContext context, StateSetter setState) {
                                return Column(
                                  children: [
                                    TextFormField(
                                      controller: passwordController,
                                      validator: FormValidator.validatePassword,
                                      decoration: InputDecoration(
                                        hintText: '********',
                                        labelText: 'Password',
                                        prefixIcon: const Icon(Icons.lock),
                                        suffixIcon: IconButton(
                                          icon: Icon(passwordVisible
                                              ? Icons.visibility
                                              : Icons.visibility_off),
                                          onPressed: () {
                                            setState(() {
                                              passwordVisible =
                                                  !passwordVisible;
                                            });
                                          },
                                        ),
                                      ),
                                      obscureText: !passwordVisible,
                                    ),
                                    TextFormField(
                                      controller: rePasswordController,
                                      validator: (value) =>
                                          FormValidator.validateRePassword(
                                              passwordController.text,
                                              rePasswordController.text),
                                      decoration: const InputDecoration(
                                        hintText: '********',
                                        labelText: 'Re-enter Password',
                                        prefixIcon: Icon(Icons.lock),
                                      ),
                                      obscureText: !passwordVisible,
                                    ),
                                  ],
                                );
                              },
                            ),
                            const SizedBox(height: 20),
                            FilledButton(
                              style: FilledButton.styleFrom(
                                shadowColor: Colors.grey,
                                elevation: 5,
                              ),
                              onPressed: isProcessing
                                  ? null
                                  : () async {
                                      if (_formKey.currentState!.validate()) {
                                        setState(() {
                                          isProcessing = true;
                                        });
                                        SmartDialog.showLoading(
                                          msg: 'Registering...',
                                        );
                                        final RegisterApi registerApi =
                                            RegisterApi();
                                        String? result;
                                        if (_profileImage != null) {
                                          result =
                                              await registerApi.registerUser(
                                            userName: userNameController.text,
                                            nameOfUser: nameController.text,
                                            userEmail: emailController.text,
                                            userPassword:
                                                passwordController.text,
                                            profilePictureImage: _profileImage!,
                                          );
                                        } else {
                                          SmartDialog.showNotify(
                                              msg:
                                                  'You haven\'t chosen profile picture',
                                              notifyType: NotifyType.error);
                                        }
                                        SmartDialog.dismiss();
                                        setState(() {
                                          isProcessing = false;
                                        });
                                        if (context.mounted) {
                                          if (result == 'success') {
                                            _showVerificationDialog(context);
                                          } else {
                                            if (result != null) {
                                              _showErrorDialog(context, result);
                                            }
                                          }
                                        }
                                      }
                                    },
                              child: const Text(
                                'Register',
                                style: TextStyle(fontSize: 20),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ]),
    );
  }
}

void _showVerificationDialog(BuildContext context) {
  AwesomeDialog(
    dismissOnTouchOutside: false,
    context: context,
    keyboardAware: true,
    dismissOnBackKeyPress: false,
    dialogType: DialogType.info,
    animType: AnimType.scale,
    transitionAnimationDuration: const Duration(milliseconds: 200),
    btnOkText: "Login",
    btnOkColor: Theme.of(context).primaryColor,
    title: 'Verify Your Email',
    desc:
        'Please check your email, then click the verification link to finish the registration process and be able to login your account.',
    btnOkOnPress: () {
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => const LoginPage()),
        (Route<dynamic> route) => false,
      );
    },
  ).show();
}

void _showErrorDialog(BuildContext context, String errorMessage) {
  AwesomeDialog(
    dismissOnTouchOutside: false,
    context: context,
    keyboardAware: true,
    dismissOnBackKeyPress: false,
    dialogType: DialogType.error,
    animType: AnimType.scale,
    transitionAnimationDuration: const Duration(milliseconds: 200),
    btnOkText: "Ok",
    btnOkColor: Theme.of(context).primaryColor,
    title: 'Error Occured',
    desc: errorMessage,
    btnOkOnPress: () {
      DismissType.btnOk;
    },
  ).show();
}
