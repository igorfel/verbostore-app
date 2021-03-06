import 'dart:async';
import '../consts.dart';
import 'blocProvider.dart';
import '../models/signInInfo.dart';
import '../models/signUpInfo.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:rxdart/rxdart.dart';
import 'package:verboshop/blocs/validators.dart';

class AuthBloc extends BlocBase with Validators {
  bool requesting;

  Firestore database;
  FirebaseAuth auth;
  FirebaseUser user;

  final _username = BehaviorSubject<String>();
  final _email = BehaviorSubject<String>();
  final _password = BehaviorSubject<String>();
  final _validLogin = BehaviorSubject();

  Stream<String> get username => _username.stream.transform(checkUsername);
  Stream<String> get email => _email.stream.transform(validateEmail);
  Stream<String> get password => _password.stream.transform(validatePassword);
  Stream get submitValidNewAccount =>
      Observable.combineLatest3(username, email, password, (u, e, p) => true);
  Stream get submitValidAccount =>
      Observable.combineLatest2(username, password, (u, p) => true);

  Stream get validLogin => _validLogin.stream;

  Function(String) get changeUsername => _username.sink.add;
  Function(String) get changeEmail => _email.sink.add;
  Function(String) get changePassword => _password.sink.add;

  get isPlaying => true == true;

  AuthBloc() {
    requesting = false;
    database = Firestore.instance;
    auth = FirebaseAuth.instance;
  }

  Future signIn() async {
    _validLogin.add({'requesting': true});

    SignInInfo loginInfo =
        SignInInfo(user: this._username.value, pass: this._password.value);

    // Retrieve user info from the database
    DocumentSnapshot dbUserInfo = await database
        .collection(Consts.USER_DB)
        .document(loginInfo.user)
        .get();

    if (dbUserInfo.exists) {
      // Login user with email and password
      this.user = await auth
          .signInWithEmailAndPassword(
              email: dbUserInfo['email'], password: loginInfo.pass)
          .catchError((e) => _password.addError('Senha inválida'));

      if (this.user != null) {
        _validLogin.add({'requesting': false, 'valid': true});
        erasePassword();
      } else
        _validLogin.add({'valid': false});
    } else {
      _username.addError("Usuário não encontrado");
      _validLogin.add({'valid': false});
    }
  }

  Future signUp() async {
    _validLogin.add({'requesting': true});

    FirebaseUser newUser;
    SignUpInfo signUpInfo = SignUpInfo(
        user: this._username.value,
        email: this._email.value,
        password: this._password.value);

    // Try to create a new user
    try {
      newUser = await auth.createUserWithEmailAndPassword(
          email: signUpInfo.email, password: signUpInfo.password);
    } catch (error) {
      _email.addError('Email já registrado');
      _validLogin.add({'requesting': false});

      return;
    }
    // after registering the new user add his info to the database
    database.collection(Consts.USER_DB).document(signUpInfo.user).setData({
      'uid': newUser.uid,
      'user': signUpInfo.user,
      'email': newUser.email,
      'isPremium': false,
      'created_at': FieldValue.serverTimestamp()
    });

    _validLogin.add({'requesting': false, 'valid': true});
  }

  //To sign out the current User
  Future signOut() async {
    await auth.signOut().then((onValue) {
      _validLogin.add({'requesting': false, 'valid': false, 'signOut': true});
      erasePassword();
    }).catchError((e) {
      _validLogin.add({
        'requesting': false,
        'valid': false,
        'signOut': false,
        'message': 'Erro ao sair'
      });
    });
  }

  @override
  void dispose() {
    _username.close();
    _email.close();
    _password.close();
    _validLogin.close();
  }

  void erasePassword() {
    _password.sink.add('');
  }
}
