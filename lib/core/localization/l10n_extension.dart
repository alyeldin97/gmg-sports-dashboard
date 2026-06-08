import 'package:flutter/material.dart';
import 'package:gmg_dashboard/l10n/app_localizations.dart';

extension L10nExtension on BuildContext {
  AppLocalizations get l10n => AppLocalizations.of(this)!;
}
