import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:yamble_yap_to_gamble_ai_game/db/auth/forget_password_api.dart';
import 'package:yamble_yap_to_gamble_ai_game/pages/auth/login_page.dart';
import 'package:yamble_yap_to_gamble_ai_game/pages/auth/register_page.dart';
import 'package:yamble_yap_to_gamble_ai_game/pages/onboarding/onboarding_page.dart';
import 'package:yamble_yap_to_gamble_ai_game/utils/form_validator.dart';

class ForgetPasswordPage extends StatefulWidget {
  const ForgetPasswordPage({super.key});

  @override
  ForgetPasswordState createState() => ForgetPasswordState();
}

class ForgetPasswordState extends State<ForgetPasswordPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController emailController = TextEditingController();
  bool isProcessing = false;

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
                  builder: (context) => const OnboardingPage(),
                ),
                (Route<dynamic> route) => false,
              );
            }
          },
        ),
        title: const Text(
          'Forget Password',
          style: TextStyle(
            color: Colors.white,
          ),
        ),
      ),
      body: PopScope(
        canPop: false,
        onPopInvoked: (didPop) async {
          if (!didPop) {
            if (Navigator.canPop(context)) {
              Navigator.pop(context);
            } else {
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(
                  builder: (context) => const OnboardingPage(),
                ),
                (Route<dynamic> route) => false,
              );
            }
          }
        },
        child: Column(children: [
          Expanded(
            child: Stack(
              children: [
                Positioned(
                  left: 0,
                  right: 0,
                  child: Center(
                    child: SvgPicture.asset(
                      'assets/images/forget.svg',
                      height: height * 0.35,
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
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.only(
                            topRight: Radius.circular(50),
                            topLeft: Radius.circular(50)),
                      ),
                      color: Colors.white,
                    ),
                    child: Padding(
                      padding: const EdgeInsets.only(right: 16.0, left: 16.0),
                      child: SingleChildScrollView(
                        child: Form(
                          key: _formKey,
                          child: Column(
                            children: [
                              SizedBox(
                                height: height * 0.05,
                              ),
                              const Text('Enter Your Email to Reset',
                                  style: TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                  )),
                              TextFormField(
                                controller: emailController,
                                validator: FormValidator.validateEmail,
                                decoration: const InputDecoration(
                                  labelStyle: TextStyle(
                                      // Change this to your desired color
                                      ),
                                  hintText: 'email@name.domain',
                                  labelText: 'Email',
                                  prefixIcon: Icon(
                                    Icons.email,
                                  ),
                                ),
                              ),
                              SizedBox(
                                height: height * 0.1,
                              ),
                              FilledButton(
                                style: FilledButton.styleFrom(
                                  shadowColor: Colors.grey,
                                  elevation: 5,
                                ),
                                onPressed: isProcessing
                                    ? null
                                    : () async {
                                        if (_formKey.currentState!.validate()) {
                                          // Call loginUser from LoginApi
                                          setState(() {
                                            isProcessing = true;
                                          });
                                          SmartDialog.showLoading(
                                              msg: 'Processing...');

                                          final forgetPasswordApi =
                                              ForgetPasswordApi();
                                          Map<String, dynamic> result =
                                              await forgetPasswordApi
                                                  .resetPassword(
                                                      emailController.text);
                                          SmartDialog.dismiss();
                                          setState(() {
                                            isProcessing = false;
                                          });
                                          // Check the result
                                          if (context.mounted) {
                                            if (result['status'] == 'success') {
                                              AwesomeDialog(
                                                dismissOnTouchOutside: false,
                                                context: context,
                                                keyboardAware: true,
                                                dismissOnBackKeyPress: false,
                                                dialogType: DialogType.success,
                                                animType: AnimType.scale,
                                                transitionAnimationDuration:
                                                    const Duration(
                                                        milliseconds: 200),
                                                btnOkText: "Login",
                                                btnOkColor: Theme.of(context)
                                                    .primaryColor,
                                                btnCancelText: "Stay",
                                                title:
                                                    'Password Has Been Reset',
                                                desc: result['message'],
                                                btnOkOnPress: () {
                                                  Navigator.pushAndRemoveUntil(
                                                    context,
                                                    MaterialPageRoute(
                                                      builder: (context) =>
                                                          const LoginPage(),
                                                    ),
                                                    (Route<dynamic> route) =>
                                                        false,
                                                  );
                                                },
                                              ).show();
                                            } else {
                                              // If there was an error, show a message to the user

                                              AwesomeDialog(
                                                dismissOnTouchOutside: false,
                                                context: context,
                                                keyboardAware: true,
                                                dismissOnBackKeyPress: false,
                                                dialogType: DialogType.error,
                                                animType: AnimType.scale,
                                                transitionAnimationDuration:
                                                    const Duration(
                                                        milliseconds: 200),
                                                btnOkText: "Ok",
                                                btnOkColor: Theme.of(context)
                                                    .primaryColor,
                                                title: 'Error Occured',
                                                desc: result['message'],
                                                btnOkOnPress: () {
                                                  DismissType.btnOk;
                                                },
                                              ).show();
                                              // Get.snackbar('Error: ', result['message']);
                                            }
                                          }
                                        }
                                      },
                                child: const Text(
                                  '  Reset  ',
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
      ),
    );
  }
}
