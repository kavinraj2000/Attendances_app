class NavItem {
  final int index;
  final String path;
  final String icon;
  final String label;
  final bool isDefault;
  final bool skipInNavBar;

  const NavItem({
    required this.index,
    required this.path,
    required this.icon,
    required this.label,
    this.isDefault = false,
    this.skipInNavBar = false,
  });
}