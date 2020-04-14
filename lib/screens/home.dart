import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:groceries_shopping_app/appTheme.dart';
import 'package:groceries_shopping_app/product_provider.dart';
import 'package:groceries_shopping_app/widgets/products_checkout.dart';
import 'package:groceries_shopping_app/widgets/products_checkout_preview.dart';
import 'package:groceries_shopping_app/widgets/products_preview.dart';
import 'package:provider/provider.dart';
import 'package:response/Response.dart';

var response = ResponseUI();

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with SingleTickerProviderStateMixin {
  bool isCartExpanded = false;
  double currentCartScreenFactor = 0.92;
  double currentMainScreenFactor = 0.01;
  double animationValue = 1;
  double transformAnimationValue = 0;
  double cartCheckoutTransitionValue = 0;
  AnimationController animationController;
  Animation transformAnimation;
  Animation animation;
  Animation cartCheckoutTransitionAnimation;
  Animation mainBoardAnimation;
  Animation cartBoardAnimation;
  AnimationStatus currentAnimationStatus;
  CurvedAnimation curvedAnimation;
  CurvedAnimation cartCheckoutCurvedAnimation;
  CurvedAnimation mainBoardCurvedAnimation;
  CurvedAnimation cartBoardCurvedAnimation;
  Duration _duration;
  Curve _curve;

  @override
  void initState() {
    super.initState();
    SystemChrome.setEnabledSystemUIOverlays([]);
    _duration = Duration(milliseconds: 700);
    _curve = Curves.decelerate;
    /**
     * Main Animation Controller
     */
    animationController = AnimationController(vsync: this, duration: _duration);
    /**
     * Animations Curves
     */
    curvedAnimation =
        CurvedAnimation(parent: animationController, curve: _curve);
    cartCheckoutCurvedAnimation =
        CurvedAnimation(parent: animationController, curve: Curves.easeInExpo);
    mainBoardCurvedAnimation =
        CurvedAnimation(parent: animationController, curve: _curve);
    cartBoardCurvedAnimation = CurvedAnimation(
        parent: animationController, curve: Interval(0.3, 1, curve: _curve));
    /**
     * Animations
     */
    animation = Tween<double>(begin: 1, end: 0).animate(curvedAnimation);
    transformAnimation =
        Tween<double>(begin: 0, end: 1).animate(curvedAnimation);
    cartCheckoutTransitionAnimation =
        Tween<double>(begin: 0, end: 1).animate(cartCheckoutCurvedAnimation);
    mainBoardAnimation = Tween<double>(begin: 0.01, end: 0.825)
        .animate(mainBoardCurvedAnimation);
    cartBoardAnimation =
        Tween<double>(begin: 0.92, end: 0.12).animate(cartBoardCurvedAnimation);
    /**
     * Animations Listners
     */
    animation.addStatusListener((AnimationStatus status) {
      setState(() => currentAnimationStatus = status);
    });
    animation.addListener(() {
      setState(() {
        animationValue = animation.value;
      });
    });
    transformAnimation.addListener(() {
      setState(() {
        transformAnimationValue = transformAnimation.value;
      });
    });
    cartCheckoutTransitionAnimation.addListener(() {
      setState(() {
        cartCheckoutTransitionValue =
            cartCheckoutTransitionAnimation.value * 80;
      });
    });
    mainBoardAnimation.addListener(() {
      setState(() {
        currentMainScreenFactor = mainBoardAnimation.value;
      });
    });
    cartBoardAnimation.addListener(() {
      setState(() {
        currentCartScreenFactor = cartBoardAnimation.value;
      });
    });
  }

  void _animateCartCheckout() {
    switch (currentAnimationStatus) {
      case AnimationStatus.completed:
        animationController.reverse();
        setState(() => isCartExpanded = false);
        break;
      case AnimationStatus.reverse:
        animationController.forward();
        setState(() => isCartExpanded = true);
        break;
      default:
        setState(() => isCartExpanded = true);
        animationController.forward();
    }
  }

/*
_animateCartCheckout();
          Provider.of<ProductsOperationsController>(context, listen: false)
              .returnTotalCost();
*/
  @override
  Widget build(BuildContext context) {
    var cartProductsProvider =
        Provider.of<ProductsOperationsController>(context).cart;
    var totalPriceProvider =
        Provider.of<ProductsOperationsController>(context).totalCost;
    return Scaffold(
      backgroundColor: AppTheme.mainCartBackgroundColor,
      floatingActionButton: Align(
        alignment: Alignment(0.25, 1),
        child: GestureDetector(
          onTap: () {
            _animateCartCheckout();
            Provider.of<ProductsOperationsController>(context, listen: false)
                .returnTotalCost();
          },
          child: CircleAvatar(
            backgroundColor: Colors.transparent,
            radius: 60,
          ),
        ),
      ),
      body: Stack(
        overflow: Overflow.visible,
        children: <Widget>[
          //cart
          //open = 0.12
          //closed = 0.92
          Positioned(
            bottom: -response.screenHeight * currentCartScreenFactor,
            left: 0,
            width: response.screenWidth,
            child: Container(
              height: response.screenHeight,
              width: response.screenWidth,
              child: ListView(
                children: <Widget>[
                  Container(
                    height: response.setHeight(80),
                    width: response.screenWidth,
                    padding:
                        EdgeInsets.symmetric(horizontal: response.setWidth(25)),
                    child: CartPreview(
                        transformAnimationValue: transformAnimationValue,
                        animationValue: animationValue,
                        cartProductsProvider: cartProductsProvider),
                  ),
                  Padding(
                    padding:
                        EdgeInsets.symmetric(horizontal: response.setWidth(20)),
                    child: Container(
                      height: response.screenHeight * 0.85,
                      width: response.screenWidth,
                      // color: Colors.redAccent,
                      child: ProductsCheckout(
                          cartCheckoutTransitionValue:
                              cartCheckoutTransitionValue,
                          cartProductsProvider: cartProductsProvider,
                          totalPriceProvider: totalPriceProvider),
                    ),
                  ),
                ],
              ),
            ),
          ),
          //main
          //open = 0.01
          //closed = 0.8
          Positioned(
            top: -response.screenHeight * currentMainScreenFactor,
            left: 0,
            width: response.screenWidth,
            child: Hero(
              tag: 'detailsScreen',
              child: Container(
                height: response.screenHeight * 0.90,
                width: response.screenWidth,
                decoration: BoxDecoration(
                  color: AppTheme.mainScaffoldBackgroundColor,
                  // color: Colors.teal,
                  borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(40),
                    bottomRight: Radius.circular(40),
                  ),
                ),
              ),
            ),
          ),
          Positioned(
            top: -response.screenHeight * currentMainScreenFactor,
            left: 0,
            width: response.screenWidth,
            child: IgnorePointer(
              ignoring: isCartExpanded,
              child: Container(
                height: response.screenHeight * 0.90,
                width: response.screenWidth,
                child: ProductsPreview(),
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    animationController.dispose();
    super.dispose();
  }
}
