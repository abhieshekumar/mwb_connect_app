import 'package:flutter/material.dart';
import 'package:quiver/strings.dart';
import 'package:mwb_connect_app/service_locator.dart';
import 'package:mwb_connect_app/utils/utils.dart';
import 'package:mwb_connect_app/core/services/user_service.dart';
import 'package:mwb_connect_app/core/services/profile_service.dart';
import 'package:mwb_connect_app/core/models/profile_model.dart';
import 'package:mwb_connect_app/core/models/user_model.dart';
import 'package:mwb_connect_app/core/models/field_model.dart';
import 'package:mwb_connect_app/core/models/subfield_model.dart';

class ProfileViewModel extends ChangeNotifier {
  UserService _userService = locator<UserService>();
  ProfileService _profileService = locator<ProfileService>();
  Profile profile;
  bool _shouldUnfocus = false;

  Future<User> getUserDetails() async {
    return await _userService.getUserDetails();
  }

  Future<List<Field>> getFields() async {
    return await _profileService.getFields();
  }

  setFields(List<Field> fields) {
    for (Field field in fields) {
      _profileService.addField(field);
    }
  }    

  setUserDetails(User user) {
    _userService.setUserDetails(user);
  }

  void setName(String name) {
    profile.user.name = name;
    setUserDetails(profile.user);
  }
  
  void setField(String field) {
    if (profile.user.field != field) {
      profile.user.field = field;
      profile.user.subfields = [];
      setUserDetails(profile.user);
      notifyListeners();
    }
  }

  Field getSelectedField() {
    Field selectedField;
    String selectedFieldName;
    List<Field> fields = profile.fields;
    if (isNotEmpty(profile.user.field)) {
      selectedFieldName = profile.user.field;
    } else {
      selectedFieldName = fields[0].name;
    }
    for (var field in fields) {
      if (field.name == selectedFieldName) {
        selectedField = field;
        break;
      }
    }
    return selectedField;
  }   

  void setSubfield(String subfield, int index) {
    if (index < profile.user.subfields.length) {
      profile.user.subfields[index] = subfield;
    } else {
      profile.user.subfields.add(subfield);
    }
    setUserDetails(profile.user);
    notifyListeners();
  }  

  List<Subfield> getSubfields(int index) {
    List<Subfield> subfields = profile.fields[_getSelectedFieldIndex()].subfields;
    List<String> selectedSubfields = profile.user.subfields;
    List<Subfield> filteredSubfields = List();
    if (subfields != null) {
      for (var subfield in subfields) {
        if (!selectedSubfields.contains(subfield.name) || 
            subfield.name == selectedSubfields[index]) {
          filteredSubfields.add(subfield);
        }
      }
    }
    return filteredSubfields;
  }

  int _getSelectedFieldIndex() {
    List<Field> fields = profile.fields;
    String selectedField = profile.user.field;
    return fields.indexWhere((field) => field.name == selectedField);
  }
  
  Subfield getSelectedSubfield(int index) {
    Subfield selectedSubfield;
    List<Subfield> subfields = profile.fields[_getSelectedFieldIndex()].subfields;
    List<String> selectedSubfields = profile.user.subfields;
    for (var subfield in subfields) {
      if (subfield.name == selectedSubfields[index]) {
        selectedSubfield = subfield;
        break;
      }
    }
    return selectedSubfield;
  }

  void addSubfield() {
    List<Subfield> subfields = profile.fields[_getSelectedFieldIndex()].subfields;
    List<String> selectedSubfields = profile.user.subfields;
    for (var subfield in subfields) {
      if (!selectedSubfields.contains(subfield.name)) {
        setSubfield(subfield.name, selectedSubfields.length+1);
        break;
      }
    }
    notifyListeners();
  }
  
  void deleteSubfield(int index) {
    profile.user.subfields.removeAt(index);
    setUserDetails(profile.user);
    notifyListeners();
  }

  void setIsAvailable(bool isAvailable) {
    profile.user.isAvailable = isAvailable;
    setUserDetails(profile.user);
    notifyListeners();
  }
  
  void addAvailability(Availability availability) {
    profile.user.availabilities.add(availability);
    sortAvailability();
    mergeAvailabilityTimes();
    setUserDetails(profile.user);
    notifyListeners();
  }

  void sortAvailability() {
    profile.user.availabilities.sort((a, b) => Utils.convertTime12to24(a.time.from).compareTo(Utils.convertTime12to24(b.time.from)));
    profile.user.availabilities.sort((a, b) => Utils.daysOfWeek.indexOf(a.dayOfWeek).compareTo(Utils.daysOfWeek.indexOf(b.dayOfWeek)));
  }

  void mergeAvailabilityTimes() {
    List<Availability> availabilities = List();
    for (String dayOfWeek in Utils.daysOfWeek) {
      List<Availability> dayAvailabilities = List();
      for (var availability in profile.user.availabilities) {
        if (availability.dayOfWeek == dayOfWeek) {
          dayAvailabilities.add(availability);
        }
      }
      List<Availability> merged = List();
      int mergedLastTo = -1;
      bool mergedLastShown = false;
      for (var availability in dayAvailabilities) {
        if (merged.isNotEmpty) {
          mergedLastTo = Utils.convertTime12to24(merged.last.time.to);
        }
        int availabilityFrom = Utils.convertTime12to24(availability.time.from);
        int availabilityTo = Utils.convertTime12to24(availability.time.to);
        if (merged.isEmpty || mergedLastTo < availabilityFrom) {
          merged.add(availability);
        } else {
          if (mergedLastTo < availabilityTo) {
            if (!mergedLastShown) {
              print(merged.last.dayOfWeek + ' from ' + merged.last.time.from + ' to ' + merged.last.time.to);
              mergedLastShown = true;
            }
            print(availability.dayOfWeek + ' from ' + availability.time.from + ' to ' + availability.time.to);
            merged.last.time.to = availability.time.to;
          } else {
            if (!mergedLastShown) {
              print('Inside ' + merged.last.dayOfWeek + ' from ' + merged.last.time.from + ' to ' + merged.last.time.to);
              mergedLastShown = true;
            }
            print('Inside ' + availability.dayOfWeek + ' from ' + availability.time.from + ' to ' + availability.time.to);
          }
        }
      }
      availabilities.addAll(merged);
    }
    profile.user.availabilities = availabilities;
  }

  bool isAvailabilityValid(Availability availability) {
    int timeFrom = Utils.convertTime12to24(availability.time.from);
    int timeTo = Utils.convertTime12to24(availability.time.to);
    return timeFrom < timeTo;
  }

  void deleteAvailability(int index) {
    profile.user.availabilities.removeAt(index);
    setUserDetails(profile.user);
    notifyListeners();
  }  

  bool get shouldUnfocus => _shouldUnfocus;
  set shouldUnfocus(bool unfocus) {
    _shouldUnfocus = unfocus;
    if (shouldUnfocus) {
      notifyListeners();
    }
  }
}
