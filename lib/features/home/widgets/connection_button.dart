import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:gap/gap.dart';
import 'package:hiddify/core/core_providers.dart';
import 'package:hiddify/core/theme/theme.dart';
import 'package:hiddify/domain/connectivity/connectivity.dart';
import 'package:hiddify/domain/failures.dart';
import 'package:hiddify/features/common/connectivity/connectivity_controller.dart';
import 'package:hiddify/gen/assets.gen.dart';
import 'package:hiddify/utils/alerts.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:recase/recase.dart';

// TODO: rewrite
class ConnectionButton extends HookConsumerWidget {
  const ConnectionButton({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = ref.watch(translationsProvider);
    final connectionStatus = ref.watch(connectivityControllerProvider);

    ref.listen(
      connectivityControllerProvider,
      (_, next) {
        if (next case AsyncError(:final error)) {
          CustomToast.error(t.presentError(error)).show(context);
        }
        if (next
            case AsyncData(value: Disconnected(:final connectionFailure?))) {
          CustomAlertDialog(
            message: connectionFailure.present(t),
          ).show(context);
        }
      },
    );

    switch (connectionStatus) {
      case AsyncData(value: final status):
        final Color connectionLogoColor = status.isConnected
            ? ConnectionButtonColor.connected
            : ConnectionButtonColor.disconnected;

        return _ConnectionButton(
          onTap: () => ref
              .read(connectivityControllerProvider.notifier)
              .toggleConnection(),
          enabled: !status.isSwitching,
          label: status.present(t),
          buttonColor: connectionLogoColor,
        );
      case AsyncError():
        return _ConnectionButton(
          onTap: () => ref
              .read(connectivityControllerProvider.notifier)
              .toggleConnection(),
          enabled: true,
          label: const Disconnected().present(t),
          buttonColor: ConnectionButtonColor.disconnected,
        );
      default:
        // HACK
        return _ConnectionButton(
          onTap: () {},
          enabled: false,
          label: "",
          buttonColor: Colors.red,
        );
    }
  }
}

class _ConnectionButton extends StatelessWidget {
  const _ConnectionButton({
    required this.onTap,
    required this.enabled,
    required this.label,
    required this.buttonColor,
  });

  final VoidCallback onTap;
  final bool enabled;
  final String label;
  final Color buttonColor;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          clipBehavior: Clip.antiAlias,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                blurRadius: 16,
                color: buttonColor.withOpacity(0.5),
              ),
            ],
          ),
          width: 148,
          height: 148,
          child: Material(
            shape: const CircleBorder(),
            color: Colors.white,
            child: InkWell(
              onTap: onTap,
              child: Padding(
                padding: const EdgeInsets.all(36),
                child: Assets.images.logo.svg(
                  colorFilter: ColorFilter.mode(
                    buttonColor,
                    BlendMode.srcIn,
                  ),
                ),
              ),
            ),
          ).animate(target: enabled ? 0 : 1).blurXY(end: 1),
        )
            .animate(target: enabled ? 0 : 1)
            .scaleXY(end: .88, curve: Curves.easeIn),
        const Gap(16),
        Text(
          label.sentenceCase,
          style: Theme.of(context).textTheme.bodyLarge,
        ),
      ],
    );
  }
}
