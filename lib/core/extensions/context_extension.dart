import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sync_together/core/common/app/providers/user_provider.dart';
import 'package:sync_together/features/auth/domain/entities/user.dart';

extension ContextExtension on BuildContext {
  ThemeData get theme => Theme.of(this);

  MediaQueryData get mediaQuery => MediaQuery.of(this);

  Size get size => mediaQuery.size;
  double get width => size.width;
  double get height => size.height;

  UserProvider get userProvider => read<UserProvider>();

  UserEntity? get currentUser => userProvider.user;
}
