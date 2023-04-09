import 'package:flutter/material.dart';
import 'dart:async';
import '../Note.dart';
import '../database_helper.dart';
import 'note_details.dart';
import 'package:sqflite/sqflite.dart';

class NoteList extends StatefulWidget {
  const NoteList({super.key});

  @override
  State<NoteList> createState() => _NoteListState();
}

class _NoteListState extends State<NoteList> {
  DatabaseHelper databaseHelper = DatabaseHelper();
  List<Note> noteList = [];
  int count = 0;

  void navigateToDetail(Note note, String title) async {
    bool result = await Navigator.push(context, MaterialPageRoute(builder: (Context) {
      return NoteDetail(note, title);
    }));

    if (result == true) {
      updateListView();
    }
  }

  void updateListView() {
    final Future<Database>? dbFuture = databaseHelper.initializeDatabase();
    dbFuture?.then((database) {
      Future<List<Note>> notelistFuture = databaseHelper.getNoteList();
      notelistFuture.then((noteList) {
        setState(() {
          this.noteList = noteList;
          count = noteList.length;
        });
      });
    });
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    updateListView();
  }

  ListView getNoteListView() {
    return ListView.builder(
      itemCount: noteList.length,
      itemBuilder: (context, index) {
        return Card(
          margin: const EdgeInsets.all(20),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.0)),
          // color: Colors.deepPurple,
          elevation: 20.0,
          borderOnForeground: true,
          child: Opacity(
            opacity: 0.9,
            child: DecoratedBox(
              decoration: const BoxDecoration(color: Color.fromARGB(66, 191, 184, 184)),
              child: ListTile(
                leading: const CircleAvatar(backgroundImage: NetworkImage("https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcQ1HUly3GxpAXXQ-qylutQHgJI49SvAn0mKwKprM0c&s")),
                trailing: const Icon(Icons.note_add_rounded),
                isThreeLine: true,
                title: Text(noteList[index].title, style: const TextStyle(fontSize: 25.0, color: Colors.blueGrey, fontWeight: FontWeight.bold)),
                subtitle: Column(
                  children: [
                    noteList[index].description != null ? Text(noteList[index].description.toString(), style: const TextStyle(fontSize: 20.0, color: Colors.grey)) : const SizedBox.shrink(),
                    Text(noteList[index].date, style: const TextStyle(color: Colors.black)),
                  ],
                ),
                splashColor: Colors.black,
                onTap: () => navigateToDetail(noteList[index], "Edit ToDo"),
              ),
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    if (noteList == null) {
      noteList = [];
      updateListView();
    }
    return Scaffold(
      appBar: AppBar(
        leading: const Icon(
          Icons.note_alt,
          size: 35,
        ),
        title: const Text(
          "TODO List",
          style: TextStyle(fontWeight: FontWeight.bold, color: Color.fromARGB(137, 217, 214, 214)),
        ),
        centerTitle: true,
      ),
      body: noteList.isEmpty
          ? const Center(
              child: Text(
                'Create Your first TODO',
                style: TextStyle(fontStyle: FontStyle.italic, fontSize: 20, fontWeight: FontWeight.w300),
              ),
            )
          : getNoteListView(),
      floatingActionButton: FloatingActionButton(
        onPressed: (() {
          navigateToDetail(Note("", "", 2), "Add a note");
        }),
        child: const Icon(Icons.note_add_sharp),
      ),
    );
  }
}
