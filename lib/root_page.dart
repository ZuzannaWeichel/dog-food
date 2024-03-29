import 'package:dog_food/auth.dart';
import 'package:dog_food/home_page.dart';
import 'package:dog_food/login_page.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter/material.dart';

class RootPage extends StatefulWidget{
  RootPage({this.auth});
  final BaseAuth auth;
  
  @override
  State<StatefulWidget> createState() => _RootPageState();

}

enum AuthStatus {
  notSignedIn,
  signedIn
}

class _RootPageState extends State<RootPage>{

  AuthStatus authStatus = AuthStatus.notSignedIn;
  String userId;

  // @override
  // void initState() {
  //   super.initState();
  //   widget.auth.currentUser().then((userId){
  //     setState((){
  //       //authStatus = userId == null ? AuthStatus.notSignedIn : AuthStatus.signedIn;
  //     });
  //   });
  // }

  void _signedIn(){
    setState(() {
      authStatus = AuthStatus.signedIn;
    });
  }

  void _signedOut(){
    setState(() {
      authStatus = AuthStatus.notSignedIn;
    });
  }


  @override
  Widget build(BuildContext context) {   
    switch (authStatus){
      case AuthStatus.notSignedIn : return LoginPage(auth: widget.auth, onSignedIn: _signedIn,);
      case AuthStatus.signedIn : return HomePage(auth: widget.auth, onSignedOut: _signedOut,);
    }
  }

}