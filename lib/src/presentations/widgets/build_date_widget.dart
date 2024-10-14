import 'package:flutter/material.dart';
import 'package:date_format/date_format.dart' as df;

Widget buildDateWidget({
  required BuildContext context,
  required DateTime dateTime,
}) {
  return Center(
    child: ClipRRect(
      borderRadius: BorderRadius.circular(25),
      child: Card(
        elevation: 2,
        color:  Theme.of(context).cardColor,
        clipBehavior: Clip.antiAlias,
        child: Padding(
          padding: const EdgeInsets.all(8),
          child: Text(
            df.formatDate(dateTime, [df.dd,' ',df.M,' ', df.yyyy]),
            style: TextStyle(
              fontSize: 12,
              color:  Theme.of(context).colorScheme.onBackground,
              fontWeight: FontWeight.w500,
            )
            )
        ),
      ),
    ),
  );
}