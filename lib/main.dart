import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

const _ink = Color(0xFF202B29);
const _muted = Color(0xFF687571);
const _paper = Color(0xFFF5F6F1);
const _green = Color(0xFF276253);
const _greenPale = Color(0xFFE5F0EA);
const _coral = Color(0xFFC75D43);
const _line = Color(0xFFE4E8E1);

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'PadHer',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        scaffoldBackgroundColor: _paper,
        colorScheme: ColorScheme.fromSeed(
          seedColor: _green,
          brightness: Brightness.light,
          surface: Colors.white,
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: _paper,
          foregroundColor: _ink,
          surfaceTintColor: Colors.transparent,
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: Colors.white,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 14,
            vertical: 13,
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: _line),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: _line),
          ),
        ),
      ),
      home: const HomeScreen(),
    );
  }
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;
  String _selectedProduct = 'Reusable pads';
  String _priority = 'Standard';
  int _requestQuantity = 6;

  final List<_Supply> _supplies = [
    _Supply(name: 'Reusable pads', onHand: 42, lowAt: 20, unit: 'kits'),
    _Supply(name: 'Disposable pads', onHand: 12, lowAt: 25, unit: 'packs'),
    _Supply(name: 'Soap', onHand: 31, lowAt: 15, unit: 'bars'),
  ];

  final List<_SupplyRequest> _requests = [
    _SupplyRequest(
      facility: 'Oli Primary School',
      item: 'Disposable pads',
      quantity: 12,
      status: 'Ready for review',
      age: '35 min ago',
    ),
    _SupplyRequest(
      facility: 'Ediofe Girls School',
      item: 'Reusable pads',
      quantity: 8,
      status: 'Approved',
      age: 'Yesterday',
    ),
  ];

  int get _lowStockCount =>
      _supplies.where((supply) => supply.onHand <= supply.lowAt).length;

  void _changeStock(_Supply supply, int delta) {
    setState(() {
      supply.onHand = (supply.onHand + delta).clamp(0, 9999);
    });
  }

  void _submitRequest() {
    final supply = _supplies.firstWhere(
      (item) => item.name == _selectedProduct,
    );
    setState(() {
      _requests.insert(
        0,
        _SupplyRequest(
          facility: 'St. Mary\'s Secondary',
          item: _selectedProduct,
          quantity: _requestQuantity,
          status: 'Ready for review',
          age: 'Just now',
        ),
      );
      supply.onHand = (supply.onHand - _requestQuantity).clamp(0, 9999);
      _selectedIndex = 1;
    });
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Request logged for staff review')),
    );
  }

  @override
  Widget build(BuildContext context) {
    final pages = [
      _buildOverview(),
      _buildRequests(),
      _buildStock(),
      _buildInsights(),
    ];

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            _TopBar(
              onNotificationTap: () => setState(() => _selectedIndex = 1),
            ),
            Expanded(
              child: IndexedStack(index: _selectedIndex, children: pages),
            ),
          ],
        ),
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _selectedIndex,
        backgroundColor: Colors.white,
        indicatorColor: _greenPale,
        labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
        onDestinationSelected: (index) =>
            setState(() => _selectedIndex = index),
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.grid_view_outlined),
            selectedIcon: Icon(Icons.grid_view_rounded),
            label: 'Home',
          ),
          NavigationDestination(
            icon: Icon(Icons.assignment_outlined),
            selectedIcon: Icon(Icons.assignment_rounded),
            label: 'Requests',
          ),
          NavigationDestination(
            icon: Icon(Icons.inventory_2_outlined),
            selectedIcon: Icon(Icons.inventory_2_rounded),
            label: 'Stock',
          ),
          NavigationDestination(
            icon: Icon(Icons.insights_outlined),
            selectedIcon: Icon(Icons.insights_rounded),
            label: 'Insights',
          ),
        ],
      ),
    );
  }

  Widget _buildOverview() {
    return _PageScroll(
      children: [
        const _FacilityHeader(
          eyebrow: 'STAFF DASHBOARD',
          title: 'St. Mary\'s Secondary',
          subtitle: 'Arua City  ·  Senior women teacher',
        ),
        const SizedBox(height: 20),
        _ImpactStrip(requests: _requests.length + 36, lowStock: _lowStockCount),
        const SizedBox(height: 24),
        Row(
          children: [
            const Expanded(child: _SectionTitle('Stock at this point')),
            TextButton(
              onPressed: () => setState(() => _selectedIndex = 2),
              child: const Text('Manage stock'),
            ),
          ],
        ),
        const SizedBox(height: 4),
        ..._supplies.map((supply) => _StockSummaryRow(supply: supply)),
        const SizedBox(height: 22),
        Row(
          children: [
            const Expanded(child: _SectionTitle('Recent requests')),
            TextButton(
              onPressed: () => setState(() => _selectedIndex = 1),
              child: const Text('View all'),
            ),
          ],
        ),
        const SizedBox(height: 4),
        ..._requests.take(2).map((request) => _RequestRow(request: request)),
        const SizedBox(height: 18),
        FilledButton.icon(
          onPressed: () => setState(() => _selectedIndex = 1),
          icon: const Icon(Icons.add_rounded),
          label: const Text('Log a supply request'),
          style: _primaryButtonStyle,
        ),
        const SizedBox(height: 12),
        const Center(
          child: Text(
            'No personal information about girls is stored.',
            textAlign: TextAlign.center,
            style: TextStyle(color: _muted, fontSize: 12),
          ),
        ),
      ],
    );
  }

  Widget _buildRequests() {
    return _PageScroll(
      children: [
        const _FacilityHeader(
          eyebrow: 'REQUEST INTAKE',
          title: 'Log a request',
          subtitle: 'Record the need, not the person.',
        ),
        const SizedBox(height: 18),
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: const Color(0xFFFFF3E7),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: const Color(0xFFF0D5B7)),
          ),
          child: const Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(Icons.shield_outlined, color: Color(0xFF9A5A24), size: 20),
              SizedBox(width: 10),
              Expanded(
                child: Text(
                  'No names or personal details are collected.',
                  style: TextStyle(
                    color: Color(0xFF754519),
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 22),
        const _FieldLabel('School or distribution point'),
        const SizedBox(height: 8),
        const _ReadOnlyField(
          icon: Icons.location_on_outlined,
          label: 'St. Mary\'s Secondary',
        ),
        const SizedBox(height: 18),
        const _FieldLabel('Supply needed'),
        const SizedBox(height: 8),
        Wrap(
          spacing: 9,
          runSpacing: 8,
          children: [
            _ProductChoice(
              label: 'Reusable pads',
              selected: _selectedProduct == 'Reusable pads',
              onTap: () => setState(() => _selectedProduct = 'Reusable pads'),
            ),
            _ProductChoice(
              label: 'Disposable pads',
              selected: _selectedProduct == 'Disposable pads',
              onTap: () => setState(() => _selectedProduct = 'Disposable pads'),
            ),
            _ProductChoice(
              label: 'Soap',
              selected: _selectedProduct == 'Soap',
              onTap: () => setState(() => _selectedProduct = 'Soap'),
            ),
          ],
        ),
        const SizedBox(height: 18),
        const _FieldLabel('Quantity'),
        const SizedBox(height: 8),
        _QuantityControl(
          value: _requestQuantity,
          unit: _selectedProduct == 'Reusable pads' ? 'kits' : 'packs / bars',
          onChanged: (value) => setState(() => _requestQuantity = value),
        ),
        const SizedBox(height: 18),
        const _FieldLabel('Priority'),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          children: [
            _PriorityChoice(
              label: 'Standard',
              selected: _priority == 'Standard',
              onTap: () => setState(() => _priority = 'Standard'),
            ),
            _PriorityChoice(
              label: 'Urgent',
              selected: _priority == 'Urgent',
              onTap: () => setState(() => _priority = 'Urgent'),
            ),
          ],
        ),
        const SizedBox(height: 22),
        FilledButton.icon(
          onPressed: _submitRequest,
          icon: const Icon(Icons.check_rounded),
          label: const Text('Submit request'),
          style: _primaryButtonStyle,
        ),
        const SizedBox(height: 26),
        const _SectionTitle('Recent requests'),
        const SizedBox(height: 8),
        ..._requests.map((request) => _RequestRow(request: request)),
      ],
    );
  }

  Widget _buildStock() {
    return _PageScroll(
      children: [
        const _FacilityHeader(
          eyebrow: 'INVENTORY',
          title: 'Stock levels',
          subtitle: 'St. Mary\'s Secondary  ·  Last updated just now',
        ),
        const SizedBox(height: 18),
        if (_lowStockCount > 0)
          _LowStockBanner(count: _lowStockCount)
        else
          const _InStockBanner(),
        const SizedBox(height: 18),
        ..._supplies.map(
          (supply) => Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: _StockManagementCard(
              supply: supply,
              onDecrease: () => _changeStock(supply, -1),
              onIncrease: () => _changeStock(supply, 1),
              onEdit: () => _showStockEditDialog(supply),
            ),
          ),
        ),
        const SizedBox(height: 12),
        const Text(
          'Stock is tracked by school or distribution point. A request does not reveal who needs the supplies.',
          style: TextStyle(color: _muted, fontSize: 13, height: 1.5),
        ),
        const SizedBox(height: 18),
        OutlinedButton.icon(
          onPressed: () => setState(() => _selectedIndex = 1),
          icon: const Icon(Icons.add_rounded),
          label: const Text('Log a supply request'),
          style: OutlinedButton.styleFrom(
            foregroundColor: _green,
            minimumSize: const Size.fromHeight(50),
            side: const BorderSide(color: _green),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildInsights() {
    return _PageScroll(
      children: [
        const _FacilityHeader(
          eyebrow: 'PARTNER VIEW',
          title: 'Demand insights',
          subtitle: 'Arua City  ·  Aggregate data only',
        ),
        const SizedBox(height: 20),
        const _AggregateNotice(),
        const SizedBox(height: 20),
        const Row(
          children: [
            Expanded(
              child: _StatCard(
                value: '48',
                label: 'Requests this month',
                icon: Icons.assignment_outlined,
                color: _green,
              ),
            ),
            SizedBox(width: 10),
            Expanded(
              child: _StatCard(
                value: '3',
                label: 'Points need supply',
                icon: Icons.inventory_2_outlined,
                color: _coral,
              ),
            ),
          ],
        ),
        const SizedBox(height: 24),
        const _SectionTitle('Demand by supply type'),
        const SizedBox(height: 12),
        const _DemandBar(
          label: 'Disposable pads',
          amount: '27 requests',
          value: .78,
        ),
        const _DemandBar(
          label: 'Reusable pad kits',
          amount: '14 requests',
          value: .48,
        ),
        const _DemandBar(label: 'Soap', amount: '7 requests', value: .27),
        const SizedBox(height: 22),
        const _SectionTitle('Where support is needed'),
        const SizedBox(height: 10),
        const _NeedRow(
          facility: 'Oli Primary School',
          need: 'Disposable pads',
          gap: '18 packs short',
          urgent: true,
        ),
        const _NeedRow(
          facility: 'Ediofe Girls School',
          need: 'Reusable pad kits',
          gap: '9 kits short',
          urgent: false,
        ),
        const _NeedRow(
          facility: 'St. Mary\'s Secondary',
          need: 'Disposable pads',
          gap: '13 packs short',
          urgent: false,
        ),
        const SizedBox(height: 22),
        FilledButton.icon(
          onPressed: () => _showPledgeDialog(context),
          icon: const Icon(Icons.volunteer_activism_outlined),
          label: const Text('Record a supply pledge'),
          style: _primaryButtonStyle,
        ),
        const SizedBox(height: 14),
        const Center(
          child: Text(
            'Counts are combined across facilities. No individual records are shown.',
            textAlign: TextAlign.center,
            style: TextStyle(color: _muted, fontSize: 12, height: 1.4),
          ),
        ),
      ],
    );
  }

  Future<void> _showStockEditDialog(_Supply supply) async {
    final controller = TextEditingController(text: '${supply.onHand}');
    final quantity = await showDialog<int>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Update ${supply.name.toLowerCase()}'),
        content: TextField(
          controller: controller,
          autofocus: true,
          keyboardType: TextInputType.number,
          decoration: InputDecoration(labelText: 'Current ${supply.unit}'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () =>
                Navigator.pop(context, int.tryParse(controller.text)),
            child: const Text('Save'),
          ),
        ],
      ),
    );
    controller.dispose();
    if (quantity != null && quantity >= 0) {
      setState(() => supply.onHand = quantity);
    }
  }

  void _showPledgeDialog(BuildContext context) {
    showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Supply pledge'),
        content: const Text(
          'Pledge tracking will connect to partner accounts when backend services are configured.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }
}

final _primaryButtonStyle = FilledButton.styleFrom(
  backgroundColor: _green,
  foregroundColor: Colors.white,
  minimumSize: const Size.fromHeight(52),
  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
  textStyle: const TextStyle(fontWeight: FontWeight.w700, fontSize: 15),
);

class _Supply {
  _Supply({
    required this.name,
    required this.onHand,
    required this.lowAt,
    required this.unit,
  });

  final String name;
  int onHand;
  final int lowAt;
  final String unit;
}

class _SupplyRequest {
  const _SupplyRequest({
    required this.facility,
    required this.item,
    required this.quantity,
    required this.status,
    required this.age,
  });

  final String facility;
  final String item;
  final int quantity;
  final String status;
  final String age;
}

class _TopBar extends StatelessWidget {
  const _TopBar({required this.onNotificationTap});

  final VoidCallback onNotificationTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 11, 18, 8),
      child: Row(
        children: [
          Container(
            width: 34,
            height: 34,
            decoration: BoxDecoration(
              color: _green,
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(
              Icons.water_drop_rounded,
              color: Colors.white,
              size: 19,
            ),
          ),
          const SizedBox(width: 9),
          const Text(
            'PadHer',
            style: TextStyle(
              color: _ink,
              fontSize: 21,
              fontWeight: FontWeight.w800,
            ),
          ),
          const Spacer(),
          IconButton(
            tooltip: 'Request activity',
            onPressed: onNotificationTap,
            icon: const Icon(Icons.notifications_none_rounded),
            style: IconButton.styleFrom(
              backgroundColor: Colors.white,
              foregroundColor: _ink,
              fixedSize: const Size(42, 42),
            ),
          ),
          const SizedBox(width: 8),
          const CircleAvatar(
            radius: 18,
            backgroundColor: Color(0xFFE6D5C9),
            child: Text(
              'SM',
              style: TextStyle(
                color: Color(0xFF744B38),
                fontWeight: FontWeight.w800,
                fontSize: 12,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _PageScroll extends StatelessWidget {
  const _PageScroll({required this.children});

  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(18, 15, 18, 28),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 620),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: children,
          ),
        ),
      ),
    );
  }
}

class _FacilityHeader extends StatelessWidget {
  const _FacilityHeader({
    required this.eyebrow,
    required this.title,
    required this.subtitle,
  });

  final String eyebrow;
  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          eyebrow,
          style: const TextStyle(
            color: _green,
            fontSize: 11,
            fontWeight: FontWeight.w800,
            letterSpacing: 1.1,
          ),
        ),
        const SizedBox(height: 5),
        Text(
          title,
          style: const TextStyle(
            color: _ink,
            fontSize: 25,
            height: 1.2,
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(height: 5),
        Text(subtitle, style: const TextStyle(color: _muted, fontSize: 13)),
      ],
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle(this.label);

  final String label;

  @override
  Widget build(BuildContext context) {
    return Text(
      label,
      style: const TextStyle(
        color: _ink,
        fontSize: 17,
        fontWeight: FontWeight.w800,
      ),
    );
  }
}

class _ImpactStrip extends StatelessWidget {
  const _ImpactStrip({required this.requests, required this.lowStock});

  final int requests;
  final int lowStock;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(17),
      decoration: BoxDecoration(
        color: _green,
        borderRadius: BorderRadius.circular(15),
      ),
      child: Row(
        children: [
          const Icon(
            Icons.volunteer_activism_outlined,
            color: Colors.white,
            size: 24,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '$requests requests supported this month',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  lowStock == 0
                      ? 'All supplies are above the low-stock mark'
                      : '$lowStock supply type${lowStock == 1 ? '' : 's'} need attention',
                  style: const TextStyle(
                    color: Color(0xFFDDECE5),
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          const Icon(
            Icons.arrow_forward_ios_rounded,
            color: Colors.white70,
            size: 16,
          ),
        ],
      ),
    );
  }
}

class _StockSummaryRow extends StatelessWidget {
  const _StockSummaryRow({required this.supply});

  final _Supply supply;

  @override
  Widget build(BuildContext context) {
    final low = supply.onHand <= supply.lowAt;
    final ratio = (supply.onHand / (supply.lowAt * 2.5)).clamp(0.0, 1.0);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Container(
            width: 37,
            height: 37,
            decoration: BoxDecoration(
              color: low ? const Color(0xFFFFE8DE) : _greenPale,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              Icons.inventory_2_outlined,
              color: low ? _coral : _green,
              size: 19,
            ),
          ),
          const SizedBox(width: 11),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  supply.name,
                  style: const TextStyle(
                    color: _ink,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 6),
                ClipRRect(
                  borderRadius: BorderRadius.circular(3),
                  child: LinearProgressIndicator(
                    value: ratio,
                    minHeight: 5,
                    backgroundColor: const Color(0xFFE8EBE6),
                    color: low ? _coral : _green,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Text(
            '${supply.onHand} ${supply.unit}',
            style: TextStyle(
              color: low ? _coral : _ink,
              fontWeight: FontWeight.w800,
              fontSize: 13,
            ),
          ),
        ],
      ),
    );
  }
}

class _RequestRow extends StatelessWidget {
  const _RequestRow({required this.request});

  final _SupplyRequest request;

  @override
  Widget build(BuildContext context) {
    final approved = request.status == 'Approved';
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: _line),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Container(
            width: 34,
            height: 34,
            decoration: BoxDecoration(
              color: approved ? _greenPale : const Color(0xFFFFF0E7),
              borderRadius: BorderRadius.circular(9),
            ),
            child: Icon(
              approved ? Icons.check_rounded : Icons.schedule_rounded,
              color: approved ? _green : const Color(0xFF9A5A24),
              size: 19,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${request.quantity} ${request.item.toLowerCase()}',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: _ink,
                    fontWeight: FontWeight.w700,
                    fontSize: 13,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  '${request.facility}  ·  ${request.age}',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(color: _muted, fontSize: 11),
                ),
              ],
            ),
          ),
          const SizedBox(width: 6),
          Text(
            approved ? 'Approved' : 'Review',
            style: TextStyle(
              color: approved ? _green : const Color(0xFF9A5A24),
              fontWeight: FontWeight.w700,
              fontSize: 11,
            ),
          ),
        ],
      ),
    );
  }
}

