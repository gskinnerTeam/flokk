import 'universal_picker.dart';

UniversalPicker getPlatformPicker({required String accept}) =>
    throw UnsupportedError(
        'Cannot create a picker without the packages dart:html or whatever is used for desktop');
