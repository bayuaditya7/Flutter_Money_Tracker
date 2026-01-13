import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'package:http/http.dart' as http;

class DuitkuService {
  static const String merchantCode = ''; //Merchant Code dari Duitku
  static const String apiKey = ''; //API Key dari Duitku
  static const String baseUrl = 'https://sandbox.duitku.com/webapi/api/merchant/v2/inquiry';

  Future<String?> createPayment({
    required int amount,
    required String productDetail,
    required String email,
    required String phoneNumber,
  }) async {
    try {
      String orderId = DateTime.now().millisecondsSinceEpoch.toString();

      // Signature (Wajib MD5: merchantCode + orderId + amount + apiKey)
      var bytes = utf8.encode('$merchantCode$orderId$amount$apiKey');
      var signature = md5.convert(bytes).toString();

      // Body Request
      Map<String, dynamic> body = {
        'merchantCode': merchantCode,
        'paymentAmount': amount,
        'paymentMethod': 'VC', // VC = Virtual Account (Bisa diganti method lain)
        'merchantOrderId': orderId,
        'productDetails': productDetail,
        'email': email,
        'phoneNumber': phoneNumber,
        'signature': signature,
        'expiryPeriod': 10, // Expire dalam 10 menit
      };

      // 4. Kirim Request ke Duitku
      final response = await http.post(
        Uri.parse(baseUrl),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(body),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        // Jika sukses, Duitku mengembalikan paymentUrl
        if (data['paymentUrl'] != null) {
          return data['paymentUrl'];
        } else {
          print("Error Duitku: ${data['statusMessage']}");
        }
      }
      return null;
    } catch (e) {
      print("Exception: $e");
      return null;
    }
  }
}