import 'package:flutter/material.dart';

class AppIcons {
  static const List<AppIcon> walletCategoryIcons = [
    AppIcon(
      id: 'home',
      icon: Icons.home,
      name: 'Home',
      link:
          "https://firebasestorage.googleapis.com/v0/b/moneymind-972f5.firebasestorage.app/o/Icons%2Fhousing.png?alt=media&token=f3a86a7c-54f3-4369-9021-90a086136cd1",
    ),
    AppIcon(
      id: 'food',
      icon: Icons.fastfood,
      name: 'Food',
      link:
          "https://firebasestorage.googleapis.com/v0/b/moneymind-972f5.firebasestorage.app/o/Icons%2Fdining_out.png?alt=media&token=f450fa04-1a2f-4ddd-ace3-625889f04f9b",
    ),
    AppIcon(
        id: 'transport',
        icon: Icons.directions_car,
        name: 'Transport',
        link: ""),
    AppIcon(
        id: 'shopping', icon: Icons.shopping_bag, name: 'Shopping', link: ""),
    AppIcon(
        id: 'entertainment',
        icon: Icons.movie,
        name: 'Entertainment',
        link: ""),
    AppIcon(id: 'health', icon: Icons.favorite, name: 'Health', link: ""),
    AppIcon(id: 'education', icon: Icons.school, name: 'Education', link: ""),
    AppIcon(id: 'bills', icon: Icons.receipt, name: 'Bills', link: ""),
    AppIcon(id: 'travel', icon: Icons.flight, name: 'Travel', link: ""),
    AppIcon(id: 'gift', icon: Icons.card_giftcard, name: 'Gift', link: ""),
    AppIcon(id: 'savings', icon: Icons.savings, name: 'Savings', link: ""),
    AppIcon(id: 'others', icon: Icons.category, name: 'Others', link: ""),
  ];

  static IconData getIconById(String id) {
    return walletCategoryIcons
        .firstWhere(
          (element) => element.id == id,
          orElse: () =>
              AppIcon(id: 'default', icon: Icons.category, name: 'Default'),
        )
        .icon;
  }

  static String? getLinkById(String id) {
    try {
      return walletCategoryIcons.firstWhere((icon) => icon.id == id).link;
    } catch (e) {
      return null;
    }
  }
}

class AppIcon {
  final String id;
  final IconData icon;
  final String name;
  final String? link;

  const AppIcon({
    required this.id,
    required this.icon,
    required this.name,
    this.link,
  });
}
