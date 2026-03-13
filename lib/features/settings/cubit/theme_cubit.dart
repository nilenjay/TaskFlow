import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';

import '../data/datasources/settings_local_datasource.dart';
import '../data/models/settings_model.dart';

// ─── State ────────────────────────────────────────────────────────────────────

class SettingsState extends Equatable {
  final AppSettings settings;

  const SettingsState({required this.settings});

  ThemeMode get themeMode =>
      settings.isDarkMode ? ThemeMode.dark : ThemeMode.light;

  @override
  List<Object?> get props => [settings];
}

// ─── Cubit ────────────────────────────────────────────────────────────────────

class SettingsCubit extends Cubit<SettingsState> {
  final SettingsLocalDataSource _dataSource;

  SettingsCubit(this._dataSource)
      : super(SettingsState(settings: AppSettings())) {
    _load();
  }

  Future<void> _load() async {
    final settings = await _dataSource.loadSettings();
    emit(SettingsState(settings: settings));
  }

  Future<void> toggleTheme() async {
    final updated =
    state.settings.copyWith(isDarkMode: !state.settings.isDarkMode);
    await _dataSource.saveSettings(updated);
    emit(SettingsState(settings: updated));
  }

  Future<void> setDefaultDuration(int minutes) async {
    final updated =
    state.settings.copyWith(defaultDurationMinutes: minutes);
    await _dataSource.saveSettings(updated);
    emit(SettingsState(settings: updated));
  }

  Future<void> setDefaultFocusType(int index) async {
    final updated =
    state.settings.copyWith(defaultFocusTypeIndex: index);
    await _dataSource.saveSettings(updated);
    emit(SettingsState(settings: updated));
  }

  Future<void> toggleNotifications() async {
    final updated = state.settings.copyWith(
        notificationsEnabled: !state.settings.notificationsEnabled);
    await _dataSource.saveSettings(updated);
    emit(SettingsState(settings: updated));
  }
}