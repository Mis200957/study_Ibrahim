import 'dart:io';
import 'dart:math' as math;

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';

import 'study_store.dart';

const Color bg = Color(0xff020b20),
    card = Color(0xff071a38),
    edge = Color(0xff173d72),
    purple = Color(0xff7c3cff),
    cyan = Color(0xff25c5ff);
const colors = [
  Color(0xff9b6bff),
  Color(0xff32a7ff),
  Color(0xff36d399),
  Color(0xffffa24b),
  Color(0xffff69aa),
  Color(0xff35d5dc),
];
const icons = [
  Icons.menu_book_rounded,
  Icons.calculate_rounded,
  Icons.language_rounded,
  Icons.science_rounded,
  Icons.public_rounded,
  Icons.palette_rounded,
  Icons.music_note_rounded,
  Icons.code_rounded,
];

void main() => runApp(const SmartStudyApp());

class SmartStudyApp extends StatefulWidget {
  const SmartStudyApp({super.key});
  @override
  State<SmartStudyApp> createState() => _AppState();
}

class _AppState extends State<SmartStudyApp> {
  bool light = false, english = false;
  int accent = purple.value;
  String username = 'إبراهيم سامح', avatar = '';
  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final store = StudyStore.instance;
    if (!mounted) return;
    final values = await Future.wait([
      store.getSetting('light'),
      store.getSetting('english'),
      store.getSetting('name'),
      store.getSetting('avatar'),
      store.getSetting('accent'),
    ]);
    if (!mounted) return;
    setState(() {
      light = values[0] == 'true';
      english = values[1] == 'true';
      username = values[2] ?? username;
      avatar = values[3] ?? '';
      accent = int.tryParse(values[4] ?? '') ?? purple.value;
    });
  }

  Future<void> savePrefs() async {
    final store = StudyStore.instance;
    await store.setSetting('light', light.toString());
    await store.setSetting('english', english.toString());
    await store.setSetting('name', username);
    await store.setSetting('avatar', avatar);
    await store.setSetting('accent', accent.toString());
  }

  @override
  Widget build(BuildContext context) => MaterialApp(
    debugShowCheckedModeBanner: false,
    title: 'IBRAHIM SMART STUDY',
    theme: ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: light ? const Color(0xff101d37) : bg,
      colorScheme: ColorScheme.fromSeed(
        seedColor: Color(accent),
        brightness: Brightness.dark,
      ),
      fontFamily: 'Roboto',
    ),
    home: StudyHome(state: this),
  );
}

class StudyHome extends StatefulWidget {
  final _AppState state;
  const StudyHome({super.key, required this.state});
  @override
  State<StudyHome> createState() => _HomeState();
}

