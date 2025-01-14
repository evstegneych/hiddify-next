import 'package:fpdart/fpdart.dart';
import 'package:hiddify/data/api/clash_api.dart';
import 'package:hiddify/data/repository/exception_handlers.dart';
import 'package:hiddify/domain/clash/clash.dart';
import 'package:hiddify/domain/connectivity/connection_status.dart';
import 'package:hiddify/domain/constants.dart';
import 'package:hiddify/domain/core_facade.dart';
import 'package:hiddify/domain/core_service_failure.dart';
import 'package:hiddify/services/connectivity/connectivity.dart';
import 'package:hiddify/services/files_editor_service.dart';
import 'package:hiddify/services/singbox/singbox_service.dart';
import 'package:hiddify/utils/utils.dart';

class CoreFacadeImpl with ExceptionHandler, InfraLogger implements CoreFacade {
  CoreFacadeImpl(this.singbox, this.filesEditor, this.clash, this.connectivity);

  final SingboxService singbox;
  final FilesEditorService filesEditor;
  final ClashApi clash;
  final ConnectivityService connectivity;

  bool _initialized = false;

  @override
  TaskEither<CoreServiceFailure, Unit> setup() {
    if (_initialized) return TaskEither.of(unit);
    return exceptionHandler(
      () {
        loggy.debug("setting up singbox");
        return singbox
            .setup(
              filesEditor.baseDir.path,
              filesEditor.workingDir.path,
              filesEditor.tempDir.path,
            )
            .map((r) {
              loggy.debug("setup complete");
              _initialized = true;
              return r;
            })
            .mapLeft(CoreServiceFailure.other)
            .run();
      },
      CoreServiceFailure.unexpected,
    );
  }

  @override
  TaskEither<CoreServiceFailure, Unit> parseConfig(String path) {
    return exceptionHandler(
      () {
        return singbox
            .parseConfig(path)
            .mapLeft(CoreServiceFailure.invalidConfig)
            .run();
      },
      CoreServiceFailure.unexpected,
    );
  }

  @override
  TaskEither<CoreServiceFailure, Unit> changeConfig(String fileName) {
    return exceptionHandler(
      () {
        final configPath = filesEditor.configPath(fileName);
        loggy.debug("changing config to: $configPath");
        return setup()
            .andThen(
              () =>
                  singbox.create(configPath).mapLeft(CoreServiceFailure.create),
            )
            .run();
      },
      CoreServiceFailure.unexpected,
    );
  }

  @override
  TaskEither<CoreServiceFailure, Unit> start() {
    return exceptionHandler(
      () => singbox.start().mapLeft(CoreServiceFailure.start).run(),
      CoreServiceFailure.unexpected,
    );
  }

  @override
  TaskEither<CoreServiceFailure, Unit> stop() {
    return exceptionHandler(
      () => singbox.stop().mapLeft(CoreServiceFailure.other).run(),
      CoreServiceFailure.unexpected,
    );
  }

  @override
  Stream<Either<CoreServiceFailure, String>> watchLogs() {
    return singbox
        .watchLogs(filesEditor.logsPath)
        .handleExceptions(CoreServiceFailure.unexpected);
  }

  @override
  TaskEither<CoreServiceFailure, ClashConfig> getConfigs() {
    return exceptionHandler(
      () async => clash.getConfigs().mapLeft(CoreServiceFailure.other).run(),
      CoreServiceFailure.unexpected,
    );
  }

  @override
  TaskEither<CoreServiceFailure, Unit> patchOverrides(ClashConfig overrides) {
    return exceptionHandler(
      () async =>
          clash.patchConfigs(overrides).mapLeft(CoreServiceFailure.other).run(),
      CoreServiceFailure.unexpected,
    );
  }

  @override
  TaskEither<CoreServiceFailure, List<ClashProxy>> getProxies() {
    return exceptionHandler(
      () async => clash.getProxies().mapLeft(CoreServiceFailure.other).run(),
      CoreServiceFailure.unexpected,
    );
  }

  @override
  TaskEither<CoreServiceFailure, Unit> changeProxy(
    String selectorName,
    String proxyName,
  ) {
    return exceptionHandler(
      () async => clash
          .changeProxy(selectorName, proxyName)
          .mapLeft(CoreServiceFailure.other)
          .run(),
      CoreServiceFailure.unexpected,
    );
  }

  @override
  Stream<Either<CoreServiceFailure, ClashTraffic>> watchTraffic() {
    return clash.watchTraffic().handleExceptions(CoreServiceFailure.unexpected);
  }

  @override
  TaskEither<CoreServiceFailure, int> testDelay(
    String proxyName, {
    String testUrl = Defaults.delayTestUrl,
  }) {
    return exceptionHandler(
      () async {
        final result = clash
            .getProxyDelay(proxyName, testUrl)
            .mapLeft(CoreServiceFailure.other)
            .run();
        return result;
      },
      CoreServiceFailure.unexpected,
    );
  }

  @override
  TaskEither<CoreServiceFailure, Unit> connect() {
    return exceptionHandler(
      () async {
        await connectivity.connect();
        return right(unit);
      },
      CoreServiceFailure.unexpected,
    );
  }

  @override
  TaskEither<CoreServiceFailure, Unit> disconnect() {
    return exceptionHandler(
      () async {
        await connectivity.disconnect();
        return right(unit);
      },
      CoreServiceFailure.unexpected,
    );
  }

  @override
  Stream<ConnectionStatus> watchConnectionStatus() =>
      connectivity.watchConnectionStatus();
}
