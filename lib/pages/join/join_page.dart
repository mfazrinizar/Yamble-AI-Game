import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:yamble_yap_to_gamble_ai_game/utils/form_validator.dart';

class JoinPage extends StatefulWidget {
  const JoinPage({super.key});

  @override
  State<JoinPage> createState() => _JoinPageState();
}

class _JoinPageState extends State<JoinPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController joinCodeController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final top = MediaQuery.of(context).padding.top;
    final height = MediaQuery.of(context).size.height;
    final width = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: Theme.of(context).primaryColor,
      body: Stack(
        children: [
          // Background SVG image
          Positioned(
            top: -top,
            left: 0,
            width: width,
            height: height * 0.4,
            child: SizedBox(
              child: SvgPicture.asset(
                'assets/images/game.svg', // Replace with your SVG asset
              ),
            ),
          ),
          DraggableScrollableSheet(
            initialChildSize: 0.6,
            minChildSize: 0.5,
            maxChildSize: 1.0,
            builder: (context, scrollController) {
              return Container(
                decoration: BoxDecoration(
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(32.0),
                    topRight: Radius.circular(32.0),
                  ),
                  color: Colors.white,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.5),
                      spreadRadius: 2,
                      blurRadius: 5,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: SingleChildScrollView(
                  controller: scrollController,
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        children: [
                          const SizedBox(
                            height: 10,
                          ),
                          const Center(
                            child: CircleAvatar(
                              radius: 40,
                              child: Icon(
                                Icons.videogame_asset,
                                size: 40,
                              ),
                            ),
                          ),
                          const SizedBox(
                            height: 20,
                          ),
                          TextFormField(
                            controller: joinCodeController,
                            validator: FormValidator.validateJoin,
                            maxLength: 6,
                            decoration: const InputDecoration(
                              labelText: 'Enter 6-character Join Code',
                              prefixIcon: Icon(Icons.code),
                            ),
                          ),
                          const SizedBox(
                            height: 20,
                          ),
                          FilledButton(
                            onPressed: () {
                              if (_formKey.currentState!.validate()) {
                                // Handle Join Game action
                              }
                            },
                            child: const Text(
                              'Join Game',
                              style: TextStyle(fontSize: 18),
                            ),
                          ),
                          const SizedBox(
                            height: 10,
                          ),
                          OutlinedButton(
                            onPressed: () {
                              // Handle Create a Game action
                            },
                            child: const Text(
                              'Create a Game',
                              style: TextStyle(fontSize: 16),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
