import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/exchange_provider.dart';
import '../../widgets/rate_chart.dart';
import '../../widgets/theme_icons.dart';

class RateAlertsScreen extends StatefulWidget {
  const RateAlertsScreen({super.key});

  @override
  State<RateAlertsScreen> createState() => _RateAlertsScreenState();
}

class _RateAlertsScreenState extends State<RateAlertsScreen> {
  final List<RateAlert> _alerts = [
    RateAlert(targetRate: 0.72, isAbove: true, isActive: true),
    RateAlert(targetRate: 0.68, isAbove: false, isActive: true),
  ];

  @override
  Widget build(BuildContext context) {
    final rate = context.watch<ExchangeProvider>().baseRate;

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: Stack(
        children: [
          // Main Content
          CustomScrollView(
            physics: const BouncingScrollPhysics(),
            slivers: [
              // Header
              SliverToBoxAdapter(child: _buildHeader(rate)),
              // Chart
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
                  child: RateChart(currentRate: rate),
                ),
              ),
              // Section Title
              SliverToBoxAdapter(child: _buildSectionTitle()),
              // Alerts List
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 140),
                sliver: _alerts.isEmpty
                    ? SliverToBoxAdapter(child: _buildEmpty())
                    : SliverList(
                        delegate: SliverChildBuilderDelegate(
                          (context, index) => _buildAlertItem(_alerts[index], rate),
                          childCount: _alerts.length,
                        ),
                      ),
              ),
            ],
          ),
          // Fixed Bottom Button
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: _buildBottomButton(),
          ),
        ],
      ),
    );
  }


  Widget _buildHeader(double rate) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF6366F1), Color(0xFF8B5CF6)],
        ),
      ),
      child: SafeArea(
        bottom: false,
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      ThemeIcons.notification(color: Colors.white, size: 28),
                      const SizedBox(width: 8),
                      const Text(
                        'Rate Alerts',
                        style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Current: ₹${(rate * 100).toStringAsFixed(2)} / 100 BDT',
                    style: const TextStyle(color: Colors.white70, fontSize: 14),
                  ),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                children: [
                  ThemeIcons.trendingUp(color: Colors.white, size: 16),
                  const SizedBox(width: 4),
                  const Text('LIVE', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 11)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text('Your Alerts', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF1E293B))),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: const Color(0xFF6366F1).withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              '${_alerts.where((a) => a.isActive).length} active',
              style: const TextStyle(color: Color(0xFF6366F1), fontSize: 12, fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAlertItem(RateAlert alert, double currentRate) {
    final isHit = alert.isAbove ? currentRate >= alert.targetRate : currentRate <= alert.targetRate;
    final color = alert.isAbove ? const Color(0xFF10B981) : const Color(0xFFEF4444);
    final index = _alerts.indexOf(alert);

    return Dismissible(
      key: Key('alert_${alert.targetRate}_${alert.isAbove}_$index'),
      direction: DismissDirection.endToStart,
      background: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.only(right: 20),
        decoration: BoxDecoration(
          color: const Color(0xFFEF4444),
          borderRadius: BorderRadius.circular(16),
        ),
        alignment: Alignment.centerRight,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            ThemeIcons.delete(color: Colors.white, size: 24),
            const SizedBox(width: 8),
            const Text('Delete', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
          ],
        ),
      ),
      confirmDismiss: (direction) async {
        return await _showDeleteConfirmation(alert);
      },
      onDismissed: (direction) {
        _deleteAlert(alert);
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: isHit && alert.isActive ? Border.all(color: color, width: 2) : null,
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 10)],
        ),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(12)),
              child: Center(
                child: alert.isAbove
                    ? ThemeIcons.trendingUp(color: color, size: 24)
                    : ThemeIcons.trendingDown(color: color, size: 24),
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(alert.isAbove ? 'Above' : 'Below', style: TextStyle(color: color, fontSize: 12, fontWeight: FontWeight.w600)),
                      if (isHit && alert.isActive) ...[
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(4)),
                          child: const Text('HIT!', style: TextStyle(color: Colors.white, fontSize: 9, fontWeight: FontWeight.bold)),
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 2),
                  Text('₹${(alert.targetRate * 100).toStringAsFixed(2)}', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF1E293B))),
                ],
              ),
            ),
            // Delete button
            GestureDetector(
              onTap: () => _showDeleteConfirmation(alert).then((confirmed) {
                if (confirmed == true) _deleteAlert(alert);
              }),
              child: Container(
                width: 36,
                height: 36,
                margin: const EdgeInsets.only(right: 8),
                decoration: BoxDecoration(
                  color: const Color(0xFFEF4444).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Center(
                  child: ThemeIcons.delete(color: const Color(0xFFEF4444), size: 20),
                ),
              ),
            ),
            Switch(
              value: alert.isActive,
              onChanged: (v) => setState(() => alert.isActive = v),
              activeColor: const Color(0xFF6366F1),
            ),
          ],
        ),
      ),
    );
  }

  Future<bool?> _showDeleteConfirmation(RateAlert alert) {
    return showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: const Color(0xFFEF4444).withOpacity(0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: ThemeIcons.delete(color: const Color(0xFFEF4444), size: 24),
            ),
            const SizedBox(width: 12),
            const Text('Delete Alert?'),
          ],
        ),
        content: Text(
          'Are you sure you want to delete the alert for ₹${(alert.targetRate * 100).toStringAsFixed(2)}?',
          style: const TextStyle(fontSize: 15, color: Color(0xFF64748B)),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel', style: TextStyle(color: Color(0xFF64748B))),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFEF4444),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  void _deleteAlert(RateAlert alert) {
    setState(() => _alerts.remove(alert));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Alert deleted'),
        backgroundColor: const Color(0xFF64748B),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        action: SnackBarAction(
          label: 'Undo',
          textColor: Colors.white,
          onPressed: () {
            setState(() => _alerts.add(alert));
          },
        ),
      ),
    );
  }

  Widget _buildEmpty() {
    return Container(
      padding: const EdgeInsets.all(40),
      child: Column(
        children: [
          ThemeIcons.notificationOff(color: Colors.grey[300]!, size: 60),
          const SizedBox(height: 16),
          const Text('No alerts yet', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Color(0xFF64748B))),
        ],
      ),
    );
  }


  Widget _buildBottomButton() {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 100),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.08), blurRadius: 20, offset: const Offset(0, -5))],
      ),
      child: SafeArea(
        top: false,
        child: ElevatedButton.icon(
          onPressed: _showAddAlert,
          icon: ThemeIcons.add(color: Colors.white, size: 22),
          label: const Text('Create New Alert', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF6366F1),
            minimumSize: const Size(double.infinity, 56),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            elevation: 0,
          ),
        ),
      ),
    );
  }

  void _showAddAlert() {
    final controller = TextEditingController();
    bool isAbove = true;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setS) => Container(
          padding: EdgeInsets.fromLTRB(24, 24, 24, MediaQuery.of(ctx).viewInsets.bottom + 24),
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(child: Container(width: 40, height: 4, decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(2)))),
              const SizedBox(height: 24),
              const Text('Create Price Alert', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Color(0xFF1E293B))),
              const SizedBox(height: 8),
              const Text('Get notified when rate hits your target', style: TextStyle(color: Color(0xFF64748B), fontSize: 14)),
              const SizedBox(height: 24),
              const Text('Target Rate (per 100 BDT)', style: TextStyle(fontWeight: FontWeight.w600, color: Color(0xFF1E293B))),
              const SizedBox(height: 10),
              TextField(
                controller: controller,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                decoration: InputDecoration(
                  hintText: '72.00',
                  prefixText: '₹ ',
                  prefixStyle: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF6366F1)),
                  filled: true,
                  fillColor: const Color(0xFFF8FAFC),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide.none),
                  focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: const BorderSide(color: Color(0xFF6366F1), width: 2)),
                ),
              ),
              const SizedBox(height: 20),
              const Text('Alert when rate', style: TextStyle(fontWeight: FontWeight.w600, color: Color(0xFF1E293B))),
              const SizedBox(height: 10),
              Row(
                children: [
                  Expanded(
                    child: GestureDetector(
                      onTap: () => setS(() => isAbove = true),
                      child: Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: isAbove ? const Color(0xFF10B981) : const Color(0xFFF8FAFC),
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(color: isAbove ? const Color(0xFF10B981) : const Color(0xFFE2E8F0)),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            ThemeIcons.trendingUp(
                              color: isAbove ? Colors.white : const Color(0xFF64748B),
                              size: 24,
                            ),
                            const SizedBox(width: 8),
                            Text('Goes Above', style: TextStyle(color: isAbove ? Colors.white : const Color(0xFF64748B), fontWeight: FontWeight.w600)),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: GestureDetector(
                      onTap: () => setS(() => isAbove = false),
                      child: Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: !isAbove ? const Color(0xFFEF4444) : const Color(0xFFF8FAFC),
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(color: !isAbove ? const Color(0xFFEF4444) : const Color(0xFFE2E8F0)),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            ThemeIcons.trendingDown(
                              color: !isAbove ? Colors.white : const Color(0xFF64748B),
                              size: 24,
                            ),
                            const SizedBox(width: 8),
                            Text('Goes Below', style: TextStyle(color: !isAbove ? Colors.white : const Color(0xFF64748B), fontWeight: FontWeight.w600)),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 28),
              ElevatedButton(
                onPressed: () {
                  final r = double.tryParse(controller.text);
                  if (r == null) return;
                  setState(() => _alerts.insert(0, RateAlert(targetRate: r / 100, isAbove: isAbove, isActive: true)));
                  Navigator.pop(ctx);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: const Text('Alert created! 🔔'),
                      backgroundColor: const Color(0xFF10B981),
                      behavior: SnackBarBehavior.floating,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF6366F1),
                  minimumSize: const Size(double.infinity, 56),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  elevation: 0,
                ),
                child: const Text('Create Alert', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class RateAlert {
  final double targetRate;
  final bool isAbove;
  bool isActive;
  RateAlert({required this.targetRate, required this.isAbove, required this.isActive});
}
