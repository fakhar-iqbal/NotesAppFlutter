
import 'package:flutter/material.dart';
import 'package:notesfirst/utilities/dialogs/generic_dialog.dart';

Future<bool> showDeleteDialog( 
  {
    required BuildContext context,
    }
){
  return showGenericDialog<bool>(
    context: context,
     title: 'Delete Note?',
      content: 'Do you want to delete this note?',
       optionBuilder: ()=>{
        'Cancel': false,
        'Delete':true,
       }).then((value)=> value ?? false);

}