class _HomeState extends State<StudyHome> {
  int tab = 0;
  bool ready = false;
  String search = '';
  final store = StudyStore.instance;
  bool get en => widget.state.english;
  String tr(String ar, String english) => en ? english : ar;
  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(milliseconds: 900), () {
      if (mounted) setState(() => ready = true);
    });
  }

  Future<void> refresh() async {
    if (mounted) setState(() {});
  }

  void go(int i) {
    setState(() => tab = i);
  }

  @override
  Widget build(BuildContext context) {
    final app = widget.state;
    if (!ready)
      return Scaffold(
        backgroundColor: bg,
        body: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 110,
                height: 110,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: cyan, width: 2),
                  boxShadow: [
                    BoxShadow(color: purple.withOpacity(.45), blurRadius: 32),
                  ],
                ),
                child: const Icon(
                  Icons.workspace_premium_rounded,
                  size: 62,
                  color: Color(0xffffd56a),
                ),
              ),
              const SizedBox(height: 20),
              const Text(
                'IBRAHIM SMART STUDY',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 1.3,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                en ? 'Created for Ibrahim Sameh' : 'اصنع مستقبلك بخطوة كل يوم',
                style: TextStyle(
                  color: Colors.white.withOpacity(.7),
                  fontSize: 13,
                ),
              ),
              const SizedBox(height: 22),
              SizedBox(
                width: 160,
                child: LinearProgressIndicator(
                  color: cyan,
                  backgroundColor: edge,
                ),
              ),
            ],
          ),
        ),
      );
    final pages = [
      home(),
      subjectsPage(),
      tasksPage(),
      statsPage(),
      settingsPage(),
    ];
    return Directionality(
      textDirection: en ? TextDirection.ltr : TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: widget.state.light ? card : Colors.transparent,
          title: Text(
            'IBRAHIM SMART STUDY',
            style: TextStyle(
              fontSize: 15,
              letterSpacing: 1,
              fontWeight: FontWeight.w800,
              color: Theme.of(context).colorScheme.onSurface,
            ),
          ),
          leading: PopupMenuButton<String>(
            icon: const Icon(Icons.menu_rounded),
            onSelected: (v) {
              if (v == 'settings') go(4);
              if (v == 'motivation') showMotivation();
              if (v == 'notes') notesPage();
              if (v == 'schedule') schedulePage();
            },
            itemBuilder: (_) => [
              PopupMenuItem(
                value: 'settings',
                child: Text(tr('الإعدادات', 'Settings')),
              ),
              PopupMenuItem(
                value: 'notes',
                child: Text(tr('ملاحظاتي', 'My notes')),
              ),
              PopupMenuItem(
                value: 'schedule',
                child: Text(tr('جدول المذاكرة', 'Study plan')),
              ),
              PopupMenuItem(
                value: 'motivation',
                child: Text(tr('رسالة تحفيزية', 'Motivation')),
              ),
            ],
          ),
          actions: [
            IconButton(
              onPressed: () => go(4),
              icon: CircleAvatar(
                radius: 15,
                backgroundImage: app.avatar.isNotEmpty
                    ? FileImage(File(app.avatar))
                    : null,
                child: app.avatar.isEmpty
                    ? const Icon(Icons.person, size: 18)
                    : null,
              ),
            ),
          ],
        ),
        body: IndexedStack(index: tab, children: pages),
        bottomNavigationBar: NavigationBar(
          selectedIndex: tab,
          onDestinationSelected: go,
          backgroundColor: card,
          indicatorColor: purple.withOpacity(.28),
          destinations: [
            NavigationDestination(
              icon: Icon(Icons.home_rounded),
              label: tr('الرئيسية', 'Home'),
            ),
            NavigationDestination(
              icon: Icon(Icons.menu_book_rounded),
              label: tr('المواد', 'Subjects'),
            ),
            NavigationDestination(
              icon: Icon(Icons.checklist_rounded),
              label: tr('المهام', 'Tasks'),
            ),
            NavigationDestination(
              icon: Icon(Icons.insights_rounded),
              label: tr('إحصائيات', 'Stats'),
            ),
            NavigationDestination(
              icon: Icon(Icons.settings_rounded),
              label: tr('الإعدادات', 'Settings'),
            ),
          ],
        ),
      ),
    );
  }

  Widget home() => FutureBuilder<List<Map<String, Object?>>>(
    future: store.subjects(),
    builder: (c, s) {
      final subjects = s.data ?? [];
      return _scroll(
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _hero(),
            const SizedBox(height: 24),
            _title(
              tr(
                'ماذا تريد أن تفعل اليوم؟',
                'What would you like to do today?',
              ),
            ),
            const SizedBox(height: 12),
            GridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: 2,
              mainAxisSpacing: 12,
              crossAxisSpacing: 12,
              childAspectRatio: 1.15,
              children: [
                _action(
                  Icons.menu_book_rounded,
                  tr('المواد الدراسية', 'Subjects'),
                  tr('تابع تقدمك في كل مادة', 'Track every subject'),
                  colors[0],
                  () => go(1),
                ),
                _action(
                  Icons.task_alt_rounded,
                  tr('المهام اليومية', 'Daily tasks'),
                  tr('أنجز خطتك اليوم', 'Get things done'),
                  colors[1],
                  () => go(2),
                ),
                _action(
                  Icons.insights_rounded,
                  tr('إحصائياتك', 'Your stats'),
                  tr('شاهد تقدمك الحقيقي', 'See your progress'),
                  colors[2],
                  () => go(3),
                ),
                _action(
                  Icons.settings_rounded,
                  tr('الإعدادات', 'Settings'),
                  tr('خصص تجربتك', 'Personalize your app'),
                  colors[3],
                  () => go(4),
                ),
              ],
            ),
            const SizedBox(height: 25),
            _title(tr('موادك الحالية', 'Your subjects')),
            const SizedBox(height: 10),
            if (subjects.isEmpty)
              _empty(
                tr(
                  'أضف أول مادة لتبدأ رحلتك',
                  'Add your first subject to get started',
                ),
                Icons.auto_stories_rounded,
              )
            else
              ...subjects.take(3).map((s) => _subjectTile(s, compact: true)),
            const SizedBox(height: 12),
            _motivationCard(),
          ],
        ),
      );
    },
  );

  Widget _hero() => Container(
    width: double.infinity,
    padding: const EdgeInsets.all(20),
    decoration: BoxDecoration(
      borderRadius: BorderRadius.circular(24),
      gradient: const LinearGradient(
        colors: [Color(0xff122b59), Color(0xff25104e)],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
      border: Border.all(color: edge),
    ),
    child: Row(
      children: [
        CircleAvatar(
          radius: 31,
          backgroundColor: purple.withOpacity(.35),
          backgroundImage: widget.state.avatar.isNotEmpty
              ? FileImage(File(widget.state.avatar))
              : null,
          child: widget.state.avatar.isEmpty
              ? const Icon(Icons.person_rounded, size: 34, color: Colors.white)
              : null,
        ),
        const SizedBox(width: 15),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                tr('أهلًا بعودتك،', 'Welcome back,'),
                style: TextStyle(color: Colors.white.withOpacity(.74)),
              ),
              Text(
                widget.state.username,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 5),
              Text(
                tr(
                  'خطوة صغيرة اليوم تصنع فرقًا كبيرًا غدًا ✨',
                  'Small steps today make a brighter tomorrow ✨',
                ),
                style: TextStyle(
                  color: Colors.white.withOpacity(.84),
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ),
        const Icon(Icons.auto_awesome, color: Color(0xffffd56a), size: 27),
      ],
    ),
  );
  Widget _action(
    IconData i,
    String title,
    String desc,
    Color color,
    VoidCallback onTap,
  ) => InkWell(
    onTap: onTap,
    borderRadius: BorderRadius.circular(20),
    child: Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: card,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: edge),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(i, color: color, size: 27),
          const Spacer(),
          Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 4),
          Text(
            desc,
            style: TextStyle(color: Colors.grey[500], fontSize: 11),
            maxLines: 2,
          ),
        ],
      ),
    ),
  );
  Widget _motivationCard() => InkWell(
    onTap: showMotivation,
    borderRadius: BorderRadius.circular(20),
    child: Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        gradient: const LinearGradient(
          colors: [Color(0xff111f42), Color(0xff31195c)],
        ),
        border: Border.all(color: edge),
      ),
      child: Row(
        children: [
          const Icon(
            Icons.nights_stay_rounded,
            color: Color(0xffffd56a),
            size: 30,
          ),
          const SizedBox(width: 13),
          Expanded(
            child: Text(
              tr(
                'لا تتوقف لأنك لم تصل بعد، فأنت أقرب مما تتخيل.',
                'Keep going. You are closer than you think.',
              ),
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
          ),
          const Icon(Icons.arrow_forward_ios_rounded, size: 15, color: cyan),
        ],
      ),
    ),
  );

  Widget subjectsPage() => FutureBuilder<List<Map<String, Object?>>>(
    future: store.subjects(),
    builder: (c, s) {
      final rows = (s.data ?? [])
          .where(
            (x) => x['name'].toString().toLowerCase().contains(
              search.toLowerCase(),
            ),
          )
          .toList();
      return _scroll(
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(child: _title(tr('المواد الدراسية', 'Subjects'))),
                IconButton.filled(
                  onPressed: () => subjectForm(),
                  icon: const Icon(Icons.add_rounded),
                ),
              ],
            ),
            const SizedBox(height: 8),
            _searchBox(),
            const SizedBox(height: 12),
            if (rows.isEmpty)
              _empty(
                tr(
                  'لا توجد مواد بعد. أضف مادة جديدة.',
                  'No subjects yet. Add one to begin.',
                ),
                Icons.library_books_rounded,
              )
            else
              ...rows.map((r) => _subjectTile(r)),
          ],
        ),
      );
    },
  );
  Widget _subjectTile(Map<String, Object?> s, {bool compact = false}) {
    final id = s['id'] as int;
    final color = Color(s['color'] as int);
    return FutureBuilder<List<Map<String, Object?>>>(
      future: store.lessons(id),
      builder: (c, l) {
        final lessons = l.data ?? [];
        final done = lessons.where((x) => x['done'] == 1).length;
        final pct = lessons.isEmpty ? 0 : done / lessons.length;
        return Card(
          color: card,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(19),
            side: BorderSide(color: edge.withOpacity(.85)),
          ),
          margin: const EdgeInsets.only(bottom: 11),
          child: InkWell(
            borderRadius: BorderRadius.circular(19),
            onTap: () => subjectDetails(s),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: color.withOpacity(.17),
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: Icon(
                      IconData(s['icon'] as int, fontFamily: 'MaterialIcons'),
                      color: color,
                    ),
                  ),
                  const SizedBox(width: 13),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          s['name'].toString(),
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        const SizedBox(height: 3),
                        Text(
                          '$done / ${lessons.length} ${tr('درس مكتمل', 'lessons complete')}  •  ${(pct * 100).round()}%',
                          style: TextStyle(
                            color: Colors.grey[500],
                            fontSize: 11,
                          ),
                        ),
                        const SizedBox(height: 9),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: LinearProgressIndicator(
                            value: pct,
                            minHeight: 6,
                            backgroundColor: edge,
                            valueColor: AlwaysStoppedAnimation(color),
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (!compact) const SizedBox(width: 5),
                  if (!compact) Icon(Icons.chevron_right, color: color),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget tasksPage() => FutureBuilder<List<Map<String, Object?>>>(
    future: store.tasks(),
    builder: (c, s) {
      final rows = s.data ?? [];
      return _scroll(
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(child: _title(tr('المهام اليومية', 'Daily tasks'))),
                IconButton.filled(
                  onPressed: addTask,
                  icon: const Icon(Icons.add),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              tr(
                'خطط يومك وأنجزه خطوة بخطوة.',
                'Plan your day and make progress.',
              ),
              style: TextStyle(color: Colors.grey[500]),
            ),
            const SizedBox(height: 16),
            if (rows.isEmpty)
              _empty(
                tr(
                  'لا توجد مهام. أضف مهمتك الأولى.',
                  'No tasks yet. Add your first task.',
                ),
                Icons.checklist_rounded,
              )
            else
              ...rows.map(
                (t) => Card(
                  color: card,
                  child: CheckboxListTile(
                    value: t['done'] == 1,
                    title: Text(
                      t['title'].toString(),
                      style: TextStyle(
                        decoration: t['done'] == 1
                            ? TextDecoration.lineThrough
                            : null,
                      ),
                    ),
                    subtitle: t['due'] == null
                        ? null
                        : Text(t['due'].toString().substring(0, 10)),
                    secondary: IconButton(
                      onPressed: () async {
                        await store.deleteTask(t['id'] as int);
                        refresh();
                      },
                      icon: const Icon(
                        Icons.delete_outline,
                        color: Colors.redAccent,
                      ),
                    ),
                    onChanged: (v) async {
                      await store.toggleTask(t['id'] as int, v ?? false);
                      if (v == true) await store.recordStudy(1);
                      refresh();
                    },
                  ),
                ),
              ),
          ],
        ),
      );
    },
  );

  Widget statsPage() => FutureBuilder<Map<String, dynamic>>(
    future: store.stats(),
    builder: (c, s) {
      if (!s.hasData) return const Center(child: CircularProgressIndicator());
      final d = s.data!;
      final rows = List<Map<String, Object?>>.from(d['subjects'] as List);
      final total = d['total'] as int, done = d['done'] as int;
      final pct = total == 0 ? 0.0 : done / total;
      final best = rows.isEmpty ? null : rows.first;
      return _scroll(
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _title(tr('إحصائياتك', 'Your statistics')),
            const SizedBox(height: 20),
            Center(
              child: SizedBox(
                width: 190,
                height: 190,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    SizedBox.expand(
                      child: CircularProgressIndicator(
                        value: pct,
                        strokeWidth: 13,
                        backgroundColor: edge,
                        valueColor: const AlwaysStoppedAnimation(cyan),
                        strokeCap: StrokeCap.round,
                      ),
                    ),
                    Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          '${(pct * 100).round()}%',
                          style: const TextStyle(
                            fontSize: 38,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        Text(
                          tr('إنجاز الدروس', 'Lesson progress'),
                          style: TextStyle(
                            color: Colors.grey[500],
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: _statCard(
                    Icons.check_circle_outline,
                    '$done / $total',
                    tr('دروس مكتملة', 'Lessons done'),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _statCard(
                    Icons.local_fire_department_rounded,
                    '${d['days']}',
                    tr('أيام مذاكرة', 'Study days'),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            _statCard(
              Icons.emoji_events_rounded,
              best == null ? '—' : best['name'].toString(),
              tr('الأكثر تقدمًا', 'Top subject'),
              full: true,
            ),
            const SizedBox(height: 23),
            _title(tr('التقدم حسب المادة', 'Progress by subject')),
            const SizedBox(height: 12),
            if (rows.isEmpty)
              _empty(
                tr(
                  'أضف مواد ودروسًا لعرض إحصائياتك.',
                  'Add subjects and lessons to see your stats.',
                ),
                Icons.insights_rounded,
              )
            else
              ...rows.map((r) {
                final n = (r['total'] as int);
                final dn = (r['done'] as int);
                final val = n == 0 ? 0.0 : dn / n;
                final co = Color(r['color'] as int);
                return Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  padding: const EdgeInsets.all(15),
                  decoration: BoxDecoration(
                    color: card,
                    borderRadius: BorderRadius.circular(17),
                    border: Border.all(color: edge),
                  ),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              r['name'].toString(),
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          Text(
                            '$dn / $n  ${(val * 100).round()}%',
                            style: TextStyle(color: co, fontSize: 12),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      LinearProgressIndicator(
                        value: val,
                        minHeight: 6,
                        backgroundColor: edge,
                        valueColor: AlwaysStoppedAnimation(co),
                      ),
                    ],
                  ),
                );
              }),
          ],
        ),
      );
    },
  );

  Widget settingsPage() => _scroll(
    Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _title(tr('الإعدادات', 'Settings')),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: card,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: edge),
          ),
          child: Row(
            children: [
              CircleAvatar(
                radius: 30,
                backgroundImage: widget.state.avatar.isNotEmpty
                    ? FileImage(File(widget.state.avatar))
                    : null,
                child: widget.state.avatar.isEmpty
                    ? const Icon(Icons.person, size: 30)
                    : null,
              ),
              const SizedBox(width: 13),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.state.username,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 17,
                      ),
                    ),
                    Text(
                      tr('ملفك الشخصي', 'Your profile'),
                      style: TextStyle(color: Colors.grey[500]),
                    ),
                  ],
                ),
              ),
              IconButton(
                onPressed: editProfile,
                icon: const Icon(Icons.edit_outlined, color: cyan),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        SwitchListTile(
          secondary: const Icon(Icons.dark_mode_outlined, color: purple),
          title: Text(tr('خلفية أفتح', 'Lighter background')),
          value: widget.state.light,
          onChanged: (v) async {
            widget.state.setState(() => widget.state.light = v);
            await widget.state.savePrefs();
          },
        ),
        ListTile(
          leading: const Icon(Icons.language, color: cyan),
          title: Text(tr('اللغة', 'Language')),
          subtitle: Text(en ? 'English' : 'العربية'),
          trailing: const Icon(Icons.chevron_right),
          onTap: () async {
            widget.state.setState(() => widget.state.english = !en);
            await widget.state.savePrefs();
          },
        ),
        ListTile(
          leading: const Icon(Icons.color_lens_outlined, color: purple),
          title: Text(tr('لون الواجهة', 'Accent color')),
          subtitle: Text(tr('اختر لونك المفضل', 'Choose your accent')),
          onTap: () => showDialog(
            context: context,
            builder: (_) => AlertDialog(
              title: Text(tr('اختر لونًا', 'Choose a color')),
              content: Wrap(
                spacing: 12,
                children: colors
                    .map(
                      (x) => InkWell(
                        onTap: () {
                          widget.state.setState(
                            () => widget.state.accent = x.value,
                          );
                          widget.state.savePrefs();
                          Navigator.pop(context);
                        },
                        child: CircleAvatar(
                          backgroundColor: x,
                          child: widget.state.accent == x.value
                              ? const Icon(Icons.check, color: Colors.white)
                              : null,
                        ),
                      ),
                    )
                    .toList(),
              ),
            ),
          ),
        ),
        const Divider(),
        ListTile(
          leading: const Icon(Icons.backup_outlined, color: cyan),
          title: Text(tr('نسخ احتياطي للبيانات', 'Back up data')),
          onTap: backup,
        ),
        ListTile(
          leading: const Icon(Icons.restore_rounded, color: purple),
          title: Text(tr('استعادة نسخة احتياطية', 'Restore backup')),
          onTap: restore,
        ),
        ListTile(
          leading: const Icon(Icons.info_outline, color: Colors.amber),
          title: Text(tr('عن التطبيق', 'About')),
          subtitle: const Text(
            'IBRAHIM SMART STUDY • Created for Ibrahim Sameh',
          ),
        ),
      ],
    ),
  );

  Widget _statCard(
    IconData icon,
    String value,
    String label, {
    bool full = false,
  }) => Container(
    width: full ? double.infinity : null,
    padding: const EdgeInsets.all(15),
    decoration: BoxDecoration(
      color: card,
      borderRadius: BorderRadius.circular(18),
      border: Border.all(color: edge),
    ),
    child: Row(
      children: [
        Icon(icon, color: cyan),
        const SizedBox(width: 11),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                value,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              Text(
                label,
                style: TextStyle(color: Colors.grey[500], fontSize: 11),
              ),
            ],
          ),
        ),
      ],
    ),
  );
  Widget _title(String s) => Text(
    s,
    style: const TextStyle(fontSize: 21, fontWeight: FontWeight.w800),
  );
  Widget _searchBox() => TextField(
    onChanged: (v) => setState(() => search = v),
    decoration: InputDecoration(
      hintText: tr('ابحث عن مادة...', 'Search subjects...'),
      prefixIcon: const Icon(Icons.search),
      filled: true,
      fillColor: card,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide(color: edge),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide(color: edge),
      ),
    ),
  );
  Widget _scroll(Widget w) => SafeArea(
    child: SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(18, 12, 18, 26),
      child: w,
    ),
  );
  Widget _empty(String text, IconData i) => Container(
    width: double.infinity,
    padding: const EdgeInsets.symmetric(vertical: 35, horizontal: 20),
    decoration: BoxDecoration(
      color: card,
      borderRadius: BorderRadius.circular(20),
      border: Border.all(color: edge),
    ),
    child: Column(
      children: [
        Icon(i, size: 35, color: cyan),
        const SizedBox(height: 9),
        Text(
          text,
          textAlign: TextAlign.center,
          style: TextStyle(color: Colors.grey[400]),
        ),
      ],
    ),
  );

  Future<void> subjectForm([Map<String, Object?>? old]) async {
    final name = TextEditingController(text: old?['name']?.toString() ?? '');
    final memo = TextEditingController(text: old?['notes']?.toString() ?? '');
    int color = old?['color'] as int? ?? colors[0].value;
    int icon = old?['icon'] as int? ?? icons[0].codePoint;
    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: card,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, ss) => Padding(
          padding: EdgeInsets.fromLTRB(
            20,
            20,
            20,
            MediaQuery.of(ctx).viewInsets.bottom + 24,
          ),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  tr('إضافة مادة جديدة', 'Add a subject'),
                  style: const TextStyle(
                    fontSize: 21,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: name,
                  decoration: InputDecoration(
                    labelText: tr('اسم المادة', 'Subject name'),
                    hintText: tr('مثل: الرياضيات', 'e.g. Mathematics'),
                  ),
                ),
                const SizedBox(height: 15),
                Text(tr('اختر اللون', 'Choose a color')),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 10,
                  children: colors
                      .map(
                        (c) => InkWell(
                          onTap: () => ss(() => color = c.value),
                          child: CircleAvatar(
                            backgroundColor: c,
                            child: color == c.value
                                ? const Icon(Icons.check, color: Colors.white)
                                : null,
                          ),
                        ),
                      )
                      .toList(),
                ),
                const SizedBox(height: 15),
                Text(tr('اختر أيقونة', 'Choose an icon')),
                Wrap(
                  spacing: 8,
                  children: icons
                      .map(
                        (i) => IconButton.filledTonal(
                          onPressed: () => ss(() => icon = i.codePoint),
                          style: IconButton.styleFrom(
                            backgroundColor: icon == i.codePoint
                                ? purple.withOpacity(.5)
                                : null,
                          ),
                          icon: Icon(i),
                        ),
                      )
                      .toList(),
                ),
                TextField(
                  controller: memo,
                  maxLines: 2,
                  decoration: InputDecoration(
                    labelText: tr('ملاحظات اختيارية', 'Optional notes'),
                  ),
                ),
                const SizedBox(height: 18),
                _gradientButton(
                  old == null
                      ? tr('إضافة المادة', 'Add subject')
                      : tr('حفظ التعديلات', 'Save changes'),
                  () async {
                    if (name.text.trim().isEmpty) return;
                    if (old == null) {
                      await store.addSubject(
                        name.text.trim(),
                        color,
                        icon,
                        memo.text.trim(),
                      );
                    } else {
                      await store.updateSubject(
                        old['id'] as int,
                        name.text.trim(),
                        color,
                        icon,
                        memo.text.trim(),
                      );
                    }
                    if (ctx.mounted) Navigator.pop(ctx);
                    refresh();
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _gradientButton(String text, VoidCallback onTap) => SizedBox(
    width: double.infinity,
    height: 52,
    child: DecoratedBox(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        gradient: const LinearGradient(colors: [purple, Color(0xff4d74ff)]),
      ),
      child: ElevatedButton(
        onPressed: onTap,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          shadowColor: Colors.transparent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
        child: Text(
          text,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    ),
  );

  Future<void> subjectDetails(Map<String, Object?> subject) async {
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: bg,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, ss) => SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(18),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    CircleAvatar(
                      backgroundColor: Color(subject['color'] as int)
                          .withOpacity(.18),
                      child: Icon(
                        IconData(
                          subject['icon'] as int,
                          fontFamily: 'MaterialIcons',
                        ),
                        color: Color(subject['color'] as int),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        subject['name'].toString(),
                        style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    IconButton(
                      onPressed: () {
                        Navigator.pop(ctx);
                        subjectForm(subject);
                      },
                      icon: const Icon(Icons.edit_outlined),
                    ),
                    IconButton(
                      onPressed: () async {
                        final ok = await confirm(
                          tr(
                            'حذف المادة وكل دروسها؟',
                            'Delete this subject and its lessons?',
                          ),
                        );
                        if (ok) {
                          await store.deleteSubject(subject['id'] as int);
                          if (ctx.mounted) Navigator.pop(ctx);
                          refresh();
                        }
                      },
                      icon: const Icon(
                        Icons.delete_outline,
                        color: Colors.redAccent,
                      ),
                    ),
                  ],
                ),
                if ((subject['notes'] ?? '').toString().isNotEmpty)
                  Text(
                    subject['notes'].toString(),
                    style: TextStyle(color: Colors.grey[500]),
                  ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        tr('الدروس', 'Lessons'),
                        style: const TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    IconButton.filled(
                      onPressed: () => lessonForm(subject, ss),
                      icon: const Icon(Icons.add),
                    ),
                  ],
                ),
                SizedBox(
                  height: 320,
                  child: FutureBuilder<List<Map<String, Object?>>>(
                    future: store.lessons(subject['id'] as int),
                    builder: (c, snap) {
                      final items = snap.data ?? <Map<String, Object?>>[];
                      return ListView.builder(
                        itemCount: items.length,
                        itemBuilder: (context, index) {
                          final lesson = items[index];
                          return Card(
                            color: card,
                            child: ListTile(
                              leading: Checkbox(
                                value: lesson['done'] == 1,
                                onChanged: (v) async {
                                  lesson['done'] = v == true ? 1 : 0;
                                  await store.updateLesson(lesson);
                                  if (v == true) await store.recordStudy(15);
                                  ss(() {});
                                  refresh();
                                },
                              ),
                              title: Text(lesson['title'].toString()),
                              subtitle: Text(
                                lesson['summary'].toString(),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              onTap: () => lessonDetails(subject, lesson, ss),
                              trailing: IconButton(
                                onPressed: () =>
                                    lessonForm(subject, ss, lesson),
                                icon: const Icon(Icons.edit_outlined),
                              ),
                            ),
                          );
                        },
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> lessonForm(
    Map<String, Object?> subject,
    StateSetter update, [
    Map<String, Object?>? old,
  ]) async {
    final title = TextEditingController(text: old?['title']?.toString() ?? '');
    final summary = TextEditingController(
      text: old?['summary']?.toString() ?? '',
    );
    await showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(
          old == null
              ? tr('إضافة درس', 'Add lesson')
              : tr('تعديل الدرس', 'Edit lesson'),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: title,
              decoration: InputDecoration(
                labelText: tr('عنوان الدرس', 'Lesson title'),
              ),
            ),
            TextField(
              controller: summary,
              maxLines: 4,
              decoration: InputDecoration(
                labelText: tr('ملخص الدرس', 'Lesson summary'),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(tr('إلغاء', 'Cancel')),
          ),
          FilledButton(
            onPressed: () async {
              if (title.text.trim().isEmpty) return;
              if (old == null) {
                await store.addLesson(
                  subject['id'] as int,
                  title.text.trim(),
                  summary.text.trim(),
                );
              } else {
                old['title'] = title.text.trim();
                old['summary'] = summary.text.trim();
                await store.updateLesson(old);
              }
              if (ctx.mounted) Navigator.pop(ctx);
              update(() {});
              refresh();
            },
            child: Text(tr('حفظ', 'Save')),
          ),
        ],
      ),
    );
  }

  Future<void> lessonDetails(
    Map<String, Object?> subject,
    Map<String, Object?> lesson,
    StateSetter update,
  ) async {
    await showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(lesson['title'].toString()),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  IconData(subject['icon'] as int, fontFamily: 'MaterialIcons'),
                  color: Color(subject['color'] as int),
                ),
                const SizedBox(width: 8),
                Text(subject['name'].toString()),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              tr('ملخص الدرس', 'Lesson summary'),
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 6),
            Text(
              (lesson['summary'] ?? '').toString().isEmpty
                  ? tr('لا يوجد ملخص بعد.', 'No summary yet.')
                  : lesson['summary'].toString(),
            ),
            const SizedBox(height: 14),
            Chip(
              label: Text(
                lesson['done'] == 1
                    ? tr('مكتمل', 'Completed')
                    : tr('غير مكتمل', 'Not completed'),
              ),
              avatar: Icon(
                lesson['done'] == 1 ? Icons.check_circle : Icons.timelapse,
                color: cyan,
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              lessonForm(subject, update, lesson);
            },
            child: Text(tr('تعديل', 'Edit')),
          ),
          TextButton(
            onPressed: () async {
              final ok = await confirm(
                tr('حذف هذا الدرس؟', 'Delete this lesson?'),
              );
              if (ok) {
                await store.deleteLesson(lesson['id'] as int);
                if (ctx.mounted) Navigator.pop(ctx);
                update(() {});
                refresh();
              }
            },
            child: Text(
              tr('حذف', 'Delete'),
              style: const TextStyle(color: Colors.redAccent),
            ),
          ),
          FilledButton(
            onPressed: () async {
              lesson['done'] = lesson['done'] == 1 ? 0 : 1;
              await store.updateLesson(lesson);
              if (lesson['done'] == 1) await store.recordStudy(15);
              if (ctx.mounted) Navigator.pop(ctx);
              update(() {});
              refresh();
            },
            child: Text(
              lesson['done'] == 1
                  ? tr('إلغاء الإكمال', 'Mark incomplete')
                  : tr('تحديد كمكتمل', 'Mark complete'),
            ),
          ),
        ],
      ),
    );
  }

  Future<bool> confirm(String text) async =>
      await showDialog<bool>(
        context: context,
        builder: (ctx) => AlertDialog(
          content: Text(text),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: Text(tr('إلغاء', 'Cancel')),
            ),
            FilledButton(
              onPressed: () => Navigator.pop(ctx, true),
              child: Text(tr('حذف', 'Delete')),
            ),
          ],
        ),
      ) ??
      false;
  Future<void> addTask() async {
    final c = TextEditingController();
    DateTime? date;
    await showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, ss) => AlertDialog(
          title: Text(tr('مهمة جديدة', 'New task')),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: c,
                decoration: InputDecoration(
                  labelText: tr('اسم المهمة', 'Task name'),
                ),
              ),
              TextButton.icon(
                onPressed: () async {
                  final d = await showDatePicker(
                    context: ctx,
                    firstDate: DateTime.now(),
                    lastDate: DateTime.now().add(const Duration(days: 365)),
                    initialDate: DateTime.now(),
                  );
                  if (d != null) ss(() => date = d);
                },
                icon: const Icon(Icons.calendar_month),
                label: Text(
                  date == null
                      ? tr('اختيار موعد اختياري', 'Optional due date')
                      : date!.toIso8601String().substring(0, 10),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: Text(tr('إلغاء', 'Cancel')),
            ),
            FilledButton(
              onPressed: () async {
                if (c.text.trim().isNotEmpty)
                  await store.addTask(c.text.trim(), date);
                if (ctx.mounted) Navigator.pop(ctx);
                refresh();
              },
              child: Text(tr('إضافة', 'Add')),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> editProfile() async {
    final c = TextEditingController(text: widget.state.username);
    await showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(tr('تعديل الملف الشخصي', 'Edit profile')),
        content: TextField(
          controller: c,
          decoration: InputDecoration(labelText: tr('الاسم', 'Name')),
        ),
        actions: [
          TextButton(
            onPressed: () async {
              final x = await FilePicker.platform.pickFiles(
                type: FileType.image,
              );
              if (x?.files.single.path != null) {
                final docs = await getApplicationDocumentsDirectory();
                final source = File(x!.files.single.path!);
                final extension = source.path.contains('.')
                    ? source.path.substring(source.path.lastIndexOf('.'))
                    : '.jpg';
                final destination = File(
                  '${docs.path}/profile_image$extension',
                );
                await source.copy(destination.path);
                widget.state.setState(
                  () => widget.state.avatar = destination.path,
                );
                await widget.state.savePrefs();
              }
            },
            child: Text(tr('اختيار صورة', 'Choose photo')),
          ),
          FilledButton(
            onPressed: () async {
              if (c.text.trim().isEmpty) return;
              widget.state.setState(
                () => widget.state.username = c.text.trim(),
              );
              await widget.state.savePrefs();
              if (ctx.mounted) Navigator.pop(ctx);
            },
            child: Text(tr('حفظ', 'Save')),
          ),
        ],
      ),
    );
  }

  Future<void> backup() async {
    try {
      final file = await store.exportBackup();
      final destination = await FilePicker.platform.saveFile(
        dialogTitle: tr('حفظ النسخة الاحتياطية', 'Save backup'),
        fileName: 'ibrahim_study_backup.json',
        bytes: await file.readAsBytes(),
      );
      if (destination == null) return;
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            tr('تم حفظ النسخة الاحتياطية', 'Backup saved successfully'),
          ),
        ),
      );
    } catch (e) {
      message(e.toString());
    }
  }

  Future<void> restore() async {
    final pick = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['json'],
    );
    if (pick?.files.single.path == null) return;
    final ok = await confirm(
      tr(
        'ستستبدل الاستعادة بياناتك الحالية. متابعة؟',
        'Restoring replaces current data. Continue?',
      ),
    );
    if (!ok) return;
    try {
      await store.importBackup(File(pick!.files.single.path!));
      refresh();
      message(tr('تمت استعادة البيانات', 'Backup restored'));
    } catch (e) {
      message('${tr('تعذر الاستعادة', 'Restore failed')}: $e');
    }
  }

  void message(String m) =>
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(m)));

  Future<void> notesPage() async {
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: bg,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, ss) => SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(18),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        tr('ملاحظاتي', 'My notes'),
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 21,
                        ),
                      ),
                    ),
                    IconButton.filled(
                      onPressed: () => addNote(ss),
                      icon: const Icon(Icons.add),
                    ),
                  ],
                ),
                Flexible(
                  child: FutureBuilder<List<Map<String, Object?>>>(
                    future: store.notes(),
                    builder: (c, snap) => ListView(
                      shrinkWrap: true,
                      children: (snap.data ?? [])
                          .map(
                            (note) => Card(
                              color: card,
                              child: ListTile(
                                title: Text(note['title'].toString()),
                                subtitle: Text(
                                  note['body'].toString(),
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                trailing: IconButton(
                                  icon: const Icon(Icons.delete_outline),
                                  onPressed: () async {
                                    await store.deleteNote(note['id'] as int);
                                    ss(() {});
                                  },
                                ),
                              ),
                            ),
                          )
                          .toList(),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> addNote(StateSetter update) async {
    final title = TextEditingController(), body = TextEditingController();
    await showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(tr('ملاحظة جديدة', 'New note')),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: title,
              decoration: InputDecoration(labelText: tr('العنوان', 'Title')),
            ),
            TextField(
              controller: body,
              maxLines: 4,
              decoration: InputDecoration(labelText: tr('الملاحظة', 'Note')),
            ),
          ],
        ),
        actions: [
          FilledButton(
            onPressed: () async {
              if (title.text.trim().isNotEmpty)
                await store.addNote(title.text.trim(), body.text.trim());
              if (ctx.mounted) Navigator.pop(ctx);
              update(() {});
            },
            child: Text(tr('حفظ', 'Save')),
          ),
        ],
      ),
    );
  }

  Future<void> schedulePage() async {
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: bg,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, update) => SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(18),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        tr('جدول المذاكرة', 'Study plan'),
                        style: const TextStyle(
                          fontSize: 21,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    IconButton.filled(
                      onPressed: () => scheduleForm(update),
                      icon: const Icon(Icons.add),
                    ),
                  ],
                ),
                SizedBox(
                  height: 320,
                  child: FutureBuilder<List<Map<String, Object?>>>(
                    future: store.schedule(),
                    builder: (context, snap) {
                      final items = snap.data ?? <Map<String, Object?>>[];
                      if (items.isEmpty)
                        return Center(
                          child: Text(
                            tr(
                              'لا توجد جلسات مجدولة. أضف خطتك الأولى.',
                              'No sessions planned. Add your first study block.',
                            ),
                          ),
                        );
                      return ListView.builder(
                        itemCount: items.length,
                        itemBuilder: (context, index) {
                          final row = items[index];
                          final starts = DateTime.parse(
                            row['starts_at'].toString(),
                          );
                          return Card(
                            color: card,
                            child: ListTile(
                              leading: const Icon(
                                Icons.event_available_rounded,
                                color: cyan,
                              ),
                              title: Text(row['topic'].toString()),
                              subtitle: Text(
                                '${starts.toLocal().toString().substring(0, 16)} • ${row['duration']} ${tr('دقيقة', 'min')}',
                              ),
                              trailing: IconButton(
                                icon: const Icon(Icons.delete_outline),
                                onPressed: () async {
                                  await store.deleteSchedule(row['id'] as int);
                                  update(() {});
                                },
                              ),
                            ),
                          );
                        },
                      );
                    },
                  ),
                ),
                const SizedBox(height: 8),
                OutlinedButton.icon(
                  onPressed: () => studySessionDialog(),
                  icon: const Icon(Icons.timer_outlined),
                  label: Text(tr('تسجيل جلسة مكتملة', 'Log completed session')),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> scheduleForm(StateSetter update) async {
    final subjects = await store.subjects();
    final topic = TextEditingController();
    final duration = TextEditingController(text: '30');
    int? subjectId;
    DateTime starts = DateTime.now().add(const Duration(hours: 1));
    await showDialog<void>(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialog) => AlertDialog(
          title: Text(tr('إضافة جلسة مذاكرة', 'Add study block')),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: topic,
                  decoration: InputDecoration(
                    labelText: tr(
                      'الموضوع أو عنوان الجلسة',
                      'Topic or session title',
                    ),
                  ),
                ),
                DropdownButtonFormField<int?>(
                  value: subjectId,
                  decoration: InputDecoration(
                    labelText: tr('المادة', 'Subject (optional)'),
                  ),
                  items: [
                    DropdownMenuItem<int?>(
                      value: null,
                      child: Text(tr('بدون مادة', 'No subject')),
                    ),
                    ...subjects.map(
                      (s) => DropdownMenuItem<int?>(
                        value: s['id'] as int,
                        child: Text(s['name'].toString()),
                      ),
                    ),
                  ],
                  onChanged: (v) => setDialog(() => subjectId = v),
                ),
                TextField(
                  controller: duration,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    labelText: tr('المدة بالدقائق', 'Duration in minutes'),
                  ),
                ),
                TextButton.icon(
                  onPressed: () async {
                    final day = await showDatePicker(
                      context: ctx,
                      firstDate: DateTime.now(),
                      lastDate: DateTime.now().add(const Duration(days: 365)),
                      initialDate: starts,
                    );
                    if (day == null || !ctx.mounted) return;
                    final time = await showTimePicker(
                      context: ctx,
                      initialTime: TimeOfDay.fromDateTime(starts),
                    );
                    if (time != null)
                      setDialog(
                        () => starts = DateTime(
                          day.year,
                          day.month,
                          day.day,
                          time.hour,
                          time.minute,
                        ),
                      );
                  },
                  icon: const Icon(Icons.calendar_month),
                  label: Text(starts.toLocal().toString().substring(0, 16)),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: Text(tr('إلغاء', 'Cancel')),
            ),
            FilledButton(
              onPressed: () async {
                if (topic.text.trim().isEmpty) return;
                await store.addSchedule(
                  subjectId,
                  topic.text.trim(),
                  starts,
                  math.max(1, int.tryParse(duration.text) ?? 30).toInt(),
                );
                if (ctx.mounted) Navigator.pop(ctx);
                update(() {});
              },
              child: Text(tr('حفظ الموعد', 'Save plan')),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> studySessionDialog() async {
    final mins = TextEditingController(text: '25');
    await showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(tr('جلسة مذاكرة مكتملة', 'Completed study session')),
        content: TextField(
          controller: mins,
          keyboardType: TextInputType.number,
          decoration: InputDecoration(
            labelText: tr('المدة بالدقائق', 'Duration in minutes'),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(tr('إلغاء', 'Cancel')),
          ),
          FilledButton(
            onPressed: () async {
              await store.recordStudy(
                math.max(1, int.tryParse(mins.text) ?? 25).toInt(),
              );
              if (ctx.mounted) Navigator.pop(ctx);
              refresh();
            },
            child: Text(tr('تسجيل', 'Log session')),
          ),
        ],
      ),
    );
  }

  void showMotivation() => showDialog(
    context: context,
    builder: (ctx) => Dialog(
      backgroundColor: const Color(0xff101938),
      child: Container(
        padding: const EdgeInsets.all(25),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(24),
          gradient: const LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xff111b3a), Color(0xff39205b)],
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.nights_stay_rounded,
              size: 54,
              color: Color(0xffffd56a),
            ),
            const SizedBox(height: 10),
            const Text(
              '✦  ✧      ✦       ✧',
              style: TextStyle(color: cyan, fontSize: 20),
            ),
            const Icon(
              Icons.landscape_rounded,
              size: 78,
              color: Color(0xff7188b8),
            ),
            Text(
              tr(
                'لا تتوقف لأنك لم تصل بعد، فأنت أقرب مما تتخيل.',
                'Do not stop before you arrive; you are closer than you think.',
              ),
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 19, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 14),
            const Text(
              'IBRAHIM SMART STUDY',
              style: TextStyle(color: cyan, letterSpacing: 1.1),
            ),
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: Text(tr('متابعة', 'Continue')),
            ),
          ],
        ),
      ),
    ),
  );
}
