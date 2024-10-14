import 'package:flutter/material.dart';

class ActionDialogWidget extends StatelessWidget {
  final String text;
  final String primaryText;
  final String secondaryText;
  final Function() primaryAction;
  final Function() secondaryAction;
  final Color? iconColor;
  IconData? iconData;

   ActionDialogWidget({
    Key? key,
    required this.text,
    required this.primaryText,
    required this.secondaryText,
    this.iconColor,
    required this.iconData,
    required this.primaryAction,
    required this.secondaryAction,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return IntrinsicHeight(
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
        ),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.confirmation_num_sharp,
              ),
              const SizedBox(
                height: 16.2,
              ),
              Visibility(
                visible: iconData != null,
                child: Icon(
                  iconData,
                  color: iconColor,
                ),
              ),
              Visibility(
                  visible: iconData != null,
                  child: const SizedBox(
                    height: 16.2,
                  )),
              Text(
                text,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                      color: Colors.black,
                      letterSpacing: -0.24,
                      fontSize: 15,
                    ),
              ),
              const SizedBox(height: 32.0),
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Theme.of(context).colorScheme.primary,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                          side: const BorderSide(color:Colors.grey),
                        ),
                        textStyle:
                            Theme.of(context).textTheme.bodyMedium!.copyWith(
                                  color: Colors.white,
                                  letterSpacing: -0.24,
                                  fontSize: 15,
                                ),
                      ),
                      onPressed: primaryAction,
                      child: Text(
                        primaryText,
                        style: Theme.of(context)
                            .textTheme
                            .bodyMedium!
                            .copyWith(color: Colors.white),
                      ),
                    ),
                  ),
                  const SizedBox(
                    width: 23,
                  ),
                  Expanded(
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Theme.of(context).colorScheme.primary,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                          side: const BorderSide(color: Colors.grey),
                        ),
                        textStyle:
                            Theme.of(context).textTheme.bodyMedium!.copyWith(
                                  color: Colors.white,
                                  letterSpacing: -0.24,
                                  fontSize: 15,
                                ),
                      ),
                      onPressed: secondaryAction,
                      child: Text(
                        secondaryText,
                        style: Theme.of(context)
                            .textTheme
                            .bodyMedium!
                            .copyWith(color: Colors.white),
                      ),
                    ),
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
