import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dog_food/auth.dart';
import 'package:flutter/material.dart';

class HomePage extends StatefulWidget {
  final BaseAuth auth;
  final VoidCallback onSignedOut;

  HomePage({this.auth, this.onSignedOut});

  void _signOut() async {
    try {
      await auth.signOut();
      onSignedOut();
    } catch (e) {
      print(e);
    }
  }

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  String _userID;

  @override
  void initState() {
    super.initState();
    widget.auth.currentUser().then((userId) {
      setState(() {
        _userID = userId;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return buildScaffold();
  }

  Widget buildScaffold() {
    return StreamBuilder(
      stream: Firestore.instance
          .collection('users')
          .where('userId', isEqualTo: _userID)
          .snapshots(),
      builder: (context, snapshots) {
        if (!snapshots.hasData) {
          return LinearProgressIndicator();
        } else {
          return Scaffold(
            backgroundColor: Colors.transparent,
            appBar: buildAppbar(),
            body: buildList(context, snapshots.data.documents[0]),
            floatingActionButton: buildFloatingActionButton(() {
              resetData(snapshots.data.documents[0]);
            }, Icons.refresh),
          );
        }
      },
    );
  }

  AppBar buildAppbar() {
    return AppBar(
      title: Text('Did you feed the dog?'),
      actions: <Widget>[
        FlatButton(
          child: Text(
            'Logout',
            style: Theme.of(context).textTheme.body1.apply(color: Colors.white),
          ),
          onPressed: widget._signOut,
        )
      ],
    );
  }

  Widget buildList(BuildContext context, DocumentSnapshot snapshot) {
    return ListView(
      children: <Widget>[
        Padding(
          padding: const EdgeInsets.only(top: 10),
          child:
              cardWithButton(snapshot['walkCounter'], 'Walks:', true, snapshot),
        ),
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: buildCardWithScoops(context, snapshot),
        ),
        cardWithButton(snapshot['treatCounter'], 'Treats:',
            showTreatCard(snapshot), snapshot),
      ],
    );
  }

  Card buildCardWithScoops(BuildContext context, DocumentSnapshot snapshot) {
    return Card(
        child: Padding(
      padding: const EdgeInsets.all(10.0),
      child: Column(
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.all(10.0),
            child: Text('Food:', style: Theme.of(context).textTheme.display1),
          ),
          buildSwitchListTile('First Scoop', snapshot['firstScoop'],
              changeFirstScoop, snapshot),
          buildSwitchListTile('Second Scoop', snapshot['secondScoop'],
              changeSecondScoop, snapshot)
        ],
      ),
    ));
  }

  SwitchListTile buildSwitchListTile(
      String title, bool param, Function f, DocumentSnapshot snapshot) {
    return SwitchListTile(
      title: Text(
        title,
        style: Theme.of(context).textTheme.headline,
      ),
      value: param,
      onChanged: (bool value) {
        f(value, snapshot);
      },
    );
  }

  FloatingActionButton buildFloatingActionButton(Function f, IconData i) {
    return FloatingActionButton(
      onPressed: f,
      child: Icon(i),
    );
  }

  Widget cardWithButton(
      int counter, String text, bool show, DocumentSnapshot snapshot) {
    return Container(
        child: show
            ? Padding(
                padding: EdgeInsets.all(8.0),
                child: Card(
                    child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    children: <Widget>[
                      Padding(
                        padding: const EdgeInsets.all(15.0),
                        child: Text('$text',
                            style: Theme.of(context).textTheme.display1),
                      ),
                      cardWithButtonRow(counter, text, snapshot),
                    ],
                  ),
                )),
              )
            : new Container());
  }

  Row cardWithButtonRow(int counter, String text, DocumentSnapshot snapshot) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        Container(
          padding: EdgeInsets.only(left: 50, right: 20),
          child: Text(
            '$counter',
            style: Theme.of(context).textTheme.headline,
          ),
        ),
        Container(
            padding: EdgeInsets.only(left: 20, right: 50),
            child: buildFloatingActionButton(() {
              incrementCounter(text, snapshot);
            }, Icons.add)),
      ],
    );
  }

  void changeFirstScoop(bool value, DocumentSnapshot snapshot) {
    snapshot.reference.updateData({'firstScoop': value});
  }

  void changeSecondScoop(bool value, DocumentSnapshot snapshot) {
    snapshot.reference.updateData({'secondScoop': value});
  }

  bool showTreatCard(DocumentSnapshot snapshot) {
    if (snapshot['firstScoop'] == true && snapshot['secondScoop'] == true) {
      snapshot.reference.updateData({'showTreats': true});
      // } else {
      //   snapshot.reference.updateData({'showTreats': false});
    }
    return snapshot['showTreats'];
  }

  void incrementCounter(String val, DocumentSnapshot snapshot) {
    if (val == 'Treats:') {
      snapshot.reference
          .updateData({'treatCounter': snapshot['treatCounter'] + 1});
    } else if (val == 'Walks:') {
      snapshot.reference
          .updateData({'walkCounter': snapshot['walkCounter'] + 1});
    }
  }

  void resetData(DocumentSnapshot snapshot) {
    snapshot.reference.updateData({
      'treatCounter': 0,
      'walkCounter': 0,
      'firstScoop': false,
      'secondScoop': false,
      'showTreats': false,
    });
  }
}