class _LowStockBanner extends StatelessWidget {
  const _LowStockBanner({required this.count});

  final int count;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFFFEEE6),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFF0D0C0)),
      ),
      child: Row(
        children: [
          const Icon(Icons.warning_amber_rounded, color: _coral),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              '$count item${count == 1 ? '' : 's'} below the restock threshold',
              style: const TextStyle(
                color: Color(0xFF873E2C),
                fontWeight: FontWeight.w700,
                fontSize: 13,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _InStockBanner extends StatelessWidget {
  const _InStockBanner();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: _greenPale,
        borderRadius: BorderRadius.circular(12),
      ),
      child: const Row(
        children: [
          Icon(Icons.check_circle_outline_rounded, color: _green),
          SizedBox(width: 10),
          Text(
            'All supply types are above threshold',
            style: TextStyle(
              color: _green,
              fontWeight: FontWeight.w700,
              fontSize: 13,
            ),
          ),
        ],
      ),
    );
  }
}

class _StockManagementCard extends StatelessWidget {
  const _StockManagementCard({
    required this.supply,
    required this.onDecrease,
    required this.onIncrease,
    required this.onEdit,
  });

  final _Supply supply;
  final VoidCallback onDecrease;
  final VoidCallback onIncrease;
  final VoidCallback onEdit;

