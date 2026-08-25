import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
  runApp(const ZekrShomarApp());
}

/// -------------------- داده ذکرها --------------------
class Zekr {
  final String title;
  final String text;
  const Zekr(this.title, this.text);
}

const List<Zekr> zekrList = [
  Zekr('صلوات', 'اللَّهُمَّ صَلِّ عَلَی مُحَمَّدٍ وَ آلِ مُحَمَّدٍ وَ عَجِّلْ فَرَجَهُمْ'),
  Zekr('استغفار', 'أَسْتَغْفِرُ اللَّهَ رَبِّی وَ أَتُوبُ إِلَیْهِ'),
  Zekr('تسبیح حضرت زهرا (س)', 'اللَّهُ أَکْبَرُ، الْحَمْدُ لِلَّهِ، سُبْحَانَ اللَّهِ'),
  Zekr('ذکر امام حسین (ع)', 'یَا حُسَیْن'),
  Zekr('ذکر امام زمان (عج)', 'اللَّهُمَّ عَجِّلْ لِوَلِیِّکَ الْفَرَج'),
  Zekr('ذکر توحید', 'لَا إِلَهَ إِلَّا اللَّه'),
  Zekr('ذکر حوقله', 'لَا حَوْلَ وَ لَا قُوَّةَ إِلَّا بِاللَّهِ الْعَلِیِّ الْعَظِیم'),
  Zekr('ذکر امام علی (ع)', 'یَا عَلِی'),
  Zekr('دعای فرج کوتاه', 'یَا صَاحِبَ الزَّمَانِ أَغِثْنِی'),
  Zekr('سلامتی امام زمان (عج)', 'اللَّهُمَّ کُنْ لِوَلِیِّکَ الْحُجَّةِ بْنِ الْحَسَن'),
];

/// -------------------- تم‌های رنگی --------------------
enum AppThemeMode { black, white, green }

class ThemeColors {
  final Color background;
  final Color boxFill;
  final Color boxBorder;
  final Color textColor;
  final Color accent;
  const ThemeColors({
    required this.background,
    required this.boxFill,
    required this.boxBorder,
    required this.textColor,
    required this.accent,
  });
}

const Map<AppThemeMode, ThemeColors> themeMap = {
  AppThemeMode.black: ThemeColors(
    background: Color(0xFF0B0B0B),
    boxFill: Color(0xFF1C1C1C),
    boxBorder: Color(0xFFF5F5F5),
    textColor: Color(0xFFF5F5F5),
    accent: Color(0xFFD4AF37),
  ),
  AppThemeMode.white: ThemeColors(
    background: Color(0xFFFAFAFA),
    boxFill: Color(0xFFFFFFFF),
    boxBorder: Color(0xFF1A1A1A),
    textColor: Color(0xFF1A1A1A),
    accent: Color(0xFF0B6E4F),
  ),
  AppThemeMode.green: ThemeColors(
    background: Color(0xFF0B4A34),
    boxFill: Color(0xFF0F5C41),
    boxBorder: Color(0xFFD4AF37),
    textColor: Color(0xFFF5F5F5),
    accent: Color(0xFFD4AF37),
  ),
};

/// -------------------- تبدیل اعداد به فارسی --------------------
String toFarsiDigits(int number) {
  const en = ['0', '1', '2', '3', '4', '5', '6', '7', '8', '9'];
  const fa = ['۰', '۱', '۲', '۳', '۴', '۵', '۶', '۷', '۸', '۹'];
  String s = number.toString();
  for (int i = 0; i < en.length; i++) {
    s = s.replaceAll(en[i], fa[i]);
  }
  return s;
}

/// -------------------- اپ --------------------
class ZekrShomarApp extends StatelessWidget {
  const ZekrShomarApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'ذکر شمار',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        fontFamily: null,
        useMaterial3: true,
      ),
      builder: (context, child) {
        return Directionality(
          textDirection: TextDirection.rtl,
          child: child ?? const SizedBox.shrink(),
        );
      },
      home: const SplashScreen(),
    );
  }
}

/// -------------------- اسپلش --------------------
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});
  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(milliseconds: 1800), () {
      if (mounted) {
        Navigator.of(context).pushReplacement(
          PageRouteBuilder(
            transitionDuration: const Duration(milliseconds: 400),
            pageBuilder: (_, __, ___) => const HomeScreen(),
            transitionsBuilder: (_, anim, __, child) =>
                FadeTransition(opacity: anim, child: child),
          ),
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0B4A34),
      body: Center(
        child: Image.asset(
          'assets/splash.png',
          width: 220,
          errorBuilder: (_, __, ___) => const Icon(
            Icons.mosque,
            size: 120,
            color: Colors.white,
          ),
        ),
      ),
    );
  }
}

