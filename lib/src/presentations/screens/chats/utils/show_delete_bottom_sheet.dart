
import 'package:flutter/material.dart';

void showDeleteBottomSheet({
  required bool isSender,
  required BuildContext context,
  required bool isLoading,
  required Function({required bool deleteForEveryoneOrNot}) onDelete,
}) {
  showModalBottomSheet(
    context: context,
    isDismissible: false,
    builder: (context) => SizedBox(
      width: double.infinity,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ListTile(
              leading: const Icon(Icons.delete, color:Colors.purple),
              title: Text("S.of(context).deleteForMe",
                  style: Theme.of(context)
                      .textTheme
                      .bodyMedium
                      ?.copyWith(color: Colors.black)),
              onTap: isLoading
                  ? null
                  : () async {
                      onDelete(deleteForEveryoneOrNot: false);
                    }),
          isSender
              ? ListTile(
                  leading: const Icon(
                    Icons.delete_forever,
                    color:Colors.purple,
                  ),
                  title: Text("S.of(context).deleteForAll",
                      style: Theme.of(context)
                          .textTheme
                          .bodyMedium
                          ?.copyWith(color: Colors.black)),
                  onTap: isLoading
                      ? null
                      : () async {
                          onDelete(deleteForEveryoneOrNot: true);
                        },
                )
              : const SizedBox.shrink(),
          ListTile(
            leading: const Icon(Icons.cancel, color:Colors.purple),
            title: Text("Cancel",
                style: Theme.of(context)
                    .textTheme
                    .bodyMedium
                    ?.copyWith(color: Colors.black)),
            onTap: isLoading
                ? null
                : () {
                    Navigator.pop(context);
                  },
          ),
        ],
      ),
    ),
    // title: S.of(context).delete,
  );
}
