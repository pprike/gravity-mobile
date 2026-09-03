with open('lib/features/profile/profile_screen.dart', 'r', encoding='utf-8') as f:
    content = f.read()

sep = '\r\n' if '\r\n' in content else '\n'

marker = (
    "                          : () => showChangePasswordSheet(context)," + sep +
    "                    )," + sep +
    "                    const Divider(height: 1)," + sep +
    "                    ListTile(" + sep +
    "                      leading: Icon(" + sep +
    "                        Icons.logout_rounded,"
)

replacement = (
    "                          : () => showChangePasswordSheet(context)," + sep +
    "                    )," + sep +
    "                    const Divider(height: 1)," + sep +
    "                    const _BiometricTile()," + sep +
    "                    const Divider(height: 1)," + sep +
    "                    ListTile(" + sep +
    "                      leading: Icon(" + sep +
    "                        Icons.logout_rounded,"
)

if marker in content:
    content = content.replace(marker, replacement, 1)
    with open('lib/features/profile/profile_screen.dart', 'w', encoding='utf-8') as f:
        f.write(content)
    print('replaced')
else:
    print('not found - checking line endings')
    print(repr(content[content.find('showChangePasswordSheet'):content.find('showChangePasswordSheet')+200]))
