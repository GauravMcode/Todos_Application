class Note {
  int? _id;
  late String _title;
  String? _description;
  late String _date;
  late int _priority;

  Note(this._title, this._date, this._priority, [this._description]);
  Note.withId(this._id, this._title, this._date, this._priority, [this._description]);

  // All the getters
  int? get id => _id;
  String get title => _title;
  String? get description {
    if (_description == null) {
      return "";
    } else {
      return _description;
    }
  }

  String get date => _date;
  int get priority => _priority;

  //All the setters
  set title(String? newTitle) {
    if (newTitle!.length <= 255) {
      _title = newTitle;
    }
  }

  set description(String? newDescription) {
    if (newDescription!.length <= 255) {
      _description = newDescription;
    }
  }

  set date(String? newdate) {
    if (newdate!.length <= 255) {
      _date = newdate;
    }
  }

  set priority(int? newPriority) {
    if (newPriority! >= 1 && newPriority <= 2) {
      _priority = newPriority;
    }
  }

  // used to save and retrieve from database:

  // convert note object to map object
  Map<String, dynamic> toMap() {
    var map = <String, dynamic>{};
    if (id != null) {
      map["id"] = _id;
    }
    map["title"] = _title;
    map["description"] = _description;
    map["priority"] = _priority;
    map["date"] = _date;
    return map;
  }

  //convert map object to note object
  Note.fromMapObject(Map<String, dynamic> map) {
    _id = map["id"];
    _date = map["date"];
    _description = map["description"];
    _priority = map["priority"];
    _title = map["title"];
  }
}
