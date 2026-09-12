import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/providers/user_provider.dart';
import '../../../core/services/api_service.dart';
import '../../../shared/widgets/glass_container.dart';

class FarmerDoctorsScreen extends ConsumerStatefulWidget {
  const FarmerDoctorsScreen({super.key});

  @override
  ConsumerState<FarmerDoctorsScreen> createState() => _FarmerDoctorsScreenState();
}

class _FarmerDoctorsScreenState extends ConsumerState<FarmerDoctorsScreen> {
  bool _isLoading = true;
  List<dynamic> _doctors = [];
  final TextEditingController _searchController = TextEditingController();
  String _selectedSpecialty = 'All Specialties';

  static const List<String> _specialties = [
    'All Specialties',
    'General Vet',
    'Large Animal',
    'Dairy',
    'Poultry',
    'Surgery',
  ];

  @override
  void initState() {
    super.initState();
    _loadDoctors();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadDoctors() async {
    final token = ref.read(userProvider).token;
    if (token.isEmpty) {
      setState(() => _isLoading = false);
      return;
    }

    try {
      final doctors = await ApiService.getNearbyDoctors(token);
      setState(() {
        _doctors = doctors;
        _isLoading = false;
      });
    } catch (_) {
      setState(() => _isLoading = false);
    }
  }

  List<dynamic> get _filteredDoctors {
    final query = _searchController.text.trim().toLowerCase();

    return _doctors.where((doctor) {
      final map = doctor as Map<String, dynamic>;
      final name = (map['name'] ?? '').toString().toLowerCase();
      final specialty = (map['specialization'] ?? '').toString().toLowerCase();
      final matchesSearch = query.isEmpty || name.contains(query) || specialty.contains(query);
      final matchesSpecialty = _selectedSpecialty == 'All Specialties' ||
          specialty.contains(_selectedSpecialty.toLowerCase().replaceAll(' ', '')) ||
          specialty.contains(_selectedSpecialty.toLowerCase());
      return matchesSearch && matchesSpecialty;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final filteredDoctors = _filteredDoctors;

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 120),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Find Nearby Doctors',
              style: TextStyle(fontSize: 32, fontWeight: FontWeight.w800, color: Colors.black87),
            ),
            const SizedBox(height: 6),
            const Text(
              'Connect with experienced veterinary doctors near you',
              style: TextStyle(fontSize: 14, color: Colors.black54),
            ),
            const SizedBox(height: 20),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.7),
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: Colors.black12),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 12,
                        height: 12,
                        decoration: const BoxDecoration(
                          color: Color(0xFFEC4C87),
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 8),
                      const Text(
                        'Doctors Location Map',
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black87),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    'Click on markers to see doctor details',
                    style: TextStyle(fontSize: 13, color: Colors.black54),
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    height: 240,
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Container(
                        decoration: const BoxDecoration(
                          color: Color(0xFFEDE9E2),
                        ),
                        child: Stack(
                          children: [
                            Positioned.fill(
                              child: CustomPaint(
                                painter: _MapPainter(),
                              ),
                            ),
                            Positioned(
                              left: 64,
                              top: 72,
                              child: _mapMarker('Dr. Mehta', 0xFF5B7CFA),
                            ),
                            Positioned(
                              left: 180,
                              top: 120,
                              child: _mapMarker('Vet Care', 0xFF22A06B),
                            ),
                            Positioned(
                              left: 300,
                              top: 80,
                              child: _mapMarker('Livestock Clinic', 0xFFEC4C87),
                            ),
                            Positioned(
                              right: 20,
                              bottom: 18,
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                decoration: BoxDecoration(
                                  color: Colors.white.withValues(alpha: 0.75),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: const Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(Icons.map_outlined, size: 12, color: Colors.black54),
                                    SizedBox(width: 4),
                                    Text('Leaflet', style: TextStyle(fontSize: 10, color: Colors.black54)),
                                    SizedBox(width: 6),
                                    Text('© OpenStreetMap contributors', style: TextStyle(fontSize: 10, color: Colors.black54)),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.7),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: Colors.black12),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.search, color: Colors.black38, size: 18),
                        const SizedBox(width: 10),
                        Expanded(
                          child: TextField(
                            controller: _searchController,
                            onChanged: (_) => setState(() {}),
                            decoration: const InputDecoration(
                              hintText: 'Search by doctor name, specialty, or location...',
                              hintStyle: TextStyle(color: Colors.black38),
                              border: InputBorder.none,
                              enabledBorder: InputBorder.none,
                              focusedBorder: InputBorder.none,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.7),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: Colors.black12),
                  ),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      value: _selectedSpecialty,
                      dropdownColor: Colors.white,
                      icon: const Icon(Icons.keyboard_arrow_down, size: 18, color: Colors.black54),
                      items: _specialties.map((specialty) {
                        return DropdownMenuItem<String>(
                          value: specialty,
                          child: Text(specialty, style: const TextStyle(color: Colors.black87)),
                        );
                      }).toList(),
                      onChanged: (value) {
                        setState(() => _selectedSpecialty = value ?? 'All Specialties');
                      },
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Expanded(
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : filteredDoctors.isEmpty
                      ? Container(
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.7),
                            borderRadius: BorderRadius.circular(18),
                            border: Border.all(color: Colors.black12),
                          ),
                          child: const Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.search_off, size: 52, color: Colors.black38),
                                SizedBox(height: 16),
                                Text(
                                  'No doctors found matching your criteria',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(fontSize: 20, color: Colors.black54),
                                ),
                              ],
                            ),
                          ),
                        )
                      : ListView.builder(
                          padding: EdgeInsets.zero,
                          itemCount: filteredDoctors.length,
                          itemBuilder: (context, index) {
                            final doctor = filteredDoctors[index] as Map<String, dynamic>;
                            final name = doctor['name'] ?? 'Doctor';
                            final specialty = doctor['specialization'] ?? 'Veterinarian';
                            final rating = double.tryParse('${doctor['rating'] ?? 0}') ?? 0.0;

                            return Container(
                              margin: const EdgeInsets.only(bottom: 12),
                              padding: const EdgeInsets.all(14),
                              decoration: BoxDecoration(
                                color: Colors.white.withValues(alpha: 0.72),
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(color: Colors.black12),
                              ),
                              child: Row(
                                children: [
                                  CircleAvatar(
                                    radius: 26,
                                    backgroundColor: const Color(0xFF2563EB).withValues(alpha: 0.12),
                                    child: Text(
                                      name.substring(0, 1).toUpperCase(),
                                      style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF2563EB)),
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(name, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black87)),
                                        const SizedBox(height: 4),
                                        Text(specialty, style: const TextStyle(color: Colors.black54)),
                                        const SizedBox(height: 8),
                                        Row(
                                          children: [
                                            const Icon(Icons.location_on, size: 14, color: Colors.black54),
                                            const SizedBox(width: 4),
                                            Text(doctor['location'] ?? 'Indore, MP', style: const TextStyle(fontSize: 12, color: Colors.black54)),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                  Column(
                                    children: [
                                      const Icon(Icons.star, size: 16, color: Colors.orange),
                                      const SizedBox(height: 4),
                                      Text(rating.toStringAsFixed(1), style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.black87)),
                                    ],
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _mapMarker(String label, int color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Color(color).withValues(alpha: 0.18),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: Color(color).withValues(alpha: 0.8)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.location_on, size: 10, color: Color(color)),
          const SizedBox(width: 4),
          Text(label, style: const TextStyle(fontSize: 9, color: Colors.black87)),
        ],
      ),
    );
  }
}

class _MapPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5
      ..color = Colors.white.withValues(alpha: 0.7);

    final roadPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.5
      ..color = const Color(0xFFD2B48C);

    final trafPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.2
      ..color = const Color(0xFFE8C568);

    final gridPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.8
      ..color = Colors.black12;

    for (double x = 0; x < size.width; x += 28) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), gridPaint);
    }
    for (double y = 0; y < size.height; y += 28) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), gridPaint);
    }

    final roads = [
      const Offset(0, 32), const Offset(220, 32), const Offset(400, 32), const Offset(520, 60),
      const Offset(30, 120), const Offset(210, 150), const Offset(330, 200), const Offset(500, 160),
      const Offset(140, 220), const Offset(290, 180), const Offset(450, 120), const Offset(620, 210),
    ];

    for (int i = 0; i < roads.length - 1; i += 2) {
      final p1 = roads[i];
      final p2 = roads[i + 1];
      canvas.drawLine(Offset(p1.dx, p1.dy), Offset(p2.dx, p2.dy), roadPaint);
    }

    final lanes = [
      const Offset(80, 0), const Offset(80, 220),
      const Offset(200, 0), const Offset(200, 260),
      const Offset(360, 0), const Offset(360, 220),
      const Offset(470, 40), const Offset(470, 260),
    ];

    for (int i = 0; i < lanes.length - 1; i += 2) {
      final p1 = lanes[i];
      final p2 = lanes[i + 1];
      canvas.drawLine(Offset(p1.dx, p1.dy), Offset(p2.dx, p2.dy), trafPaint);
    }

    final parkRects = [
      Rect.fromLTWH(10, 10, 110, 70),
      Rect.fromLTWH(460, 35, 120, 62),
      Rect.fromLTWH(20, 170, 130, 50),
      Rect.fromLTWH(430, 170, 80, 52),
    ];

    final parkPaint = Paint()..color = const Color(0xFFCFE8C0);
    for (final rect in parkRects) {
      canvas.drawRect(rect, parkPaint);
    }

    final waterPaint = Paint()..color = const Color(0xFFBDE3F2);
    canvas.drawOval(Rect.fromLTWH(300, 0, 120, 72), waterPaint);
    canvas.drawOval(Rect.fromLTWH(120, 150, 84, 60), waterPaint);

    final cityPaint = Paint()..color = Colors.white.withValues(alpha: 0.32);
    canvas.drawRect(Rect.fromLTWH(100, 70, 210, 120), cityPaint);
    canvas.drawRect(Rect.fromLTWH(240, 120, 180, 110), cityPaint);
    canvas.drawRect(Rect.fromLTWH(90, 190, 150, 50), cityPaint);

    canvas.drawCircle(const Offset(180, 90), 8, paint);
    canvas.drawCircle(const Offset(410, 125), 10, paint);
    canvas.drawCircle(const Offset(310, 180), 7, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
