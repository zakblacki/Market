import 'package:flutter/material.dart';
import 'package:intl/intl.dart' show DateFormat;
import 'package:mvc_pattern/mvc_pattern.dart';

import '../../generated/l10n.dart';
import '../controllers/order_controller.dart';
import '../elements/EmptyOrdersWidget.dart';
import '../elements/OrderItemWidget.dart';
import '../elements/ShoppingCartButtonWidget.dart';
import '../helpers/helper.dart';

class OrdersHistoryWidget extends StatefulWidget {
  final GlobalKey<ScaffoldState> parentScaffoldKey;

  OrdersHistoryWidget({Key key, this.parentScaffoldKey}) : super(key: key);

  @override
  _OrdersHistoryWidgetState createState() => _OrdersHistoryWidgetState();
}

class _OrdersHistoryWidgetState extends StateMVC<OrdersHistoryWidget> {
  OrderController _con;

  _OrdersHistoryWidgetState() : super(OrderController()) {
    _con = controller;
  }

  @override
  void initState() {
    _con.listenForOrdersHistory();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context).copyWith(dividerColor: Colors.transparent);
    return Scaffold(
      key: _con.scaffoldKey,
      appBar: AppBar(
        leading: new IconButton(
          icon: new Icon(Icons.sort, color: Theme.of(context).hintColor),
          onPressed: () => widget.parentScaffoldKey.currentState.openDrawer(),
        ),
        automaticallyImplyLeading: false,
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        title: Text(
          S.of(context).orders_history,
          style: Theme.of(context).textTheme.headline6.merge(TextStyle(letterSpacing: 1.3)),
        ),
        actions: <Widget>[
          new ShoppingCartButtonWidget(iconColor: Theme.of(context).hintColor, labelColor: Theme.of(context).accentColor),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _con.refreshOrders,
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(vertical: 10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.start,
            mainAxisSize: MainAxisSize.max,
            children: <Widget>[
              _con.orders.isEmpty
                  ? EmptyOrdersWidget()
                  : ListView.separated(
                      scrollDirection: Axis.vertical,
                      shrinkWrap: true,
                      primary: false,
                      itemCount: _con.orders.length,
                      itemBuilder: (context, index) {
                        var _order = _con.orders.elementAt(index);
                        return Theme(
                          data: theme,
                          child: ExpansionTile(
                            initiallyExpanded: index == 0 ? true : false,
                            title: Column(
                              children: <Widget>[
                                Text('${S.of(context).order_id}: #${_con.orders.elementAt(index).id}'),
                                Text(
                                  '${_con.orders.elementAt(index).orderStatus.status}',
                                  style: Theme.of(context).textTheme.caption,
                                ),
                              ],
                              crossAxisAlignment: CrossAxisAlignment.start,
                            ),
                            trailing: Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: <Widget>[
                                Helper.getPrice(Helper.getTotalOrdersPrice(_order), context, style: Theme.of(context).textTheme.headline4),
                                Text(
                                  DateFormat('dd-MM | HH:mm').format(_order.dateTime),
                                  style: Theme.of(context).textTheme.caption,
                                )
                              ],
                            ),
                            children: <Widget>[
                              Column(
                                  children: List.generate(
                                _order.productOrders.length,
                                (indexFood) {
                                  return OrderItemWidget(heroTag: 'my_orders', order: _order, productOrder: _order.productOrders.elementAt(indexFood));
                                },
                              )),
                              Padding(
                                padding: EdgeInsets.symmetric(vertical: 10, horizontal: 20),
                                child: Column(
                                  children: <Widget>[
                                    Row(
                                      children: <Widget>[
                                        Expanded(
                                          child: Text(
                                            S.of(context).delivery_fee,
                                            style: Theme.of(context).textTheme.bodyText1,
                                          ),
                                        ),
                                        Helper.getPrice(_order.deliveryFee, context, style: Theme.of(context).textTheme.subtitle1)
                                      ],
                                    ),
                                    Row(
                                      children: <Widget>[
                                        Expanded(
                                          child: Text(
                                            '${S.of(context).tax} (${_order.tax}%)',
                                            style: Theme.of(context).textTheme.bodyText1,
                                          ),
                                        ),
                                        Helper.getPrice(Helper.getTaxOrder(_order), context, style: Theme.of(context).textTheme.subtitle1)
                                      ],
                                    ),
                                    Row(
                                      children: <Widget>[
                                        Expanded(
                                          child: Text(
                                            S.of(context).total,
                                            style: Theme.of(context).textTheme.bodyText1,
                                          ),
                                        ),
                                        Helper.getPrice(Helper.getTotalOrdersPrice(_order), context, style: Theme.of(context).textTheme.headline4)
                                      ],
                                    ),
                                  ],
                                ),
                              )
                            ],
                          ),
                        );
                      },
                      separatorBuilder: (context, index) {
                        return Divider(
                          height: 30,
                          color: Theme.of(context).hintColor.withOpacity(0.1),
                        );
                      },
                    ),
            ],
          ),
        ),
      ),
    );
  }
}
