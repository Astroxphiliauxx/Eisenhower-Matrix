import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:noteapp/screens/note_detail.dart';
import 'package:noteapp/utlis/database_helper.dart';
import 'package:provider/provider.dart';
import 'package:sqflite/sqflite.dart';

import '../modal/note.dart';
import '../modal/note_list_state.dart';


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

    return SafeArea(
      child: Scaffold(
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
            // leading: GestureDetector(
            //     onTap: (){
            //
            //     },
            //     child: Icon(Icons.menu,
            //  ),
            // ),
            automaticallyImplyLeading: true,
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
        backgroundColor: Colors.grey,
      
        body:  Padding(
          padding: const EdgeInsets.all(15),
          child: Column(
            children: [
              Expanded(
                child: Stack(
                  children: [
                    noteList.isEmpty
                        ? Center(
                            child: Column(
                             mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                             children: [
                               Lottie.asset( 'assets/empty_list.json',
                                 width: 400,
                                 height: 400,
                                 fit: BoxFit.fill,
                               ),
                               Text(
                               "Matrix is empty !!",
                                style: TextStyle(
                                   fontSize: 24,
                                 ),
                                ),
                             ],
                            ),
                         ) : getNoteListView(),
                  ],
                ),
              ),
              Align(
                alignment: Alignment.bottomCenter,
                child: Container(
                  width: MediaQuery.of(context).size.width,
                  height: 40,
                  margin: const EdgeInsets.only(top: 5),
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
                    onPressed: () {
                      navigateToDetail(Note('', 1, '', ''), 'Add Note');
                    },
                    child: Text("Add Matrix"),
                  ),
                ),
              ),
            ],
          ),
        ),
      
        drawer: Drawer(
          child: ListView(
            padding: EdgeInsets.zero,
            children: <Widget>[
              const DrawerHeader(
                child: Text("Header"),
                decoration: BoxDecoration(color: Colors.blue),
              ),
              ListTile(
                title: const Text("Text1"),
                leading: const Icon(Icons.railway_alert_rounded),
                onTap: (){
                  Navigator.pop(context);
                },
              ),
              ListTile(
                title: const Text("Text1"),
                leading: const Icon(Icons.offline_pin_rounded),
                onTap: (){
                  Navigator.pop(context);
                },
              ),
              ListTile(
                title: const Text("Text2"),
                leading: const Icon(Icons.key),
                onTap: (){
                  Navigator.pop(context);
                },
              ),
              ListTile(
                title: const Text("Text3"),
                leading: const Icon(Icons.hail),
                onTap: (){
                  Navigator.pop(context);
                },
              ),
              ListTile(
                title: const Text("Text4"),
                leading: const Icon(Icons.back_hand),
                onTap: (){
                  Navigator.pop(context);
                },
              ),
      
            ],
          ),
        ),
      
      ),
    );
  }
  ListView getNoteListView(){
    final noteListState = Provider.of<NoteListState>(context, listen: false);

    return ListView.builder(

     itemCount: count,
        itemBuilder: (BuildContext context, int position){

          return Card(
            margin: EdgeInsets.only(bottom: 8.0),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(15),
              // Sets the border radius to 30
            ),

            //color: Color.fromARGB(0.1, 12, 12, 1),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(15), // Ensures the child respects the border radius
              child: Container(
                color: Colors.white10, // Background color of the ListTile
                child: ListTile(
                  selectedTileColor: Colors.black12,
                  onTap: () {
                    navigateToDetail(this.noteList[position], 'Edit Note');
                  },
                  leading: CircleAvatar(
                    backgroundColor: getPriorityColor(this.noteList[position].priority),
                    child: getPriorityIcon(this.noteList[position].priority),
                  ),
                  title: Text(this.noteList[position].title),
                  subtitle: Text(this.noteList[position].date),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        onPressed: () {
                          cupertinoDialogDelete("Delete", "You want to delete this note?", position);
                        },
                        icon: Icon(Icons.delete),
                      ),
                      IconButton(
                        onPressed: () {
                         noteListState.toggleNoteLock(position);
                        },
                        icon: const Icon(Icons.lock_open_rounded),
                      ),


                    ],
                  ),
                ),
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

  Future<void> cupertinoDialogDelete(String title, String content, int position) async{
    showDialog(
        context: context,
        builder: (BuildContext context){
          return CupertinoAlertDialog(
            title:  Text(title),
            content: Text(content),
            actions: <Widget>[
              CupertinoDialogAction(
                child: Text('Yes'),
                onPressed: (){
                  _delete(context, noteList[position]);
                  Navigator.of(context).pop();
                },
              ),
              CupertinoDialogAction(
                  child: Text("No"),
              onPressed: (){
                    Navigator.of(context).pop();
              },)
            ],
          );
        }
    );
  }
}
