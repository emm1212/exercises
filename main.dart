import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:json_annotation/json_annotation.dart';

// 🔗 ربط الملف الحالي بالملف الذي سيولده build_runner تلقائياً لقراءة وتصدير الـ JSON
part 'main.g.dart';

// ==========================================================
// 1. MODELS (نماذج البيانات مع Null Safety وتوليد الكود)
// ==========================================================

/// الوسم @JsonSerializable يخبر المكتبة بأن هذا الكلاس يحتاج توليد كود لـ fromJson و toJson
@JsonSerializable()
class WeatherModel {
  @JsonKey(name: 'name', defaultValue: 'مدينة غير معروفة')
  final String cityName;

  // 🛡️ Null Safety: جعل الكائن قابلاً للـ null لو لم يرجعه السيرفر
  @JsonKey(name: 'main')
  final MainTemp? mainTemp;

  // 🛡️ تحديد قيمة افتراضية قائمة فارغة لتجنب NullThrownError
  @JsonKey(name: 'weather', defaultValue: [])
  final List<WeatherInfo> weatherList;

  WeatherModel({
    required this.cityName,
    this.mainTemp,
    this.weatherList = const [],
  });

  factory WeatherModel.fromJson(Map<String, dynamic> json) => _$WeatherModelFromJson(json);
  Map<String, dynamic> toJson() => _$WeatherModelToJson(this);
}

@JsonSerializable()
class MainTemp {
  // 🛡️ حماية حقل درجه الحرارة بقيمة افتراضية 0.0 إذا وصل null من الـ API
  @JsonKey(defaultValue: 0.0)
  final double temp;

  @JsonKey(defaultValue: 0)
  final int humidity;

  MainTemp({
    required this.temp,
    required this.humidity,
  });

  factory MainTemp.fromJson(Map<String, dynamic> json) => _$MainTempFromJson(json);
  Map<String, dynamic> toJson() => _$MainTempToJson(this);
}

@JsonSerializable()
class WeatherInfo {
  @JsonKey(defaultValue: 'لا يوجد وصف متاح')
  final String description;

  @JsonKey(defaultValue: '')
  final String main;

  WeatherInfo({
    required this.description,
    required this.main,
  });

  factory WeatherInfo.fromJson(Map<String, dynamic> json) => _$WeatherInfoFromJson(json);
  Map<String, dynamic> toJson() => _$WeatherInfoToJson(this);
}

// ==========================================================
// 2. NETWORK SERVICE (طبقة الاتصال بالشبكة باستخدام Dio)
// ==========================================================
class WeatherService {
  final Dio _dio = Dio(
    BaseOptions(
      baseUrl: 'https://api.openweathermap.org/data/2.5',
      // ⏱️ مهلة الاتصال: لو تأخر الرد أكثر من 5 ثوانٍ سينطلق DioException.connectionTimeout
      connectTimeout: const Duration(seconds: 5), 
    ),
  );

  static const String _apiKey = 'YOUR_OPENWEATHERMAP_API_KEY';

  /// دالة جلب البيانات وتُرجع Future يحتوي على WeatherModel
  Future<WeatherModel> fetchWeather(String cityName) async {
    try {
      final response = await _dio.get(
        '/weather',
        queryParameters: {
          'q': cityName,
          'appid': _apiKey,
          'units': 'metric',
        },
      );

      // 🛡️ التحقق من أن الاستجابة ليست null وتأتي بتنسيق Map صحيح
      if (response.data != null && response.data is Map<String, dynamic>) {
        return WeatherModel.fromJson(response.data as Map<String, dynamic>);
      } else {
        throw Exception('استجابة السيرفر فارغة أو غير صالحة');
      }
    } on DioException catch (e) {
      // التقاط استثناءات Dio المقترنة بمهلة الاتصال أو أخطاء السيرفر (مثل 404 أو 500)
      throw Exception('فشل الاتصال بالشبكة: ${e.message}');
    }
  }
}

// ==========================================================
// 3. UI LAYER WITH FUTURE FUNCTION (واجهة المستخدم)
// ==========================================================
class WeatherScreen extends StatefulWidget {
  const WeatherScreen({super.key});

  @override
  State<WeatherScreen> createState() => _WeatherScreenState();
}

class _WeatherScreenState extends State<WeatherScreen> {
  final WeatherService _weatherService = WeatherService();
  
  // 💡 حفظ الـ Future هنا يمنع إعادة طلب الشبكة مع كل Rebuild للواجهة
  late Future<WeatherModel> _weatherFuture;

  @override
  void initState() {
    super.initState();
    // تهيئة طلب الطقس عند أول فتح للشاشة
    _weatherFuture = _getWeatherData('Mukalla');
  }

  Future<WeatherModel> _getWeatherData(String city) async {
    return await _weatherService.fetchWeather(city);
  }

  void _refreshWeather() {
    setState(() {
      _weatherFuture = _getWeatherData('Mukalla');
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Weather App (Null-Safe)'),
        centerTitle: true,
      ),
      body: Center(
        child: FutureBuilder<WeatherModel>(
          future: _weatherFuture,
          builder: (context, snapshot) {
            // ⏳ 1. حالة التحميل (Loading State)
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const CircularProgressIndicator();
            }

            // ❌ 2. حالة الخطأ (Error State)
            if (snapshot.hasError) {
              return Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.error_outline, color: Colors.red, size: 60),
                    const SizedBox(height: 10),
                    Text(
                      '${snapshot.error}',
                      textAlign: TextAlign.center,
                      style: const TextStyle(color: Colors.red),
                    ),
                    const SizedBox(height: 15),
                    ElevatedButton(
                      onPressed: _refreshWeather,
                      child: const Text('إعادة المحاولة'),
                    ),
                  ],
                ),
              );
            }

            // ✅ 3. حالة النجاح (Success State)
            if (snapshot.hasData) {
              final weather = snapshot.data!;

              // 🛡️ قراءة آمنة لدرجة الحرارة باستخدام ?? للقيم الافتراضية
              final temp = weather.mainTemp?.temp ?? 0.0;

              // 🛡️ قراءة آمنة للقائمة تتفادى خطأ StateError في حال كان weatherList فارغاً
              final description = weather.weatherList.isNotEmpty
                  ? weather.weatherList.first.description
                  : 'لا يوجد وصف متوفر';

              return Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    weather.cityName,
                    style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
                  ),
                  Text(
                    '${temp.round()}°C',
                    style: const TextStyle(fontSize: 40, color: Colors.blue),
                  ),
                  Text(
                    description,
                    style: const TextStyle(fontSize: 18, color: Colors.grey),
                  ),
                ],
              );
            }

            return const Text('لا توجد بيانات متاحة');
          },
        ),
      ),
    );
  }
}