import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';

class MockBuildContext implements BuildContext {
  @override
  bool get debugDoingBuild => false;
  
  @override
  InheritedWidget dependOnInheritedElement(InheritedElement ancestor, {Object? aspect}) {
    throw UnimplementedError();
  }
  
  @override
  T? dependOnInheritedWidgetOfExactType<T extends InheritedWidget>({Object? aspect}) => null;
  
  @override
  DiagnosticsNode describeElement(String name, {DiagnosticsTreeStyle style = DiagnosticsTreeStyle.errorProperty}) => DiagnosticsNode.message(name);
  
  @override
  List<DiagnosticsNode> describeMissingAncestor({required Type expectedAncestorType}) => [];
  
  @override
  DiagnosticsNode describeOwnershipChain(String name) => DiagnosticsNode.message(name);
  
  @override
  DiagnosticsNode describeWidget(String name, {DiagnosticsTreeStyle style = DiagnosticsTreeStyle.errorProperty}) => DiagnosticsNode.message(name);
  
  @override
  T? findAncestorRenderObjectOfType<T extends RenderObject>() => null;
  
  @override
  T? findAncestorStateOfType<T extends State<StatefulWidget>>() => null;
  
  @override
  T? findAncestorWidgetOfExactType<T extends Widget>() => null;
  
  @override
  RenderObject? findRenderObject() => null;
  
  @override
  T? findRootAncestorStateOfType<T extends State<StatefulWidget>>() => null;
  
  @override
  InheritedElement? getElementForInheritedWidgetOfExactType<T extends InheritedWidget>() => null;
  
  @override
  T? getInheritedWidgetOfExactType<T extends InheritedWidget>() => null;
  
  @override
  BuildOwner? get owner => null;
  
  @override
  Size? get size => const Size(800, 600);
  
  @override
  void visitAncestorElements(bool Function(Element element) visitor) {}
  
  @override
  void visitChildElements(ElementVisitor visitor) {}
  
  @override
  Widget get widget => const SizedBox();
  
  @override
  bool get mounted => true;
  
  @override
  void dispatchNotification(Notification notification) {}
}