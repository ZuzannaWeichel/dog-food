import 'package:dog_food/auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class LoginPage extends StatefulWidget {
  final BaseAuth auth;
  final VoidCallback onSignedIn;

  LoginPage({this.auth, this.onSignedIn});

  @override
  State<StatefulWidget> createState() => new LoginPageState();
}

enum FormType { login, register }

class LoginPageState extends State<LoginPage> {
  String _email;
  String _password;
  FormType _formType = FormType.login;

  final formKey = GlobalKey<FormState>();

  bool validateAndSave() {
    final form = formKey.currentState;

    if (form.validate()) {
      form.save();
      print('form is valid. Email $_email and password $_password');
      return true;
    }
    return false;
  }

  void validateAndSubmmit() async {
    if (validateAndSave()) {
      try {
        if (_formType == FormType.login) {
          String userId =
              await widget.auth.signInWithEmailAndPassword(_email, _password);
          print('Signed in: $userId');
        } else {
          String userId = await widget.auth
              .createUserWithEmailAndPassword(_email, _password);
          print('Registered user $userId');
          Firestore.instance.collection('users').document(userId).setData({
            'userId': userId,
            'treatCounter': 0,
            'walkCounter': 0,
            'firstScoop': false,
            'secondScoop': false,
            'showTreats': false,
          });
        }
        widget.onSignedIn();
      } catch (error) {
        print('Error: $error');
        AlertDialog alert = AlertDialog(
            title: Container(
              margin: EdgeInsets.only(top: 30),
              child: Text(
                'Invalid Email or Password!',
                style: Theme.of(context).textTheme.subhead.apply(color: Colors.red),
                textAlign: TextAlign.center,
              ),
            ),
            content: ButtonBar(
              children: <Widget>[
                FlatButton(
                  child: Text(
                    'Try again',
                    style: Theme.of(context).textTheme.body2.apply(color: Colors.green),
                  ),
                  onPressed: () {
                    Navigator.pop(context);
                  },
                ),
                FlatButton(
                  child: Text('Register',
                      style: Theme.of(context).textTheme.body2.apply(color: Colors.green)),
                  onPressed: () {
                    moveToRegister();
                    Navigator.pop(context);
                  },
                )
              ],
            ));
        showDialog(context: context, child: alert);
      }
    }
  }

  void moveToRegister() {
    formKey.currentState.reset();
    setState(() {
      _formType = FormType.register;
    });
  }

  void moveToLogin() {
    formKey.currentState.reset();
    setState(() {
      _formType = FormType.login;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        title: Text(_formType == FormType.login ? 'Login' : 'Register'),
      ),
      body: SingleChildScrollView(
        child: Container(
            padding: EdgeInsets.all(20),
            child: Form(
              key: formKey,
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: buildInputs() + buildSubmitButtons()),
            )),
      ),
    );
  }

  List<Widget> buildInputs() {
    return [
      TextFormField(
        decoration: InputDecoration(labelText: 'Email'),
        validator: (value) => value.isEmpty ? 'Email can\'t be empty.' : null,
        onSaved: (value) =>  _email = value.trim(),
      ),
      TextFormField(
        decoration: InputDecoration(labelText: 'Password'),
        validator: (value) =>
            value.isEmpty ? 'Password can\'t be empty.' : null,
        onSaved: (value) => _password = value,
        obscureText: true,
      )
    ];
  }

  List<Widget> buildSubmitButtons() {
    if (_formType == FormType.login) {
      return [
        RaisedButton(
          child: Text(
            'Login',
            style: Theme.of(context).textTheme.body2,
          ),
          onPressed: validateAndSubmmit,
        ),
        FlatButton(
          child: Text(
            'Create an account',
            style: Theme.of(context).textTheme.body2.apply(color: Colors.green),
          ),
          onPressed: moveToRegister,
        )
      ];
    } else {
      return [
        RaisedButton(
          child: Text(
            'Create an account',
            style: Theme.of(context).textTheme.body2,
          ),
          onPressed: validateAndSubmmit,
        ),
        FlatButton(
          child: Text(
            'Have an account? Login',
            style: Theme.of(context).textTheme.body2.apply(color: Colors.green),
          ),
          onPressed: moveToLogin,
        ),
      ];
    }
  }
}
