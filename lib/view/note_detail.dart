import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:intl/intl.dart';
import 'package:noteapp/utlis/database_helper.dart';
import '../modal/note.dart';

class NoteDetail extends StatefulWidget {

  final Note note;
  final String appBarTitle;
  NoteDetail(this.note,this.appBarTitle);

  @override
  State<NoteDetail> createState() => _NoteDetailState(this.note,this.appBarTitle);
}

class _NoteDetailState extends State<NoteDetail> {

   DatabaseHelper helper = DatabaseHelper();
   Note note;
   String appBarTitle;
  _NoteDetailState(this.note, this.appBarTitle);

 TextEditingController titleController = TextEditingController();
 TextEditingController descriptionController = TextEditingController();

  static var _priorities = [
    'Important & Urgent',
    'Unimportant & Urgent',
    'Important & not Urgent',
    'Unimportant & not Urgent'
  ];
  bool _isTitleEmpty = false;
  bool _isTitleLarge= false;

   @override
   void initState() {
     super.initState();
     titleController.text = note.title;
     descriptionController.text = note.description;
   }

  @override
  Widget build(BuildContext context) {

    titleController.text= note.title;
    descriptionController.text=note.description;

    return Scaffold(
      appBar: AppBar(
        title: Text(appBarTitle),
        backgroundColor: Colors.blueGrey,
        leading: IconButton(icon: Icon(CupertinoIcons.back), onPressed: () { Navigator.pop(context); },),
      ),
      body: Padding(
          padding: EdgeInsets.all(15),
        child: ListView(

          children: [
            ListTile(
              title: DropdownButton(
                items: _priorities.map((String DropDownStringItem){
                  return DropdownMenuItem<String> (
                  value: DropDownStringItem,
                  child: Text(DropDownStringItem),
                  );
              }).toList(),
                style: TextStyle(color: Colors.black),
                value: getPriorityAsString(note.priority),
                onChanged: (valueSelectedByUser){
                  setState(() {
                    debugPrint('user selected $valueSelectedByUser');
                    updatePriorityAsInt(valueSelectedByUser!);
                  });
                }
                ,
              ),
            ),

            Padding(
              padding: EdgeInsets.only(top: 15, bottom: 10),
            child: TextField(
              controller: titleController,
              style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
              onChanged: (value){
                setState(() {
                  _isTitleEmpty = value.isEmpty;
                  if(value.length>=25){
                    _isTitleLarge=true;
                  }
                  else {
                    _isTitleLarge= false;
                  }
                });

                updateTitle();
              },


              decoration: InputDecoration(
                labelText: 'Title',
                labelStyle: TextStyle(),

                 errorText: !_isTitleEmpty ? _isTitleLarge? ' Title can\'t be this large': null :'Title can\'t be empty' ,


                border: OutlineInputBorder(borderRadius: BorderRadius.circular(8.0)
              ),
            ),
           ),
            ),

            Padding(
              padding: EdgeInsets.only(top: 10, bottom: 10),
              child: TextField(
                controller: descriptionController,
                style: TextStyle(),
                onChanged: (value){

                  updateDescription();
                },

                decoration: InputDecoration(
                  labelText: 'Description',
                  labelStyle: TextStyle(),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(8.0)
                  ),
                ),
                maxLines: 7,
                minLines: 1,
              ),
            ),
            Padding(padding: EdgeInsets.only(top: 10, bottom: 10),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                ElevatedButton(
                    onPressed: (){
                      setState(() {
                         if(note.title.isNotEmpty){
                           _save();
                         }
                      });
                    },
                    child: Text('Save')),
                ElevatedButton(
                    onPressed: (){
                      setState(() {
                         _delete();
                      });
                    },
                    child: Text('Delete'))
              ],
            ),

            )
          ],
        ),
      ),
    );
  }

  void updatePriorityAsInt(String value){
    switch(value){
      case 'Important & Urgent':
        note.priority= 1;
      case 'Unimportant & Urgent':
        note.priority=2;
      case 'Important & not Urgent':
        note.priority=3;
      case 'Unimportant & not Urgent':
        note.priority=4;
    }
  }
  
  String getPriorityAsString(int value){
    String priority=" ";
    switch(value){
      case 1:
        priority = _priorities[0];
      case 2:
        priority= _priorities[1];
      case 3:
        priority= _priorities[2];
      case 4:
        priority= _priorities[3];
    }
    return priority;
  }

  void updateTitle(){
    note.title= titleController.text;
  }
  void updateDescription(){
    note.description= descriptionController.text;
  }
  void _save() async{


    note.date= DateFormat.yMMMd().format(DateTime.now());

    int result;
    if(note.id!=null){
      result= await helper.updateNote(note);
    }
    else{
      result=  await helper.insertNote(note);
    }
    Navigator.pop(context, true);

    if(result!=0){
       cupertinoDialog('Status', 'Note Saved Successfully');
    }
    else{
      cupertinoDialog("Status", 'Not Saved');
    }

  }
  
  void _delete() async{

    Navigator.pop(context,true);
    int result = await helper.deleteNote(note.id ??0); //?? handle if the id is null then it throws 0

    if(result!=0){
      cupertinoDialog("Status", "Note was deleted");
    }
    else{
      cupertinoDialog('Status', "error was occurred");
    }

  }



  Future<void> cupertinoDialog(String title, String content) async{
    showDialog(
        context: context,
        builder: (BuildContext context){
          return CupertinoAlertDialog(
            title:  Text(title),
            content: Text(content),
            actions: <Widget>[
              CupertinoDialogAction(
                child: Text('Ok'),
                onPressed: (){
                  Navigator.pop(context);
                },
              )
            ],
          );
        }
    );
  }
}



