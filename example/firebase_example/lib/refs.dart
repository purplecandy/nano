import 'package:auth/auth.dart';
import 'package:contacts/contacts.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'di/di.dart';

final authRef = Pool().register<AuthState>(
    () => AuthState()..init(FirebaseAuth.instance.onAuthStateChanged));

final contactRef = Pool().register<ContactState>(() => ContactState()
  ..init(Firestore.instance.collection("contacts").snapshots()));
