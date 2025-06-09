// ignore_for_file: must_be_immutable
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:que/models/que_user.dart';
import 'package:que/providers/task_provider.dart';
import 'package:que/resources/style_manager.dart';
import 'package:que/widgets/function_widgets.dart';

class FilterCheckListWidget extends StatefulWidget {
  final String filterName;
  bool isChecked;
  final QueUser queUser;
  FilterCheckListWidget({
    Key? key, required this.filterName,
    this.isChecked = true,
    required this.queUser,
  }) : super(key: key);

  @override
  State<FilterCheckListWidget> createState() => _FilterCheckListWidgetState();
}

class _FilterCheckListWidgetState extends State<FilterCheckListWidget> {
  @override
  Widget build(BuildContext context) {
    return CheckboxListTile(
      dense: true,
      secondary: Padding(
        padding: const EdgeInsets.only(left: 8.0),
        child: Container(
          child: initialCircleWidget(widget.queUser.displayName, widget.queUser.color),
        ),
      ),
      title: Text(widget.filterName, style: getMediumFont(color: Theme.of(context).primaryColor),),
      autofocus: false,
      activeColor: Colors.green,
      checkColor: Colors.white,
      selected: widget.isChecked,
      value: widget.isChecked,
      onChanged: (bool? value) {
        widget.isChecked = value!;
        final taskProvider = Provider.of<TaskProvider>(context, listen: false);
        taskProvider.applyFilter(widget.filterName, widget.isChecked);
      },
      contentPadding: const EdgeInsets.only(left: 0.0, right: 4.0),
    );
  }
}
