import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:noteapp/screens/note_detail.dart';
import 'package:noteapp/utlis/database_helper.dart';
import 'package:sqflite/sqflite.dart';

import '../modal/note.dart';


class NoteList extends StatefulWidget {
  NoteList({super.key});

  @override
  State<NoteList> createState() => _NoteListState();
}

class _NoteListState extends State<NoteList> {
  DatabaseHelper dataBaseHelper = DatabaseHelper();
   List<Note> noteList=[];
  int count=0;

  @override
  Widget build(BuildContext context) {

    if(noteList.isEmpty) {
      updateListView();
    }

    return Scaffold(
      appBar: AppBar(
          actionsIconTheme: IconThemeData(
            size: 30.0,
            color: Colors.black,

          ),
          backgroundColor: Colors.blueGrey,
          title: Text('The Eisenhower Matrix',
          textAlign: TextAlign.left),
          titleTextStyle: TextStyle(
            color: Colors.black,
            fontSize: 21
          ),
          leading: GestureDetector(
              onTap: (){},
              child: Icon(Icons.menu,
           ),
          ),
          automaticallyImplyLeading: false,
          actions: [
           Padding(
               padding: EdgeInsets.only(right: 20.0),
               child: GestureDetector(
                 onTap: () {},
                 child: Icon(
                     Icons.more_vert
                 ),
               )
           ),
         ],

      ),
      body:  Padding(
        padding: const EdgeInsets.all(15.0),
        child: Container(
          height: MediaQuery.of(context).size.height,
          width: MediaQuery.of(context).size.width,
          child: Stack(
            children: [
              getNoteListView(),
              Align(
                  alignment: Alignment.bottomCenter,

                  child: Container(
                    height: MediaQuery.of(context).size.height-740,
                    width:  MediaQuery.of(context).size.width-50,
                    
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                          shadowColor: Colors.black,
                          backgroundColor: Colors.blueGrey,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10.0),
                          ),
                          textStyle: TextStyle(
                              color: Colors.black,
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                          ),
                        ),
                        onPressed: (){
                          navigateToDetail( Note('', 2, '',''), 'Add Note');
                        },
                        child: Text("Add Matrix"),
                    ),
                  ))
            ],
          ),
        ),
      ),
    );
  }
  ListView getNoteListView(){
     return ListView.builder(
        itemCount: count,
        itemBuilder: (BuildContext context, int position){
          return Card(

            elevation: 3,
            color: Colors.white30,
            child: ListTile(

              onTap: (){
                navigateToDetail(this.noteList[position],'Edit Note');
              },
              leading: CircleAvatar(
                backgroundColor: getPriorityColor(this.noteList[position].priority),
                child: getPriorityIcon(this.noteList[position].priority)
              ),

              title: Text(this.noteList[position].title),
              subtitle: Text(this.noteList[position].date),
              trailing: IconButton(
                onPressed: (){
                  _delete(context, noteList[position]);
                },
                icon: Icon(Icons.delete) ,
              ),
            ),
          );
        }
    );
  }
  Color? getPriorityColor(int priority){
    switch (priority){
      case 1:
        return Colors.red;
      case 2:
        return Colors.yellow;
      case 3:
        return Colors.pinkAccent;
      case 4:
        return Colors.black54;
    }
  }
  Icon? getPriorityIcon( int priority){
    switch(priority){
      case 1:
        return Icon(Icons.chevron_right);
      case 2:
        return Icon(Icons.ac_unit);
      case 3:
        return Icon(Icons.access_alarm_sharp);
      case 4:
        return Icon(Icons.accessibility_new_outlined);
    }
  }

  void _delete(BuildContext context, Note note) async {

    if (note.id != null) {  // Ensure id is not null
      int result = await dataBaseHelper.deleteNote(note.id!); // Use null-aware operator
      if (result != 0) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Deleted Successfully")),
        );
        updateListView();
      }
    } else {
      // Handle the case when id is null
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error: Note ID is null")),
      );
    }
  }

  void updateListView(){
    final Future<Database> dbFuture= dataBaseHelper.initializeDatabase();
    dbFuture.then((Database){
      Future<List<Note>> noteListFuture = dataBaseHelper.getNoteList();
      noteListFuture.then((noteList){
        setState(() {
          this.noteList= noteList;
          this.count= noteList.length;
        });
      });
    });
  }

  void navigateToDetail(Note note, String title) async {
    bool result = await Navigator.push(context, MaterialPageRoute(builder: (context) {
      return NoteDetail(note, title);
    }));

    if (result == true) {
      updateListView();
    }
  }
}