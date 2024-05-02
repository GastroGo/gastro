import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:gastro/components/payment_config.dart';
import 'package:pay/pay.dart';
import 'package:gastro/data/models.dart';
import 'package:shared_preferences/shared_preferences.dart';

class MyPayButton extends StatefulWidget {
  MyPayButton({Key? key}) : super(key: key);

  @override
  State<MyPayButton> createState() => _MyPayButtonState();
}

class _MyPayButtonState extends State<MyPayButton> {

  List<PaymentItem> paymentItems = [];
  List<Gericht> fetchedGerichtList = [];



  @override
  void initState() {
    super.initState();
  }

  Future<void> _fetchAndUpdateList() async {
    fetchedGerichtList = await loadObjectList();
    _fillupItems();
  }

  Future<List<Gericht>> loadObjectList() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonStringList = prefs.getStringList('dishList') ?? [];
    return jsonStringList.map((jsonString) => Gericht.fromJson(jsonDecode(jsonString))).toList();
  }

  void _fillupItems() {
    double total = 0;
    paymentItems.clear();

    for (Gericht item in fetchedGerichtList) {
      setState(() {
        paymentItems.add(PaymentItem(
          label:item.amount.toString() +'x '+ item.dishName,
          amount: item.dishPrice.toString(), status: PaymentItemStatus.final_price
        ));
        total += item.dishPrice * item.amount;
      });
    }
    if (paymentItems.isNotEmpty) {
      paymentItems.add(PaymentItem(amount: total.toString(), label: 'Total', status: PaymentItemStatus.final_price));
    }

  }

  @override
  Widget build(BuildContext context) {

    return Padding(
      padding: const EdgeInsets.all(10),
      child: Center(
        child: Platform.isIOS ? applePayButton : googlePayButton,
      ),
    );
  }

  late final applePayButton = ApplePayButton(
    paymentConfiguration: PaymentConfiguration.fromJsonString(defaultApplePay),
    onPressed: () => _fetchAndUpdateList(),
    paymentItems: paymentItems ?? [],
    style: ApplePayButtonStyle.black,
    width: double.infinity,
    height: 50,
    cornerRadius: 14,
    type: ApplePayButtonType.buy,
    margin: const EdgeInsets.only(top: 5.0),
    onPaymentResult: (result) => debugPrint('Payment Result $result'),
    loadingIndicator: const Center(
      child: CircularProgressIndicator(),
    ),
  );

  final googlePayButton = GooglePayButton(
    paymentConfiguration: PaymentConfiguration.fromJsonString(defaultGooglePay),
    paymentItems: const [
      PaymentItem(
        label: 'Total',
        amount: '0.01',
        status: PaymentItemStatus.final_price,
      )
    ],
    type: GooglePayButtonType.pay,
    margin: const EdgeInsets.only(top: 15.0),
    onPaymentResult: (result) => debugPrint('Payment Result $result'),
    loadingIndicator: const Center(
      child: CircularProgressIndicator(),
    ),
  );
}

