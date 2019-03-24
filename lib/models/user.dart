import 'package:flutter/material.dart';
import '../models/event.dart';

enum UserTypes { Student, Admin, E_Board, Other }

class User {
  final String name;
  final String ucid;

  User({@required name, @required ucid})
      : name = name,
        ucid = ucid;
}

class UserTypeHelper {
  static String getString(UserTypes type) {
    if (type == UserTypes.Student) {
      return "Student";
    } else if (type == UserTypes.Admin) {
      return "Admin";
    } else if (type == UserTypes.E_Board) {
      return "E-Board";
    }else{
      return "Other";
    }
  }

  static UserTypes stringToUserType(String typeStr){
    if(typeStr == "Student"){
      return UserTypes.Student;
    }else if(typeStr == "Admin"){
      return UserTypes.Admin;
    }else if(typeStr == "E-Board"){
      return UserTypes.E_Board;
    }else{
      return UserTypes.Other;
    }
  }

}
