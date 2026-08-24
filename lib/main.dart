import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);
  runApp(const ZekrShomarApp());
}

/// یک ذکر/دعا با نام نمایشی و متن کامل آن
class Dhikr {
  final String id;
  final String name;
  final String text;
  const Dhikr({required this.id, required this.name, required this.text});
}

/// لیست اذکار برنامه (پیش‌فرض: صلوات - اولین آیتم)
const List<Dhikr> kDhikrList = [
  Dhikr(
    id: 'salawat',
    name: 'صلوات',
    text: 'اللَّهُمَّ صَلِّ عَلَىٰ مُحَمَّدٍ وَآلِ مُحَمَّدٍ وَعَجِّلْ فَرَجَهُمْ',
  ),
  Dhikr(
    id: 'esteghfar',
    name: 'استغفار',
    text: 'أَسْتَغْفِرُ اللَّهَ رَبِّي وَأَتُوبُ إِلَيْهِ',
  ),
  Dhikr(
    id: 'tasbih_zahra',
    name: 'تسبیح حضرت زهرا (س)',
    text: 'اللَّهُ أَکْبَرُ، الْحَمْدُ لِلَّهِ، سُبْحَانَ اللَّهِ',
  ),
  Dhikr(
    id: 'ya_hussain',
    name: 'ذکر امام حسین (ع)',
    text: 'یَا حُسَیْن',
  ),
  Dhikr(
    id: 'faraj',
    name: 'ذکر امام زمان (عج)',
    text: 'اللَّهُمَّ عَجِّلْ لِوَلِیِّکَ الْفَرَج',
  ),
  Dhikr(
    id: 'tawhid',
    name: 'ذکر توحید',
    text: 'لَا إِلَٰهَ إِلَّا اللَّه',
  ),
  Dhikr(
    id: 'hawqala',
    name: 'ذکر حوقله',
    text: 'لَا حَوْلَ وَلَا قُوَّةَ إِلَّا بِاللَّهِ الْعَلِیِّ الْعَظِیم',
  ),
  Dhikr(
    id: 'ya_ali',
    name: 'ذکر امام علی (ع)',
    text: 'یَا عَلِیّ',
  ),
  Dhikr(
    id: 'faraj_kootah',
    name: 'دعای فرج کوتاه',
    text: 'یَا صَاحِبَ الزَّمَانِ أَغِثْنِی',
  ),
  Dhikr(
    id: 'salamati_emam',
    name: 'ذکر سلامتی امام زمان (عج)',
    text: 'اللَّهُمَّ کُنْ لِوَلِیِّکَ الْحُجَّةِ بْنِ الْحَسَنِ',
  ),
];

/// یک پالت رنگی برای هر یک از سه حالت پس‌زمینه
class AppTheme {
  final String key;
  final String label;
  final Color background;
  final Color foreground; // رنگ متن اصلی روی پس‌زمینه
  final Color circleFill;
  final Color circleLine;
  final Color boxBackground;
  final Color boxBorder;
  final Color accent;

  const AppTheme({
    required this.key,
    required this.label,
    required this.background,
    required this.foreground,
    required this.circleFill,
    required this.circleLine,
    required this.boxBackground,
    required this.boxBorder,
    required this.accent,
  });
}

const List<AppTheme> kThemes = [
  AppTheme(
    key: 'black',
    label: 'سیاه',
    background: Color(0xFF000000),
    foreground: Color(0xFFFFFFFF),
    circleFill: Color(0xFFFFFFFF),
    circleLine: Color(0xFF111111),
    boxBackground: Color(0xFF1A1A1A),
    boxBorder: Color(0xFFFFFFFF),
    accent: Color(0xFFD4AF37),
  ),
  AppTheme(
    key: 'white',
    label: 'سفید',
    background: Color(0xFFFAFAFA),
    foreground: Color(0xFF1A1A1A),
    circleFill: Color(0xFF1A1A1A),
    circleLine: Color(0xFFFAFAFA),
    boxBackground: Color(0xFFEDEDED),
    boxBorder: Color(0xFF1A1A1A),
    accent: Color(0xFF9C7A1E),
  ),
  AppTheme(
    key: 'green',
    label: 'سبز',
    background: Color(0xFF0F3D2E),
    foreground: Color(0xFFFFFFFF),
    circleFill: Color(0xFFFFFFFF),
    circleLine: Color(0xFF0F3D2E),
    boxBackground: Color(0xFF12513C),
    boxBorder: Color(0xFFFFFFFF),
    accent: Color(0xFFD4AF37),
  ),
];

String toPersianDigits(int number) {
  const fa = ['۰', '۱', '۲', '۳', '۴', '۵', '۶', '۷', '۸', '۹'];
  return number.toString().split('').map((c) {
    final d = int.tryParse(c);
    return d == null ? c : fa[d];
  }).join();
}

