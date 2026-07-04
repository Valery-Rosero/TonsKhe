import 'package:flutter/material.dart';

import '../../presentation/widgets/common/app_snackbar.dart';

extension BuildContextX on BuildContext {
  ThemeData get theme => Theme.of(this);
  TextTheme get textTheme => Theme.of(this).textTheme;

  void showErrorSnackBar(String message) => AppSnackBar.showError(this, message);
  void showSuccessSnackBar(String message) => AppSnackBar.showSuccess(this, message);
}
