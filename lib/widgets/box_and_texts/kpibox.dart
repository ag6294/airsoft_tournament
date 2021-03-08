import 'package:airsoft_tournament/constants/style.dart';
import 'package:flutter/material.dart';

class KPIBox extends StatelessWidget {
  final String value;
  final String label;
  final bool isSelected;
  final Function selectionCallback;
  final Function deselectionCallback;

  const KPIBox(
      {this.value,
      this.label,
      this.isSelected = false,
      this.selectionCallback,
      this.deselectionCallback});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: isSelected
          ? deselectionCallback ?? () {}
          : selectionCallback ?? () {},
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 4.0, vertical: 16),
        child: Container(
          height: 100,
          width: 100,
          child: Card(
            color: isSelected
                ? Theme.of(context).accentColor
                : Theme.of(context).cardColor,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12.0),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(
                    value,
                    style: isSelected ? kAccentCardTitle : kCardTitle,
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(
                    label,
                    style: isSelected ? kAccentMediumText : kMediumText,
                    softWrap: false,
                    overflow: TextOverflow.fade,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
