import 'package:flutter/material.dart';
import '../database_helper.dart';
import '../Note.dart';
import 'package:intl/intl.dart';

class NoteDetail extends StatefulWidget {
  Note note;
  String appBarTitle;

  NoteDetail(this.note, this.appBarTitle, {super.key});

  @override
  State<NoteDetail> createState() {
    return NoteDetailState(note, appBarTitle);
  }
}

class NoteDetailState extends State<NoteDetail> {
  static final _priorities = ["High", "Low"];
  DatabaseHelper helper = DatabaseHelper();
  Note note;
  String appBarTitle;

  NoteDetailState(this.note, this.appBarTitle);

  TextEditingController? titleController = TextEditingController();
  TextEditingController? descriptionController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    TextStyle? textStyle = Theme.of(context).textTheme.titleMedium;

    titleController?.text = note.title;
    descriptionController?.text = note.description.toString();

    return WillPopScope(
      onWillPop: (() async {
        moveToLastScreen();
        return true;
      }),
      child: Scaffold(
        backgroundColor: Colors.cyanAccent,
        appBar: AppBar(
          title: Text(appBarTitle),
          backgroundColor: Colors.blueGrey,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: (() {
              moveToLastScreen();
            }),
          ),
        ),
        body: Padding(
          padding: const EdgeInsets.all(10.0),
          child: Card(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(15.0),
            ),
            child: ListView(
              children: <Widget>[
                //first element
                Padding(
                  padding: const EdgeInsets.only(top: 15.0, bottom: 5.0),
                  child: ListTile(
                    leading: const Icon(Icons.low_priority),
                    title: DropdownButton(
                      items: _priorities.map((String dropDownStringItem) {
                        return DropdownMenuItem<String>(
                            value: dropDownStringItem,
                            child: Text(
                              dropDownStringItem,
                              style: const TextStyle(
                                fontSize: 20.0,
                                fontWeight: FontWeight.bold,
                                color: Colors.deepPurple,
                              ),
                            ));
                      }).toList(),
                      value: getPriorityAsString(note.priority),
                      onChanged: ((valueSelectedByUser) {
                        setState(() {
                          updatePriority(valueSelectedByUser.toString());
                        });
                      }),
                    ),
                  ),
                ),

                //second element:
                Padding(
                  padding: const EdgeInsets.only(top: 15.0, bottom: 5.0, left: 15.0),
                  child: TextField(
                    autofocus: true,
                    controller: titleController,
                    onChanged: ((value) {
                      updateTitle();
                    }),
                    decoration: InputDecoration(
                      label: const Text("Title"),
                      labelStyle: textStyle,
                      icon: const Icon(Icons.title),
                    ),
                  ),
                ),

                //third element
                Padding(
                  padding: const EdgeInsets.only(top: 15.0, bottom: 5.0, left: 15.0),
                  child: TextField(
                    autofocus: true,
                    controller: descriptionController,
                    onChanged: ((value) {
                      updateDescription();
                    }),
                    decoration: InputDecoration(
                      label: const Text("Description"),
                      labelStyle: textStyle,
                      icon: const Icon(Icons.description),
                    ),
                  ),
                ),

                //fourth element
                Padding(
                  padding: const EdgeInsets.all(15.0),
                  child: Row(
                    children: <Widget>[
                      Expanded(
                        child: MaterialButton(
                          onPressed: () {
                            setState(() {
                              _save();
                            });
                          },
                          textColor: Colors.white,
                          color: Colors.indigoAccent,
                          padding: const EdgeInsets.all(8.0),
                          child: const Text(
                            "Save",
                            textScaleFactor: 1.5,
                          ),
                        ),
                      ),
                      Container(
                        width: 5.0,
                      ),
                      Expanded(
                        child: MaterialButton(
                          onPressed: () {
                            setState(() {
                              _delete();
                            });
                          },
                          textColor: Colors.white,
                          color: Colors.grey,
                          padding: const EdgeInsets.all(8.0),
                          child: const Text(
                            "Delete",
                            textScaleFactor: 1.5,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void updateTitle() {
    note.title = titleController?.text;
  }

  void updateDescription() {
    note.description = descriptionController?.text;
  }

//convert String to int and save in database
  void updatePriority(String value) {
    switch (value) {
      case "High":
        note.priority = 1;
        break;
    }
  }

//convert int from database to String to show to the user
  String? getPriorityAsString(int value) {
    String? priority;
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

  void _showAlertDialog(String title, String message) {
    AlertDialog alertDialog = AlertDialog(
      title: Text(title),
      content: Text(message),
    );

    showDialog(context: context, builder: (_) => alertDialog);
  }

  void _save() async {
    moveToLastScreen();

    note.date = DateFormat.yMMMd().format(DateTime.now());
    int result;
    if (note.id != null) {
      result = await helper.updateNote(note);
    } else {
      result = await helper.insertNote(note.id, note.title, note.date, note.priority, note.description);
    }

    if (result != 0) {
      _showAlertDialog("Status", "Note saved Successfully");
    } else {
      _showAlertDialog("Status", "Problem Saving Note");
    }
  }

  void _delete() async {
    moveToLastScreen();

    if (note.id == null) {
      _showAlertDialog("Status", "First Add a note");
    }
    int result = await helper.deleteNote(note.id);
    if (result != 0) {
      _showAlertDialog("Status", "Note deleted Successfully");
    } else {
      _showAlertDialog("Status", "Error");
    }
  }

  void moveToLastScreen() {
    Navigator.pop(context, true);
  }
}
