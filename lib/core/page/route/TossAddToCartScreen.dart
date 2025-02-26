import 'package:flutter/material.dart';

class AddToCartAnimationPage extends StatefulWidget {
  @override
  _AddToCartAnimationPageState createState() => _AddToCartAnimationPageState();
}

class _AddToCartAnimationPageState extends State<AddToCartAnimationPage>
    with SingleTickerProviderStateMixin {
  int _cartItemCount = 0;
  bool _isAnimating = false;
  late AnimationController _controller;
  late Animation<Offset> _positionAnimation;
  late Animation<double> _scaleAnimation;
  final GlobalKey _cartKey = GlobalKey();
  final GlobalKey _buttonKey = GlobalKey();

  @override
  void initState() {
    super.initState();

    // Initialize the animation controller
    _controller = AnimationController(
      duration: Duration(milliseconds: 700),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.3).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOut),
    );

    _controller.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        setState(() {
          _isAnimating = false;
          _cartItemCount++;
        });
        _controller.reset();
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _startAddToCartAnimation() {
    final buttonPosition = _getWidgetPosition(_buttonKey);
    final cartPosition = _getWidgetPosition(_cartKey);

    if (buttonPosition != null && cartPosition != null) {
      final dx = cartPosition.dx - buttonPosition.dx;
      final dy = cartPosition.dy - buttonPosition.dy;

      setState(() {
        _positionAnimation = Tween<Offset>(
          begin: Offset.zero,
          end: Offset(dx, dy),
        ).animate(
            CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
        _isAnimating = true;
      });

      _controller.forward();
    }
  }

  Offset? _getWidgetPosition(GlobalKey key) {
    final renderBox = key.currentContext?.findRenderObject() as RenderBox?;
    return renderBox?.localToGlobal(Offset.zero);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Add to Cart Animation"),
        actions: [
          Stack(
            alignment: Alignment.center,
            children: [
              IconButton(
                key: _cartKey,
                icon: Icon(Icons.shopping_cart),
                onPressed: () {
                  // Cart action
                },
              ),
              if (_cartItemCount > 0)
                Positioned(
                  right: 8,
                  top: 8,
                  child: Container(
                    padding: EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: Colors.red,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    constraints: BoxConstraints(
                      minWidth: 20,
                      minHeight: 20,
                    ),
                    child: Text(
                      '$_cartItemCount',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
            ],
          ),
        ],
      ),
      body: Stack(
        children: [
          Center(
            child: ElevatedButton(
              key: _buttonKey,
              onPressed: () {
                if (!_isAnimating) _startAddToCartAnimation();
              },
              style: ElevatedButton.styleFrom(
                padding: EdgeInsets.all(20),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(5),
                ),
              ),
              child: Text("Add to Cart"),
            ),
          ),
          if (_isAnimating)
            AnimatedBuilder(
              animation: _positionAnimation,
              builder: (context, child) {
                return Positioned(
                  left: _positionAnimation.value.dx +
                      _getWidgetPosition(_buttonKey)!.dx,
                  top: _positionAnimation.value.dy +
                      _getWidgetPosition(_buttonKey)!.dy,
                  child: ScaleTransition(
                    scale: _scaleAnimation,
                    child: child,
                  ),
                );
              },
              child: Container(
                height: 24,
                width: 24,
                decoration: BoxDecoration(
                  color: Colors.red,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Center(
                  child: Text(
                    '1',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
