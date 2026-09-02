import "package:flutter/material.dart";
import "package:flutter_riverpod/flutter_riverpod.dart";
import "package:go_router/go_router.dart";
import "package:image_picker/image_picker.dart";

import "../../core/providers/app_providers.dart";
import "../../core/theme/design_tokens.dart";
import "../../core/widgets/gravity_button.dart";
import "../../core/widgets/gravity_card.dart";
import "../../core/widgets/gravity_feedback.dart";
import "../../core/widgets/gravity_input.dart";
import "../notifications/notification_settings_screen.dart";
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

  String _resolveAvatarUrl(String? avatarUrl) {
    if (avatarUrl == null || avatarUrl.isEmpty) return "";
    if (avatarUrl.startsWith("http")) return avatarUrl;
    final baseUrl = ref.read(appConfigProvider).apiBaseUrl;
    return "$baseUrl$avatarUrl";
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
      if (mounted) setState(() => _isEditing = false);
    } catch (error) {
      setState(() => _error = error.toString());
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
      setState(() => _error = error.toString());
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

    ref.listen(profileControllerProvider(session.user.id), (previous, next) {
      final profile = next.valueOrNull?.member;
      if (profile != null && !_isEditing) {
        _populateFields(profile);
      }
    });

    if (profileState.isLoading && member == null) {
      return const Center(child: CircularProgressIndicator());
    }

    if (!_isEditing && member != null && _displayNameController.text.isEmpty) {
      _populateFields(member);
    }

    final avatarUrl = _resolveAvatarUrl(member?.avatarUrl);

    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 32),
      children: [
        Row(
          children: [
            const Expanded(
              child: Text(
                "Profile",
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w800,
                  color: GravityColors.gray900,
                ),
              ),
            ),
            if (!_isEditing && member != null)
              TextButton(
                onPressed: () => setState(() => _isEditing = true),
                child: const Text("Edit"),
              ),
          ],
        ),
        const SizedBox(height: GravitySpacing.md),
        Center(
          child: Stack(
            children: [
              CircleAvatar(
                radius: 48,
                backgroundColor: GravityColors.primary50,
                backgroundImage: avatarUrl.isNotEmpty
                    ? NetworkImage(avatarUrl)
                    : null,
                child: avatarUrl.isEmpty
                    ? Text(
                        (member?.displayName ?? session.user.displayName)
                            .characters
                            .first
                            .toUpperCase(),
                        style: const TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.w700,
                          color: GravityColors.primary700,
                        ),
                      )
                    : null,
              ),
              if (_isEditing)
                Positioned(
                  right: 0,
                  bottom: 0,
                  child: IconButton.filled(
                    style: IconButton.styleFrom(
                      backgroundColor: GravityColors.primary600,
                      foregroundColor: Colors.white,
                    ),
                    onPressed: _isSaving
                        ? null
                        : () => _pickAvatar(session.user.id),
                    icon: const Icon(Icons.camera_alt_outlined, size: 18),
                  ),
                ),
            ],
          ),
        ),
        const SizedBox(height: GravitySpacing.sm),
        Center(
          child: Text(
            member?.displayName ?? session.user.displayName,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: GravityColors.gray900,
            ),
          ),
        ),
        Center(
          child: Text(
            session.user.email,
            style: const TextStyle(fontSize: 13, color: GravityColors.gray500),
          ),
        ),
        const SizedBox(height: GravitySpacing.lg),
        if (subscription?.planName != null)
          Padding(
            padding: const EdgeInsets.only(bottom: GravitySpacing.md),
            child: GravityCard(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: GravityColors.primary50,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(
                      Icons.workspace_premium_rounded,
                      color: GravityColors.primary700,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          subscription!.planName!,
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        Text(
                          [
                            if (subscription.status != null)
                              subscription.status,
                            if (subscription.renewalLabel != null)
                              subscription.renewalLabel,
                          ].join(" · "),
                          style: const TextStyle(
                            fontSize: 12,
                            color: GravityColors.gray500,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        if (member == null)
          const GravityCard(
            child: Text(
              "No member profile is linked to this account. "
              "Sign in with a Member role to edit profile details.",
            ),
          )
        else if (_isEditing) ...[
          GravityCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                GravityInput(
                  label: "Display name",
                  controller: _displayNameController,
                  textInputAction: TextInputAction.next,
                ),
                const SizedBox(height: GravitySpacing.md),
                GravityInput(
                  label: "Phone",
                  controller: _phoneController,
                  keyboardType: TextInputType.phone,
                  textInputAction: TextInputAction.next,
                ),
                const SizedBox(height: GravitySpacing.lg),
                Text(
                  "Emergency contact",
                  style: Theme.of(context).textTheme.titleSmall,
                ),
                const SizedBox(height: GravitySpacing.sm),
                GravityInput(
                  label: "Name",
                  controller: _emergencyNameController,
                  textInputAction: TextInputAction.next,
                ),
                const SizedBox(height: GravitySpacing.md),
                GravityInput(
                  label: "Phone",
                  controller: _emergencyPhoneController,
                  keyboardType: TextInputType.phone,
                ),
                if (_error != null) ...[
                  const SizedBox(height: GravitySpacing.md),
                  Text(
                    _error!,
                    style: const TextStyle(color: GravityColors.danger600),
                  ),
                ],
                const SizedBox(height: GravitySpacing.lg),
                Row(
                  children: [
                    Expanded(
                      child: GravityButton(
                        label: "Cancel",
                        variant: GravityButtonVariant.secondary,
                        onPressed: _isSaving
                            ? null
                            : () => setState(() {
                                _isEditing = false;
                                _populateFields(member);
                              }),
                      ),
                    ),
                    const SizedBox(width: GravitySpacing.sm),
                    Expanded(
                      child: GravityButton(
                        label: "Save",
                        onPressed: _isSaving
                            ? null
                            : () => _save(session.user.id),
                        isLoading: _isSaving,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ] else ...[
          GravityCard(
            child: Column(
              children: [
                _ProfileField(
                  label: "Display name",
                  value: member.displayName ?? "—",
                ),
                const Divider(height: GravitySpacing.lg),
                _ProfileField(label: "Phone", value: member.phone ?? "—"),
              ],
            ),
          ),
          const SizedBox(height: GravitySpacing.md),
          GravityCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Emergency contact",
                  style: Theme.of(context).textTheme.titleSmall,
                ),
                const SizedBox(height: GravitySpacing.md),
                _ProfileField(
                  label: "Name",
                  value: member.emergencyContact?["name"] ?? "—",
                ),
                const Divider(height: GravitySpacing.lg),
                _ProfileField(
                  label: "Phone",
                  value: member.emergencyContact?["phone"] ?? "—",
                ),
              ],
            ),
          ),
        ],
        const SizedBox(height: GravitySpacing.md),
        GravityCard(
          padding: EdgeInsets.zero,
          child: Column(
            children: [
              ListTile(
                leading: const Icon(
                  Icons.notifications_outlined,
                  color: GravityColors.primary700,
                ),
                title: const Text("Notifications"),
                subtitle: const Text("Choose what the studio can send you"),
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
              ListTile(
                leading: const Icon(
                  Icons.logout_rounded,
                  color: GravityColors.danger600,
                ),
                title: const Text("Sign out"),
                onTap: _logout,
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _ProfileField extends StatelessWidget {
  const _ProfileField({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: Theme.of(context).textTheme.labelMedium),
        const SizedBox(height: 4),
        Text(
          value,
          style: Theme.of(
            context,
          ).textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w500),
        ),
      ],
    );
  }
}
