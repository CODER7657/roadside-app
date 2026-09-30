// Fails tool/lint_design.sh: one line per check.
Widget build(BuildContext context) {
  final a = EdgeInsets.all(16);
  final b = EdgeInsets.only(top: 8);
  final c = EdgeInsets.symmetric(horizontal: lane.space.s16, vertical: 12);
  final d = Color(0xFF000000);
  final e = Colors.red;
  final f = TextStyle(fontSize: 14);
  final g = SizedBox(height: 8);
  final h = BorderRadius.circular(12);
  final i = Duration(milliseconds: 200);
  final j = Text('Hello');
  final k = ElevatedButton(onPressed: null, child: null);
  final l = showDialog(context: context, builder: (_) => null);
  final m = HapticFeedback.lightImpact();
  print('x');
}