  @override
  Widget build(BuildContext context) {
    final low = supply.onHand <= supply.lowAt;
    return Container(
      padding: const EdgeInsets.fromLTRB(14, 13, 8, 13),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: _line),
        borderRadius: BorderRadius.circular(13),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      supply.name,
                      style: const TextStyle(
                        color: _ink,
                        fontSize: 15,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Restock alert at ${supply.lowAt} ${supply.unit}',
                      style: const TextStyle(color: _muted, fontSize: 12),
                    ),
                  ],
                ),
              ),
              TextButton.icon(
                onPressed: onEdit,
                icon: const Icon(Icons.edit_outlined, size: 16),
                label: const Text('Edit'),
                style: TextButton.styleFrom(foregroundColor: _green),
              ),
            ],
          ),
          const Divider(height: 18, color: _line),
          Row(
            children: [
              Expanded(
                child: Text.rich(
                  TextSpan(
                    children: [
                      TextSpan(
                        text: '${supply.onHand}',
                        style: TextStyle(
                          color: low ? _coral : _ink,
                          fontSize: 25,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      TextSpan(
                        text: ' ${supply.unit} on hand',
                        style: const TextStyle(color: _muted, fontSize: 12),
                      ),
                    ],
                  ),
                ),
              ),
              IconButton(
                tooltip: 'Remove one ${supply.unit}',
                onPressed: onDecrease,
                icon: const Icon(Icons.remove_rounded),
                style: IconButton.styleFrom(
                  backgroundColor: const Color(0xFFF0F2EE),
                  foregroundColor: _ink,
                  fixedSize: const Size(40, 40),
                ),
              ),
              const SizedBox(width: 5),
              IconButton(
                tooltip: 'Add one ${supply.unit}',
                onPressed: onIncrease,
                icon: const Icon(Icons.add_rounded),
                style: IconButton.styleFrom(
                  backgroundColor: _greenPale,
                  foregroundColor: _green,
                  fixedSize: const Size(40, 40),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _AggregateNotice extends StatelessWidget {
  const _AggregateNotice();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: _greenPale,
        borderRadius: BorderRadius.circular(12),
      ),
      child: const Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.visibility_outlined, color: _green, size: 20),
          SizedBox(width: 10),
          Expanded(
            child: Text(
              'Partner view shows combined supply needs across facilities, never individual requests.',
              style: TextStyle(color: _green, fontSize: 13, height: 1.4),
            ),
          ),
        ],
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  const _StatCard({
    required this.value,
    required this.label,
    required this.icon,
    required this.color,
  });

  final String value;
  final String label;
  final IconData icon;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(minHeight: 108),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(13),
        border: Border.all(color: _line),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(height: 10),
          Text(
            value,
            style: const TextStyle(
              color: _ink,
              fontSize: 24,
              fontWeight: FontWeight.w800,
            ),
          ),
          Text(label, style: const TextStyle(color: _muted, fontSize: 11)),
        ],
      ),
    );
  }
}

