// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'message.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_Message _$MessageFromJson(Map<String, dynamic> json) => _Message(
      sender: json['sender'] as String,
      body: json['body'] as String,
      timestamp: (json['timestamp'] as num).toInt(),
    );

Map<String, dynamic> _$MessageToJson(_Message instance) => <String, dynamic>{
      'sender': instance.sender,
      'body': instance.body,
      'timestamp': instance.timestamp,
    };
