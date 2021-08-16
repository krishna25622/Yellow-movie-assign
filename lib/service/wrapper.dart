import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:movie_list/models/user_model.dart';
import 'package:movie_list/screens/login_screen.dart';
import 'package:movie_list/screens/photo_list.dart';
import 'package:movie_list/service/service.dart';
import 'package:provider/provider.dart';

class Wrapper extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final authService = Provider.of<AuthService>(context);
    return StreamBuilder<User>(
        stream: authService.user,
        builder: (_, AsyncSnapshot<User> snapshot) {
          if (snapshot.connectionState == ConnectionState.active) {
            final User user = snapshot.data;
            return user == null ? LoginScreen() : PhotoList();
          } else {
            return Scaffold(
              body: Center(
                child: CircularProgressIndicator(),
              ),
            );
          }
        });
  }
}
