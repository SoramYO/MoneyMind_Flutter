import 'package:flutter/material.dart';
import 'package:my_project/core/constants/app_colors.dart';
import 'package:my_project/data/models/wallet.dart';
import 'package:my_project/domain/repository/wallet.dart';
import 'package:my_project/presentation/wallet/wallet_add.dart';
import 'package:my_project/service_locator.dart';
import 'package:my_project/core/utils/hex_color.dart';
import 'package:cached_network_image/cached_network_image.dart';

class WalletListView extends StatefulWidget {
  final String userId;

  const WalletListView({
    super.key,
    required this.userId,
  });

  @override
  State<WalletListView> createState() => _WalletListViewState();
}

class _WalletListViewState extends State<WalletListView> {
  List<Wallet> wallets = [];
  bool isLoading = false;
  String? error;
  int currentPage = 1;
  int pageSize = 20;

  @override
  void initState() {
    super.initState();
    _loadWallets();
  }

  Future<void> _loadWallets() async {
    setState(() {
      isLoading = true;
      error = null;
    });

    try {
      final result = await sl<WalletRepository>().getWallets(
        queryParams: {
          'userId': widget.userId,
          'page': currentPage.toString(),
          'pageSize': pageSize.toString(),
        },
      );

      result.fold(
        (errorMessage) {
          setState(() {
            error = errorMessage;
            isLoading = false;
          });
        },
        (data) {
          setState(() {
            wallets = data;
            isLoading = false;
          });
        },
      );
    } catch (e) {
      setState(() {
        error = e.toString();
        isLoading = false;
      });
    }
  }

  void _handleWalletTap(Wallet wallet) {
    // Handle wallet tap
  }

  void _handleAddWallet() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => WalletAddScreen(userId: widget.userId)),
    ).then((_) {
      _loadWallets(); // Reload wallets after adding a new one
    });
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (error != null) {
      return Center(child: Text(error!));
    }

    if (wallets.isEmpty) {
      return Scaffold(
        appBar: AppBar(
          backgroundColor: AppColors.primary,
          elevation: 10,
          title: const Text(
            'Wallets',
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
          actions: [
            IconButton(
              icon: const Icon(Icons.add),
              color: Colors.white,
              onPressed: _handleAddWallet,
            ),
          ],
        ),
        body: _buildEmptyState(),
      );
    }

    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        elevation: 0,
        title: const Text(
          'Wallets',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            color: Colors.white,
            onPressed: _handleAddWallet,
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _loadWallets,
        child: ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: wallets.length,
          itemBuilder: (context, index) {
            final wallet = wallets[index];
            return WalletCard(
              wallet: wallet,
              onTap: () => _handleWalletTap(wallet),
            );
          },
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.folder_open, size: 64, color: Colors.grey),
          const SizedBox(height: 20),
          const Text(
            'No wallets available',
            style: TextStyle(fontSize: 18, color: Colors.grey),
          ),
        ],
      ),
    );
  }
}

class WalletCard extends StatelessWidget {
  final Wallet wallet;
  final VoidCallback onTap;

  const WalletCard({
    super.key,
    required this.wallet,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: (wallet.walletCategory.color != null
                      ? HexColor(wallet.walletCategory.color!).withOpacity(0.2)
                      : Colors.grey[200]),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: _buildWalletIcon(),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      wallet.name, // Hiển thị tên ví
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      wallet.walletCategory.name,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      wallet.walletCategory.description,
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[600],
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      children: [
                        _buildInfoChip(
                          '${wallet.balance} ${wallet.currency}',
                          Icons.account_balance_wallet_outlined,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildWalletIcon() {
    if (wallet.walletCategory.iconPath != null &&
        (wallet.walletCategory.iconPath!.startsWith('http://') ||
            wallet.walletCategory.iconPath!.startsWith('https://'))) {
      return CachedNetworkImage(
        imageUrl: wallet.walletCategory.iconPath!,
        color: wallet.walletCategory.color != null
            ? HexColor(wallet.walletCategory.color!)
            : Colors.grey,
        placeholder: (context, url) => const Center(
          child: CircularProgressIndicator(),
        ),
        errorWidget: (context, url, error) {
          print("Error loading image: $error");
          return Icon(
            Icons.account_balance_wallet_outlined,
            color: wallet.walletCategory.color != null
                ? HexColor(wallet.walletCategory.color!)
                : Colors.grey,
          );
        },
        width: 48,
        height: 48,
        fit: BoxFit.contain,
      );
    } else if (wallet.walletCategory.iconPath != null) {
      return Image.asset(
        wallet.walletCategory.iconPath!,
        color: wallet.walletCategory.color != null
            ? HexColor(wallet.walletCategory.color!)
            : Colors.grey,
        width: 48,
        height: 48,
        fit: BoxFit.contain,
      );
    } else {
      return Icon(
        Icons.account_balance_wallet_outlined,
        color: wallet.walletCategory.color != null
            ? HexColor(wallet.walletCategory.color!)
            : Colors.grey,
      );
    }
  }

  Widget _buildInfoChip(String text, IconData icon) {
    return Chip(
      label: Text(text),
      labelStyle: const TextStyle(fontSize: 12),
      avatar: Icon(icon, size: 16),
      visualDensity: const VisualDensity(horizontal: -4, vertical: -4),
      backgroundColor: Colors.grey[100],
    );
  }
}