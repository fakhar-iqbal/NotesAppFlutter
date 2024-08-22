

import 'package:flutter/material.dart';
import 'package:notesfirst/utilities/dialogs/generic_dialog.dart';

Future<void> cannotShareEmptyNoteDialog(BuildContext context){
  return showGenericDialog<void>(context: context,
  title: 'Note Sharing',
  content: 'You cannot share an empty note!',
  optionBuilder:()=> {
    'ok':null,
  } );
}