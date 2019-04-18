import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_storage/firebase_storage.dart';
import "package:flutter/material.dart";
import 'package:verboshop/blocs/blocProvider.dart';
import 'package:verboshop/blocs/authBloc.dart';
import 'package:audioplayers_with_rate/audioplayers.dart';
import 'package:verboshop/pages/AudioList/audioList.dart';

final AudioPlayer audioPlayer = new AudioPlayer();

class HomePage extends StatefulWidget {
  const HomePage({Key key}) : super(key: key);

  @override
  HomePageState createState() => new HomePageState();
}

class HomePageState extends State<HomePage> {
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();
  bool showPlayIcon = true;

  int _selectedIndex = 1;
  final _widgetOptions = [
    // Container(
    //     child: Column(
    //   children: <Widget>[
    //     Text('Index 0: Home'),
    //     FlatButton(
    //       child: Text('Play'),
    //       onPressed: () async {
    //         dynamic url = await storage
    //             .ref()
    //             .child('ministracoes')
    //             .child(
    //                 'Domingo Manhã - Puxando do invisível para o visível - Ap Sergio Pessoa.mp3')
    //             .getDownloadURL();
    //         print('URL-----------------------------------' + url.toString());
    //         audioPlayer.play(url);
    //       },
    //     ),
    //     FlatButton(
    //       child: Text('Pause'),
    //       onPressed: () => audioPlayer.pause(),
    //     )
    //   ],
    // )),
    AudioList(audioPlayer),
    Text('Index 1: Search'),
    Container(
      child: Column(
        children: <Widget>[Text('Index 2: Account')],
      ),
    )
  ];

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();

    audioPlayer.stop();
  }

  void showInSnackBar(String value) {
    _scaffoldKey.currentState
        .showSnackBar(new SnackBar(content: new Text(value)));
  }

  void _handleSignOut() {
    final AuthBloc bloc = BlocProvider.of<AuthBloc>(context);
    bloc.signOut();

    bloc.validLogin.listen((data) {
      if (data['signOut'] == true)
        Navigator.pushNamedAndRemoveUntil(context, '/Login', (_) => false);
      else
        showInSnackBar(data['message']);
    });
  }

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      key: _scaffoldKey,
      appBar: new AppBar(
        title: new Text('VERBO STORE'),
      ),
      body: Center(
        child: _widgetOptions.elementAt(_selectedIndex),
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: <BottomNavigationBarItem>[
          BottomNavigationBarItem(
              icon: Icon(Icons.home), title: Text('Início')),
          BottomNavigationBarItem(
              icon: Icon(Icons.search), title: Text('Procurar')),
          BottomNavigationBarItem(
              icon: Icon(Icons.account_circle), title: Text('Conta')),
        ],
        currentIndex: _selectedIndex,
        fixedColor: Colors.red[900],
        onTap: _onItemTapped,
      ),
    );
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
      if (index == 2) {
        _handleSignOut();
      }
    });
  }
}

// new Center(
//         child:
//           new ListView.builder(
//             padding: new EdgeInsets.all(8.0),
//             itemCount: audiosManager.listOfAudios.length,
//             itemExtent: 80.0,
//             itemBuilder: (BuildContext context, int index) {
//               return new ListTile(
//                 //leading: const Icon(Icons.flight_land),
//                 title: new Row(
//                   children: <Widget>[
//                     new Expanded(child: new Text(audiosManager.listOfAudios[index].title)),
//                     new IconButton(
//                       icon: (audiosManager.currentPlaying == index && !showPlayIcon) ? new Icon(Icons.pause) : new Icon(Icons.play_arrow),
//                       tooltip: 'Ouvir/pausar ministração',
//                       onPressed: (audiosManager.currentPlaying == index && !showPlayIcon) ? () => _pauseAudio() : () => _playAudio(index),

//                     ),
//                   ],
//                 ),
//                 subtitle: Text('Ministro: ' + audiosManager.listOfAudios[index].minister),
//                 //onTap: () { /* react to the tile being tapped */ }
//               );
//             },
//           )
//  )
