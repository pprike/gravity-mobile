import "package:flutter/material.dart";
import "package:flutter_riverpod/flutter_riverpod.dart";
import "package:go_router/go_router.dart";
import "package:image_picker/image_picker.dart";

import "../../core/providers/app_providers.dart";
import "../../core/theme/design_tokens.dart";
import "../../core/widgets/gravity_button.dart";
import "../../core/widgets/gravity_card.dart";
import "../../core/widgets/gravity_input.dart";
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
      await ref.read(profileControllerProvider(userId).notifier).save(
            UpdateProfileRequest(
              displayName: _displayNameController.text.trim(),
              phone: _phoneController.text.trim(),
              emergencyContact: (emergencyName.isEmpty && emergencyPhone.isEmpty)
                  ? null
                  : {
                      if (emergencyName.isNotEmpty) "name": emergencyName,
                      if (emergencyPhone.isNotEmpty) "phone": emergencyPhone,
                    },
            ),
          );
      if (mounted) setState(() => _isEditing = false);
    } catch (error) {
      setState(() => _error = error.toString());
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  Future<void> _logout() async {
    await ref.read(authRepositoryProvider).logout();
    ref.invalidate(authSessionProvider);
    if (mounted) context.go("/login");
  }

  @override
  Widget build(BuildContext context) {
    final session = ref.watch(authSessionProvider).value;
    if (session == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    final profileState = ref.watch(profileControllerProvider(session.user.id));
    final member = profileState.valueOrNull?.member;

    ref.listen(profileControllerProvider(session.user.id), (previous, next) {
      final profile = next.valueOrNull?.member;
      if (profile != null && !_isEditing) {
        _populateFields(profile);
      }
    });

    if (profileState.isLoading && member == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    if (profileState.hasError && member == null) {
      return Scaffold(
        appBar: widget.embedded ? null : _buildAppBar(member),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(GravitySpacing.lg),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(profileState.error.toString()),
                const SizedBox(height: GravitySpacing.md),
                GravityButton(
                  label: "Retry",
                  onPressed: () => ref
                      .read(profileControllerProvider(session.user.id).notifier)
                      .load(),
                ),
              ],
            ),
          ),
        ),
      );
    }

    if (!_isEditing && member != null && _displayNameController.text.isEmpty) {
      _populateFields(member);
    }

    final avatarUrl = _resolveAvatarUrl(member?.avatarUrl);

    return Scaffold(
      appBar: widget.embedded ? null : _buildAppBar(member),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(GravitySpacing.lg),
          children: [
            if (widget.embedded) ...[
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "Profile",
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                  Row(
                    children: [
                      if (!_isEditing && member != null)
                        IconButton(
                          tooltip: "Edit",
                          onPressed: () => setState(() => _isEditing = true),
                          icon: const Icon(Icons.edit_outlined),
                        ),
                      IconButton(
                        tooltip: "Sign out",
                        onPressed: _logout,
                        icon: const Icon(Icons.logout_rounded),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: GravitySpacing.md),
            ],
            Center(
              child: Stack(
                children: [
                  CircleAvatar(
                    radius: 48,
                    backgroundColor: GravityColors.neutral200,
                    backgroundImage:
                        avatarUrl.isNotEmpty ? NetworkImage(avatarUrl) : null,
                    child: avatarUrl.isEmpty
                        ? Text(
                            (member?.displayName ?? session.user.displayName)
                                .characters
                                .first
                                .toUpperCase(),
                            style: const TextStyle(
                              fontSize: 28,
                              fontWeight: FontWeight.w600,
                              color: GravityColors.neutral700,
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
                session.user.email,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: GravityColors.neutral600,
                    ),
              ),
            ),
            const SizedBox(height: GravitySpacing.lg),
            if (member == null)
              GravityCard(
                child: Text(
                  "No member profile is linked to this account. "
                  "Sign in with a Member role to edit profile details.",
                  style: Theme.of(context).textTheme.bodyMedium,
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
                            onPressed:
                                _isSaving ? null : () => _save(session.user.id),
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
                    _ProfileField(
                      label: "Phone",
                      value: member.phone ?? "—",
                    ),
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
          ],
        ),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar(MemberProfileData? member) {
    return AppBar(
      title: const Text("Profile"),
      actions: [
        if (!_isEditing && member != null)
          IconButton(
            tooltip: "Edit",
            onPressed: () => setState(() => _isEditing = true),
            icon: const Icon(Icons.edit_outlined),
          ),
        IconButton(
          tooltip: "Sign out",
          onPressed: _logout,
          icon: const Icon(Icons.logout_rounded),
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
        Text(
          label,
          style: Theme.of(context).textTheme.labelMedium,
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                fontWeight: FontWeight.w500,
              ),
        ),
      ],
    );
  }
}
