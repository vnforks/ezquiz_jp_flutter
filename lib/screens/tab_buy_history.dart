import 'package:flutter/material.dart';
import 'package:ezquiz_flutter/utils/resources.dart';
import 'package:ezquiz_flutter/model/payment_history.dart';
import 'package:flutter_html_view/flutter_html_text.dart';
import 'package:intl/intl.dart';

class TabBuy extends StatefulWidget {
  final List<PaymentHistory> listPaymentHistory;

  const TabBuy({Key key, this.listPaymentHistory}) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return _TabBuy(listPaymentHistory);
  }

}

class _TabBuy extends State<TabBuy> {

  final List<PaymentHistory> _listPaymentHistory;

  _TabBuy(this._listPaymentHistory);

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
        itemCount: _listPaymentHistory.length,
        itemBuilder: (context, index) {
          PaymentHistory paymentHistory = _listPaymentHistory[index];
          return Card(
            margin: SizeUtil.defaultPadding,
            child: Container(
              color: Colors.white,
              padding: SizeUtil.defaultPadding,
              child: Column(
                children: <Widget>[
                  HtmlText(data: paymentHistory.content,),
                  Text(
                    DateFormat("dd/MM/yyyy").format(
                        DateTime.fromMicrosecondsSinceEpoch(
                            (paymentHistory.time * 1000).round())),
                    style: TextStyle(
                        fontSize: SizeUtil.textSizeSmall,
                        color: ColorUtil.textGray),
                  )
                ],
              ),
            ),
          );
        });
  }

}