class _DemandBar extends StatelessWidget {
  const _DemandBar({
    required this.label,
    required this.amount,
    required this.value,
  });

  final String label;
  final String amount;
  final double value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  label,
                  style: const TextStyle(
                    color: _ink,
                    fontWeight: FontWeight.w700,
                    fontSize: 13,
                  ),
                ),
              ),
              Text(amount, style: const TextStyle(color: _muted, fontSize: 12)),
            ],
          ),
          const SizedBox(height: 7),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: value,
              minHeight: 8,
              backgroundColor: const Color(0xFFE5E9E3),
              color: _green,
            ),
          ),
        ],
      ),
    );
  }
}

class _NeedRow extends StatelessWidget {
  const _NeedRow({
    required this.facility,
    required this.need,
    required this.gap,
    required this.urgent,
  });

  final String facility;
  final String need;
  final String gap;
  final bool urgent;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: _line),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(
            urgent ? Icons.priority_high_rounded : Icons.location_on_outlined,
            color: urgent ? _coral : _green,
            size: 19,
          ),
          const SizedBox(width: 9),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  facility,
                  style: const TextStyle(
                    color: _ink,
                    fontWeight: FontWeight.w700,
                    fontSize: 13,
                  ),
                ),
                const SizedBox(height: 3),
                Text(need, style: const TextStyle(color: _muted, fontSize: 11)),
              ],
            ),
          ),
          const SizedBox(width: 5),
          Text(
            gap,
            textAlign: TextAlign.end,
            style: TextStyle(
              color: urgent ? _coral : _ink,
              fontWeight: FontWeight.w800,
              fontSize: 11,
            ),
          ),
        ],
      ),
    );
  }
}

