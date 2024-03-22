import 'package:flutter/material.dart';

class SettingButton extends StatelessWidget {
  const SettingButton({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return IconButton(
        onPressed: () {
          showModalBottomSheet(
              context: context,
              builder: (context) => ListView(
                    children: const [
                      Card(
                        child: ListTile(
                          title: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text('Session Time'),
                              Text('5 min'),
                            ],
                          ),
                        ),
                      )
                    ],
                  ));
        },
        icon: const Icon(Icons.settings));
  }
}
