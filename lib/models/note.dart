

class Note {
  int? _id;
  String _title;
  String _description;
  String _date;
  int _priority;

  Note(this._date, this._priority, this._title, this._description);
  Note.withId(this._id,this._date, this._priority, this._title, this._description);

  int? get id => _id;
  String get date => _date;
  int get priority => _priority;
  String get description => _description;
  String get title => _title;

  set title(String newTitle){
      this._title = newTitle;
  }

  set description(String newDescription){
      this._description = newDescription;
  }
  set date(String newDate){
      this._date = newDate;
  }

  set priority(int newPriority){
      this._priority = newPriority;
  }
  //convert a note object into a Map object

  Map<String,dynamic> toMap(){
    var map = Map<String,dynamic>();
    if(id!=null){
      map['id']= _id;
    }
    map['title']= _title;
    map['description']= _description;
    map['priority']= _priority;
    map['date']= _date;

    return map;
}
  // extract Note object from the map object

   Note.fromMapObject(Map<String, dynamic> map)
      : _id = map['id'] ?? 0,
        _date = map['date'] ?? '',
        _priority = map['priority'] ?? 1,
        _description = map['description'] ?? '',
        _title = map['title'] ?? '';
}