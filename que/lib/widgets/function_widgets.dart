import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:que/helpers/constants.dart';
import 'package:que/resources/assets_manager.dart';
import 'package:que/resources/style_manager.dart';

Widget priorityDropDownItemWidget(BuildContext context, String name) {
  return Row(children: [
    if (name == PriorityEnum.Blocker.name)
      const Icon(
        Icons.block_rounded, color: Colors.red,
      ),
    if (name == PriorityEnum.Highest.name)
      const Icon(
        Icons.keyboard_double_arrow_up, color: Colors.red,
      ),
    if (name == PriorityEnum.High.name)
      const Icon(
        Icons.keyboard_arrow_up, color: Colors.red,
      ),
    if (name == PriorityEnum.Medium.name)
      const Icon(
        Icons.priority_high, color: Colors.orange,
      ),
    if (name == PriorityEnum.Normal.name)
      const Icon(
        Icons.low_priority, color: Colors.green,
      ),
    if (name == PriorityEnum.Latest.name)
      Transform(
        alignment: Alignment.center,
        transform: Matrix4.rotationY(math.pi),
        child: const Icon(
          Icons.restore_rounded, color: Colors.greenAccent,
        ),
      ),
    if (name == PriorityEnum.Oldest.name)
      const Icon(
        Icons.restore_rounded, color: Colors.purpleAccent,
      ),
    const SizedBox(width: 8.0,),
    Text(name, style: getSemiBoldFont(color: Theme.of(context).primaryColor),),
  ],);
}

Widget initialCircleWidget(String displayName, int color) {
  return CircleAvatar(
    backgroundColor: Color(color).withOpacity(1.0),
    child: Center(
      child: Text(
        displayName.substring(0, 1).toUpperCase(),
        style: getBoldFont(color: Colors.white),
      ),
    ),
  );
}

Widget noTasksWidget(BuildContext context) {
  return Container(
    width: MediaQuery.of(context).size.width * 0.9,
    height: MediaQuery.of(context).size.height * 0.9,
    child: Column(children: [
      Image.asset(ImageAssets.noTasks),
      Text('No Tasks',
        style: getSemiBoldFont(color: Theme.of(context).colorScheme.background, fontSize: 22.0,),
      ),
    ], mainAxisAlignment: MainAxisAlignment.spaceEvenly, crossAxisAlignment: CrossAxisAlignment.center,),
  );
}