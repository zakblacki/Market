import 'package:flutter/material.dart';
import 'package:intl/intl.dart' show DateFormat;
import 'package:mvc_pattern/mvc_pattern.dart';
import '../helpers/helper.dart';

import '../../generated/l10n.dart';
import '../controllers/profile_controller.dart';
import '../elements/CircularLoadingWidget.dart';
import '../elements/OrderItemWidget.dart';
import '../elements/ProfileAvatarWidget.dart';
import '../elements/ShoppingCartButtonWidget.dart';

class ProfileWidget extends StatefulWidget {
  final GlobalKey<ScaffoldState> parentScaffoldKey;

  ProfileWidget({Key key, this.parentScaffoldKey}) : super(key: key);

  @override
  _ProfileWidgetState createState() => _ProfileWidgetState();
}

class _ProfileWidgetState extends StateMVC<ProfileWidget> {
  ProfileController _con;

  _ProfileWidgetState() : super(ProfileController()) {
    _con = controller;
  }

  @override
  void initState() {
    _con.listenForRecentOrders();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context).copyWith(dividerColor: Colors.transparent);
    return Scaffold(
      appBar: AppBar(
        leading: new IconButton(
          icon: new Icon(Icons.sort, color: Theme.of(context).primaryColor),
          onPressed: () => widget.parentScaffoldKey?.currentState?.openDrawer(),
        ),
        automaticallyImplyLeading: false,
        backgroundColor: Theme.of(context).accentColor,
        elevation: 0,
        centerTitle: true,
        title: Text(
          S.of(context).profile,
          style: Theme.of(context).textTheme.headline6.merge(TextStyle(letterSpacing: 1.3, color: Theme.of(context).primaryColor)),
        ),
        actions: <Widget>[
          new ShoppingCartButtonWidget(iconColor: Theme.of(context).primaryColor, labelColor: Theme.of(context).hintColor),
        ],
      ),
      key: _con.scaffoldKey,
      body: _con.user.apiToken == null
          ? CircularLoadingWidget(height: 500)
          : SingleChildScrollView(
//              padding: const EdgeInsets.symmetric(horizontal: 0, vertical: 10),
              child: Column(
                children: <Widget>[
                  ProfileAvatarWidget(user: _con.user),
                  ListTile(
                    contentPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                    leading: Icon(
                      Icons.person,
                      color: Theme.of(context).hintColor,
                    ),
                    title: Text(
                      S.of(context).about,
                      style: Theme.of(context).textTheme.headline4,
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Text(
                      _con.user.bio,
                      style: Theme.of(context).textTheme.bodyText2,
                    ),
                  ),
                  ListTile(
                    contentPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                    leading: Icon(
                      Icons.shopping_basket,
                      color: Theme.of(context).hintColor,
                    ),
                    title: Text(
                      S.of(context).recent_orders,
                      style: Theme.of(context).textTheme.headline4,
                    ),
                  ),
                  _con.recentOrders.isEmpty
                      ? CircularLoadingWidget(height: 200)
                      : ListView.separated(
                          scrollDirection: Axis.vertical,
                          shrinkWrap: true,
                          primary: false,
                          itemCount: _con.recentOrders.length,
                          itemBuilder: (context, index) {
                            var _order = _con.recentOrders.elementAt(index);
                            return Theme(
                              data: theme,
                              child: ExpansionTile(
                                initiallyExpanded: index == 0 ? true : false,
                                title: Column(
                                  children: <Widget>[
                                    Text('${S.of(context).order_id}: #${_con.recentOrders.elementAt(index).id}'),
                                    Text(
                                      '${_con.recentOrders.elementAt(index).orderStatus.status}',
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
    );
  }
}
