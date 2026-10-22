import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  runApp(const MyApp());
}

const _ink = Color(0xFF181316);
const _muted = Color(0xFF70666A);
const _paper = Color(0xFFF7F4F5);
const _green = Color(0xFFA10032);
const _greenPale = Color(0xFFF5E5EA);
const _coral = Color(0xFFD52B45);
const _line = Color(0xFFE7DDE0);

Widget _softTransition({required Key key, required Widget child}) {
  return AnimatedSwitcher(
    duration: const Duration(milliseconds: 240),
    switchInCurve: Curves.easeOutCubic,
    switchOutCurve: Curves.easeInCubic,
    transitionBuilder: (child, animation) => FadeTransition(
      opacity: animation,
      child: SlideTransition(
        position: Tween<Offset>(
          begin: const Offset(0, 0.025),
          end: Offset.zero,
        ).animate(animation),
        child: child,
      ),
    ),
    child: KeyedSubtree(key: key, child: child),
  );
}

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
      home: const AccessGate(),
    );
  }
}

enum _PortalRole { teacher, parent }

class AccessGate extends StatefulWidget {
  const AccessGate({super.key});

  @override
  State<AccessGate> createState() => _AccessGateState();
}

class _AccessGateState extends State<AccessGate> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _newSchoolController = TextEditingController();
  final List<String> _schoolOptions = [..._staffFacilities];

  _PortalRole? _role;
  bool _registering = false;
  bool _addingSchool = false;
  String _school = 'St. Mary\'s Secondary';

  @override
  void dispose() {
    _nameController.dispose();
    _newSchoolController.dispose();
    super.dispose();
  }

  void _saveSchool() {
    final school = _newSchoolController.text.trim();
    if (school.isEmpty) return;
    setState(() {
      if (!_schoolOptions.contains(school)) _schoolOptions.add(school);
      _school = school;
      _addingSchool = false;
      _newSchoolController.clear();
    });
  }

  void _openPortal() {
    if (!_formKey.currentState!.validate()) return;

    final navigator = Navigator.of(context);
    void onSignOut() {
      navigator.pushAndRemoveUntil(
        MaterialPageRoute<void>(builder: (_) => const AccessGate()),
        (route) => false,
      );
    }

    if (_role == _PortalRole.teacher) {
      navigator.pushReplacement(
        MaterialPageRoute<void>(
          builder: (_) => HomeScreen(facility: _school, onSignOut: onSignOut),
        ),
      );
    } else {
      navigator.pushReplacement(
        MaterialPageRoute<void>(
          builder: (_) => ParentHomeScreen(
            parentName: _nameController.text.trim().isEmpty
                ? 'Parent account'
                : _nameController.text.trim(),
            onSignOut: onSignOut,
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: _PageScroll(
          children: [
            const SizedBox(height: 26),
            const _BrandLockup(),
            const SizedBox(height: 34),
            _softTransition(
              key: ValueKey('access-${_role?.name ?? 'roles'}'),
              child: _role == null ? _buildRolePicker() : _buildAccessForm(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRolePicker() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Choose your PadHer access',
          style: TextStyle(
            color: _ink,
            fontSize: 25,
            height: 1.2,
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(height: 8),
        const Text(
          'Explore PadHer as a school staff member or as a parent or guardian.',
          style: TextStyle(color: _muted, height: 1.5),
        ),
        const SizedBox(height: 24),
        _RoleCard(
          icon: Icons.school_outlined,
          title: 'Senior woman teacher',
          subtitle: 'Preview school stock and review local requests',
          onTap: () => setState(() => _role = _PortalRole.teacher),
        ),
        const SizedBox(height: 12),
        _RoleCard(
          icon: Icons.family_restroom_rounded,
          title: 'Parent or guardian',
          subtitle: 'Submit a local request and choose a school pickup point',
          onTap: () => setState(() => _role = _PortalRole.parent),
        ),
        const SizedBox(height: 22),
        const _PrivacyNote(
          text: 'Requests do not ask for a girl\'s name, age, or class.',
        ),
      ],
    );
  }

  Widget _buildAccessForm() {
    final isTeacher = _role == _PortalRole.teacher;
    final roleLabel = isTeacher ? 'teacher' : 'parent';
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TextButton.icon(
            onPressed: () => setState(() {
              _role = null;
              _registering = false;
            }),
            icon: const Icon(Icons.arrow_back_rounded, size: 18),
            label: const Text('Choose another access'),
            style: TextButton.styleFrom(foregroundColor: _green),
          ),
          const SizedBox(height: 12),
          Text(
            '${isTeacher ? 'Teacher' : 'Parent'} preview${_registering ? ' setup' : ''}',
            style: const TextStyle(
              color: _ink,
              fontSize: 25,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            isTeacher
              ? 'Preview only. Choose a sample school or distribution point.'
              : 'Preview only. Requests stay on this device and are not sent to a school.',
            style: const TextStyle(color: _muted, height: 1.45),
          ),
          const SizedBox(height: 22),
          if (_registering) ...[
            TextFormField(
              key: const ValueKey('account-name'),
              controller: _nameController,
              textCapitalization: TextCapitalization.words,
              autofillHints: const [AutofillHints.name],
              decoration: const InputDecoration(
                labelText: 'Display name (optional)',
                hintText: 'Used for this preview only',
              ),
            ),
            const SizedBox(height: 16),
          ],
          if (isTeacher) ...[
            if (!_addingSchool)
              DropdownButtonFormField<String>(
                key: const ValueKey('teacher-school-dropdown'),
                initialValue: _school,
                decoration: const InputDecoration(
                  labelText: 'School or distribution point',
                ),
                items: _schoolOptions
                    .map(
                      (facility) => DropdownMenuItem(
                        value: facility,
                        child: Text(facility),
                      ),
                    )
                    .toList(),
                onChanged: (value) => setState(() {
                  if (value != null) _school = value;
                }),
              ),
            if (_registering) ...[
              Align(
                alignment: Alignment.centerLeft,
                child: TextButton.icon(
                  onPressed: () =>
                      setState(() => _addingSchool = !_addingSchool),
                  icon: Icon(
                    _addingSchool ? Icons.close_rounded : Icons.add_rounded,
                  ),
                  label: Text(
                    _addingSchool ? 'Cancel school entry' : 'Add a school',
                  ),
                ),
              ),
              if (_addingSchool) ...[
                TextFormField(
                  key: const ValueKey('new-school-name'),
                  controller: _newSchoolController,
                  textCapitalization: TextCapitalization.words,
                  decoration: const InputDecoration(labelText: 'School name'),
                  validator: (value) => value == null || value.trim().isEmpty
                      ? 'Enter a school name or cancel to select an existing school'
                      : null,
                ),
                const SizedBox(height: 4),
                Align(
                  alignment: Alignment.centerLeft,
                  child: TextButton.icon(
                    key: const ValueKey('save-school'),
                    onPressed: _saveSchool,
                    icon: const Icon(Icons.check_rounded),
                    label: const Text('Use this school'),
                  ),
                ),
                const Text(
                  'This school is added to this preview session only.',
                  style: TextStyle(color: _muted, fontSize: 11),
                ),
              ],
            ],
            const SizedBox(height: 16),
          ],
          if (!isTeacher && !_registering) const SizedBox(height: 10),
          FilledButton(
            key: const ValueKey('submit-access'),
            onPressed: _openPortal,
            style: _primaryButtonStyle,
            child: Text(
                'Open $roleLabel preview',
            ),
          ),
          const SizedBox(height: 10),
          Center(
            child: TextButton(
              onPressed: () => setState(() => _registering = !_registering),
              child: Text(
                _registering ? 'Back to preview' : 'Set a display name',
              ),
            ),
          ),
          const SizedBox(height: 8),
          const Center(
            child: Text(
              'No account is created. Preview data is not shared with a school.',
              textAlign: TextAlign.center,
              style: TextStyle(color: _muted, fontSize: 11, height: 1.4),
            ),
          ),
        ],
      ),
    );
  }
}

const _staffFacilities = [
  'St. Mary\'s Secondary',
  'Oli Primary School',
  'Ediofe Girls School',
];

const _pickupSchoolsByArea = <String, String>{
  'Oli': 'Oli Primary School',
  'Ediofe': 'Ediofe Girls School',
  'Arua Hill': 'St. Mary\'s Secondary',
};

class _BrandLockup extends StatelessWidget {
  const _BrandLockup();

  @override
  Widget build(BuildContext context) {
    return const Row(
      children: [
        _BrandMark(),
        SizedBox(width: 10),
        Text(
          'PadHer',
          style: TextStyle(
            color: _ink,
            fontSize: 23,
            fontWeight: FontWeight.w800,
          ),
        ),
        Spacer(),
        Text(
          'ARUA CITY',
          style: TextStyle(
            color: _muted,
            fontSize: 11,
            fontWeight: FontWeight.w800,
          ),
        ),
      ],
    );
  }
}

class _BrandMark extends StatelessWidget {
  const _BrandMark();

  @override
  Widget build(BuildContext context) {
    return Container(
      key: const ValueKey('padher-logo'),
      width: 36,
      height: 36,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        boxShadow: const [
          BoxShadow(
            color: Color(0x14000000),
            blurRadius: 6,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: Image.asset('assets/padher_icon.png', fit: BoxFit.cover),
      ),
    );
  }
}

class _PadHerLogoPainter extends CustomPainter {
  const _PadHerLogoPainter();

  @override
  void paint(Canvas canvas, Size size) {
    canvas.save();
    canvas.scale(size.width / 24, size.height / 24);

    final padPaint = Paint()..color = Colors.white;
    final wingPath = Path()
      ..moveTo(8.5, 8)
      ..lineTo(3.1, 6.1)
      ..quadraticBezierTo(1.9, 5.7, 2.3, 7.1)
      ..lineTo(4.5, 13.7)
      ..quadraticBezierTo(4.8, 14.6, 5.8, 14.2)
      ..lineTo(9, 12.8)
      ..close();
    canvas.drawPath(wingPath, padPaint);
    canvas.save();
    canvas.scale(-1, 1);
    canvas.translate(-24, 0);
    canvas.drawPath(wingPath, padPaint);
    canvas.restore();

    canvas.drawRRect(
      RRect.fromRectAndRadius(
        const Rect.fromLTWH(8, 2.5, 8, 19),
        const Radius.circular(4),
      ),
      padPaint,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        const Rect.fromLTWH(10.2, 4.2, 3.6, 15.5),
        const Radius.circular(1.8),
      ),
      Paint()..color = const Color(0xFFFFD9D0),
    );

    final dropPath = Path()
      ..moveTo(12, 8.1)
      ..cubicTo(10.6, 10, 9.4, 11.5, 9.4, 13.2)
      ..cubicTo(9.4, 14.9, 10.5, 16.1, 12, 16.1)
      ..cubicTo(13.5, 16.1, 14.6, 14.9, 14.6, 13.2)
      ..cubicTo(14.6, 11.5, 13.4, 10, 12, 8.1)
      ..close();
    canvas.drawPath(dropPath, Paint()..color = _coral);
    canvas.drawCircle(
      const Offset(10.9, 12.5),
      0.65,
      Paint()..color = const Color(0xFFFFB6A7),
    );
    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant _PadHerLogoPainter oldDelegate) => false;
}

class _PrivacyNote extends StatelessWidget {
  const _PrivacyNote({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(13),
      decoration: BoxDecoration(
        color: _greenPale,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.shield_outlined, color: _green, size: 19),
          const SizedBox(width: 9),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(color: _green, fontSize: 12, height: 1.4),
            ),
          ),
        ],
      ),
    );
  }
}

