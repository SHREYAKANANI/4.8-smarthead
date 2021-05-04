import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'dart:async';//
import 'package:flutter_app/models/note.dart';//
import 'package:flutter_app/utils/database_helper.dart';//
import 'package:intl/intl.dart';//

class NoteDetail extends StatefulWidget {
  final String appBarTitle;
  final Note note;

  NoteDetail(this.note, this.appBarTitle);

  @override
  State<StatefulWidget> createState() {
    return NoteDetailState(this.note, this.appBarTitle);
  }
}

class NoteDetailState extends State<NoteDetail> {
  static var _priorities = ['High', 'Low'];
  DatabaseHelper helper = DatabaseHelper();
  String appBarTitle;
  Note note;
  TextEditingController titleController = TextEditingController();
  TextEditingController descriptionController = TextEditingController();

  NoteDetailState(this.note, this.appBarTitle);

  @override
  Widget build(BuildContext context) {
    TextStyle textStyle = Theme.of(context).textTheme.subtitle1;
    titleController.text = note.title;
    descriptionController.text = note.description;
    return WillPopScope(
        onWillPop: () {
          moveToLastScreen();
        },
        child: Scaffold(
            appBar: AppBar(
              title: Text(appBarTitle),
              leading: IconButton(
                icon: Icon(Icons.arrow_back),
                onPressed: () {
                  moveToLastScreen();
                },
              ),
            ),
            body: Padding(
                padding: EdgeInsets.only(top: 15.0, left: 10.0, right: 10.0),
                child: ListView(
                  children: [
                    ListTile(
                      title: DropdownButton(
                          items: _priorities.map((String dropDownStringItem) {
                            return DropdownMenuItem<String>(
                              value: dropDownStringItem,
                              child: Text(dropDownStringItem),
                            );
                          }).toList(),
                          style: textStyle,
                          value: getPriorityAsString(note.priority),
                          onChanged: (ValueSelectedbyUser) {
                            setState(() {
                              debugPrint('User selected $ValueSelectedbyUser');
                              updatePriorityAsInt(ValueSelectedbyUser);
                            });
                          }),
                    ),
                    Padding(
                        padding: EdgeInsets.only(top: 15.0, bottom: 15.0),
                        child: TextField(
                            controller: titleController,
                            style: textStyle,
                            onChanged: (value) {
                              debugPrint(
                                  'Something changed in title Text Field');
                              updateTitle();
                            },
                            decoration: InputDecoration(
                                labelText: 'Title',
                                labelStyle: textStyle,
                                border: OutlineInputBorder(
                                    borderRadius:
                                    BorderRadius.circular(5.0))))),
                    Padding(
                        padding: EdgeInsets.only(top: 15.0, bottom: 15.0),
                        child: TextField(
                            controller: descriptionController,
                            style: textStyle,
                            onChanged: (value) {
                              debugPrint(
                                  'Something changed in description Text Field');
                              updateDescription();
                            },
                            decoration: InputDecoration(
                                labelText: 'description',
                                labelStyle: textStyle,
                                border: OutlineInputBorder(
                                    borderRadius:
                                    BorderRadius.circular(5.0))))),
                    Padding(
                        padding: EdgeInsets.only(top: 15.0, bottom: 15.0),
                        child: Row(
                          children: [
                            Expanded(
                                child: ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                    primary: Colors.purple,
                                    onPrimary: Colors.white,
                                  ),
                                  child: Text(
                                    'SAVE',
                                    textScaleFactor: 1.5,
                                  ),
                                  onPressed: () {
                                    setState(() {
                                      debugPrint("Save button clicked");
                                      _save();
                                    });
                                  },
                                )),
                            Container(width: 5.0),
                            Expanded(
                                child: ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                    primary: Colors.purple,
                                    onPrimary: Colors.white,
                                  ),
                                  child: Text(
                                    'Delete',
                                    textScaleFactor: 1.5,
                                  ),
                                  onPressed: () {
                                    setState(() {
                                      debugPrint("Delete button clicked");
                                    });
                                  },
                                ))
                          ],
                        ))
                  ],
                ))));
  }

  void moveToLastScreen() {
    Navigator.pop(context, true);
  }
  //convert the String priority in the form of integer before saving it to database
   void updatePriorityAsInt(String value) {
    switch (value) {
      case 'High':
        note.priority = 1;
        break;
      case 'Low':
        note.priority=2;
        break;
        
    }
   }
   //Convert int priority to String priority and display it to user in DropDown
   String getPriorityAsString (int value) {
    String priority;
    switch (value) {
      case 1:
        priority = _priorities[0];
        break;
      case 2:
        priority = _priorities[1];
        break;
    }
    return priority;
   }
   //Update the title of note object
void updateTitle() {
    note.title = titleController.text;
}
//update the description of note object
void updateDescription () {
    note.description = descriptionController.text;
}
//save date to database
void _save() async{
    moveToLastScreen();
    note.date = DateFormat.yMMMd().format(DateTime.now());
    int result;
    if (note.id != null) { //case 1: Update operation
      result = await helper.updateNote(note);
    } else { //Case 2: Insert operation
     result = await helper.insertNote(note);
    }
    if (result != 0) {  //success
      _showAlertDialogue('Status', 'Note Saved Successfully');
    } else {  //failure
      _showAlertDialogue('Status', 'Problem Saving Note');
    }
}
void _delete() async{
    moveToLastScreen();
    //Case 1:If user is trying to delete the NEW NOTE i.e. he has come to
  //the detail page by pressing the FAB of NoteList page.
  if (note.id == null) {
    _showAlertDialogue('Status', 'No Notes was deleted');
    return;
  }

  //Case 2: User is trying to delete the old ote that already has a valid ID.
  int result = await helper.deleteNote(note.id);
  if (result != 0) {
    _showAlertDialogue('Status', 'Note Deleted Successfully');

  } else {
    _showAlertDialogue('Status', 'Error Occured while Deleting Note');
  }
}
void _showAlertDialogue(String title, String message) {
    AlertDialog alertDialog = AlertDialog(
      title: Text(title),
      content: Text(message),
    );
    showDialog(
        context: context,
        builder: (_) => alertDialog);
}

}

