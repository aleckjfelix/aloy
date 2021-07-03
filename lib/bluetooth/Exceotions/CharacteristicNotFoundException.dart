

class CharacteristicNotFoundException implements Exception {


  String _message = "";

  CharacteristicNotFoundException([String message = 'Characteristic Not Found']) {
    this._message = message;
  }


} // CharacteristicNotFoundException