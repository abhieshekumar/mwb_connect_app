import 'package:get_it/get_it.dart';
import 'package:mwb_connect_app/core/services/local_storage_service.dart';
import 'package:mwb_connect_app/core/services/api_service.dart';
import 'package:mwb_connect_app/core/services/defaults_service.dart';
import 'package:mwb_connect_app/core/services/profile_service.dart';
import 'package:mwb_connect_app/core/services/user_service.dart';
import 'package:mwb_connect_app/core/services/goals_service.dart';
import 'package:mwb_connect_app/core/services/notifications_service.dart';
import 'package:mwb_connect_app/core/services/download_service.dart';
import 'package:mwb_connect_app/core/services/analytics_service.dart';
import 'package:mwb_connect_app/core/viewmodels/common_view_model.dart';
import 'package:mwb_connect_app/core/viewmodels/profile_view_model.dart';
import 'package:mwb_connect_app/core/viewmodels/goals_view_model.dart';
import 'package:mwb_connect_app/core/viewmodels/steps_view_model.dart';
import 'package:mwb_connect_app/core/viewmodels/quizzes_view_model.dart';
import 'package:mwb_connect_app/core/viewmodels/notifications_view_model.dart';
import 'package:mwb_connect_app/core/viewmodels/support_request_view_model.dart';
import 'package:mwb_connect_app/core/viewmodels/feedback_view_model.dart';
import 'package:mwb_connect_app/core/viewmodels/updates_view_model.dart';

GetIt locator = GetIt.instance;

void setupLocator() {
  locator.registerSingletonAsync<LocalStorageService>(() async => LocalStorageService().init()); 
  locator.registerLazySingleton(() => Api());
  locator.registerLazySingleton(() => DefaultsService());
  locator.registerLazySingleton(() => ProfileService());
  locator.registerLazySingleton(() => UserService());
  locator.registerLazySingleton(() => GoalsService());
  locator.registerLazySingleton(() => NotificationsService());
  locator.registerLazySingleton(() => DownloadService());
  locator.registerLazySingleton(() => AnalyticsService());
  locator.registerLazySingleton(() => CommonViewModel());
  locator.registerLazySingleton(() => ProfileViewModel());
  locator.registerLazySingleton(() => GoalsViewModel());
  locator.registerLazySingleton(() => StepsViewModel());
  locator.registerLazySingleton(() => QuizzesViewModel());
  locator.registerLazySingleton(() => NotificationsViewModel());
  locator.registerLazySingleton(() => SupportRequestViewModel());
  locator.registerLazySingleton(() => FeedbackViewModel());
  locator.registerLazySingleton(() => UpdatesViewModel());
}