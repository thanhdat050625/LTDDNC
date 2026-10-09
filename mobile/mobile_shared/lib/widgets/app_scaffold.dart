import 'package:flutter/material.dart';

class AppScaffold extends StatelessWidget {
  final String title;
  final Widget? titleWidget;
  final Widget body;
  final bool showBackButton;
  final Widget? leading;
  final List<Widget>? actions;
  final Widget? floatingActionButton;
  final Widget? bottomNavigationBar;
  final Widget? drawer;
  final bool bottomSafeArea;

  const AppScaffold({
    super.key,
    required this.title,
    this.titleWidget,
    required this.body,
    this.showBackButton = true,
    this.leading,
    this.actions,
    this.floatingActionButton,
    this.bottomNavigationBar,
    this.drawer,
    this.bottomSafeArea = true,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: titleWidget ??
            FittedBox(
              fit: BoxFit.scaleDown,
              child: Text(title),
            ),
        automaticallyImplyLeading: showBackButton,
        leading: leading,
        actions: actions,
      ),
      drawer: drawer,
      body: SafeArea(
        bottom: bottomSafeArea,
        child: body,
      ),
      floatingActionButton: floatingActionButton,
      bottomNavigationBar: bottomNavigationBar,
    );
  }
}
