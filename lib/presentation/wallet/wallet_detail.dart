import 'package:flutter/material.dart';
import 'package:my_project/data/models/wallet.dart';
import 'package:my_project/data/models/wallet_detail.dart';
import 'package:my_project/domain/repository/wallet.dart';
import 'package:my_project/service_locator.dart';

class WalletDetail extends StatefulWidget {
  final String walletId;

  const WalletDetail({
    Key? key,
    required this.walletId,
  }) : super(key: key);

  @override
  _WalletDetailState createState() => _WalletDetailState();
}

class _WalletDetailState extends State<WalletDetail> {
  WalletClone? wallet;
  bool isLoading = true;
  String? error;

  @override
  void initState() {
    super.initState();
    _loadWalletDetail();
  }

  Future<void> _loadWalletDetail() async {
    try {
      final result = await sl<WalletRepository>().getWalletById(widget.walletId);
      result.fold(
        (errorMessage) {
          setState(() {
            error = errorMessage;
            isLoading = false;
          });
        },
        (data) {
          setState(() {
            wallet = data;
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Wallet Detail')),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : error != null
              ? Center(child: Text(error!, style: TextStyle(color: Colors.red)))
              : Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: _buildWalletDetail(),
                ),
    );
  }

  Widget _buildWalletDetail() {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          shrinkWrap: true,
          children: [
            _buildInfoRow(Icons.account_balance_wallet, 'Name', wallet?.name),
            _buildDivider(),
            _buildInfoRow(Icons.description, 'Description', wallet?.description),
            _buildDivider(),
            _buildInfoRow(Icons.attach_money, 'Balance', wallet?.balance?.toString()),
            _buildDivider(),
            _buildInfoRow(Icons.monetization_on, 'Currency', wallet?.currency),
            _buildDivider(),
            _buildInfoRow(Icons.access_time, 'Created Time', wallet!.createdTime.toString()),
            _buildDivider(),
            _buildInfoRow(Icons.update, 'Last Updated Time', wallet?.lastUpdatedTime.toString()),
            _buildDivider(),
            _buildInfoRow(Icons.category, 'Wallet Category', wallet?.walletCategory?.name ?? 'N/A'),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String? value) {
    return Row(
      children: [
        Icon(icon, size: 28, color: Colors.green),
        SizedBox(width: 12),
        Expanded(
          child: Text(
            '$label: ${value ?? "N/A"}',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
          ),
        ),
      ],
    );
  }

  Widget _buildDivider() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Divider(color: Colors.grey[300]),
    );
  }
}
