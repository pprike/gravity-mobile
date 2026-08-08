import "package:flutter/material.dart";
import "package:flutter_riverpod/flutter_riverpod.dart";
import "package:go_router/go_router.dart";
import "package:image_picker/image_picker.dart";

import "../../core/providers/app_providers.dart";
import "models/user_profile.dart";
import "profile_controller.dart";

class ProfileScreen extends ConsumerStatefulWidget {
  const ProfileScreen({super.key});

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
        appBar: AppBar(title: const Text("Profile")),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(profileState.error.toString()),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () => ref
                      .read(profileControllerProvider(session.user.id).notifier)
                      .load(),
                  child: const Text("Retry"),
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
      appBar: AppBar(
        title: const Text("Profile"),
        actions: [
          if (!_isEditing)
            IconButton(
              tooltip: "Edit",
              onPressed: member == null
                  ? null
                  : () => setState(() => _isEditing = true),
              icon: const Icon(Icons.edit_outlined),
            ),
          IconButton(
            tooltip: "Sign out",
            onPressed: _logout,
            icon: const Icon(Icons.logout),
          ),
        ],
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(24),
          children: [
            Center(
              child: Stack(
                children: [
                  CircleAvatar(
                    radius: 48,
                    backgroundColor: const Color(0xFFE2E8F0),
                    backgroundImage:
                        avatarUrl.isNotEmpty ? NetworkImage(avatarUrl) : null,
                    child: avatarUrl.isEmpty
                        ? Text(
                            (member?.displayName ?? session.user.displayName)
                                .characters
                                .first
                                .toUpperCase(),
                            style: const TextStyle(fontSize: 28),
                          )
                        : null,
                  ),
                  if (_isEditing)
                    Positioned(
                      right: 0,
                      bottom: 0,
                      child: IconButton.filled(
                        onPressed: _isSaving
                            ? null
                            : () => _pickAvatar(session.user.id),
                        icon: const Icon(Icons.camera_alt_outlined, size: 18),
                      ),
                    ),
                ],
              ),
            ),
            const SizedBox(height: 8),
            Center(
              child: Text(
                session.user.email,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Colors.grey.shade600,
                    ),
              ),
            ),
            const SizedBox(height: 24),
            if (member == null)
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Text(
                    "No member profile is linked to this account. "
                    "Sign in with a Member role to edit profile details.",
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ),
              )
            else if (_isEditing) ...[
              TextField(
                controller: _displayNameController,
                decoration: const InputDecoration(labelText: "Display name"),
                textInputAction: TextInputAction.next,
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _phoneController,
                decoration: const InputDecoration(labelText: "Phone"),
                keyboardType: TextInputType.phone,
                textInputAction: TextInputAction.next,
              ),
              const SizedBox(height: 24),
              Text(
                "Emergency contact",
                style: Theme.of(context).textTheme.titleSmall,
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _emergencyNameController,
                decoration: const InputDecoration(labelText: "Name"),
                textInputAction: TextInputAction.next,
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _emergencyPhoneController,
                decoration: const InputDecoration(labelText: "Phone"),
                keyboardType: TextInputType.phone,
              ),
              if (_error != null) ...[
                const SizedBox(height: 16),
                Text(
                  _error!,
                  style: TextStyle(color: Theme.of(context).colorScheme.error),
                ),
              ],
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: _isSaving
                          ? null
                          : () => setState(() {
                                _isEditing = false;
                                _populateFields(member);
                              }),
                      child: const Text("Cancel"),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: _isSaving ? null : () => _save(session.user.id),
                      child: _isSaving
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Text("Save"),
                    ),
                  ),
                ],
              ),
            ] else ...[
              _ProfileField(
                label: "Display name",
                value: member.displayName ?? "—",
              ),
              _ProfileField(label: "Phone", value: member.phone ?? "—"),
              const SizedBox(height: 8),
              Text(
                "Emergency contact",
                style: Theme.of(context).textTheme.titleSmall,
              ),
              const SizedBox(height: 8),
              _ProfileField(
                label: "Name",
                value: member.emergencyContact?["name"] ?? "—",
              ),
              _ProfileField(
                label: "Phone",
                value: member.emergencyContact?["phone"] ?? "—",
              ),
            ],
          ],
        ),
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
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: Theme.of(context).textTheme.labelMedium?.copyWith(
                  color: Colors.grey.shade600,
                ),
          ),
          const SizedBox(height: 4),
          Text(value, style: Theme.of(context).textTheme.bodyLarge),
        ],
      ),
    );
  }
}
