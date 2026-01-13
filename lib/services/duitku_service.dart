import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'package:http/http.dart' as http;

class DuitkuService {
  static const String merchantCode = 'DS27438'; //Merchant Code dari Duitku
  static const String apiKey = '8058ce195b12f0053c42c9e3959d6790'; //API Key dari Duitku
  static const String baseUrl = 'https://sandbox.duitku.com/webapi/api/merchant/v2/inquiry';

Future<String> createPayment({
    required int amount,
    required String productDetail,
    required String email,
    required String phoneNumber,
    required String paymentMethod,
  }) async {
    try {
      String orderId = DateTime.now().millisecondsSinceEpoch.toString();
      
      // Signature MD5
      var bytes = utf8.encode('$merchantCode$orderId$amount$apiKey');
      var signature = md5.convert(bytes).toString();

      Map<String, dynamic> body = {
        'merchantCode': merchantCode,
        'paymentAmount': amount,
        'paymentMethod': paymentMethod,
        'merchantOrderId': orderId,
        'productDetails': productDetail,
        'email': email,
        'phoneNumber': phoneNumber,
        'signature': signature,
        'expiryPeriod': 10,
      };

      final response = await http.post(
        Uri.parse(baseUrl),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(body),
      );

      // handle response
      if (response.statusCode == 200) {
         final data = jsonDecode(response.body);
         if (data['paymentUrl'] != null) {
           return data['paymentUrl'];
         } else {
           throw Exception(data['statusMessage']);
         }
      } else {
        throw Exception("Server Error: ${response.statusCode}");
      }
    } catch (e) {
      rethrow;
    }
  }
}