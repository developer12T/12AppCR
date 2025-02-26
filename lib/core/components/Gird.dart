import 'package:flutter/material.dart';

class GridLayoutExample extends StatelessWidget {
  const GridLayoutExample({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Grid Layout Example')),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
            // First row
            Expanded(
              child: Row(
                children: [
                  // Column span 2, Row span 2
                  Expanded(
                    flex: 2,
                    child: Container(
                      margin: EdgeInsets.all(4),
                      color: Colors.red,
                      child: Center(
                          child: Text('Span 2x2',
                              style: TextStyle(color: Colors.white))),
                    ),
                  ),
                  Expanded(
                    child: Column(
                      children: [
                        Expanded(
                          child: Container(
                            margin: EdgeInsets.all(4),
                            color: Colors.blue,
                            child: Center(
                                child: Text('1x1',
                                    style: TextStyle(color: Colors.white))),
                          ),
                        ),
                        Expanded(
                          child: Container(
                            margin: EdgeInsets.all(4),
                            color: Colors.green,
                            child: Center(
                                child: Text('1x1',
                                    style: TextStyle(color: Colors.white))),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            // Second row
            Expanded(
              child: Row(
                children: [
                  // This is part of the 2x2 span from the first row
                  Expanded(flex: 2, child: SizedBox()),
                  Expanded(
                    child: Container(
                      margin: EdgeInsets.all(4),
                      color: Colors.yellow,
                      child: Center(child: Text('1x1')),
                    ),
                  ),
                ],
              ),
            ),
            // Third row
            Expanded(
              child: Row(
                children: [
                  Expanded(
                    child: Container(
                      margin: EdgeInsets.all(4),
                      color: Colors.purple,
                      child: Center(
                          child: Text('1x1',
                              style: TextStyle(color: Colors.white))),
                    ),
                  ),
                  // Column span 2
                  Expanded(
                    flex: 2,
                    child: Container(
                      margin: EdgeInsets.all(4),
                      color: Colors.orange,
                      child: Center(child: Text('Span 2x1')),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