/// -------------------- صفحه اصلی --------------------
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with SingleTickerProviderStateMixin {
  AppThemeMode _themeMode = AppThemeMode.green;
  int _selectedZekr = 0;
  Map<int, int> _counts = {};
  bool _colorPickerOpen = false;
  bool _menuOpen = false;
  late AnimationController _tapAnimCtrl;

  @override
  void initState() {
    super.initState();
    _tapAnimCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 120),
      lowerBound: 0.0,
      upperBound: 0.08,
    );
    _loadData();
  }

  @override
  void dispose() {
    _tapAnimCtrl.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    final prefs = await SharedPreferences.getInstance();
    final themeIndex = prefs.getInt('theme') ?? AppThemeMode.green.index;
    final zekrIndex = prefs.getInt('selectedZekr') ?? 0;
    final countsJson = prefs.getString('counts');
    Map<int, int> counts = {};
    if (countsJson != null) {
      final decoded = jsonDecode(countsJson) as Map<String, dynamic>;
      counts = decoded.map((k, v) => MapEntry(int.parse(k), v as int));
    }
    setState(() {
      _themeMode = AppThemeMode.values[themeIndex];
      _selectedZekr = zekrIndex;
      _counts = counts;
    });
  }

  Future<void> _saveData() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('theme', _themeMode.index);
    await prefs.setInt('selectedZekr', _selectedZekr);
    final asStringMap = _counts.map((k, v) => MapEntry(k.toString(), v));
    await prefs.setString('counts', jsonEncode(asStringMap));
  }

  int get _currentCount => _counts[_selectedZekr] ?? 0;

  void _incrementCount() {
    HapticFeedback.lightImpact();
    _tapAnimCtrl.forward().then((_) => _tapAnimCtrl.reverse());
    setState(() {
      _counts[_selectedZekr] = _currentCount + 1;
    });
    _saveData();
  }

  void _resetCount() {
    setState(() {
      _counts[_selectedZekr] = 0;
    });
    _saveData();
  }

  void _changeTheme(AppThemeMode mode) {
    setState(() {
      _themeMode = mode;
      _colorPickerOpen = false;
    });
    _saveData();
  }

  void _selectZekr(int index) {
    setState(() {
      _selectedZekr = index;
      _menuOpen = false;
    });
    _saveData();
  }

  @override
  Widget build(BuildContext context) {
    final colors = themeMap[_themeMode]!;
    final size = MediaQuery.of(context).size;
    final panelWidth = size.width / 3;

    return Scaffold(
      backgroundColor: colors.background,
      body: SafeArea(
        child: Stack(
          children: [
            // ---------- محتوای اصلی ----------
            Column(
              children: [
                _buildTopBar(colors),
                const SizedBox(height: 12),
                Expanded(
                  child: SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    child: Column(
                      children: [
                        const SizedBox(height: 8),
                        Text(
                          zekrList[_selectedZekr].title,
                          style: TextStyle(
                            color: colors.accent,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 10),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 28),
                          child: Text(
                            zekrList[_selectedZekr].text,
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: colors.textColor,
                              fontSize: 20,
                              height: 1.7,
                            ),
                          ),
                        ),
                        const SizedBox(height: 36),
                        GestureDetector(
                          onTap: _incrementCount,
                          child: AnimatedBuilder(
                            animation: _tapAnimCtrl,
                            builder: (context, child) {
                              final scale = 1.0 - _tapAnimCtrl.value;
                              return Transform.scale(scale: scale, child: child);
                            },
                            child: SizedBox(
                              width: 240,
                              height: 240,
                              child: CustomPaint(
                                painter: _CirclePainter(accent: colors.accent),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 34),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            _buildCounterBox(colors),
                            const SizedBox(width: 12),
                            _buildResetCircle(colors),
                          ],
                        ),
                        const SizedBox(height: 24),
                      ],
                    ),
                  ),
                ),
              ],
            ),

            // ---------- پاپ‌آپ انتخاب رنگ ----------
            if (_colorPickerOpen)
              Positioned(
                top: 56,
                right: size.width - panelWidth < 0 ? 12 : null,
                left: 12,
                child: _buildColorPicker(colors),
              ),

            // ---------- پرده تیره پشت منو ----------
            if (_menuOpen)
              Positioned.fill(
                child: GestureDetector(
                  onTap: () => setState(() => _menuOpen = false),
                  child: Container(color: Colors.black.withOpacity(0.35)),
                ),
              ),

            // ---------- پنل کشویی راست ----------
            AnimatedPositioned(
              duration: const Duration(milliseconds: 260),
              curve: Curves.easeOut,
              top: 0,
              bottom: 0,
              right: _menuOpen ? 0 : -panelWidth - 10,
              width: panelWidth < 170 ? 170 : panelWidth,
              child: _buildSideMenu(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTopBar(ThemeColors colors) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          GestureDetector(
            onTap: () => setState(() => _colorPickerOpen = !_colorPickerOpen),
            child: Container(
              width: 34,
              height: 34,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: colors.textColor.withOpacity(0.5), width: 1.4),
                gradient: const SweepGradient(
                  colors: [Colors.black, Colors.white, Color(0xFF0B6E4F), Colors.black],
                ),
              ),
            ),
          ),
          Text(
            'ذکر شمار',
            style: TextStyle(
              color: colors.textColor,
              fontSize: 16,
              fontWeight: FontWeight.w600,
              letterSpacing: 1,
            ),
          ),
          GestureDetector(
            onTap: () => setState(() => _menuOpen = !_menuOpen),
            child: Icon(Icons.menu, color: colors.textColor, size: 28),
          ),
        ],
      ),
    );
  }

  Widget _buildColorPicker(ThemeColors colors) {
    Widget swatch(AppThemeMode mode, Color color) {
      final isSelected = _themeMode == mode;
      return GestureDetector(
        onTap: () => _changeTheme(mode),
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 6),
          width: 34,
          height: 34,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
            border: Border.all(
              color: isSelected ? colors.accent : Colors.grey,
              width: isSelected ? 3 : 1,
            ),
          ),
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
      decoration: BoxDecoration(
        color: colors.boxFill,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: colors.boxBorder.withOpacity(0.4)),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.25), blurRadius: 10)],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          swatch(AppThemeMode.black, const Color(0xFF0B0B0B)),
          swatch(AppThemeMode.white, const Color(0xFFFAFAFA)),
          swatch(AppThemeMode.green, const Color(0xFF0B4A34)),
        ],
      ),
    );
  }

  Widget _buildCounterBox(ThemeColors colors) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 34, vertical: 14),
      decoration: BoxDecoration(
        color: colors.boxFill,
        borderRadius: BorderRadius.circular(26),
        border: Border.all(color: colors.boxBorder, width: 2),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.2), blurRadius: 12, offset: const Offset(0, 4)),
        ],
      ),
      child: Text(
        toFarsiDigits(_currentCount),
        style: TextStyle(
          color: colors.textColor,
          fontSize: 34,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildResetCircle(ThemeColors colors) {
    final bool isLightBg = _themeMode == AppThemeMode.white;
    final Color grayFill = isLightBg ? Colors.grey.shade300 : Colors.grey.shade700;
    final Color grayIcon = isLightBg ? Colors.grey.shade800 : Colors.grey.shade200;

    return Tooltip(
      message: 'صفر کردن',
      child: GestureDetector(
        onTap: _resetCount,
        child: Container(
          width: 46,
          height: 46,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: grayFill,
            border: Border.all(color: colors.boxBorder.withOpacity(0.5), width: 1.3),
            boxShadow: [
              BoxShadow(color: Colors.black.withOpacity(0.2), blurRadius: 8, offset: const Offset(0, 3)),
            ],
          ),
          child: Icon(Icons.refresh, size: 20, color: grayIcon),
        ),
      ),
    );
  }

  Widget _buildSideMenu() {
    return Container(
      decoration: const BoxDecoration(
        borderRadius: BorderRadius.horizontal(left: Radius.circular(22)),
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFF141414), Color(0xFF040404)],
        ),
        boxShadow: [
          BoxShadow(color: Colors.black54, blurRadius: 18, offset: Offset(-4, 0)),
        ],
      ),
      child: ClipRRect(
        borderRadius: const BorderRadius.horizontal(left: Radius.circular(22)),
        child: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(14, 18, 14, 10),
                child: Column(
                  children: [
                    const Icon(Icons.mosque, color: Color(0xFFD4AF37), size: 26),
                    const SizedBox(height: 6),
                    const Text(
                      'انتخاب ذکر',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ],
                ),
              ),
              Divider(color: Colors.white.withOpacity(0.12), height: 1, indent: 16, endIndent: 16),
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 10),
                  itemCount: zekrList.length,
                  itemBuilder: (context, index) {
                    final isSelected = index == _selectedZekr;
                    return GestureDetector(
                      onTap: () => _selectZekr(index),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        margin: const EdgeInsets.symmetric(vertical: 4),
                        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 10),
                        decoration: BoxDecoration(
                          gradient: isSelected
                              ? const LinearGradient(
                                  colors: [Color(0x33D4AF37), Color(0x11D4AF37)],
                                )
                              : null,
                          color: isSelected ? null : Colors.white.withOpacity(0.03),
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(
                            color: isSelected
                                ? const Color(0xFFD4AF37)
                                : Colors.white.withOpacity(0.08),
                            width: isSelected ? 1.2 : 1,
                          ),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              isSelected ? Icons.radio_button_checked : Icons.radio_button_off,
                              size: 14,
                              color: isSelected ? const Color(0xFFD4AF37) : Colors.white38,
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                zekrList[index].title,
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  color: isSelected ? const Color(0xFFD4AF37) : Colors.white,
                                  fontSize: 12.5,
                                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// -------------------- نقاشی دایره وسط --------------------
class _CirclePainter extends CustomPainter {
  final Color accent;
  const _CirclePainter({required this.accent});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;

    // سایه نرم
    final shadowPaint = Paint()
      ..color = Colors.black.withOpacity(0.25)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 18);
    canvas.drawCircle(center.translate(0, 6), 
