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
  bool _loading = true;
  List<dynamic> _requests = [];

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
      final data =
          await widget.api.getPendingRequests();

      if (!mounted) return;

      setState(() {
        _requests = data is List ? data : [];
      });
    } on ApiException catch (e) {
      _message(e.message);
    } catch (_) {
      _message('تعذر تحميل الطلبات');
    } finally {
      if (mounted) {
        setState(() {
          _loading = false;
        });
      }
    }
  }

  Future<void> _approve(int id) async {
    try {
      await widget.api.approveRequest(id);

      if (!mounted) return;

      _message('تمت الموافقة على الإعلان');

      await _loadRequests();
    } on ApiException catch (e) {
      _message(e.message);
    } catch (_) {
      _message('تعذر تنفيذ العملية');
    }
  }

  Future<void> _reject(int id) async {
    try {
      await widget.api.rejectRequest(id);

      if (!mounted) return;

      _message('تم رفض الإعلان');

      await _loadRequests();
    } on ApiException catch (e) {
      _message(e.message);
    } catch (_) {
      _message('تعذر تنفيذ العملية');
    }
  }

  void _message(String text) {
    if (!mounted) return;

    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(text),
        ),
      );
  }

  String _text(
    Map<String, dynamic> item,
    String key,
  ) {
    return item[key]?.toString() ?? '';
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: const Color(0xFF08080B),
        appBar: AppBar(
          title: const Text(
            'طلبات الموافقة',
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
        body: _loading
            ? const Center(
                child: CircularProgressIndicator(
                  color: Color(0xFFFF176F),
                ),
              )
            : _requests.isEmpty
                ? const Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons
                              .check_circle_outline_rounded,
                          color: Color(0xFFFF176F),
                          size: 60,
                        ),
                        SizedBox(height: 12),
                        Text(
                          'ماكو طلبات معلقة',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  )
                : RefreshIndicator(
                    color: const Color(0xFFFF176F),
                    onRefresh: _loadRequests,
                    child: ListView.builder(
                      padding:
                          const EdgeInsets.all(16),
                      itemCount: _requests.length,
                      itemBuilder: (_, index) {
                        final raw =
                            _requests[index];

                        if (raw is! Map) {
                          return const SizedBox();
                        }

                        final item =
                            Map<String, dynamic>.from(
                          raw,
                        );

                        final id =
                            int.tryParse(
                                  _text(
                                    item,
                                    'id',
                                  ),
                                ) ??
                                0;

                        final brand =
                            _text(
                              item,
                              'brand',
                            );

                        final model =
                            _text(
                              item,
                              'model',
                            );

                        final year =
                            _text(
                              item,
                              'year',
                            );

                        final price =
                            _text(
                              item,
                              'price',
                            );

                        final city =
                            _text(
                              item,
                              'city',
                            );

                        final seller =
                            _text(
                              item,
                              'seller_name',
                            );

                        final phone =
                            _text(
                              item,
                              'seller_phone',
                            );

                        final plan =
                            _text(
                              item,
                              'plan',
                            );

                        return Container(
                          margin:
                              const EdgeInsets.only(
                            bottom: 14,
                          ),
                          padding:
                              const EdgeInsets.all(15),
                          decoration:
                              BoxDecoration(
                            color: const Color(
                              0xFF15151B,
                            ),
                            borderRadius:
                                BorderRadius.circular(
                              18,
                            ),
                            border: Border.all(
                              color: const Color(
                                0xFF292932,
                              ),
                            ),
                          ),
                          child: Column(
                            crossAxisAlignment:
                                CrossAxisAlignment
                                    .stretch,
                            children: [
                              Row(
                                children: [
                                  Container(
                                    width: 48,
                                    height: 48,
                                    decoration:
                                        BoxDecoration(
                                      color:
                                          const Color(
                                        0xFF29131F,
                                      ),
                                      borderRadius:
                                          BorderRadius
                                              .circular(
                                        14,
                                      ),
                                    ),
                                    child: const Icon(
                                      Icons
                                          .directions_car_rounded,
                                      color: Color(
                                        0xFFFF176F,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(
                                    width: 12,
                                  ),
                                  Expanded(
                                    child: Text(
                                      '$brand $model',
                                      style:
                                          const TextStyle(
                                        color:
                                            Colors.white,
                                        fontSize: 18,
                                        fontWeight:
                                            FontWeight
                                                .w900,
                                      ),
                                    ),
                                  ),
                                  if (plan
                                      .toUpperCase()
                                      .contains('VIP'))
                                    Container(
                                      padding:
                                          const EdgeInsets
                                              .symmetric(
                                        horizontal: 9,
                                        vertical: 5,
                                      ),
                                      decoration:
                                          BoxDecoration(
                                        color:
                                            const Color(
                                          0xFFFF176F,
                                        ),
                                        borderRadius:
                                            BorderRadius
                                                .circular(
                                          20,
                                        ),
                                      ),
                                      child:
                                          const Text(
                                        'VIP',
                                        style:
                                            TextStyle(
                                          color:
                                              Colors.white,
                                          fontSize: 10,
                                          fontWeight:
                                              FontWeight
                                                  .w900,
                                        ),
                                      ),
                                    ),
                                ],
                              ),

                              const SizedBox(
                                height: 14,
                              ),

                              _info(
                                Icons
                                    .calendar_month_rounded,
                                'السنة',
                                year,
                              ),

                              _info(
                                Icons
                                    .attach_money_rounded,
                                'السعر',
                                price.isEmpty
                                    ? ''
                                    : '\$$price',
                              ),

                              _info(
                                Icons
                                    .location_on_rounded,
                                'الموقع',
                                city,
                              ),

                              if (seller.isNotEmpty)
                                _info(
                                  Icons
                                      .person_rounded,
                                  'البائع',
                                  seller,
                                ),

                              if (phone.isNotEmpty)
                                _info(
                                  Icons
                                      .phone_rounded,
                                  'الهاتف',
                                  phone,
                                ),

                              const SizedBox(
                                height: 12,
                              ),

                              Row(
                                children: [
                                  Expanded(
                                    child:
                                        ElevatedButton.icon(
                                      onPressed:
                                          id == 0
                                              ? null
                                              : () =>
                                                  _approve(
                                                    id,
                                                  ),
                                      icon:
                                          const Icon(
                                        Icons
                                            .check_rounded,
                                      ),
                                      label:
                                          const Text(
                                        'موافقة',
                                      ),
                                      style:
                                          ElevatedButton
                                              .styleFrom(
                                        backgroundColor:
                                            const Color(
                                          0xFFFF176F,
                                        ),
                                        foregroundColor:
                                            Colors.white,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(
                                    width: 10,
                                  ),
                                  Expanded(
                                    child:
                                        OutlinedButton.icon(
                                      onPressed:
                                          id == 0
                                              ? null
                                              : () =>
                                                  _reject(
                                                    id,
                                                  ),
                                      icon:
                                          const Icon(
                                        Icons
                                            .close_rounded,
                                      ),
                                      label:
                                          const Text(
                                        'رفض',
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ),
      ),
    );
  }

  Widget _info(
    IconData icon,
    String title,
    String value,
  ) {
    if (value.isEmpty) {
      return const SizedBox();
    }

    return Padding(
      padding:
          const EdgeInsets.only(bottom: 7),
      child: Row(
        children: [
          Icon(
            icon,
            size: 18,
            color: Colors.white38,
          ),
          const SizedBox(width: 8),
          Text(
            '$title: ',
            style: const TextStyle(
              color: Colors.white38,
              fontSize: 12,
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                color: Colors.white70,
                fontSize: 12,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
