import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';
import 'package:yamble_yap_to_gamble_ai_game/db/settings/settings_api.dart';
import 'package:yamble_yap_to_gamble_ai_game/utils/form_validator.dart';
import 'package:yamble_yap_to_gamble_ai_game/utils/hex_color.dart';

class ChangePasswordPage extends StatefulWidget {
  const ChangePasswordPage({super.key});

  @override
  ChangePasswordPageState createState() => ChangePasswordPageState();
}

class ChangePasswordPageState extends State<ChangePasswordPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController currentPasswordController =
      TextEditingController();
  final TextEditingController newPasswordController = TextEditingController();
  final TextEditingController reNewPasswordController = TextEditingController();
  bool currentPasswordVisible = false,
      newPasswordVisible = false,
      reNewPasswordVisible = false,
      isProcessing = false;

  @override
  Widget build(BuildContext context) {
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
            }
          },
        ),
        title: const Text('Change Password',
            style: TextStyle(color: Colors.white)),
      ),
      body: Column(children: [
        Expanded(
          child: Stack(
            children: [
              Positioned(
                left: 0,
                right: 0,
                child: Center(
                  child: Icon(Icons.lock,
                      size: height * 0.25, color: HexColor('#E5DEFF')),
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
                            Text('Please Fill the Form',
                                style: Theme.of(context).textTheme.titleLarge),
                            const SizedBox(
                              height: 10,
                            ),
                            StatefulBuilder(
                              builder:
                                  (BuildContext context, StateSetter setState) {
                                return Column(
                                  children: [
                                    TextFormField(
                                      controller: currentPasswordController,
                                      validator: FormValidator.validatePassword,
                                      decoration: InputDecoration(
                                        hintText: '********',
                                        labelText: 'Current Password',
                                        prefixIcon: const Icon(Icons.lock),
                                        suffixIcon: IconButton(
                                          icon: Icon(currentPasswordVisible
                                              ? Icons.visibility
                                              : Icons.visibility_off),
                                          onPressed: () {
                                            setState(() {
                                              currentPasswordVisible =
                                                  !currentPasswordVisible;
                                            });
                                          },
                                        ),
                                      ),
                                      obscureText: !currentPasswordVisible,
                                    ),
                                    TextFormField(
                                      controller: newPasswordController,
                                      validator: FormValidator.validatePassword,
                                      decoration: InputDecoration(
                                        hintText: '********',
                                        labelText: 'New Password',
                                        prefixIcon: const Icon(Icons.lock),
                                        suffixIcon: IconButton(
                                          icon: Icon(newPasswordVisible
                                              ? Icons.visibility
                                              : Icons.visibility_off),
                                          onPressed: () {
                                            setState(() {
                                              newPasswordVisible =
                                                  !newPasswordVisible;
                                            });
                                          },
                                        ),
                                      ),
                                      obscureText: !newPasswordVisible,
                                    ),
                                    TextFormField(
                                      controller: reNewPasswordController,
                                      validator: (value) =>
                                          FormValidator.validateRePassword(
                                              newPasswordController.text,
                                              reNewPasswordController.text),
                                      decoration: InputDecoration(
                                        hintText: '********',
                                        labelText: 'Re-enter New Password',
                                        prefixIcon: const Icon(Icons.lock),
                                        suffixIcon: IconButton(
                                          icon: Icon(reNewPasswordVisible
                                              ? Icons.visibility
                                              : Icons.visibility_off),
                                          onPressed: () {
                                            setState(() {
                                              reNewPasswordVisible =
                                                  !reNewPasswordVisible;
                                            });
                                          },
                                        ),
                                      ),
                                      obscureText: !reNewPasswordVisible,
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
                                          maskColor: Theme.of(context)
                                              .primaryColor
                                              .withOpacity(0.5),
                                          msg: 'Changing password...',
                                        );

                                        final changePasswordApi = SettingsApi();
                                        final result = await changePasswordApi
                                            .changePassword(
                                          currentPasswordController.text,
                                          newPasswordController.text,
                                        );

                                        SmartDialog.dismiss();
                                        setState(() {
                                          isProcessing = false;
                                        });

                                        if (context.mounted) {
                                          if (result['status'] ==
                                              'SUCCESS_SIR') {
                                            _showSuccessDialog(
                                                context, result['message']);
                                          } else {
                                            _showErrorDialog(
                                                context, result['message']);
                                          }
                                        }
                                      }
                                    },
                              child: const Text(
                                'Change Password',
                                style: TextStyle(fontSize: 20),
                              ),
                            ),
                            const SizedBox(
                              height: 10,
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

void _showSuccessDialog(BuildContext context, String successMessage) {
  AwesomeDialog(
    dismissOnTouchOutside: false,
    context: context,
    keyboardAware: true,
    dismissOnBackKeyPress: false,
    dialogType: DialogType.success,
    animType: AnimType.scale,
    transitionAnimationDuration: const Duration(milliseconds: 200),
    btnOkText: "Ok",
    btnOkColor: Theme.of(context).primaryColor,
    title: 'Success',
    desc: successMessage,
    btnOkOnPress: () {},
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
    title: 'Error Occurred',
    desc: errorMessage,
    btnOkOnPress: () {
      DismissType.btnOk;
    },
  ).show();
}
