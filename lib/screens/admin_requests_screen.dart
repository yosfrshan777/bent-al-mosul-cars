import 'package:flutter/material.dart';

import '../services/api_service.dart';

class AdminRequestsScreen extends StatefulWidget {
  const AdminRequestsScreen({
    super.key,
    required this.api,
  });

  final ApiService api;

  @override
  State<AdminRequestsScreen> createState() =>
      _AdminRequestsScreenState();
}

class _AdminRequestsScreenState
    extends State<AdminRequestsScreen> {
  bool _loading = false;
  List<Map<String, dynamic>> _requests = [];

  @override
  void initState() {
    super.initState();
    _loadRequests();
  }

  Future<void> _loadRequests() async {
    setState(() {
      _loading = true;
    });

    try {
      final result =
          await widget.api.getPendingRequests();

      final list = <Map<String, dynamic>>[];

      if (result is List) {
        for (final item in result) {
          if (item is Map) {
            list.add(
              Map<String, dynamic>.from(item),
            );
          }
        }
      } else if (result is Map &&
          result['requests'] is List) {
        for (final item in result['requests']) {
          if (item is Map) {
            list.add(
              Map<String, dynamic>.from(item),
            );
          }
        }
      }

      if (!mounted) return;

      setState(() {
        _requests = list;
      });
    } on ApiException catch (e) {
      if (mounted) {
        _message(e.message);
      }
    } catch (_) {
      if (mounted) {
        _message(
          'تعذر تحميل الطلبات',
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _loading = false;
        });
      }
    }
  }

  Future<void> _approve(
    Map<String, dynamic> request,
  ) async {
    final id = _toInt(request['id']);

    if (id <= 0) {
      _message('رقم الطلب غير صحيح');
      return;
    }

    try {
      await widget.api.approveRequest(id);

      if (!mounted) return;

      setState(() {
        _requests.remove(request);
      });

      _message('تمت الموافقة على الطلب');
    } on ApiException catch (e) {
      _message(e.message);
    } catch (_) {
      _message(
        'حدث خطأ أثناء الموافقة',
      );
    }
  }

  Future<void> _reject(
    Map<String, dynamic> request,
  ) async {
    final id = _toInt(request['id']);

    if (id <= 0) {
      _message('رقم الطلب غير صحيح');
      return;
    }

    try {
      await widget.api.rejectRequest(id);

      if (!mounted) return;

      setState(() {
        _requests.remove(request);
      });

      _message('تم رفض الطلب');
    } on ApiException catch (e) {
      _message(e.message);
    } catch (_) {
      _message(
        'حدث خطأ أثناء رفض الطلب',
      );
    }
  }

  int _toInt(dynamic value) {
    if (value is int) return value;
    if (value is num) return value.toInt();

    return int.tryParse(
          value?.toString() ?? '',
        ) ??
        0;
  }

  String _value(
    Map<String, dynamic> data,
    List<String> keys,
  ) {
    for (final key in keys) {
      final value = data[key];

      if (value != null &&
          value.toString().trim().isNotEmpty) {
        return value.toString();
      }
    }

    return 'غير محدد';
  }

  IconData _requestIcon(
    Map<String, dynamic> request,
  ) {
    final type = _value(
      request,
      ['type', 'section', 'role'],
    ).toLowerCase();

    if (type.contains('part') ||
        type.contains('قطع')) {
      return Icons.build_rounded;
    }

    if (type.contains('shop') ||
        type.contains('showroom') ||
        type.contains('معرض')) {
      return Icons.store_rounded;
    }

    return Icons.directions_car_rounded;
  }

  Widget _requestCard(
    Map<String, dynamic> request,
  ) {
    final name = _value(
      request,
      ['name', 'user_name', 'seller_name'],
    );

    final phone = _value(
      request,
      ['phone', 'user_phone', 'seller_phone'],
    );

    final type = _value(
      request,
      ['type', 'section', 'role'],
    );

    final city = _value(
      request,
      ['city', 'location'],
    );

    final created = _value(
      request,
      ['created_at', 'date'],
    );

    return Container(
      margin: const EdgeInsets.only(
        bottom: 12,
      ),
      padding: const EdgeInsets.all(15),
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
            CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: const Color(0xFF29151F),
                  borderRadius:
                      BorderRadius.circular(14),
                ),
                child: Icon(
                  _requestIcon(request),
                  color:
                      const Color(0xFFFF176F),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment:
                      CrossAxisAlignment.start,
                  children: [
                    Text(
                      name,
                      maxLines: 1,
                      overflow:
                          TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight:
                            FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      type,
                      style: const TextStyle(
                        color:
                            Color(0xFFFF176F),
                        fontSize: 12,
                        fontWeight:
                            FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
              Text(
                '#${request['id'] ?? '-'}',
                style: const TextStyle(
                  color: Colors.white30,
                  fontSize: 11,
                ),
              ),
            ],
          ),

          const SizedBox(height: 14),

          _detail(
            Icons.phone_rounded,
            'الهاتف',
            phone,
          ),

          _detail(
            Icons.location_on_outlined,
            'الموقع',
            city,
          ),

          if (created != 'غير محدد')
            _detail(
              Icons.access_time_rounded,
              'التاريخ',
              created,
            ),

          const SizedBox(height: 12),

          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () {
                    _approve(request);
                  },
                  icon: const Icon(
                    Icons.check_rounded,
                  ),
                  label: const Text(
                    'موافقة',
                  ),
                  style:
                      ElevatedButton.styleFrom(
                    backgroundColor:
                        Colors.green.shade700,
                    foregroundColor:
                        Colors.white,
                    shape:
                        RoundedRectangleBorder(
                      borderRadius:
                          BorderRadius.circular(
                        12,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 9),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () {
                    _reject(request);
                  },
                  icon: const Icon(
                    Icons.close_rounded,
                  ),
                  label: const Text(
                    'رفض',
                  ),
                  style:
                      OutlinedButton.styleFrom(
                    foregroundColor:
                        Colors.redAccent,
                    side:
                        const BorderSide(
                      color: Colors.redAccent,
                    ),
                    shape:
                        RoundedRectangleBorder(
                      borderRadius:
                          BorderRadius.circular(
                        12,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _detail(
    IconData icon,
    String title,
    String value,
  ) {
    return Padding(
      padding:
          const EdgeInsets.only(bottom: 7),
      child: Row(
        children: [
          Icon(
            icon,
            size: 16,
            color: Colors.white38,
          ),
          const SizedBox(width: 7),
          Text(
            '$title: ',
            style: const TextStyle(
              color: Colors.white38,
              fontSize: 11,
            ),
          ),
          Expanded(
            child: Text(
              value,
              overflow:
                  TextOverflow.ellipsis,
              style: const TextStyle(
                color: Colors.white70,
                fontSize: 12,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _message(String message) {
    if (!mounted) return;

    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(
            message,
            textDirection: TextDirection.rtl,
          ),
        ),
      );
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor:
            const Color(0xFF08080B),
        appBar: AppBar(
          title: const Text(
            'طلبات الإدارة',
            style: TextStyle(
              fontWeight: FontWeight.w900,
            ),
          ),
          centerTitle: true,
          actions: [
            IconButton(
              onPressed:
                  _loading ? null : _loadRequests,
              icon: const Icon(
                Icons.refresh_rounded,
              ),
            ),
          ],
        ),
        body: SafeArea(
          child: _loading && _requests.isEmpty
              ? const Center(
                  child:
                      CircularProgressIndicator(
                    color:
                        Color(0xFFFF176F),
                  ),
                )
              : RefreshIndicator(
                  color:
                      const Color(0xFFFF176F),
                  onRefresh: _loadRequests,
                  child: _requests.isEmpty
                      ? ListView(
                          children: const [
                            SizedBox(
                              height: 180,
                            ),
                            Icon(
                              Icons
                                  .inbox_outlined,
                              color:
                                  Colors.white24,
                              size: 70,
                            ),
                            SizedBox(
                              height: 15,
                            ),
                            Center(
                              child: Text(
                                'لا توجد طلبات معلقة',
                                style:
                                    TextStyle(
                                  color:
                                      Colors.white54,
                                  fontSize: 16,
                                ),
                              ),
                            ),
                          ],
                        )
                      : ListView.builder(
                          padding:
                              const EdgeInsets
                                  .all(16),
                          itemCount:
                              _requests.length,
                          itemBuilder:
                              (_, index) {
                            return _requestCard(
                              _requests[index],
                            );
                          },
                        ),
                ),
        ),
      ),
    );
  }
}
