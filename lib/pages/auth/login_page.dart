import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter_exit_app/flutter_exit_app.dart';
import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:yamble_yap_to_gamble_ai_game/db/auth/login_api.dart';
import 'package:yamble_yap_to_gamble_ai_game/pages/auth/forget_password_page.dart';
import 'package:yamble_yap_to_gamble_ai_game/pages/auth/register_page.dart';
import 'package:yamble_yap_to_gamble_ai_game/pages/home_page.dart';
import 'package:yamble_yap_to_gamble_ai_game/pages/onboarding/onboarding_page.dart';
import 'package:yamble_yap_to_gamble_ai_game/utils/form_validator.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  LoginState createState() => LoginState();
}

class LoginState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  bool passwordVisible = false, isProcessing = false;

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
          'Login',
          style: TextStyle(
            color: Colors.white,
          ),
        ),
      ),
      body: PopScope(
        canPop: false,
        onPopInvoked: (didPop) async {
          if (!didPop) {
            AwesomeDialog(
              dismissOnTouchOutside: true,
              context: context,
              keyboardAware: true,
              dismissOnBackKeyPress: false,
              dialogType: DialogType.question,
              animType: AnimType.scale,
              transitionAnimationDuration: const Duration(milliseconds: 200),
              title: 'Exiting...',
              desc: 'Are you sure you want to exit the game?',
              btnOkText: 'Yes',
              btnOkColor: Theme.of(context).primaryColor,
              btnCancelText: 'Cancel',
              btnOkOnPress: () async {
                await FlutterExitApp.exitApp();
              },
              btnCancelOnPress: () {
                DismissType.btnCancel;
              },
            ).show();
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
                      'assets/images/settings.svg',
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
                              const Text('Enter Your Login Details',
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
                              StatefulBuilder(
                                builder: (BuildContext context,
                                    StateSetter setState) {
                                  return TextFormField(
                                    controller: passwordController,
                                    validator: FormValidator.validatePassword,
                                    style: const TextStyle(),
                                    decoration: InputDecoration(
                                      labelStyle: const TextStyle(
                                          // Change this to your desired color
                                          ),
                                      hintText: '********',
                                      labelText: 'Password',
                                      prefixIcon: const Icon(
                                        Icons.lock,
                                      ),
                                      suffixIcon: IconButton(
                                        icon: Icon(
                                          // Based on passwordVisible state choose the icon
                                          passwordVisible
                                              ? Icons.visibility
                                              : Icons.visibility_off,
                                        ),
                                        onPressed: () {
                                          // Update the state i.e. toggle the state of passwordVisible variable
                                          setState(() {
                                            passwordVisible = !passwordVisible;
                                          });
                                        },
                                      ),
                                    ),
                                    obscureText: !passwordVisible,
                                  );
                                },
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
                                              maskColor: Theme.of(context)
                                                  .primaryColor
                                                  .withOpacity(0.5),
                                              msg: 'Processing...');

                                          final LoginApi loginApi = LoginApi();
                                          Map<String, dynamic> result =
                                              await loginApi.loginUser(
                                            userEmail: emailController.text,
                                            userPassword:
                                                passwordController.text,
                                          );
                                          SmartDialog.dismiss();
                                          setState(() {
                                            isProcessing = false;
                                          });
                                          // Check the result
                                          if (result['status'] == 'success') {
                                            // If the login was successful, navigate to HomePage
                                            if (context.mounted) {
                                              Navigator.pushAndRemoveUntil(
                                                context,
                                                MaterialPageRoute(
                                                  builder: (context) =>
                                                      const HomePage(),
                                                ),
                                                (Route<dynamic> route) => false,
                                              );
                                              SmartDialog.showNotify(
                                                  msg: 'Logged in successfully',
                                                  notifyType:
                                                      NotifyType.success);
                                            }
                                          } else {
                                            // If there was an error, show a message to the user
                                            if (!context.mounted) return;
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
                                      },
                                child: const Text(
                                  '  Login  ',
                                  style: TextStyle(fontSize: 20),
                                ),
                              ),
                              const SizedBox(height: 5),
                              TextButton(
                                onPressed: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) =>
                                          const ForgetPasswordPage(),
                                    ),
                                  );
                                },
                                child: const Text(
                                  'Forget password?',
                                ),
                              ),
                              const SizedBox(height: 10),
                              OutlinedButton(
                                onPressed: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) =>
                                          const RegisterPage(),
                                    ),
                                  );
                                },
                                child: const Text(
                                  'Register',
                                  style: TextStyle(fontSize: 18),
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
      ),
    );
  }
}
