
import 'dart:io';

import 'package:church_of_christ/data/models/user.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';

import 'event.dart';

class DbChurch {
  final String USERS = "users";
  final String EVENTSCHURCH = "events";

  final Firestore _db = Firestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final StorageReference _storageReference = FirebaseStorage.instance.ref();

  Future<void> updateUserData(User user) async{
    DocumentReference ref = _db.collection(USERS).document(user.uid);
    return await ref.setData({
      'uid': user.uid,
      'name': user.name,
      'email': user.email,
      'photoURL': user.photoURL,
      //'myPlaces': user.myPlaces,
      //'myFavoritePlaces': user.myFavoritePlaces,
      'isAdmin': user.isAdmin,
      'lastSignIn': DateTime.now(),
      'birthday': user.birthday,
      'baptized': user.baptized,
      'baptismDate': user.baptismDate
    }, merge: true);
  }

  Future<void> updateBirthday(User user) async{
    DocumentReference refUser = _db.collection(USERS).document(user.uid);
    refUser.updateData({
      "birthday": user.birthday
    });
  }

  Future<void> updateBaptized(User user) async{
    DocumentReference refUser = _db.collection(USERS).document(user.uid);
    refUser.updateData({
      "baptized": user.baptized
    });
  }

  Future<void> updateBaptismDate(User user) async{
    DocumentReference refUser = _db.collection(USERS).document(user.uid);
    refUser.updateData({
      "baptismDate": user.baptismDate
    });
  }

  Future<User> getUser(String id) async {
    var snap = await _db.collection(USERS).document(id).get();

    return User.fromMap(snap.data);
  }

  Stream<User> streamUser(String id) {
    return _db.collection(USERS)
        .document(id)
        .snapshots()
        .map((snap) => User.fromMap(snap.data));
  }

  Future<void> updateEvent(EventModel myEvent) async{
    CollectionReference refEvents = _db.collection(EVENTSCHURCH);

    await _auth.currentUser().then((FirebaseUser user){
      refEvents.add({
        'urlImage': myEvent.urlImage,
        'title': myEvent.title,
        'description': myEvent.description,
        'address': myEvent.address,
        'currency': myEvent.currency,
        'price': myEvent.price,
        'urlVideo': myEvent.urlVideo,
        'urlTwitter': myEvent.urlTwitter,
        'urlFb': myEvent.urlFb,
        'dateTime': myEvent.dateTime,
        'userOwner': _db.document("${USERS}/${user.uid}"), //reference
      });
    });
  }

  Future<StorageUploadTask> uploadFile(String path, File image) async{
    return _storageReference.child(path).putFile(image);
  }
}