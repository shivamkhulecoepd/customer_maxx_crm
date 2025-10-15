import 'package:equatable/equatable.dart';

abstract class ThemeEvent extends Equatable {
  const ThemeEvent();

  @override
  List<Object> get props => [];
}

class LoadTheme extends ThemeEvent {}

class ThemeChanged extends ThemeEvent {
  final String themeMode;

  const ThemeChanged(this.themeMode);

  @override
  List<Object> get props => [themeMode];
}

class ToggleTheme extends ThemeEvent {}