class _RoleCard extends StatelessWidget {
  const _RoleCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            border: Border.all(color: _line),
            borderRadius: BorderRadius.circular(14),
          ),
          child: Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: _greenPale,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: _green),
              ),
              const SizedBox(width: 13),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        color: _ink,
                        fontWeight: FontWeight.w800,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: const TextStyle(
                        color: _muted,
                        fontSize: 12,
                        height: 1.35,
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right_rounded, color: _muted),
            ],
          ),
        ),
      ),
    );
  }
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({
    super.key,
    this.facility = 'St. Mary\'s Secondary',
    this.onSignOut,
  });

  final String facility;
  final VoidCallback? onSignOut;

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;
  final List<_Supply> _supplies = [
    _Supply(name: 'Reusable pads', onHand: 42, lowAt: 20, unit: 'kits'),
    _Supply(name: 'Disposable pads', onHand: 12, lowAt: 25, unit: 'packs'),
    _Supply(name: 'Soap', onHand: 31, lowAt: 15, unit: 'bars'),
  ];

  List<_LocalRequest> _requests = [];
  bool _loadingLocalData = true;
  bool _localDataFailed = false;

  @override
  void initState() {
    super.initState();
    _loadSchoolData();
  }

  List<_LocalRequest> get _facilityRequests => _requests
      .where((request) => request.school == widget.facility)
      .toList();

  int _reservedFor(String product, {List<_LocalRequest>? requests}) =>
      (requests ?? _requests)
          .where(
            (request) =>
                request.school == widget.facility &&
                request.product == product &&
                (request.status == 'Approved' ||
                    request.status == 'Ready for pickup'),
          )
          .fold(0, (total, request) => total + request.quantity);

  Future<void> _loadSchoolData() async {
    try {
      final data = await _readLocalData();
      if (!mounted) return;
      setState(() {
        _requests = data.requests;
        for (final supply in _supplies) {
          supply.onHand =
              data.stock[_stockKey(widget.facility, supply.name)] ??
              supply.onHand;
          supply.reserved = _reservedFor(supply.name);
        }
        _loadingLocalData = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _localDataFailed = true;
        _loadingLocalData = false;
      });
    }
  }

  int get _lowStockCount =>
        _supplies
          .where((supply) => supply.onHand - supply.reserved <= supply.lowAt)
          .length;

  Future<void> _changeStock(_Supply supply, int delta) async {
    await _setStock(supply, (supply.onHand + delta).clamp(0, 9999));
  }

  Future<void> _setStock(_Supply supply, int quantity) async {
    if (quantity < 0 || quantity > 9999) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Enter a stock quantity from 0 to 9999.')),
      );
      return;
    }
    if (quantity < supply.reserved) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Stock cannot be lower than reserved requests.')),
      );
      return;
    }
    try {
      final data = await _readLocalData();
      final stock = Map<String, int>.from(data.stock)
        ..[_stockKey(widget.facility, supply.name)] = quantity;
      await _saveLocalData(_LocalData(requests: data.requests, stock: stock));
      if (!mounted) return;
      setState(() => supply.onHand = quantity);
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Could not save the stock update.')),
      );
    }
  }

  Future<void> _setRequestStatus(
    _LocalRequest request,
    String status,
  ) async {
    final supply = _supplies.firstWhere(
      (item) => item.name == request.product,
      orElse: () => _Supply(
        name: request.product,
        onHand: 0,
        lowAt: 0,
        unit: 'units',
      ),
    );
    final reserved = _reservedFor(request.product);
    if (status == 'Approved' && supply.onHand - reserved < request.quantity) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Not enough available stock to approve this request.')),
      );
      return;
    }
    if (status == 'Collected' && supply.onHand < request.quantity) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('There is not enough stock to complete this collection.')),
      );
      return;
    }

    try {
      final data = await _readLocalData();
      final updatedRequests = data.requests
          .map((item) => item.id == request.id ? item.withStatus(status) : item)
          .toList();
      final stock = Map<String, int>.from(data.stock);
      if (status == 'Collected') {
        stock[_stockKey(widget.facility, supply.name)] =
            supply.onHand - request.quantity;
      }
      await _saveLocalData(
        _LocalData(requests: updatedRequests, stock: stock),
      );
      if (!mounted) return;
      setState(() {
        _requests = updatedRequests;
        if (status == 'Collected') supply.onHand -= request.quantity;
        for (final item in _supplies) {
          item.reserved = _reservedFor(item.name, requests: updatedRequests);
        }
      });
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Could not update this request.')),
      );
    }
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
              onSignOut: widget.onSignOut,
            ),
            Expanded(
              child: _softTransition(
                key: ValueKey('staff-page-$_selectedIndex'),
                child: pages[_selectedIndex],
              ),
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
        _FacilityHeader(
          eyebrow: 'STAFF DASHBOARD',
          title: widget.facility,
          subtitle: 'Arua City  ·  Teacher preview',
        ),
        const SizedBox(height: 12),
        const _PrivacyNote(
          text: 'Preview only: staff identity is not verified, and requests and stock are stored on this device.',
        ),
        const SizedBox(height: 20),
        _ImpactStrip(
          requests: _facilityRequests.length,
          lowStock: _lowStockCount,
        ),
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
        ..._facilityRequests
          .take(2)
          .map((request) => _RequestRow(request: request)),
        const SizedBox(height: 18),
        FilledButton.icon(
          onPressed: () => setState(() => _selectedIndex = 1),
          icon: const Icon(Icons.assignment_outlined),
          label: const Text('Review school requests'),
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
    final requests = _facilityRequests;
    return _PageScroll(
      children: [
        _FacilityHeader(
          eyebrow: 'SCHOOL REQUESTS',
          title: 'Review requests',
          subtitle: widget.facility,
        ),
        const SizedBox(height: 18),
        const _PrivacyNote(
          text: 'Preview only: staff identity is not verified. This inbox is only visible on this device.',
        ),
        const SizedBox(height: 14),
        if (_loadingLocalData)
          const Center(child: CircularProgressIndicator())
        else if (_localDataFailed)
          const _PrivacyNote(
            text: 'School requests could not be loaded from this device.',
          )
        else if (requests.isEmpty)
          const _PrivacyNote(
            text: 'No requests are saved for this school on this device.',
          )
        else
          ...requests.map(
            (request) => _TeacherRequestCard(
              request: request,
              available: _supplies
                      .where((supply) => supply.name == request.product)
                      .map((supply) => supply.onHand - supply.reserved)
                      .firstOrNull ??
                  0,
              onApprove: () => _setRequestStatus(request, 'Approved'),
              onDecline: () => _setRequestStatus(request, 'Declined'),
              onReady: () => _setRequestStatus(request, 'Ready for pickup'),
              onCollect: () => _setRequestStatus(request, 'Collected'),
            ),
          ),
      ],
    );
  }

  Widget _buildStock() {
    return _PageScroll(
      children: [
        _FacilityHeader(
          eyebrow: 'INVENTORY',
          title: 'Stock levels',
          subtitle: '${widget.facility}  ·  Sample starting stock',
        ),
        const SizedBox(height: 12),
        const _PrivacyNote(
          text: 'Preview only: staff identity is not verified. Stock changes are stored on this device.',
        ),
        const SizedBox(height: 18),
        if (_loadingLocalData)
          const Center(child: CircularProgressIndicator())
        else if (_localDataFailed)
          const _PrivacyNote(text: 'Stock data could not be loaded from this device.')
        else if (_lowStockCount > 0)
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
          'Approved requests reserve stock. On-hand stock changes when a request is marked collected.',
          style: TextStyle(color: _muted, fontSize: 13, height: 1.5),
        ),
        const SizedBox(height: 18),
        OutlinedButton.icon(
          onPressed: () => setState(() => _selectedIndex = 1),
          icon: const Icon(Icons.assignment_outlined),
          label: const Text('Review school requests'),
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
          eyebrow: 'SAMPLE PARTNER DATA',
          title: 'Demand insights',
          subtitle: 'Example figures only  ·  Not connected to live requests',
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
    if (quantity != null) await _setStock(supply, quantity);
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
  int reserved = 0;
}

class _TopBar extends StatelessWidget {
  const _TopBar({
    required this.onNotificationTap,
    this.onSignOut,
    this.initials = 'SM',
  });

  final VoidCallback onNotificationTap;
  final VoidCallback? onSignOut;
  final String initials;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 11, 18, 8),
      child: Row(
        children: [
          const _BrandMark(),
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
          SizedBox(
            width: 48,
            height: 48,
            child: Tooltip(
              message: 'Sign out',
              child: InkWell(
                key: const ValueKey('sign-out-control'),
                onTap: onSignOut,
                customBorder: const CircleBorder(),
                child: Center(
                  child: CircleAvatar(
                    radius: 18,
                    backgroundColor: const Color(0xFFE6D5C9),
                    child: Text(
                      initials,
                      style: const TextStyle(
                        color: Color(0xFF744B38),
                        fontWeight: FontWeight.w800,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class ParentHomeScreen extends StatefulWidget {
  const ParentHomeScreen({
    super.key,
    required this.parentName,
    required this.onSignOut,
  });

  final String parentName;
  final VoidCallback onSignOut;

  @override
  State<ParentHomeScreen> createState() => _ParentHomeScreenState();
}

class _LocalRequest {
  const _LocalRequest({
    required this.id,
    required this.reference,
    required this.school,
    required this.area,
    required this.product,
    required this.quantity,
    required this.createdAt,
    required this.status,
  });

  final String id;
  final String reference;
  final String school;
  final String area;
  final String product;
  final int quantity;
  final String createdAt;
  final String status;

  Map<String, Object> toJson() => {
    'id': id,
    'reference': reference,
    'school': school,
    'area': area,
    'product': product,
    'quantity': quantity,
    'createdAt': createdAt,
    'status': status,
  };

  factory _LocalRequest.fromJson(Map<String, dynamic> json) => _LocalRequest(
    id: json['id'] as String,
    reference: json['reference'] as String,
    school: json['school'] as String,
    area: json['area'] as String,
    product: json['product'] as String,
    quantity: json['quantity'] as int,
    createdAt: json['createdAt'] as String,
    status: json['status'] as String? ?? 'Pending review',
  );

  _LocalRequest withStatus(String status) => _LocalRequest(
    id: id,
    reference: reference,
    school: school,
    area: area,
    product: product,
    quantity: quantity,
    createdAt: createdAt,
    status: status,
  );
}

const _localStateKey = 'padher.localState.v1';
const _legacyLocalRequestsKey = 'padher.localRequests.v1';

class _LocalData {
  const _LocalData({required this.requests, required this.stock});

  final List<_LocalRequest> requests;
  final Map<String, int> stock;

  Map<String, Object> toJson() => {
    'requests': requests.map((request) => request.toJson()).toList(),
    'stock': stock,
  };
}

String _stockKey(String school, String product) => '$school::$product';

Future<_LocalData> _readLocalData() async {
  final preferences = await SharedPreferences.getInstance();
  final current = preferences.getString(_localStateKey);
  final legacy = preferences.getString(_legacyLocalRequestsKey);
  final Object? decoded = current != null
      ? jsonDecode(current)
      : legacy == null
      ? null
      : jsonDecode(legacy);
  final data = decoded is Map
      ? decoded
      : <String, dynamic>{'requests': decoded, 'stock': <String, int>{}};
  final requestData = data['requests'];
  final requests = requestData is List
      ? requestData
            .map(
              (request) => _LocalRequest.fromJson(
                Map<String, dynamic>.from(request as Map),
              ),
            )
            .toList()
      : <_LocalRequest>[];
  final stockData = data['stock'];
  final stock = stockData is Map
      ? stockData.map<String, int>(
          (key, value) => MapEntry(key.toString(), (value as num).toInt()),
        )
      : <String, int>{};
  final retentionCutoff = DateTime.now().subtract(const Duration(days: 30));
  final retainedRequests = requests.where((request) {
    final created = DateTime.tryParse(request.createdAt);
    return created != null && created.isAfter(retentionCutoff);
  }).toList();
  final localData = _LocalData(requests: retainedRequests, stock: stock);
  if (current == null || retainedRequests.length != requests.length) {
    final saved = await preferences.setString(
      _localStateKey,
      jsonEncode(localData.toJson()),
    );
    if (!saved) throw StateError('Local data could not be migrated or cleaned');
  }
  if (legacy != null) await preferences.remove(_legacyLocalRequestsKey);
  return localData;
}

Future<void> _saveLocalData(_LocalData data) async {
  final preferences = await SharedPreferences.getInstance();
  final saved = await preferences.setString(
    _localStateKey,
    jsonEncode(data.toJson()),
  );
  if (!saved) throw StateError('Local data could not be saved');
}

class _ParentHomeScreenState extends State<ParentHomeScreen> {
  int _selectedIndex = 0;
  String _selectedArea = 'Oli';
  String _selectedProduct = 'Disposable pads';
  int _quantity = 4;
  List<_LocalRequest> _localRequests = [];
  bool _loadingRequests = true;
  bool _savingRequest = false;
  bool _requestStorageFailed = false;

  @override
  void initState() {
    super.initState();
    _loadLocalRequests();
  }

  Future<void> _loadLocalRequests() async {
    try {
      final localData = await _readLocalData();
      if (!mounted) return;
      setState(() {
        _localRequests = localData.requests;
        _loadingRequests = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _loadingRequests = false;
        _requestStorageFailed = true;
      });
    }
  }

  String get _pickupSchool => _pickupSchoolsByArea[_selectedArea]!;

  void _showPickupDetails() {
    showModalBottomSheet<void>(
      context: context,
      useSafeArea: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(18)),
      ),
      builder: (context) => SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 24, 20, 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
            const Text(
              'Area-based pickup match',
              style: TextStyle(
                color: _ink,
                fontSize: 19,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 14),
            _PickupPointCard(
              area: _selectedArea,
              school: _pickupSchool,
              onTap: () => Navigator.pop(context),
            ),
            const SizedBox(height: 12),
            const Text(
              'This preview uses a sample catchment map. The school team confirms current stock and collection arrangements.',
              style: TextStyle(color: _muted, fontSize: 13, height: 1.5),
            ),
            const SizedBox(height: 16),
            FilledButton(
              onPressed: () => Navigator.pop(context),
              style: _primaryButtonStyle,
              child: const Text('Close'),
            ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _submitRequest() async {
    if (_loadingRequests || _savingRequest || _requestStorageFailed) return;
    setState(() => _savingRequest = true);

    final now = DateTime.now();
    final request = _LocalRequest(
      id: now.microsecondsSinceEpoch.toString(),
      reference: 'PH-${1000 + now.millisecondsSinceEpoch % 9000}',
      school: _pickupSchool,
      area: _selectedArea,
      product: _selectedProduct,
      quantity: _quantity,
      createdAt: now.toIso8601String(),
      status: 'Pending review',
    );
    final updatedRequests = [request, ..._localRequests];

    try {
      final data = await _readLocalData();
      await _saveLocalData(
        _LocalData(requests: updatedRequests, stock: data.stock),
      );
      if (!mounted) return;
      setState(() {
        _localRequests = updatedRequests;
        _savingRequest = false;
        _selectedIndex = 2;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() => _savingRequest = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Could not save this request on device.')),
      );
    }
  }

  Future<void> _deleteRequest(_LocalRequest request) async {
    if (request.status != 'Pending review') return;
    final updatedRequests = _localRequests
        .where((item) => item.id != request.id)
        .toList();
    try {
      final data = await _readLocalData();
      await _saveLocalData(
        _LocalData(requests: updatedRequests, stock: data.stock),
      );
      if (!mounted) return;
      setState(() => _localRequests = updatedRequests);
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Could not delete this saved request.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final pages = [_buildHome(), _buildRequestForm(), _buildActivity()];
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            _TopBar(
              initials: 'PA',
              onNotificationTap: () => setState(() => _selectedIndex = 2),
              onSignOut: widget.onSignOut,
            ),
            Expanded(
              child: _softTransition(
                key: ValueKey('parent-page-$_selectedIndex'),
                child: pages[_selectedIndex],
              ),
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
            icon: Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home_rounded),
            label: 'Home',
          ),
          NavigationDestination(
            icon: Icon(Icons.add_circle_outline_rounded),
            selectedIcon: Icon(Icons.add_circle_rounded),
            label: 'New request',
          ),
          NavigationDestination(
            icon: Icon(Icons.receipt_long_outlined),
            selectedIcon: Icon(Icons.receipt_long_rounded),
            label: 'Activity',
          ),
        ],
      ),
    );
  }

  Widget _buildHome() {
    return _PageScroll(
      children: [
        _FacilityHeader(
          eyebrow: 'PARENT & GUARDIAN',
          title: 'Pickup support near you',
          subtitle: 'Welcome, ${widget.parentName}',
        ),
        const SizedBox(height: 20),
        _PickupPointCard(
          area: _selectedArea,
          school: _pickupSchool,
          onTap: _showPickupDetails,
        ),
        const SizedBox(height: 18),
        const _SectionTitle('Request supplies for pickup'),
        const SizedBox(height: 7),
        const Text(
          'Choose what is needed. It will appear in the pickup school teacher preview on this device.',
          style: TextStyle(color: _muted, fontSize: 13, height: 1.5),
        ),
        const SizedBox(height: 16),
        FilledButton.icon(
          onPressed: () => setState(() => _selectedIndex = 1),
          icon: const Icon(Icons.add_rounded),
          label: const Text('Make a home request'),
          style: _primaryButtonStyle,
        ),
        const SizedBox(height: 20),
        const _PrivacyNote(
          text: 'Only the supply request is saved on this device. No adult contact or girl\'s name/profile is stored.',
        ),
      ],
    );
  }

  Widget _buildRequestForm() {
    return _PageScroll(
      children: [
        const _FacilityHeader(
          eyebrow: 'HOME PICKUP REQUEST',
          title: 'Request supplies',
          subtitle: 'The selected school can review this request in the local preview.',
        ),
        const SizedBox(height: 20),
        const _FieldLabel('Your area'),
        const SizedBox(height: 7),
        DropdownButtonFormField<String>(
          key: const ValueKey('pickup-area-dropdown'),
          initialValue: _selectedArea,
          decoration: const InputDecoration(
            prefixIcon: Icon(Icons.location_on_outlined),
          ),
          items: _pickupSchoolsByArea.keys
              .map((area) => DropdownMenuItem(value: area, child: Text(area)))
              .toList(),
          onChanged: (area) => setState(() {
            if (area != null) _selectedArea = area;
          }),
        ),
        const SizedBox(height: 12),
        _PickupPointCard(
          area: _selectedArea,
          school: _pickupSchool,
          onTap: _showPickupDetails,
        ),
        const SizedBox(height: 19),
        const _FieldLabel('Supply needed'),
        const SizedBox(height: 7),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            _ProductChoice(
              label: 'Disposable pads',
              selected: _selectedProduct == 'Disposable pads',
              onTap: () => setState(() => _selectedProduct = 'Disposable pads'),
            ),
            _ProductChoice(
              label: 'Reusable pads',
              selected: _selectedProduct == 'Reusable pads',
              onTap: () => setState(() => _selectedProduct = 'Reusable pads'),
            ),
          ],
        ),
        const SizedBox(height: 17),
        const _FieldLabel('Quantity'),
        const SizedBox(height: 7),
        _QuantityControl(
          value: _quantity,
          unit: _selectedProduct == 'Reusable pads' ? 'kits' : 'packs',
          onChanged: (value) => setState(() => _quantity = value),
        ),
        const SizedBox(height: 17),
        const _PrivacyNote(
          text: 'No names or personal details are needed for this request.',
        ),
        const SizedBox(height: 12),
        const _LocalOnlyNotice(),
        const SizedBox(height: 19),
        FilledButton.icon(
          key: const ValueKey('submit-home-request'),
          onPressed: _loadingRequests || _savingRequest || _requestStorageFailed
              ? null
              : _submitRequest,
          icon: Icon(
            _savingRequest ? Icons.hourglass_top_rounded : Icons.save_rounded,
          ),
          label: Text(
            _savingRequest ? 'Submitting request...' : 'Submit request',
          ),
          style: _primaryButtonStyle,
        ),
        const SizedBox(height: 12),
        const Text(
          'Pickup locations shown here use a sample area map. Staff will confirm availability and collection details.',
          style: TextStyle(color: _muted, fontSize: 11, height: 1.45),
        ),
      ],
    );
  }

  Widget _buildActivity() {
    return _PageScroll(
      children: [
        const _FacilityHeader(
          eyebrow: 'PARENT ACCOUNT',
          title: 'Request activity',
          subtitle: 'Check the status and pickup point for your requests.',
        ),
        const SizedBox(height: 20),
        if (_loadingRequests)
          const Center(child: CircularProgressIndicator())
        else if (_requestStorageFailed)
          const _PrivacyNote(
            text: 'Saved requests could not be loaded. No new request was saved.',
          )
        else if (_localRequests.isEmpty)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border.all(color: _line),
              borderRadius: BorderRadius.circular(13),
            ),
            child: const Text(
              'No saved requests on this device yet.',
              style: TextStyle(color: _muted, height: 1.5),
            ),
          )
        else ...[
          const _LocalOnlyNotice(),
          const SizedBox(height: 12),
          ..._localRequests.map(
            (request) => _LocalRequestCard(
              key: ValueKey(request.id),
              request: request,
              onDelete: () => _deleteRequest(request),
            ),
          ),
        ],
        const SizedBox(height: 18),
        const _PrivacyNote(
          text: 'The local teacher preview can see the item and quantity. No school is contacted and no child identity is collected.',
        ),
      ],
    );
  }
}

class _LocalOnlyNotice extends StatelessWidget {
  const _LocalOnlyNotice();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(13),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF3E7),
        border: Border.all(color: const Color(0xFFF0D5B7)),
        borderRadius: BorderRadius.circular(12),
      ),
      child: const Text(
        'Saved on this device for up to 30 days. It appears in the teacher preview on this device only; it is not sent over the network. Storage is not encrypted.',
        style: TextStyle(color: Color(0xFF754519), fontSize: 12, height: 1.45),
      ),
    );
  }
}

class _LocalRequestCard extends StatelessWidget {
  const _LocalRequestCard({
    super.key,
    required this.request,
    required this.onDelete,
  });

  final _LocalRequest request;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final created = DateTime.tryParse(request.createdAt)?.toLocal();
    final date = created == null
        ? ''
        : '${created.day.toString().padLeft(2, '0')}/${created.month.toString().padLeft(2, '0')}/${created.year}';
    final unit = switch (request.product) {
      'Reusable pads' => 'kits',
      'Soap' => 'bars',
      _ => 'packs',
    };

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.fromLTRB(15, 14, 8, 14),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: _line),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.only(top: 2),
            child: Icon(Icons.save_outlined, color: _green, size: 21),
          ),
          const SizedBox(width: 11),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Request ${request.reference}',
                  style: TextStyle(color: _ink, fontWeight: FontWeight.w800),
                ),
                const SizedBox(height: 6),
                Text('${request.quantity} $unit of ${request.product}'),
                const SizedBox(height: 4),
                Text(
                  request.status,
                  style: const TextStyle(color: _green, fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 4),
                Text(
                  'Pickup: ${request.school} (${request.area})',
                  style: const TextStyle(color: _muted, fontSize: 12),
                ),
                const SizedBox(height: 4),
                Text(
                  'Not sent over network${date.isEmpty ? '' : '  ·  $date'}',
                  style: const TextStyle(color: _muted, fontSize: 11),
                ),
              ],
            ),
          ),
          if (request.status == 'Pending review')
            IconButton(
              tooltip: 'Delete saved request',
              onPressed: onDelete,
              icon: const Icon(Icons.delete_outline_rounded),
              style: IconButton.styleFrom(minimumSize: const Size(48, 48)),
            )
          else
            const SizedBox(width: 48),
        ],
      ),
    );
  }
}