class _FieldLabel extends StatelessWidget {
  const _FieldLabel(this.label);

  final String label;

  @override
  Widget build(BuildContext context) {
    return Text(
      label,
      style: const TextStyle(
        color: _ink,
        fontWeight: FontWeight.w700,
        fontSize: 13,
      ),
    );
  }
}

class _ReadOnlyField extends StatelessWidget {
  const _ReadOnlyField({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
      decoration: BoxDecoration(
        color: const Color(0xFFECEFE9),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: _line),
      ),
      child: Row(
        children: [
          Icon(icon, size: 19, color: _muted),
          const SizedBox(width: 10),
          Text(
            label,
            style: const TextStyle(color: _ink, fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }
}

class _ProductChoice extends StatelessWidget {
  const _ProductChoice({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return ChoiceChip(
      label: Text(label),
      selected: selected,
      onSelected: (_) => onTap(),
      showCheckmark: false,
      labelStyle: TextStyle(
        color: selected ? _green : _ink,
        fontWeight: FontWeight.w700,
        fontSize: 12,
      ),
      backgroundColor: Colors.white,
      selectedColor: _greenPale,
      side: BorderSide(color: selected ? _green : _line),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
    );
  }
}

class _PriorityChoice extends StatelessWidget {
  const _PriorityChoice({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final urgent = label == 'Urgent';
    final color = urgent ? _coral : _green;
    return ChoiceChip(
      label: Text(label),
      selected: selected,
      onSelected: (_) => onTap(),
      showCheckmark: false,
      labelStyle: TextStyle(
        color: selected ? color : _ink,
        fontWeight: FontWeight.w700,
        fontSize: 12,
      ),
      backgroundColor: Colors.white,
      selectedColor: urgent ? const Color(0xFFFFEEE6) : _greenPale,
      side: BorderSide(color: selected ? color : _line),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
    );
  }
}

class _QuantityControl extends StatelessWidget {
  const _QuantityControl({
    required this.value,
    required this.unit,
    required this.onChanged,
  });

  final int value;
  final String unit;
  final ValueChanged<int> onChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: _line),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          IconButton(
            tooltip: 'Decrease quantity',
            onPressed: value > 1 ? () => onChanged(value - 1) : null,
            icon: const Icon(Icons.remove_rounded),
          ),
          Expanded(
            child: Text.rich(
              TextSpan(
                children: [
                  TextSpan(
                    text: '$value',
                    style: const TextStyle(
                      color: _ink,
                      fontSize: 21,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  TextSpan(
                    text: '  $unit',
                    style: const TextStyle(color: _muted, fontSize: 12),
                  ),
                ],
              ),
              textAlign: TextAlign.center,
            ),
          ),
          IconButton(
            tooltip: 'Increase quantity',
            onPressed: () => onChanged(value + 1),
            icon: const Icon(Icons.add_rounded),
          ),
        ],
      ),
    );
  }
}
