import 'package:flutter/material.dart';
import 'package:ezquiz_flutter/model/test.dart';
import 'package:ezquiz_flutter/utils/resources.dart';
import 'package:ezquiz_flutter/screens/testing.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:ezquiz_flutter/data/response.dart';
import 'package:ezquiz_flutter/screens/payment.dart';
import 'package:ezquiz_flutter/screens/login.dart';
import 'package:ezquiz_flutter/data/service.dart';
import 'package:intl/intl.dart';

class TestItem extends StatefulWidget {
  final TestModel testModel;

  const TestItem({Key key, this.testModel}) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return TestItemState();
  }
}

class TestItemState extends State<TestItem> {
  @override
  Widget build(BuildContext context) {
    return getTestWidget(widget.testModel);
  }

  Widget getTestWidget(TestModel test) {
    return GestureDetector(
      child: Card(
        margin: SizeUtil.tinyPadding,
        elevation: SizeUtil.elevationDefault,
        child: Container(
          padding: SizeUtil.defaultPadding,
          child: Column(
            children: <Widget>[
              Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                mainAxisAlignment: MainAxisAlignment.end,
                children: <Widget>[
                  Text(
                    DateFormat("dd/MM/yyyy").format(
                        DateTime.fromMicrosecondsSinceEpoch(
                            test.creationTime * 1000)),
                    style: TextStyle(
                        fontSize: SizeUtil.textSizeSmall,
                        color: ColorUtil.textGray),
                  ),
                ],
              ),
              Container(
                height: SizeUtil.spaceDefault,
              ),
              Row(
                children: <Widget>[
                  WidgetUtil.getCircleImageWithMargin(
                      SizeUtil.avatarSizeSmall,
                      "https://images.pexels.com/photos/9291/nature-bird-flying-red.jpg",
                      0),
                  Container(
                    width: SizeUtil.textSizeDefault,
                  ),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: <Widget>[
                        Text(test.testName != null ? test.testName : "",
                            style: TextStyle(
                                color: Theme.of(context).primaryColor,
                                fontWeight: FontWeight.bold)),
                        Container(
                          height: SizeUtil.spaceDefault,
                        ),
                        Row(
                          children: <Widget>[
                            Icon(
                              Icons.file_download,
                              size: SizeUtil.iconSizeTiny,
                            ),
                            Text(
                              "${test.testBuyCount == null ? 0 : test.testBuyCount}",
                              style:
                                  TextStyle(fontSize: SizeUtil.textSizeSmall),
                            ),
                            Container(
                              width: SizeUtil.spaceDefault,
                            ),
                            Icon(
                              Icons.library_books,
                              size: SizeUtil.iconSizeTiny,
                            ),
                            Text(
                              "${test.testDoneCount == null ? 0 : test.testDoneCount}",
                              style:
                                  TextStyle(fontSize: SizeUtil.textSizeSmall),
                            ),
                            Container(
                              width: SizeUtil.spaceDefault,
                            ),
                            Icon(
                              Icons.attach_money,
                              size: SizeUtil.iconSizeTiny,
                              color: Colors.orange,
                            ),
                            Text(
                              "${(test.coin == 0 || test.coin == null) ? "Free" : test.coin}",
                              style: TextStyle(
                                  fontSize: SizeUtil.textSizeSmall,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.orange),
                            ),
                          ],
                        )
                      ],
                    ),
                  )
                ],
              ),
              Container(
                height: SizeUtil.spaceBig,
              ),
              SizedBox(
                width: double.infinity,
                child: Text(
                  test.testName,
                  style: TextStyle(color: ColorUtil.textGray),
                ),
              ),
              Container(
                height: SizeUtil.spaceBig,
              ),
              Container(
                height: SizeUtil.lineSize,
                color: ColorUtil.background,
              ),
              Padding(
                padding: EdgeInsets.only(top: SizeUtil.spaceDefault),
                child: Row(
                  children: <Widget>[
                    Text(
                      "${test.rateCount == null ? 0 : test.rateCount} rates  ${test.comment == null ? 0 : test.comment} comments",
                      style: TextStyle(
                          color: ColorUtil.textGray,
                          fontSize: SizeUtil.textSizeSmall),
                    ),
                    Expanded(
                      child: Container(
                        width: double.infinity,
                      ),
                    ),
                    GestureDetector(
                      child: Icon(
                        Icons.cloud_download,
                        color: ColorUtil.textGray,
                      ),
                      onTap: () {},
                    ),
                    Container(
                      width: SizeUtil.spaceBig,
                    ),
                    GestureDetector(
                      child: Icon(Icons.comment, color: ColorUtil.textGray),
                      onTap: () {},
                    )
                  ],
                ),
              )
            ],
          ),
        ),
      ),
      onTap: () {
        _onBuyTestClick(test);
      },
    );
  }

  _onBuyTestClick(TestModel test) {
    FirebaseAuth.instance.currentUser().then((FirebaseUser user) {
      if (user != null) {
        if (test.coin != null && test.coin > 0) if (test.isBought != null &&
            !test.isBought) {
          Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => TestingScreen(test, false)));
        } else {
          WidgetUtil.showBuyTestDialog(context, test, () {
            Navigator.pop(context);
            buyTest(context, test).then((BaseResponse baseResponse) {
              _onBuyTestDone(baseResponse, test);
            });
          });
        }
        else {
          Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => TestingScreen(test, false)));
        }
      } else {
        WidgetUtil.showLoginDialog(context);
      }
    });
  }

  void _onBuyTestDone(BaseResponse baseResponse, TestModel test) {
    if (baseResponse.isSuccess()) {
      test.isBought = true;
      Navigator.push(context,
          MaterialPageRoute(builder: (context) => TestingScreen(test, false)));
    } else {
      if (baseResponse.status == BaseResponse.ERROR_OUT_BALANCE) {
        WidgetUtil.showAlertDialog(
            context, "Notice", baseResponse.message, "Get coin", () {
          Navigator.pop(context);
          Navigator.of(context)
              .push(MaterialPageRoute(builder: (context) => PaymentScreen()));
        });
      } else if (baseResponse.status == BaseResponse.ERROR_AUTH) {
        Navigator.of(context)
            .push(MaterialPageRoute(builder: (context) => LoginScreen()));
      } else
        WidgetUtil.showErrorDialog(context, baseResponse.message);
    }
  }
}
