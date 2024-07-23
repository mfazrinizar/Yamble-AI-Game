import 'package:flutter/material.dart';
import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:url_launcher/url_launcher.dart';

class AboutDeveloperPage extends StatelessWidget {
  const AboutDeveloperPage({super.key});

  void _launchURL(String url) async {
    try {
      await launchUrl(Uri.parse(url));
    } catch (e) {
      SmartDialog.showNotify(
          msg: 'Can\'t open the URL.', notifyType: NotifyType.error);
    }
  }

  @override
  Widget build(BuildContext context) {
    final height = MediaQuery.of(context).size.height;

    return Scaffold(
      backgroundColor: Theme.of(context).primaryColor,
      appBar: AppBar(
        leading: BackButton(
          color: Colors.white,
          onPressed: () {
            if (Navigator.canPop(context)) {
              Navigator.pop(context);
            }
          },
        ),
        backgroundColor: Theme.of(context).primaryColor,
        title: const Text('About Developer',
            style: TextStyle(color: Colors.white)),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              SizedBox(height: height * 0.05),
              const CircleAvatar(
                radius: 80,
                backgroundImage: AssetImage('assets/images/developer.png'),
              ),
              SizedBox(height: height * 0.03),
              const Text(
                'M. Fazri Nizar',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              SizedBox(height: height * 0.02),
              const Text(
                'A passionate developer with experience in Flutter and Firebase. Loves to create mobile applications that provide excellent user experiences.'
                ' Currently a Member of the Mobile Development Team at Google Developer Student Clubs (GDSC) Sriwijaya University',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.white,
                ),
              ),
              SizedBox(height: height * 0.03),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  IconButton(
                    icon: SvgPicture.asset(
                      'assets/icons/github.svg',
                      height: 40,
                    ),
                    onPressed: () {
                      _launchURL('https://github.com/mfazrinizar');
                    },
                  ),
                  IconButton(
                    icon: SvgPicture.asset(
                      'assets/icons/linkedin.svg',
                      height: 40,
                    ),
                    onPressed: () {
                      _launchURL('https://www.linkedin.com/in/mfazrinizar');
                    },
                  ),
                  IconButton(
                    icon: SvgPicture.asset(
                      'assets/icons/instagram.svg',
                      height: 40,
                    ),
                    onPressed: () {
                      _launchURL('https://www.instagram.com/mfazrinizar');
                    },
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
