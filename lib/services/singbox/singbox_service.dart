import 'dart:io';

import 'package:fpdart/fpdart.dart';
import 'package:hiddify/services/singbox/ffi_singbox_service.dart';
import 'package:hiddify/services/singbox/mobile_singbox_service.dart';

abstract interface class SingboxService {
  factory SingboxService() {
    if (Platform.isAndroid) {
      return MobileSingboxService();
    }
    return FFISingboxService();
  }

  TaskEither<String, Unit> setup(
    String baseDir,
    String workingDir,
    String tempDir,
  );

  TaskEither<String, Unit> parseConfig(String path);

  TaskEither<String, Unit> create(String configPath);

  TaskEither<String, Unit> start();

  TaskEither<String, Unit> stop();

  Stream<String> watchLogs(String path);
}
