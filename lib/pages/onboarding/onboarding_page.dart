import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter_exit_app/flutter_exit_app.dart';
import 'onboarding_base.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  OnboardingScreenState createState() => OnboardingScreenState();
}

class OnboardingScreenState extends State<OnboardingScreen> {
  int currentPage = 0;
  final PageController controller = PageController();

  @override
  Widget build(BuildContext context) {
    List<Map<String, String>> onboardingData = [
      {
        "title": 'Welcome to Yamble Game!',
        "description":
            'Yamble is an AI-based multiplayer game where you could play with your friends together.',
        "imageLight": "assets/logo/logo.svg",
        "imageDark": "assets/logo/logo.svg",
        "isSvg": "true",
      },
      {
        "title": 'Yap to Gamble',
        "description":
            'Yamble is a game where you can gamble on your yapping skill and win a game against your friends!',
        "imageLight": "assets/images/gamble.svg",
        "imageDark": "assets/images/gamble.svg",
        "isSvg": "true",
      },
    ];

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        title: const Text('Yamble'),
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
              title: 'Exit App',
              desc: 'Are you sure you want to exit the game?',
              btnOkText: 'Yes',
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
        child: SingleChildScrollView(
          child: Column(
            children: [
              SizedBox(
                height: MediaQuery.of(context).size.height * 0.75,
                child: PageView.builder(
                  controller: controller,
                  onPageChanged: (value) {
                    setState(() {
                      currentPage = value;
                    });
                  },
                  itemCount: onboardingData.length,
                  itemBuilder: (context, index) => OnboardingContent(
                    title: onboardingData[index]["title"]!,
                    description: onboardingData[index]["description"]!,
                    imageLight: onboardingData[index]["imageLight"]!,
                    imageDark: onboardingData[index]["imageDark"]!,
                    isSvg: onboardingData[index]["isSvg"] == "true",
                  ),
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const SizedBox(width: 20),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Theme.of(context).primaryColor,
                    ),
                    child: const Text('Skip'),
                    onPressed: () {
                      // Navigator.push(
                      //   context,
                      //   MaterialPageRoute(
                      //     builder: (context) => const LoginPage(),
                      //   ),
                      // );
                    },
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List<Widget>.generate(
                      onboardingData.length,
                      (int index) {
                        return GestureDetector(
                          onTap: () {
                            controller.animateToPage(
                              index,
                              duration: const Duration(milliseconds: 300),
                              curve: Curves.easeIn,
                            );
                          },
                          child: Container(
                            width: 15.0,
                            height: 15.0,
                            margin: const EdgeInsets.symmetric(horizontal: 8.0),
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: currentPage == index
                                  ? Theme.of(context).primaryColor
                                  : Theme.of(context)
                                      .primaryColor
                                      .withOpacity(0.5),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Theme.of(context).primaryColor,
                    ),
                    child: const Text('Next'),
                    onPressed: () {
                      if (currentPage == onboardingData.length - 1) {
                        // Navigator.pushAndRemoveUntil(
                        //   context,
                        //   MaterialPageRoute(
                        //       builder: (context) => const LoginPage()),
                        //   (Route<dynamic> route) => false,
                        // );
                      }
                      controller.nextPage(
                        duration: const Duration(milliseconds: 300),
                        curve: Curves.easeIn,
                      );
                    },
                  ),
                  const SizedBox(width: 20),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
