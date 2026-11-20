import 'dart:developer';

import 'package:flutter_bloc/flutter_bloc.dart';

/// Logs every transition and error from every bloc in one place.
class AppBlocObserver extends BlocObserver {
  const AppBlocObserver();

  @override
  void onTransition(
    Bloc<dynamic, dynamic> bloc,
    Transition<dynamic, dynamic> transition,
  ) {
    super.onTransition(bloc, transition);
    log('${bloc.runtimeType}: $transition');
  }

  @override
  void onError(BlocBase<dynamic> bloc, Object error, StackTrace stackTrace) {
    log('${bloc.runtimeType}: $error', stackTrace: stackTrace);
    super.onError(bloc, error, stackTrace);
  }
}
