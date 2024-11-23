import 'package:intl/intl.dart';
import 'package:logger/logger.dart';

var logger = Logger();

class Gemini {
  final String geminiResponse;

  Gemini({
    required this.geminiResponse,
  });


  Map<String, dynamic> toJson() {
    return {
      'generated_content': geminiResponse,
    };
  }

  factory Gemini.fromJson(Map<String, dynamic> json) {

    return Gemini(
      geminiResponse: json['generated_content'],
    );
  }
}