import 'dart:async';
import 'package:flutter/material.dart';
import 'package:movie_list/models/photo.dart';
import 'package:movie_list/screens/photo_detail.dart';
import 'package:movie_list/utils/database_helper.dart';
import 'package:movie_list/utils/util.dart';
import 'package:sqflite/sqflite.dart';

class PhotoList extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return PhotoListState();
  }
}

class PhotoListState extends State<PhotoList> {
  DatabaseHelper databaseHelper = DatabaseHelper();
  List<Photo> noteList;
  int count = 0;

  @override
  Widget build(BuildContext context) {
    if (noteList == null) {
      noteList = List<Photo>();
      updateListView();
    }

    var colors;
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Yellow Class Assignment',
          style: TextStyle(color: Colors.black),
        ),
      ),
      body: getNoteListView(),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          debugPrint('FAB clicked');
          navigateToDetail(Photo('', '', ''), 'Add Movie');
        },
        tooltip: 'Add Movie',
        child: Icon(Icons.add),
        backgroundColor: Colors.yellow,
        foregroundColor: Colors.black,
      ),
    );
  }

  ListView getNoteListView() {
    TextStyle titleStyle = Theme.of(context).textTheme.subhead;

    return ListView.builder(
      itemCount: count,
      itemBuilder: (BuildContext context, int position) {
        return Card(
          elevation: 5,
          child: Row(
            children: <Widget>[
              Container(
                height: 180,
                width: 150,
                child: Utility.imageFromBase64String(
                    this.noteList[position].movieImage),
              ),
              Container(
                padding: const EdgeInsets.all(10),
                height: 80,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      this.noteList[position].movieTitle,
                      style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.black),
                    ),
                    SizedBox(
                      height: 10,
                    ),
                    Container(
                      width: 80,
                      child: Text(
                        this.noteList[position].director,
                        style: TextStyle(color: Colors.black),
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.all(10),
                height: 150,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    // Icon(Icons.delete, color: Colors.grey,),
                    //
                    //
                    TextButton(
                        onPressed: () {
                          _delete(context, noteList[position]);
                        },
                        child: Icon(
                          Icons.delete,
                          color: Colors.red[500],
                        )),

                    SizedBox(
                      height: 10,
                    ),

                    TextButton(
                        onPressed: () {
                          navigateToDetail(
                              this.noteList[position], 'Edit Movie');
                        },
                        child: Icon(
                          Icons.edit,
                          color: Colors.green,
                        ))
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _delete(BuildContext context, Photo note) async {
    int result = await databaseHelper.deletePhoto(note.id);
    if (result != 0) {
      _showSnackBar(context, 'Movie Deleted Successfully');
      updateListView();
    }
  }

  void _showSnackBar(BuildContext context, String message) {
    final snackBar = SnackBar(content: Text(message));
    Scaffold.of(context).showSnackBar(snackBar);
  }

  void navigateToDetail(Photo photo, String title) async {
    bool result =
        await Navigator.push(context, MaterialPageRoute(builder: (context) {
      return NoteDetail(photo, title);
    }));

    if (result == true) {
      updateListView();
    }
  }

  void updateListView() {
    final Future<Database> dbFuture = databaseHelper.initializeDatabase();
    dbFuture.then((database) {
      Future<List<Photo>> noteListFuture = databaseHelper.getNoteList();
      noteListFuture.then((noteList) {
        setState(() {
          this.noteList = noteList;
          this.count = noteList.length;
        });
      });
    });
  }
}
