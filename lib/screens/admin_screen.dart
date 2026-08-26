import 'package:flutter/material.dart';

import '../services/api_service.dart';

class AdminScreen extends StatefulWidget {
  const AdminScreen({
    super.key,
    required this.api,
  });

  final ApiService api;

  @override
  State<AdminScreen> createState() => _AdminScreenState();
}

class _AdminScreenState extends State<AdminScreen>
    with SingleTickerProviderStateMixin {
  late TabController tabController;

  bool loading = true;
  String? error;

  List<dynamic> pendingCars = [];
  List<dynamic> users = [];
  List<dynamic> payments = [];

  @override
  void initState() {
    super.initState();

    tabController = TabController(
      length: 3,
      vsync: this,
    );

    _loadAdminData();
  }

  @override
  void dispose() {
    tabController.dispose();
    super.dispose();
  }

  Future<void> _loadAdminData() async {
    setState(() {
      loading = true;
      error = null;
    });

    try {
      final result =
          await widget.api.getAdminDashboard();

      if (!mounted) return;

      setState(() {
        pendingCars =
            result['pendingCars'] as List? ?? [];
        users =
            result['users'] as List? ?? [];
        payments =
            result['payments'] as List? ?? [];

        loading = false;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        loading = false;
        error = e
            .toString()
            .replaceFirst('Exception: ', '');
      });
    }
  }

  Future<void> _approveCar(
    dynamic car,
  ) async {
    final id = car['id'];

    try {
      await widget.api.adminUpdateCar(
        id: id,
        action: 'approve',
      );

      _showMessage(
        'تمت الموافقة على الإعلان',
        success: true,
      );

      await _loadAdminData();
    } catch (e) {
      _showMessage(
        e
            .toString()
            .replaceFirst('Exception: ', ''),
      );
    }
  }

  Future<void> _rejectCar(
    dynamic car,
  ) async {
    final id = car['id'];

    try {
      await widget.api.adminUpdateCar(
        id: id,
        action: 'reject',
      );

      _showMessage(
        'تم رفض الإعلان',
      );

      await _loadAdminData();
    } catch (e) {
      _showMessage(
        e
            .toString()
            .replaceFirst('Exception: ', ''),
      );
    }
  }

  Future<void> _deleteCar(
    dynamic car,
  ) async {
    final id = car['id'];

    final confirmed =
        await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor:
              const Color(0xFF18181F),
          title: const Text(
            'حذف الإعلان',
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w900,
            ),
          ),
          content: const Text(
            'هل أنت متأكد من حذف هذا الإعلان؟',
            style: TextStyle(
              color: Colors.white70,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () =>
                  Navigator.pop(
                context,
                false,
              ),
              child: const Text(
                'إلغاء',
              ),
            ),
            TextButton(
              onPressed: () =>
                  Navigator.pop(
                context,
                true,
              ),
              child: const Text(
                'حذف',
                style: TextStyle(
                  color: Colors.redAccent,
                ),
              ),
            ),
          ],
        );
      },
    );

    if (confirmed != true) {
      return;
    }

    try {
      await widget.api.adminUpdateCar(
        id: id,
        action: 'delete',
      );

      _showMessage('تم حذف الإعلان');

      await _loadAdminData();
    } catch (e) {
      _showMessage(
        e
            .toString()
            .replaceFirst('Exception: ', ''),
      );
    }
  }

  Future<void> _changeUserRole(
    dynamic user,
    String role,
  ) async {
    try {
      await widget.api.adminChangeUserRole(
        userId: user['id'],
        role: role,
      );

      _showMessage(
        role == 'admin'
            ? 'تمت إضافة الأدمن'
            : 'تمت إزالة صلاحية الأدمن',
        success: true,
      );

      await _loadAdminData();
    } catch (e) {
      _showMessage(
        e
            .toString()
            .replaceFirst('Exception: ', ''),
      );
    }
  }

  Future<void> _approvePayment(
    dynamic payment,
  ) async {
    try {
      await widget.api.adminUpdatePayment(
        id: payment['id'],
        status: 'approved',
      );

      _showMessage(
        'تم تأكيد الدفع',
        success: true,
      );

      await _loadAdminData();
    } catch (e) {
      _showMessage(
        e
            .toString()
            .replaceFirst('Exception: ', ''),
      );
    }
  }

  void _showMessage(
    String message, {
    bool success = false,
  }) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: success
            ? const Color(0xFF18A558)
            : const Color(0xFF292932),
      ),
    );
  }

  Widget _empty(
    String text,
    IconData icon,
  ) {
    return Center(
      child: Column(
        mainAxisAlignment:
            MainAxisAlignment.center,
        children: [
          Icon(
            icon,
            size: 65,
            color: Colors.white24,
          ),
          const SizedBox(height: 14),
          Text(
            text,
            style: const TextStyle(
              color: Colors.white54,
            ),
          ),
        ],
      ),
    );
  }

  Widget _carItem(
    dynamic car,
  ) {
    final brand =
        car['brand']?.toString() ?? '';
    final model =
        car['model']?.toString() ?? '';
    final city =
        car['city']?.toString() ?? '';
    final price =
        car['price']?.toString() ?? '';

    return Container(
      margin:
          const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFF15151B),
        borderRadius:
            BorderRadius.circular(18),
        border: Border.all(
          color: const Color(0xFF292932),
        ),
      ),
      child: Column(
        crossAxisAlignment:
            CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  color:
                      const Color(0xFF21121A),
                  borderRadius:
                      BorderRadius.circular(13),
                ),
                child: const Icon(
                  Icons.directions_car_rounded,
                  color: Color(0xFFFF176F),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment:
                      CrossAxisAlignment.start,
                  children: [
                    Text(
                      '$brand $model',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 17,
                        fontWeight:
                            FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '$city • $price د.ع',
                      style: const TextStyle(
                        color: Colors.white54,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: ElevatedButton(
                  onPressed: () =>
                      _approveCar(car),
                  style:
                      ElevatedButton.styleFrom(
                    backgroundColor:
                        const Color(0xFF18A558),
                    foregroundColor:
                        Colors.white,
                  ),
                  child: const Text(
                    'موافقة',
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: OutlinedButton(
                  onPressed: () =>
                      _rejectCar(car),
                  style:
                      OutlinedButton.styleFrom(
                    foregroundColor:
                        Colors.orangeAccent,
                    side: const BorderSide(
                      color: Colors.orangeAccent,
                    ),
                  ),
                  child: const Text(
                    'رفض',
                  ),
                ),
              ),
              const SizedBox(width: 8),
              IconButton(
                onPressed: () =>
                    _deleteCar(car),
                icon: const Icon(
                  Icons.delete_outline_rounded,
                  color: Colors.redAccent,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _pendingTab() {
    if (pendingCars.isEmpty) {
      return _empty(
        'لا توجد إعلانات بانتظار المراجعة',
        Icons.check_circle_outline_rounded,
      );
    }

    return RefreshIndicator(
      color: const Color(0xFFFF176F),
      onRefresh: _loadAdminData,
      child: ListView.builder(
        padding: const EdgeInsets.all(15),
        itemCount: pendingCars.length,
        itemBuilder: (_, index) {
          return _carItem(
            pendingCars[index],
          );
        },
      ),
    );
  }

  Widget _userItem(
    dynamic user,
  ) {
    final role =
        user['role']?.toString() ?? 'user';

    final admin = role == 'admin';

    return Container(
      margin:
          const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFF15151B),
        borderRadius:
            BorderRadius.circular(17),
        border: Border.all(
          color: const Color(0xFF292932),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: admin
                  ? const Color(0xFF321222)
                  : const Color(0xFF202027),
              borderRadius:
                  BorderRadius.circular(13),
            ),
            child: Icon(
              admin
                  ? Icons
                      .admin_panel_settings_rounded
                  : Icons.person_outline_rounded,
              color: admin
                  ? const Color(0xFFFF176F)
                  : Colors.white54,
            ),
          ),
          const SizedBox(width: 11),
          Expanded(
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,
              children: [
                Text(
                  user['name']
                          ?.toString() ??
                      'مستخدم',
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight:
                        FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  user['email']
                          ?.toString() ??
                      '',
                  style: const TextStyle(
                    color: Colors.white38,
                    fontSize: 11,
                  ),
                ),
              ],
            ),
          ),
          PopupMenuButton<String>(
            color: const Color(0xFF202027),
            onSelected: (value) =>
                _changeUserRole(
              user,
              value,
            ),
            itemBuilder: (_) => [
              PopupMenuItem(
                value: admin
                    ? 'user'
                    : 'admin',
                child: Text(
                  admin
                      ? 'إزالة الأدمن'
                      : 'جعله أدمن',
                  style:
                      const TextStyle(
                    color: Colors.white,
                  ),
                ),
              ),
            ],
            icon: const Icon(
              Icons.more_vert_rounded,
              color: Colors.white54,
            ),
          ),
        ],
      ),
    );
  }

  Widget _usersTab() {
    if (users.isEmpty) {
      return _empty(
        'لا توجد بيانات مستخدمين',
        Icons.people_outline_rounded,
      );
    }

    return RefreshIndicator(
      color: const Color(0xFFFF176F),
      onRefresh: _loadAdminData,
      child: ListView.builder(
        padding: const EdgeInsets.all(15),
        itemCount: users.length,
        itemBuilder: (_, index) {
          return _userItem(
            users[index],
          );
        },
      ),
    );
  }

  Widget _paymentItem(
    dynamic payment,
  ) {
    final status =
        payment['status']?.toString() ??
            'pending';

    final approved =
        status == 'approved';

    return Container(
      margin:
          const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: const Color(0xFF15151B),
        borderRadius:
            BorderRadius.circular(17),
        border: Border.all(
          color: const Color(0xFF292932),
        ),
      ),
      child: Column(
        crossAxisAlignment:
            CrossAxisAlignment.start,
        children: [
          Text(
            'طلب دفع #${payment['id'] ?? ''}',
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 7),
          Text(
            '${payment['amount'] ?? 0} د.ع',
            style: const TextStyle(
              color: Color(0xFFFF176F),
              fontSize: 18,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 5),
          Text(
            'الحالة: ${approved ? 'مؤكد' : 'بانتظار التأكيد'}',
            style: TextStyle(
              color: approved
                  ? const Color(0xFF18A558)
                  : Colors.orangeAccent,
              fontSize: 12,
            ),
          ),
          if (!approved) ...[
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () =>
                    _approvePayment(
                  payment,
                ),
                style:
                    ElevatedButton.styleFrom(
                  backgroundColor:
                      const Color(0xFF18A558),
                ),
                child: const Text(
                  'تأكيد الدفع',
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _paymentsTab() {
    if (payments.isEmpty) {
      return _empty(
        'لا توجد طلبات دفع',
        Icons.payments_outlined,
      );
    }

    return RefreshIndicator(
      color: const Color(0xFFFF176F),
      onRefresh: _loadAdminData,
      child: ListView.builder(
        padding: const EdgeInsets.all(15),
        itemCount: payments.length,
        itemBuilder: (_, index) {
          return _paymentItem(
            payments[index],
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor:
          const Color(0xFF08080B),
      appBar: AppBar(
        backgroundColor:
            const Color(0xFF111116),
        foregroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          'لوحة الإدارة',
          style: TextStyle(
            fontWeight: FontWeight.w900,
          ),
        ),
        actions: [
          IconButton(
            onPressed: _loadAdminData,
            icon: const Icon(
              Icons.refresh_rounded,
            ),
          ),
        ],
        bottom: TabBar(
          controller: tabController,
          indicatorColor:
              const Color(0xFFFF176F),
          labelColor:
              const Color(0xFFFF176F),
          unselectedLabelColor:
              Colors.white54,
          tabs: const [
            Tab(
              icon: Icon(
                Icons.directions_car_rounded,
              ),
              text: 'الإعلانات',
            ),
            Tab(
              icon: Icon(
                Icons.people_alt_outlined,
              ),
              text: 'المستخدمون',
            ),
            Tab(
              icon: Icon(
                Icons.payments_outlined,
              ),
              text: 'المدفوعات',
            ),
          ],
        ),
      ),
      body: loading
          ? const Center(
              child:
                  CircularProgressIndicator(
                color: Color(0xFFFF176F),
              ),
            )
          : error != null
              ? Center(
                  child: Padding(
                    padding:
                        const EdgeInsets.all(25),
                    child: Column(
                      mainAxisAlignment:
                          MainAxisAlignment.center,
                      children: [
                        const Icon(
                          Icons
                              .admin_panel_settings_outlined,
                          color: Colors.white30,
                          size: 65,
                        ),
                        const SizedBox(
                            height: 15),
                        Text(
                          error!,
                          textAlign:
                              TextAlign.center,
                          style:
                              const TextStyle(
                            color:
                                Colors.white60,
                          ),
                        ),
                        const SizedBox(
                            height: 15),
                        ElevatedButton(
                          onPressed:
                              _loadAdminData,
                          style:
                              ElevatedButton
                                  .styleFrom(
                            backgroundColor:
                                const Color(
                              0xFFFF176F,
                            ),
                          ),
                          child: const Text(
                            'إعادة المحاولة',
                          ),
                        ),
                      ],
                    ),
                  ),
                )
              : TabBarView(
                  controller: tabController,
                  children: [
                    _pendingTab(),
                    _usersTab(),
                    _paymentsTab(),
                  ],
                ),
    );
  }
}
