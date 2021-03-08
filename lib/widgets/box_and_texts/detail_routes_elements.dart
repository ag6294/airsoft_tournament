import 'package:flutter/material.dart';
import 'package:airsoft_tournament/constants/style.dart';

class TitleAndInfo extends StatelessWidget {
  final String title;
  final String description;
  final Widget action;

  TitleAndInfo(this.title, this.description, [this.action]);
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(
            left: 8.0,
            right: 8.0,
            bottom: 4.0,
            top: 12.0,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(title, style: kTitle),
              if (action != null) action,
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(
            left: 8.0,
            right: 8.0,
            bottom: 4.0,
          ),
          child: Text(
            description,
          ),
        ),
      ],
    );
  }
}
