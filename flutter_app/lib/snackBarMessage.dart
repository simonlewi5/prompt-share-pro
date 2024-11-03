import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

void snackBarMessage(BuildContext context, String text) {
  final snackBarMessage = SnackBar(content: Text(text));
  ScaffoldMessenger.of(context).showSnackBar(snackBarMessage);
}