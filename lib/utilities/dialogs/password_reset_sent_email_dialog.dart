import 'package:flutter/widgets.dart';
import 'package:notesfirst/utilities/dialogs/generic_dialog.dart';

Future<void> showPasswordResetEmailSentDialog(BuildContext context){
  return showGenericDialog<void>(
    context: context,
    title: 'Password Reset', 
    content: 'Password reset link sent. Please check your email for more verification. ', 
    optionBuilder: () =>{
      'Ok' : null,
    },);
}