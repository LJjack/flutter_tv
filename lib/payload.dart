import 'dart:convert';

class Payload {
  final int port;
  final int type;
  final String? message;
  final PlayModel? data;

  Payload({
    required this.port,
    required this.type,
     this.data,
    this.message,
  });

  Map<String, dynamic> toMap() {
    return {
      'port': port,
      'type': type,
      'data': data?.toMap(),
      'message': message,
    };
  }

  factory Payload.fromMap(Map<String, dynamic> map) {
    return Payload(
      port: map['port']?.toInt() ?? 0,
      type: map['type']?.toInt() ?? 0,
      data: map['data'] == null ? null : PlayModel.fromMap(map['data']) ,
      message: map['message'],
    );
  }

  String toJson() => json.encode(toMap());

  factory Payload.fromJson(String source) =>
      Payload.fromMap(json.decode(source));
}

class PlayModel {

 final String name;
 final double progress;

 PlayModel({
   required this.name,
    this.progress = 0.0,
 });


 Map<String, dynamic> toMap() {
   return {
     'name': name,
     'progress': progress,
   };
 }

 factory PlayModel.fromMap(Map<String, dynamic> map) {
   return PlayModel(
     name: map['name']??'',
     progress: map['progress']?.toDouble() ?? 0.0,
   );
 }

 String toJson() => json.encode(toMap());

 factory PlayModel.fromJson(String source) =>
     PlayModel.fromMap(json.decode(source));

}