class ZekrShomarApp extends StatelessWidget {
  const ZekrShomarApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'ذکر شمار',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(fontFamily: null, useMaterial3: true),
      builder: (context, child) {
        return Directionality(
          textDirection: TextDirection.rtl,
          child: child ?? const SizedBox.shrink(),
        );
      },
      home: const HomeScreen(),
    );
  }
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with SingleTickerProviderStateMixin {
  int _themeIndex = 0; // پیش‌فرض: سیاه
  int _dhikrIndex = 0; // پیش‌فرض: صلوات
  bool _showColorPicker = false;
  bool _showMenu = false;
  bool _pressed = false;

  final Map<String, int> _counts = {};
  SharedPreferences? _prefs;

  AppTheme get _theme => kThemes[_themeIndex];
  Dhikr get _dhikr => kDhikrList[_dhikrIndex];
  int get _count => _counts[_dhikr.id] ?? 0;

  @override
  void initState() {
    super.initState();
    _loadState();
  }

  Future<void> _loadState() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _prefs = prefs;
      _themeIndex = prefs.getInt('theme_index') ?? 0;
      _dhikrIndex = prefs.getInt('dhikr_index') ?? 0;
      for (final d in kDhikrList) {
        _counts[d.id] = prefs.getInt('count_${d.id}') ?? 0;
      }
    });
  }

  void _incrementCount() {
    HapticFeedback.lightImpact();
    setState(() {
      _counts[_dhikr.id] = _count + 1;
    });
    _prefs?.setInt('count_${_dhikr.id}', _count);
  }

  void _selectTheme(int index) {
    setState(() {
      _themeIndex = index;
      _showColorPicker = false;
    });
    _prefs?.setInt('theme_index', index);
  }

  void _selectDhikr(int index) {
    setState(() {
      _dhikrIndex = index;
      _showMenu = false;
    });
    _prefs?.setInt('dhikr_index', index);
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final panelWidth = size.width / 3;

    return Scaffold(
      backgroundColor: _theme.background,
      body: SafeArea(
        child: Stack(
          children: [
            // محتوای اصلی صفحه
            Column(
              children: [
                const SizedBox(height: 8),
                Expanded(
                  child: Center(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          _buildDhikrText(),
                          const SizedBox(height: 28),
                          _buildCircle(),
                          const SizedBox(height: 32),
                          _buildCountBox(),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 24),
              ],
            ),

            // آیکون تغییر رنگ - بالا سمت چپ
            Positioned(
              top: 8,
              left: 8,
              child: _buildColorIcon(),
            ),

            // پاپ‌آپ انتخاب رنگ
            if (_showColorPicker)
              Positioned(
                top: 56,
                left: 8,
                child: _buildColorOptions(),
              ),

            // آیکون منو - بالا سمت راست
            Positioned(
              top: 8,
              right: 8,
              child: _buildMenuIcon(),
            ),

            // لایه تیره پشت پنل هنگام باز بودن منو
            if (_showMenu)
              Positioned.fill(
                child: GestureDetector(
                  onTap: () => setState(() => _showMenu = false),
                  child: Container(color: Colors.black.withOpacity(0.4)),
                ),
              ),

            // پنل کشویی سمت راست (یک‌سوم صفحه)
            AnimatedPositioned(
              duration: const Duration(milliseconds: 260),
              curve: Curves.easeInOut,
              top: 0,
              bottom: 0,
              right: _showMenu ? 0 : -panelWidth,
              width: panelWidth,
              child: _buildMenuPanel(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDhikrText() {
    return Column(
      children: [
        Text(
          _dhikr.name,
          textAlign: TextAlign.center,
          style: TextStyle(
            color: _theme.accent,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 10),
        Text(
          _dhikr.text,
          textAlign: TextAlign.center,
          style: TextStyle(
            color: _theme.foreground,
            fontSize: 24,
            height: 1.6,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _buildCircle() {
    return GestureDetector(
      onTapDown: (_) => setState(() => _pressed = true),
      onTapCancel: () => setState(() => _pressed = false),
      onTapUp: (_) => setState(() => _pressed = false),
      onTap: _incrementCount,
      child: AnimatedScale(
        scale: _pressed ? 0.94 : 1.0,
        duration: const Duration(milliseconds: 100),
        child: SizedBox(
          width: 240,
          height: 240,
          child: CustomPaint(
            painter: _CirclePainter(
              fill: _theme.circleFill,
              line: _theme.circleLine,
              accent: _theme.accent,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCountBox() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 36, vertical: 14),
      decoration: BoxDecoration(
        color: _theme.boxBackground,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: _theme.boxBorder, width: 2),
      ),
      child: Text(
        toPersianDigits(_count),
        style: TextStyle(
          color: _theme.foreground,
          fontSize: 36,
          fontWeight: FontWeight.bold,
          letterSpacing: 1,
        ),
      ),
    );
  }

  Widget _buildColorIcon() {
    return _IconBubble(
      icon: Icons.palette_outlined,
      color: _theme.foreground,
      onTap: () => setState(() => _showColorPicker = !_showColorPicker),
    );
  }

  Widget _buildMenuIcon() {
    return _IconBubble(
      icon: Icons.menu_rounded,
      color: _theme.foreground,
      onTap: () => setState(() => _showMenu = !_showMenu),
    );
  }

  Widget _buildColorOptions() {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: _theme.background.withOpacity(0.95),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _theme.foreground.withOpacity(0.25)),
        boxShadow: const [
          BoxShadow(color: Colors.black26, blurRadius: 10, offset: Offset(0, 4)),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: List.generate(kThemes.length, (i) {
          final t = kThemes[i];
          final selected = i == _themeIndex;
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 6),
            child: GestureDetector(
              onTap: () => _selectTheme(i),
              child: Container(
                width: 34,
                height: 34,
                decoration: BoxDecoration(
                  color: t.background,
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: selected ? t.accent : Colors.grey,
                    width: selected ? 3 : 1,
                  ),
                ),
              ),
            ),
          );
        }),
      ),
    );
  }

  Widget _buildMenuPanel() {
    return Container(
      color: Colors.black,
      child: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 12),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: Row(
                children: [
                  Image.asset(
                    'assets/logo.png',
                    width: 36,
                    height: 36,
                    errorBuilder: (_, __, ___) => const Icon(
                      Icons.mosque,
                      color: Colors.white,
                      size: 30,
                    ),
                  ),
                  const SizedBox(width: 10),
                  const Expanded(
                    child: Text(
                      'ذکر شمار',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const Divider(color: Colors.white24, height: 24),
            Expanded(
              child: ListView.builder(
                itemCount: kDhikrList.length,
                itemBuilder: (context, i) {
                  final d = kDhikrList[i];
                  final selected = i == _dhikrIndex;
                  return ListTile(
                    onTap: () => _selectDhikr(i),
                    title: Text(
                      d.name,
                      textAlign: TextAlign.right,
                      style: TextStyle(
                        color: selected ? const Color(0xFFD4AF37) : Colors.white,
                        fontWeight: selected ? FontWeight.bold : FontWeight.normal,
                        fontSize: 15,
                      ),
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
}

class _IconBubble extends StatelessWidget {
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  const _IconBubble({
    required this.icon,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(24),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(10),
          child: Icon(icon, color: color, size: 26),
        ),
      ),
    );
  }
}

/// دایره اصلی: پرشده با یک رنگ، حلقه‌های هم‌مرکز و دانه‌های تسبیح‌مانند دور آن
class _CirclePainter extends CustomPainter {
  final Color fill;
  final Color line;
  final Color accent;

  _CirclePainter({required this.fill, required this.line, required this.accent});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;

    // سایه ملایم
    canvas.drawCircle(
      center,
      radius,
      Paint()
        ..color = Colors.black.withOpacity(0.25)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 12),
    );

    // دایره اصلی
    canvas.drawCircle(center, radius - 4, Paint()..color = fill);

    // حلقه‌های هم‌مرکز تزئینی
    final ringPaint = Paint()
      ..color = line.withOpacity(0.55)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.4;
    for (final f in [0.62, 0.74, 0.86]) {
      canvas.drawCircle(center, (radius - 4) * f, ringPaint);
    }

    // دانه‌های تسبیح‌مانند دور لبه (۳۳ عدد)
    const beadCount = 33;
    final beadPaint = Paint()..color = line.withOpacity(0.85);
    for (int i = 0; i < beadCount; i++) {
      final angle = (2 * math.pi / beadCount) * i;
      final beadRadius = radius - 14;
      final dx = center.dx + beadRadius * math.cos(angle);
      final dy = center.dy + beadRadius * math.sin(angle);
      canvas.drawCircle(Offset(dx, dy), 2.4, beadPaint);
    }

    // لبه بیرونی ظریف با رنگ تاکیدی
    canvas.drawCircle(
      center,
      radius - 4,
      Paint()
        ..color = accent.withOpacity(0.9)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2,
    );
  }

  @override
  bool shouldRepaint(covariant _CirclePainter oldDelegate) {
    return oldDelegate.fill != fill ||
        oldDelegate.line != line ||
        oldDelegate.accent != accent;
  }
}
