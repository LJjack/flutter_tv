import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:flutter/material.dart';
import 'package:flutter_tv/config.dart';

class DropdownButton3 extends StatefulWidget {
  const DropdownButton3({Key? key, required this.initialValue, this.onChanged})
      : super(key: key);

  final ValueChanged<DropdownCMD>? onChanged;
  final DropdownCMD initialValue;

  @override
  State<DropdownButton3> createState() => _DropdownButton3State();
}

class _DropdownButton3State extends State<DropdownButton3> {
  @override
  void initState() {
    selectedValue = widget.initialValue;
    super.initState();
  }

  DropdownCMD selectedValue = DropdownCMD.auto;

  List<DropdownMenuItem<DropdownCMD>> _addDividersAfterItems(
      List<DropdownCMD> items) {
    List<DropdownMenuItem<DropdownCMD>> menuItems = [];
    for (var item in items) {
      menuItems.addAll(
        [
          DropdownMenuItem<DropdownCMD>(
            value: item,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0),
              child: Center(
                child: Text(
                  item.name,
                  style: const TextStyle(
                    fontSize: 14,
                  ),
                ),
              ),
            ),
          ),
          //If it's last item, we will not add Divider after it.
          if (item != items.last)
            const DropdownMenuItem<DropdownCMD>(
              enabled: false,
              child: Divider(),
            ),
        ],
      );
    }
    return menuItems;
  }

  List<double> _getCustomItemsHeights() {
    List<double> itemsHeights = [];
    for (var i = 0; i < (DropdownCMD.values.length * 2) - 1; i++) {
      if (i.isEven) {
        itemsHeights.add(40);
      }
      //Dividers indexes will be the odd indexes
      if (i.isOdd) {
        itemsHeights.add(4);
      }
    }
    return itemsHeights;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        color: Colors.amber,
        child: DropdownButtonHideUnderline(
          child: DropdownButton2(
            isExpanded: true,
            items: _addDividersAfterItems(DropdownCMD.values),
            customItemsHeights: _getCustomItemsHeights(),
            value: selectedValue,
            onChanged: (value) {
              if (value! != DropdownCMD.refresh) {
                if (value == selectedValue) return;

                setState(() {
                  selectedValue = value;
                });
              }

              if (widget.onChanged != null) {
                widget.onChanged!(value);
              }
            },
            buttonHeight: 80,
            dropdownMaxHeight: 200,
            buttonWidth: 120,
            itemPadding: const EdgeInsets.symmetric(horizontal: 8.0),
          ),
        ),
      ),
    );
  }
}
