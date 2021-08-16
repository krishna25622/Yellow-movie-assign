import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:movie_list/models/photo.dart';
import 'package:movie_list/utils/database_helper.dart';

import 'package:movie_list/utils/util.dart';

class NoteDetail extends StatefulWidget {
  final String appBarTitle;
  final Photo photo;

  NoteDetail(this.photo, this.appBarTitle);

  @override
  State<StatefulWidget> createState() {
    return NoteDetailState(this.photo, this.appBarTitle);
  }
}

class NoteDetailState extends State<NoteDetail> {
  DatabaseHelper helper = DatabaseHelper();

  String appBarTitle;
  Photo photo;

  TextEditingController titleController = TextEditingController();
  TextEditingController descriptionController = TextEditingController();

  // String imageString;

  NoteDetailState(this.photo, this.appBarTitle);

  @override
  Widget build(BuildContext context) {
    TextStyle textStyle = Theme.of(context).textTheme.title;

    titleController.text = photo.movieTitle;

    descriptionController.text = photo.director;

    return WillPopScope(
        onWillPop: () {
          // Write some code to control things, when user press Back navigation button in device navigationBar
          moveToLastScreen();
        },
        child: Scaffold(
          appBar: AppBar(
            // title: Text(appBarTitle),
            leading: IconButton(
                icon: Icon(Icons.arrow_back, color: Colors.black),
                onPressed: () {
                  // Write some code to control things, when user press back button in AppBar
                  moveToLastScreen();
                }),
          ),
          body: Padding(
            padding: EdgeInsets.only(top: 15.0, left: 10.0, right: 10.0),
            child: ListView(
              children: <Widget>[
                // First Element
                // Utility.imageFromBase64String(photo.movieImage),

                //Second Element

                Padding(
                  padding: EdgeInsets.only(top: 15.0, bottom: 15.0),
                  child: Row(
                    children: <Widget>[
                      Expanded(
                        child: RaisedButton(
                          color: Theme.of(context).primaryColorDark,
                          textColor: Colors.black,
                          child: Text(
                            'Add Image',
                            textScaleFactor: 1.5,
                          ),
                          onPressed: () {
                            pickImageFromGallery();
                          },
                        ),
                      ),
                    ],
                  ),
                ),

                // Third Element
                Padding(
                  padding: EdgeInsets.only(top: 15.0, bottom: 15.0),
                  child: TextField(
                    controller: titleController,
                    style: textStyle,
                    onChanged: (value) {
                      debugPrint('Something changed in Title Text Field');
                      updateTitle();
                    },
                    decoration: InputDecoration(
                        labelText: 'Movie Name',
                        labelStyle: textStyle,
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(5.0))),
                  ),
                ),

                // Fifth Element
                Padding(
                  padding: EdgeInsets.only(top: 15.0, bottom: 15.0),
                  child: TextField(
                    controller: descriptionController,
                    style: textStyle,
                    onChanged: (value) {
                      debugPrint('Something changed in Description Text Field');
                      updateDescription();
                    },
                    decoration: InputDecoration(
                        labelText: 'Director name',
                        labelStyle: textStyle,
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(5.0))),
                  ),
                ),

                // Sixth Element
                Padding(
                  padding: EdgeInsets.only(top: 15.0, bottom: 15.0),
                  child: Row(
                    children: <Widget>[
                      Expanded(
                        child: RaisedButton(
                          color: Colors.green,
                          textColor: Colors.black,
                          child: Text(
                            'Save',
                            textScaleFactor: 1.5,
                          ),
                          onPressed: () {
                            setState(() {
                              debugPrint("Save button clicked");
                              _save();
                            });
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ));
  }

  void moveToLastScreen() {
    Navigator.pop(context, true);
  }

  // void updateImage(){
  // 	photo.movieImage = movieimageController.text;
  // }

  // Update the title of Note object
  void updateTitle() {
    photo.movieTitle = titleController.text;
  }

  // Update the description of Note object
  void updateDescription() {
    photo.director = descriptionController.text;
  }

  // Save data to database
  void _save() async {
    moveToLastScreen();

    photo.date = DateFormat.yMMMd().format(DateTime.now());
    int result;
    if (photo.id != null) {
      // Case 1: Update operation
      result = await helper.updateNote(photo);
    } else {
      // Case 2: Insert Operation
      result = await helper.insertNote(photo);
    }

    if (result != 0) {
      // Success
      _showAlertDialog('Status', 'Movie Saved Successfully');
    } else {
      // Failure
      _showAlertDialog('Status', 'Problem Saving Movie');
    }
  }

  void _delete() async {
    moveToLastScreen();

    // Case 1: If user is trying to delete the NEW NOTE i.e. he has come to
    // the detail page by pressing the FAB of NoteList page.
    if (photo.id == null) {
      _showAlertDialog('Status', 'No Movie was deleted');
      return;
    }

    // Case 2: User is trying to delete the old note that already has a valid ID.
    int result = await helper.deletePhoto(photo.id);
    if (result != 0) {
      _showAlertDialog('Status', 'Movie Deleted Successfully');
    } else {
      _showAlertDialog('Status', 'Error Occurred while Deleting Movie');
    }
  }

  void _showAlertDialog(String title, String message) {
    AlertDialog alertDialog = AlertDialog(
      title: Text(title),
      content: Text(message),
    );
    showDialog(context: context, builder: (_) => alertDialog);
  }

  pickImageFromGallery() {
    ImagePicker.pickImage(source: ImageSource.gallery).then((imgFile) {
      String imgString = Utility.base64String(imgFile.readAsBytesSync());
      photo.movieImage = imgString;
    });
  }
}
