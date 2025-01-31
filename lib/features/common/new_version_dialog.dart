import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import 'package:hiddify/core/core_providers.dart';
import 'package:hiddify/domain/app/app.dart';
import 'package:hiddify/domain/constants.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:recase/recase.dart';
import 'package:url_launcher/url_launcher.dart';

// TODO add release notes
class NewVersionDialog extends HookConsumerWidget {
  const NewVersionDialog(
    this.currentVersion,
    this.newVersion, {
    super.key,
    this.canIgnore = true,
  });

  final InstalledVersionInfo currentVersion;
  final RemoteVersionInfo newVersion;
  final bool canIgnore;

  Future<void> show(BuildContext context) {
    return showDialog(
      context: context,
      builder: (context) => this,
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = ref.watch(translationsProvider);
    final theme = Theme.of(context);

    return AlertDialog(
      title: Text(t.appUpdate.dialogTitle.titleCase),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(t.appUpdate.updateMsg),
          const Gap(8),
          Text.rich(
            TextSpan(
              children: [
                TextSpan(
                  text: "${t.appUpdate.currentVersionLbl}: ",
                  style: theme.textTheme.bodySmall,
                ),
                TextSpan(
                  text: currentVersion.fullVersion,
                  style: theme.textTheme.labelMedium,
                ),
              ],
            ),
          ),
          Text.rich(
            TextSpan(
              children: [
                TextSpan(
                  text: "${t.appUpdate.newVersionLbl}: ",
                  style: theme.textTheme.bodySmall,
                ),
                TextSpan(
                  text: newVersion.fullVersion,
                  style: theme.textTheme.labelMedium,
                ),
              ],
            ),
          ),
        ],
      ),
      actions: [
        if (canIgnore)
          TextButton(
            onPressed: () {
              // TODO add prefs for ignoring version
              context.pop();
            },
            child: Text(t.appUpdate.ignoreBtnTxt.titleCase),
          ),
        TextButton(
          onPressed: context.pop,
          child: Text(t.appUpdate.laterBtnTxt.titleCase),
        ),
        TextButton(
          onPressed: () async {
            await launchUrl(
              Uri.parse(Constants.githubLatestReleaseUrl),
              mode: LaunchMode.externalApplication,
            );
          },
          child: Text(t.appUpdate.updateNowBtnTxt.titleCase),
        ),
      ],
    );
  }
}
