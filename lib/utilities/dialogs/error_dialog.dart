
import 'package:flutter/material.dart';
import 'package:notesfirst/utilities/dialogs/generic_dialog.dart';

Future<void> showErrorDialog(
  BuildContext context,
  String text,
){
  return showGenericDialog<void>(context: context,
   title: 'Oops! Error occurred...',
    content: text, 
    optionBuilder: ()=>{
      'Ok':null,
    });
}