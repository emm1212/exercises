// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'main.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

WeatherModel _$WeatherModelFromJson(Map<String, dynamic> json) => WeatherModel(
  cityName: json['name'] as String,
  mainTemp: MainTemp.fromJson(json['main'] as Map<String, dynamic>),
  weatherList: (json['weather'] as List<dynamic>)
      .map((e) => WeatherInfo.fromJson(e as Map<String, dynamic>))
      .toList(),
);

Map<String, dynamic> _$WeatherModelToJson(WeatherModel instance) =>
    <String, dynamic>{
      'name': instance.cityName,
      'main': instance.mainTemp,
      'weather': instance.weatherList,
    };

MainTemp _$MainTempFromJson(Map<String, dynamic> json) => MainTemp(
  temp: (json['temp'] as num).toDouble(),
  humidity: (json['humidity'] as num).toInt(),
);

Map<String, dynamic> _$MainTempToJson(MainTemp instance) => <String, dynamic>{
  'temp': instance.temp,
  'humidity': instance.humidity,
};

WeatherInfo _$WeatherInfoFromJson(Map<String, dynamic> json) => WeatherInfo(
  description: json['description'] as String,
  main: json['main'] as String,
);

Map<String, dynamic> _$WeatherInfoToJson(WeatherInfo instance) =>
    <String, dynamic>{
      'description': instance.description,
      'main': instance.main,
    };
