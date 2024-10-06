import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:stripe_example/screens/platforms/loading_button.dart';
import 'package:stripe_example/screens/platforms/payment_element_web.dart';

class PaymentElementExample extends StatefulWidget {
  @override
  _ThemeCardExampleState createState() => _ThemeCardExampleState();
}

class _ThemeCardExampleState extends State<PaymentElementExample> {
  String? clientSecret;

  @override
  void initState() {
    getClientSecret();
    super.initState();
  }

  Future<void> getClientSecret() async {
    try {
      final client = await createPaymentIntent();
      setState(() {
        clientSecret = client;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            e.toString(),
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Flutter Stripe Integration'),
      ),
      body: Column(
        children: [
          Container(
              child: clientSecret != null
                  ? PlatformPaymentElement(clientSecret)
                  : Center(child: CircularProgressIndicator())),
          LoadingButton(onPressed: pay, text: 'Pay'),
        ],
      ),
    );
  }

  Future<String> createPaymentIntent() async {
    final Dio dio = Dio();

    Map<String, dynamic> data = {
      "amount": "20000", // You can dynamically set this amount
      "currency": "usd"
    };

    try {
      // Make sure your backend is running on localhost:3000
      var response = await dio.post(
        "http://localhost:3000/stripe-payment/create-payment-intent",
        data: data,
        options: Options(
          contentType: Headers.formUrlEncodedContentType,
          headers: {
            "Content-Type": 'application/x-www-form-urlencoded',
          },
        ),
      );

      if (response.statusCode == 201) {
        return response.data["clientSecret"];
      } else {
        throw Exception(
            "Failed to create payment intent: ${response.statusCode}");
      }
    } catch (e) {
      throw Exception("Failed to create payment intent: $e");
    }
  }
}
