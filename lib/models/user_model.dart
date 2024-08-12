import 'dart:convert';
import 'package:flutter/foundation.dart';

class UserModel {
  final String name;
  final String profilePic;
  final String banner;
  final String uid;
  final bool isAuthenticated;
  final int Karma;
  final List<String> awards;

  UserModel({
    required this.name,
    required this.profilePic,
    required this.banner,
    required this.uid,
    required this.isAuthenticated,
    required this.Karma,
    required this.awards,
  });

  UserModel copyWith({
    String? name,
    String? profilePic,
    String? banner,
    String? uid,
    bool? isAuthenticated,
    int? Karma,
    List<String>? awards,
  }) {
    return UserModel(
      name: name ?? this.name,
      profilePic: profilePic ?? this.profilePic,
      banner: banner ?? this.banner,
      uid: uid ?? this.uid,
      isAuthenticated: isAuthenticated ?? this.isAuthenticated,
      Karma: Karma ?? this.Karma,
      awards: awards ?? this.awards,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'name': name,
      'profilePic': profilePic,
      'banner': banner,
      'uid': uid,
      'isAuthenticated': isAuthenticated,
      'Karma': Karma,
      'awards': awards,
    };
  }

  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      name: map['name'] as String? ?? 'No Name',
      profilePic: map['profilePic'] as String? ?? 'No Profile Pic',
      banner: map['banner'] as String? ?? 'No Banner',
      uid: map['uid'] as String? ?? 'No UID',
      isAuthenticated: map['isAuthenticated'] as bool? ?? false,
      Karma: map['Karma'] as int? ?? 0,
      awards: List<String>.from(
        (map['awards'] as List<dynamic>?)?.map((item) => item.toString()) ?? [],
      ),
    );
  }

  String toJson() => json.encode(toMap());

  factory UserModel.fromJson(String source) => UserModel.fromMap(json.decode(source));

  @override
  String toString() {
    return 'UserModel(name: $name, profilePic: $profilePic, banner: $banner, uid: $uid, isAuthenticated: $isAuthenticated, Karma: $Karma, awards: $awards)';
  }

  @override
  bool operator ==(covariant UserModel other) {
    if (identical(this, other)) return true;

    return 
      other.name == name &&
      other.profilePic == profilePic &&
      other.banner == banner &&
      other.uid == uid &&
      other.isAuthenticated == isAuthenticated &&
      other.Karma == Karma &&
      listEquals(other.awards, awards);
  }

  @override
  int get hashCode {
    return name.hashCode ^
      profilePic.hashCode ^
      banner.hashCode ^
      uid.hashCode ^
      isAuthenticated.hashCode ^
      Karma.hashCode ^
      awards.hashCode;
  }
}