class _PickupPointCard extends StatelessWidget {
  const _PickupPointCard({
    required this.area,
    required this.school,
    required this.onTap,
  });

  final String area;
  final String school;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: _greenPale,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        key: const ValueKey('pickup-point-details'),
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          width: double.infinity,
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            border: Border.all(color: _green.withValues(alpha: 0.12)),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.location_on_outlined, color: _green),
              ),
              const SizedBox(width: 11),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Pickup school for $area',
                      style: const TextStyle(
                        color: _green,
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      school,
                      style: const TextStyle(
                        color: _ink,
                        fontWeight: FontWeight.w800,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.info_outline_rounded, color: _green, size: 19),
            ],
          ),
        ),
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
    final available = supply.onHand - supply.reserved;
    final low = available <= supply.lowAt;
    final ratio = (available / (supply.lowAt * 2.5)).clamp(0.0, 1.0);
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
            '$available ${supply.unit} available',
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

  final _LocalRequest request;

  @override
  Widget build(BuildContext context) {
    final approved = request.status == 'Approved' ||
      request.status == 'Ready for pickup' ||
      request.status == 'Collected';
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
                  '${request.quantity} ${request.product.toLowerCase()}',
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
                  '${request.school}  ·  ${request.status}',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(color: _muted, fontSize: 11),
                ),
              ],
            ),
          ),
          const SizedBox(width: 6),
          Text(
            request.status,
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

class _TeacherRequestCard extends StatelessWidget {
  const _TeacherRequestCard({
    required this.request,
    required this.available,
    required this.onApprove,
    required this.onDecline,
    required this.onReady,
    required this.onCollect,
  });

  final _LocalRequest request;
  final int available;
  final VoidCallback onApprove;
  final VoidCallback onDecline;
  final VoidCallback onReady;
  final VoidCallback onCollect;

  @override
  Widget build(BuildContext context) {
    final unit = switch (request.product) {
      'Reusable pads' => 'kits',
      'Soap' => 'bars',
      _ => 'packs',
    };
    final actions = switch (request.status) {
      'Pending review' => Wrap(
        spacing: 8,
        runSpacing: 8,
        children: [
          OutlinedButton.icon(
            key: ValueKey('approve-request-${request.id}'),
            onPressed: onApprove,
            icon: const Icon(Icons.check_rounded),
            label: const Text('Approve'),
          ),
          TextButton.icon(
            key: ValueKey('decline-request-${request.id}'),
            onPressed: onDecline,
            icon: const Icon(Icons.close_rounded),
            label: const Text('Decline'),
          ),
        ],
      ),
      'Approved' => FilledButton.icon(
        key: ValueKey('ready-request-${request.id}'),
        onPressed: onReady,
        icon: const Icon(Icons.inventory_2_outlined),
        label: const Text('Mark ready for pickup'),
      ),
      'Ready for pickup' => FilledButton.icon(
        key: ValueKey('collect-request-${request.id}'),
        onPressed: onCollect,
        icon: const Icon(Icons.done_all_rounded),
        label: const Text('Mark collected'),
      ),
      _ => Text(
        request.status,
        style: const TextStyle(color: _muted, fontWeight: FontWeight.w700),
      ),
    };

    return Container(
      key: ValueKey('teacher-request-${request.id}'),
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: _line),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.assignment_outlined, color: _green, size: 20),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Request ${request.reference}',
                  style: const TextStyle(
                    color: _ink,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              Text(
                request.status,
                style: const TextStyle(
                  color: _green,
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            '${request.quantity} $unit of ${request.product}',
            style: const TextStyle(color: _ink, fontSize: 15),
          ),
          const SizedBox(height: 4),
          Text(
            '${request.area} pickup area  ·  ${request.createdAt.substring(0, 10)}',
            style: const TextStyle(color: _muted, fontSize: 12),
          ),
          if (request.status == 'Pending review' ||
              request.status == 'Approved') ...[
            const SizedBox(height: 8),
            Text(
              '$available $unit available after other reservations',
              style: const TextStyle(color: _muted, fontSize: 12),
            ),
          ],
          const SizedBox(height: 12),
          actions,
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
    final low = supply.onHand - supply.reserved <= supply.lowAt;
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
          if (supply.reserved > 0)
            Align(
              alignment: Alignment.centerLeft,
              child: Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Text(
                  '${supply.reserved} ${supply.unit} reserved  ·  ${supply.onHand - supply.reserved} available',
                  style: const TextStyle(color: _muted, fontSize: 12),
                ),
              ),
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
            child: Semantics(
              container: true,
              excludeSemantics: true,
              liveRegion: true,
              label: 'Quantity: $value $unit',
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  AnimatedSwitcher(
                    duration: const Duration(milliseconds: 180),
                    transitionBuilder: (child, animation) => ScaleTransition(
                      scale: animation,
                      child: FadeTransition(opacity: animation, child: child),
                    ),
                    child: Text(
                      '$value',
                      key: ValueKey(value),
                      style: const TextStyle(
                        color: _ink,
                        fontSize: 21,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                  const SizedBox(width: 6),
                  Flexible(
                    child: Text(
                      unit,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(color: _muted, fontSize: 12),
                    ),
                  ),
                ],
              ),
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
