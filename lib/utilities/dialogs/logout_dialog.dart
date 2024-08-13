
import 'package:flutter/material.dart';
import 'package:notesfirst/utilities/dialogs/generic_dialog.dart';

Future<bool> showLogoutDialog( 
  {
    required BuildContext context,
    }
){
  return showGenericDialog<bool>(
    context: context,
     title: 'Sign out',
      content: 'Do you want to log out?',
       optionBuilder: ()=>{
        'Cancel': false,
        'Logout':true,
       }).then((value)=> value ?? false);

}