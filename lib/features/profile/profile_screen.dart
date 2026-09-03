import "package:flutter/material.dart";
import "package:flutter_riverpod/flutter_riverpod.dart";
import "package:go_router/go_router.dart";
import "package:image_picker/image_picker.dart";
import "package:url_launcher/url_launcher.dart";

import "../../core/api/error_messages.dart";
import "../../core/providers/app_providers.dart";
import "../../core/theme/design_tokens.dart";
import "../../core/theme/gravity_palette.dart";
import "../../core/theme/text_scaling.dart";
import "../../core/theme/theme_mode_controller.dart";
import "../../core/theme/studio_imagery.dart";
import "../../core/widgets/gravity_button.dart";
import "../../core/widgets/gravity_feedback.dart";
import "../../core/widgets/gravity_input.dart";
import "../notifications/notification_settings_screen.dart";
import "../scheduling/scheduling_providers.dart";
import "change_password_sheet.dart";
import "models/user_profile.dart";
import "profile_controller.dart";

class ProfileScreen extends ConsumerStatefulWidget {
  const ProfileScreen({super.key, this.embedded = false});

  final bool embedded;

  @override
  ConsumerState<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends ConsumerState<ProfileScreen> {
  final _displayNameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _emergencyNameController = TextEditingController();
  final _emergencyPhoneController = TextEditingController();
  bool _isEditing = false;
  bool _isSaving = false;
  String? _error;

  @override
  void dispose() {
    _displayNameController.dispose();
    _phoneController.dispose();
    _emergencyNameController.dispose();
    _emergencyPhoneController.dispose();
    super.dispose();
  }

  void _populateFields(MemberProfileData? member) {
    _displayNameController.text = member?.displayName ?? "";
    _phoneController.text = member?.phone ?? "";
    _emergencyNameController.text = member?.emergencyContact?["name"] ?? "";
    _emergencyPhoneController.text = member?.emergencyContact?["phone"] ?? "";
  }

  String _resolveAvatarUrl(String? avatarUrl, {required bool demo}) {
    if (avatarUrl != null && avatarUrl.isNotEmpty) return avatarUrl;
    return demo ? StudioImagery.memberAvatar : "";
  }

  ImageProvider? _avatarImage(String url) {
    if (url.isEmpty) return null;
    if (url.startsWith("assets/")) return AssetImage(url);
    return NetworkImage(url);
  }

  Future<void> _pickAvatar(String userId) async {
    final picker = ImagePicker();
    final image = await picker.pickImage(
      source: ImageSource.gallery,
      maxWidth: 1024,
      maxHeight: 1024,
      imageQuality: 85,
    );
    if (image == null) return;

    setState(() {
      _isSaving = true;
      _error = null;
    });

    try {
      await ref
          .read(profileControllerProvider(userId).notifier)
          .uploadAvatar(image.path);
      if (mounted) {
        GravityFeedback.showSnack(context, message: "Photo updated");
      }
    } catch (error) {
      setState(
        () => _error = friendlyErrorMessage(
          error,
          fallback: "Couldn’t update your photo. Please try again.",
        ),
      );
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  Future<void> _save(String userId) async {
    setState(() {
      _isSaving = true;
      _error = null;
    });

    final emergencyName = _emergencyNameController.text.trim();
    final emergencyPhone = _emergencyPhoneController.text.trim();

    try {
      await ref
          .read(profileControllerProvider(userId).notifier)
          .save(
            UpdateProfileRequest(
              displayName: _displayNameController.text.trim(),
              phone: _phoneController.text.trim(),
              emergencyContact:
                  (emergencyName.isEmpty && emergencyPhone.isEmpty)
                  ? null
                  : {
                      if (emergencyName.isNotEmpty) "name": emergencyName,
                      if (emergencyPhone.isNotEmpty) "phone": emergencyPhone,
                    },
            ),
          );
      if (mounted) {
        setState(() => _isEditing = false);
        GravityFeedback.showSnack(context, message: "Profile saved");
      }
    } catch (error) {
      setState(
        () => _error = friendlyErrorMessage(
          error,
          fallback: "Couldn’t save your profile. Please try again.",
        ),
      );
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  Future<void> _logout() async {
    final confirmed = await GravityFeedback.confirm(
      context: context,
      title: "Sign out?",
      message: "You’ll need your studio email and password to get back in.",
      cancelLabel: "Stay",
      confirmLabel: "Sign out",
      destructive: true,
    );
    if (!confirmed) return;
    await ref.read(authSessionProvider.notifier).logout();
    if (mounted) context.go("/login");
  }

  Future<void> _openBillingPortal() async {
    try {
      final url = await ref
          .read(profileRepositoryProvider)
          .createBillingPortalSession();
      final uri = Uri.parse(url);
      final launched = await launchUrl(
        uri,
        mode: LaunchMode.externalApplication,
      );
      if (!launched && mounted) {
        GravityFeedback.showSnack(
          context,
          message: "Couldn’t open billing. Try again from a browser.",
          error: true,
        );
      }
    } catch (error) {
      if (mounted) {
        GravityFeedback.showSnack(
          context,
          message: friendlyErrorMessage(
            error,
            fallback: "Billing isn’t available for this studio yet.",
          ),
          error: true,
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final session = ref.watch(authSessionProvider).value;
    if (session == null) {
      return const Center(child: CircularProgressIndicator());
    }

    final profileState = ref.watch(profileControllerProvider(session.user.id));
    final member = profileState.valueOrNull?.member;
    final subscription = ref
        .watch(memberSubscriptionProvider(session.user.id))
        .valueOrNull;
    final bookings =
        ref.watch(upcomingBookingsProvider).valueOrNull ?? const [];

    if (profileState.isLoading && member == null) {
      return const Center(child: CircularProgressIndicator());
    }

    final displayName = member?.displayName ?? session.user.displayName;
    final avatarUrl = _resolveAvatarUrl(
      member?.avatarUrl,
      demo: session.isDemo,
    );

    return ListView(
      padding: const EdgeInsets.fromLTRB(0, 0, 0, 48),
      children: [
        _ProfileHero(
          displayName: displayName,
          email: session.user.email,
          avatar: _avatarImage(avatarUrl),
          saving: _isSaving,
          onEditPhoto: member == null
              ? null
              : () => _pickAvatar(session.user.id),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              if (session.isDemo)
                const Padding(
                  padding: EdgeInsets.only(bottom: 16),
                  child: _DemoBanner(),
                ),
              if (subscription?.planName != null)
                Padding(
                  padding: const EdgeInsets.only(bottom: 16),
                  child: _MembershipPanel(
                    planName: subscription!.planName!,
                    status: subscription.status,
                    renewalLabel: subscription.renewalLabel,
                    priceLabel: subscription.priceLabel,
                    bookedCount: bookings.length,
                    onManageBilling: session.isDemo ? null : _openBillingPortal,
                  ),
                )
              else
                Padding(
                  padding: const EdgeInsets.only(bottom: 16),
                  child: _InfoCard(
                    title: "Membership",
                    child: Text(
                      "No active membership is linked to this account yet. "
                      "Your studio can add one for you at the front desk.",
                      style: TextStyle(
                        fontSize: 13,
                        height: 1.45,
                        color: context.palette.textSecondary,
                      ),
                    ),
                  ),
                ),
              if (member == null)
                const _InfoCard(
                  child: Text(
                    "No member profile is linked to this account. "
                    "Sign in with a Member role to edit profile details.",
                  ),
                )
              else if (_isEditing)
                _EditForm(
                  displayNameController: _displayNameController,
                  phoneController: _phoneController,
                  emergencyNameController: _emergencyNameController,
                  emergencyPhoneController: _emergencyPhoneController,
                  error: _error,
                  saving: _isSaving,
                  onCancel: () => setState(() {
                    _isEditing = false;
                    _populateFields(member);
                  }),
                  onSave: () => _save(session.user.id),
                )
              else ...[
                _InfoCard(
                  title: "Personal",
                  actionLabel: "Edit",
                  onAction: () => setState(() {
                    _populateFields(member);
                    _error = null;
                    _isEditing = true;
                  }),
                  child: Column(
                    children: [
                      _ProfileField(
                        label: "Display name",
                        value: member.displayName ?? "—",
                      ),
                      const Divider(height: 24),
                      _ProfileField(label: "Phone", value: member.phone ?? "—"),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                _InfoCard(
                  title: "Emergency contact",
                  actionLabel: "Edit",
                  onAction: () => setState(() {
                    _populateFields(member);
                    _error = null;
                    _isEditing = true;
                  }),
                  child: Column(
                    children: [
                      _ProfileField(
                        label: "Name",
                        value: member.emergencyContact?["name"] ?? "—",
                      ),
                      const Divider(height: 24),
                      _ProfileField(
                        label: "Phone",
                        value: member.emergencyContact?["phone"] ?? "—",
                      ),
                    ],
                  ),
                ),
              ],
              const SizedBox(height: 12),
              _InfoCard(
                padding: EdgeInsets.zero,
                child: Column(
                  children: [
                    ListTile(
                      leading: Icon(
                        Icons.notifications_outlined,
                        color: context.palette.accentStrong,
                      ),
                      title: const Text(
                        "Notifications",
                        style: TextStyle(fontWeight: FontWeight.w600),
                      ),
                      subtitle: const Text(
                        "Choose what the studio can send you",
                      ),
                      trailing: const Icon(Icons.chevron_right_rounded),
                      onTap: () {
                        Navigator.of(context).push(
                          MaterialPageRoute<void>(
                            builder: (_) => const NotificationSettingsScreen(),
                          ),
                        );
                      },
                    ),
                    const Divider(height: 1),
                    const _AppearanceTile(),
                    const Divider(height: 1),
                    ListTile(
                      leading: Icon(
                        Icons.lock_outline_rounded,
                        color: context.palette.accentStrong,
                      ),
                      title: const Text(
                        "Password",
                        style: TextStyle(fontWeight: FontWeight.w600),
                      ),
                      subtitle: const Text(
                        "Update the password for this account",
                      ),
                      trailing: const Icon(Icons.chevron_right_rounded),
                      onTap: session.isDemo
                          ? () => GravityFeedback.showSnack(
                              context,
                              message: "Password changes aren’t used in demo.",
                            )
                          : () => showChangePasswordSheet(context),
                    ),
                    const Divider(height: 1),
                    ListTile(
                      leading: Icon(
                        Icons.logout_rounded,
                        color: context.palette.danger,
                      ),
                      title: const Text(
                        "Sign out",
                        style: TextStyle(fontWeight: FontWeight.w600),
                      ),
                      onTap: _logout,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _AppearanceTile extends ConsumerWidget {
  const _AppearanceTile();

  static const _labels = {
    ThemeMode.system: "Match device",
    ThemeMode.light: "Light",
    ThemeMode.dark: "Dark",
  };

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final mode = ref.watch(themeModeProvider);

    return ListTile(
      leading: Icon(
        Icons.dark_mode_outlined,
        color: context.palette.accentStrong,
      ),
      title: const Text(
        "Appearance",
        style: TextStyle(fontWeight: FontWeight.w600),
      ),
      subtitle: Text(_labels[mode]!),
      trailing: const Icon(Icons.chevron_right_rounded),
      onTap: () => _pick(context, ref, mode),
    );
  }

  Future<void> _pick(
    BuildContext context,
    WidgetRef ref,
    ThemeMode current,
  ) async {
    final choice = await showModalBottomSheet<ThemeMode>(
      context: context,
      useSafeArea: true,
      backgroundColor: context.palette.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(GravityRadii.xl),
        ),
      ),
      builder: (sheetContext) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Padding(
              padding: EdgeInsets.fromLTRB(20, 20, 20, 4),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  "Appearance",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
                ),
              ),
            ),
            RadioGroup<ThemeMode>(
              groupValue: current,
              onChanged: (value) => Navigator.pop(sheetContext, value),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  for (final mode in ThemeMode.values)
                    RadioListTile<ThemeMode>(
                      value: mode,
                      title: Text(_labels[mode]!),
                      activeColor: sheetContext.palette.accent,
                    ),
                ],
              ),
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );

    if (choice != null) await ref.read(themeModeProvider.notifier).set(choice);
  }
}

class _ProfileHero extends StatelessWidget {
  const _ProfileHero({
    required this.displayName,
    required this.email,
    required this.saving,
    this.avatar,
    this.onEditPhoto,
  });

  final String displayName;
  final String email;
  final bool saving;
  final ImageProvider? avatar;
  final VoidCallback? onEditPhoto;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: context.scaled(236),
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Positioned.fill(
            bottom: 56,
            child: Image.asset(
              StudioImagery.hero,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) =>
                  const ColoredBox(color: Color(0xFF111827)),
            ),
          ),
          const Positioned.fill(
            bottom: 56,
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Color(0x330B1C1A), Color(0xD6111827)],
                ),
              ),
            ),
          ),
          Positioned(
            left: 20,
            right: 20,
            bottom: 0,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                // The whole avatar is the tap target; the badge is only an
                // affordance, so it can stay visually small.
                Semantics(
                  button: onEditPhoto != null,
                  label: onEditPhoto == null
                      ? "Profile photo"
                      : "Change profile photo",
                  child: InkWell(
                    onTap: saving ? null : onEditPhoto,
                    customBorder: const CircleBorder(),
                    child: Stack(
                      children: [
                        CircleAvatar(
                          radius: 44,
                          backgroundColor: context.palette.surface,
                          child: CircleAvatar(
                            radius: 40,
                            backgroundColor: context.palette.accentSurface,
                            backgroundImage: avatar,
                            child: avatar == null
                                ? Text(
                                    displayName.characters.first.toUpperCase(),
                                    style: TextStyle(
                                      fontSize: 28,
                                      fontWeight: FontWeight.w700,
                                      color: context.palette.accentStrong,
                                    ),
                                  )
                                : null,
                          ),
                        ),
                        if (onEditPhoto != null)
                          Positioned(
                            right: 2,
                            bottom: 2,
                            child: Container(
                              width: 30,
                              height: 30,
                              decoration: BoxDecoration(
                                color: saving
                                    ? context.palette.textMuted
                                    : context.palette.accent,
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: context.palette.surface,
                                  width: 2,
                                ),
                              ),
                              child: Icon(
                                Icons.camera_alt_outlined,
                                size: 15,
                                color: context.palette.onAccent,
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          displayName,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.w800,
                            letterSpacing: -0.4,
                            color: context.palette.textPrimary,
                          ),
                        ),
                        Text(
                          email,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 13,
                            color: context.palette.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _DemoBanner extends StatelessWidget {
  const _DemoBanner();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: context.palette.accentSurface,
        borderRadius: BorderRadius.circular(GravityRadii.md),
      ),
      child: Text(
        "You’re in the Iron Peak demo. Changes stay on this device until you sign out.",
        style: TextStyle(
          fontSize: 13,
          height: 1.4,
          color: context.palette.accentStrong,
        ),
      ),
    );
  }
}

class _MembershipPanel extends StatelessWidget {
  const _MembershipPanel({
    required this.planName,
    required this.bookedCount,
    this.status,
    this.renewalLabel,
    this.priceLabel,
    this.onManageBilling,
  });

  final String planName;
  final int bookedCount;
  final String? status;
  final String? renewalLabel;
  final String? priceLabel;
  final VoidCallback? onManageBilling;

  @override
  Widget build(BuildContext context) {
    final statusLabel = status == null || status!.isEmpty
        ? null
        : status![0].toUpperCase() + status!.substring(1);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF111827),
        borderRadius: BorderRadius.circular(GravityRadii.lg),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "MEMBERSHIP",
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              letterSpacing: 1.1,
              color: GravityColors.mint100,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            planName,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w800,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            [
              if (statusLabel != null) statusLabel,
              if (renewalLabel != null) renewalLabel,
              if (priceLabel != null) priceLabel,
            ].join(" · "),
            style: const TextStyle(fontSize: 13, color: Colors.white70),
          ),
          const SizedBox(height: 14),
          Text(
            bookedCount == 1
                ? "1 upcoming class"
                : "$bookedCount upcoming classes",
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: GravityColors.mint100,
            ),
          ),
          if (onManageBilling != null) ...[
            const SizedBox(height: 14),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                onPressed: onManageBilling,
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.white,
                  side: const BorderSide(color: Colors.white54),
                ),
                child: const Text("Manage billing"),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _InfoCard extends StatelessWidget {
  const _InfoCard({
    required this.child,
    this.title,
    this.actionLabel,
    this.onAction,
    this.padding,
  });

  final Widget child;
  final String? title;
  final String? actionLabel;
  final VoidCallback? onAction;
  final EdgeInsetsGeometry? padding;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: context.palette.surface,
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(GravityRadii.lg),
        side: BorderSide(color: context.palette.border),
      ),
      child: Padding(
        padding: padding ?? const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (title != null) ...[
              Row(
                children: [
                  Expanded(
                    child: Text(
                      title!,
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: context.palette.textPrimary,
                      ),
                    ),
                  ),
                  if (actionLabel != null && onAction != null)
                    TextButton(
                      onPressed: onAction,
                      style: TextButton.styleFrom(
                        padding: const EdgeInsets.symmetric(horizontal: 8),
                        minimumSize: const Size(48, 44),
                        visualDensity: VisualDensity.compact,
                      ),
                      child: Text(actionLabel!),
                    ),
                ],
              ),
              const SizedBox(height: 12),
            ],
            child,
          ],
        ),
      ),
    );
  }
}

class _EditForm extends StatelessWidget {
  const _EditForm({
    required this.displayNameController,
    required this.phoneController,
    required this.emergencyNameController,
    required this.emergencyPhoneController,
    required this.saving,
    required this.onCancel,
    required this.onSave,
    this.error,
  });

  final TextEditingController displayNameController;
  final TextEditingController phoneController;
  final TextEditingController emergencyNameController;
  final TextEditingController emergencyPhoneController;
  final bool saving;
  final VoidCallback onCancel;
  final VoidCallback onSave;
  final String? error;

  @override
  Widget build(BuildContext context) {
    return _InfoCard(
      title: "Edit profile",
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          GravityInput(
            label: "Display name",
            controller: displayNameController,
            textInputAction: TextInputAction.next,
          ),
          const SizedBox(height: GravitySpacing.md),
          GravityInput(
            label: "Phone",
            controller: phoneController,
            keyboardType: TextInputType.phone,
            textInputAction: TextInputAction.next,
          ),
          const SizedBox(height: GravitySpacing.lg),
          Text(
            "Emergency contact",
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w700,
              color: context.palette.textPrimary,
            ),
          ),
          const SizedBox(height: GravitySpacing.sm),
          GravityInput(
            label: "Name",
            controller: emergencyNameController,
            textInputAction: TextInputAction.next,
          ),
          const SizedBox(height: GravitySpacing.md),
          GravityInput(
            label: "Phone",
            controller: emergencyPhoneController,
            keyboardType: TextInputType.phone,
          ),
          if (error != null) ...[
            const SizedBox(height: GravitySpacing.md),
            Text(error!, style: TextStyle(color: context.palette.danger)),
          ],
          const SizedBox(height: GravitySpacing.lg),
          Row(
            children: [
              Expanded(
                child: GravityButton(
                  label: "Cancel",
                  variant: GravityButtonVariant.secondary,
                  onPressed: saving ? null : onCancel,
                ),
              ),
              const SizedBox(width: GravitySpacing.sm),
              Expanded(
                child: GravityButton(
                  label: "Save",
                  onPressed: saving ? null : onSave,
                  isLoading: saving,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _ProfileField extends StatelessWidget {
  const _ProfileField({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        SizedBox(
          width: 110,
          child: Text(
            label,
            style: TextStyle(
              fontSize: 13,
              color: context.palette.textSecondary,
            ),
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w600,
              color: context.palette.textPrimary,
            ),
          ),
        ),
      ],
    );
  }
}
