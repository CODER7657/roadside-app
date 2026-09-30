// Passes tool/lint_design.sh: Lane tokens everywhere.
Widget build(BuildContext context) {
  final lane = context.lane;
  return Padding(
    padding: EdgeInsets.all(lane.space.s4),
    child: Padding(
      padding: EdgeInsets.symmetric(horizontal: lane.space.s16, vertical: lane.space.s24),
      child: Padding(
        padding: EdgeInsets.only(top: lane.space.s12, bottom: lane.space.s48),
        child: Text(l10n.home_title, style: lane.text.title),
      ),
    ),
  );
}
