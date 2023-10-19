# Rules

#### prefer_suraasa_page_route
This rule ensures that all screens are tagged with a name. This is useful for analytics and debugging.
Bad
```dart
MaterialPageRoute(builder: (context) => SomeWidget());
```
Good
```dart
SuraasaPageRoute(builder: (context) => SomeWidget(), screenName: SomeWidget.screenName);
```