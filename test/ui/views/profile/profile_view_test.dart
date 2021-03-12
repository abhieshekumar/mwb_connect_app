import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:flutter_test/flutter_test.dart';
import '../../utils/firebase_auth_mocks.dart';
import '../../../ui/utils/test_app.dart';
import '../../../ui/utils/widget_loader.dart';
import 'package:mwb_connect_app/service_locator.dart';
import 'package:mwb_connect_app/utils/keys.dart';
import 'package:mwb_connect_app/core/services/local_storage_service.dart';
import 'package:mwb_connect_app/core/viewmodels/profile_view_model.dart';
import 'package:mwb_connect_app/core/models/profile_model.dart';
import 'package:mwb_connect_app/core/models/user_model.dart';
import 'package:mwb_connect_app/core/models/field_model.dart';
import 'package:mwb_connect_app/core/models/subfield_model.dart';
import 'package:mwb_connect_app/ui/views/profile/profile_view.dart';
import 'package:mwb_connect_app/ui/views/profile/widgets/field_dropdown_widget.dart';
import 'package:mwb_connect_app/ui/views/profile/widgets/subfield_dropdown_widget.dart';

void main() async {
  TestWidgetsFlutterBinding.ensureInitialized();
  setupFirebaseAuthMocks();  
  await Firebase.initializeApp();
  SharedPreferences.setMockInitialValues({});
  await EasyLocalization.ensureInitialized();  
  setupLocator();
  final getIt = GetIt.instance;
  await getIt.allReady();
  LocalStorageService storageService = locator<LocalStorageService>();
  storageService.userId = 'test_user';

  group('Profile view tests:', () {
    var profileViewModel = locator<ProfileViewModel>();
    String jsonFile;
    var profile = Profile();

    Widget createProfileWidget({bool isMentor}) {
      var widgetLoader = WidgetLoader();
      return widgetLoader.createLocalizedWidgetForTesting(
        child: TestApp(
          widget: ProfileView(isMentor: true)
        ),
        jsonFile: jsonFile
      );
    }   

    setUp(() async {
      profile.user = User(
        name: 'Bob',
        field: 'Programming',
        subfields: [
          'Web Development',
          'Mobile Development'
        ]
      );
      List<Field> fields = [
        Field(
          name: 'Programming',
          subfields: [
            Subfield(name: 'Web Development'),
            Subfield(name: 'Mobile Development'),
            Subfield(name: 'Game Development'),
          ]
        ),
        Field(
          name: 'Graphic Design',
          subfields: [
            Subfield(name: 'Visual Identity'),
            Subfield(name: 'Marketing & Advertising'),
            Subfield(name: 'User Interface'),
          ]
        ),
      ];
      await profileViewModel.setFields(fields);
      jsonFile = await rootBundle.loadString('assets/i18n/en-US.json');
    });  

    testWidgets('Profile widgets show up for mentor test', (tester) async {
      await tester.runAsync(() async {
        profile.user.isMentor = true;
        await profileViewModel.setUserDetails(profile.user);        
        await tester.pumpWidget(createProfileWidget(isMentor: true));
        await tester.pumpAndSettle();
        expect(find.byType(TextFormField), findsOneWidget);
        expect(find.byType(FieldDropdown), findsOneWidget);
        expect(find.byType(SubfieldDropdown), findsNWidgets(2));
        expect(find.byType(Image), findsNWidgets(2));        
        expect(find.text('Name'), findsOneWidget);
        expect(find.byKey(Key(AppKeys.nameField)).last, findsOneWidget);
        expect(find.text('Field'), findsOneWidget);
        expect(find.byKey(Key(AppKeys.fieldDropdown)).last, findsOneWidget);
        expect(find.text('Subfields'), findsOneWidget);
        expect(find.byKey(Key(AppKeys.subfieldDropdown + '0')).last, findsOneWidget);
        expect(find.byKey(Key(AppKeys.subfieldDropdown + '1')).last, findsOneWidget);        
        expect(find.byKey(Key(AppKeys.deleteSubfieldBtn + '0')).last, findsOneWidget);
        expect(find.byKey(Key(AppKeys.deleteSubfieldBtn + '1')).last, findsOneWidget);
        expect(find.text('Add subfield'), findsOneWidget);
        expect(find.byKey(Key(AppKeys.addSubfieldBtn)).last, findsOneWidget);
      });
    });
  });
}