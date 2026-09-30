import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lane_ui/lane_ui.dart' hide PriceRange;
import 'package:roadside_core/roadside_core.dart' hide JourneyStop;

import '../../../app/router.dart';
import '../../../l10n/app_localizations.dart';
import '../application/estimate.dart';
import '../application/live_booking.dart';
import '../data/review_repository.dart';

/// Tag codes stored in `reviews.tags`; what's offered depends on the stars.
abstract final class ReviewTags {
  static const good = ['on_time', 'friendly', 'fixed_fast', 'fair_price'];
  static const bad = ['late', 'rude', 'overcharged', 'not_fixed'];

  /// 4–5 stars get the good tags, 1–3 the bad ones.
  static List<String> forStars(int stars) => stars >= 4 ? good : bad;
}

/// U14 Rate & review: stars (required), tags and a comment for a completed booking, once.
class ReviewScreen extends ConsumerStatefulWidget {
  const ReviewScreen({super.key, required this.bookingId});

  final String bookingId;

  @override
  ConsumerState<ReviewScreen> createState() => _ReviewScreenState();
}

class _ReviewScreenState extends ConsumerState<ReviewScreen> {
  int _stars = 0;
  final _tags = <String>{};
  String _comment = '';
  bool _sending = false;
  late final Future<bool> _alreadyReviewed = ref.read(reviewRepositoryProvider).exists(widget.bookingId);

  void _setStars(int stars) => setState(() {
    _stars = stars;
    // Keep only the tags that still fit the rating.
    _tags.retainAll(ReviewTags.forStars(stars));
  });

  Future<void> _submit(Booking booking) async {
    if (_sending || _stars == 0) return;
    final l10n = AppLocalizations.of(context);
    setState(() => _sending = true);
    try {
      await ref
          .read(reviewRepositoryProvider)
          .submit(
            bookingId: widget.bookingId,
            customerId: ref.read(customerIdProvider),
            mechanicId: booking.mechanicId!,
            review: ReviewDraft(stars: _stars, tags: _tags.toList(), comment: _comment),
          );
      if (!mounted) return;
      LaneToast.show(context, l10n.review_thanks);
      context.go(AppRoutes.home);
    } on ReviewException catch (e) {
      if (!mounted) return;
      LaneHaptics.error().ignore();
      LaneToast.show(
        context,
        e.error == ReviewError.notAllowed ? l10n.review_not_allowed : l10n.review_error,
      );
    } finally {
      if (mounted) setState(() => _sending = false);
    }
  }

  String _tagLabel(AppLocalizations l10n, String tag) => switch (tag) {
    'on_time' => l10n.review_tag_on_time,
    'friendly' => l10n.review_tag_friendly,
    'fixed_fast' => l10n.review_tag_fixed_fast,
    'fair_price' => l10n.review_tag_fair_price,
    'late' => l10n.review_tag_late,
    'rude' => l10n.review_tag_rude,
    'overcharged' => l10n.review_tag_overcharged,
    _ => l10n.review_tag_not_fixed,
  };

  @override
  Widget build(BuildContext context) {
    final lane = context.lane;
    final l10n = AppLocalizations.of(context);
    final booking = ref.watch(liveBookingProvider(widget.bookingId)).value;
    final name = booking?.mechanicCard?.name ?? '';
    final home = LaneButton.primary(
      label: l10n.booking_back_home,
      onPressed: () => context.go(AppRoutes.home),
    );

    return FutureBuilder<bool>(
      future: _alreadyReviewed,
      builder: (context, reviewed) {
        if (reviewed.data == true) {
          return LaneStatusScaffold(
            visual: LaneIcon(LaneIcons.checkCircle, size: lane.space.s64),
            title: l10n.review_already,
            primary: home,
          );
        }
        if (booking == null || !reviewed.hasData) {
          return Scaffold(body: SafeArea(child: SkeletonGroup.lines()));
        }
        if (booking.status != BookingStatus.completed || booking.mechanicId == null) {
          return LaneStatusScaffold(
            visual: LaneIcon(LaneIcons.tray, size: lane.space.s64),
            title: l10n.review_not_allowed,
            primary: home,
          );
        }
        return LaneFlowScaffold(
          step: 1,
          totalSteps: 1,
          stepLabel: l10n.review_step,
          title: l10n.review_title(name),
          primary: LaneButton.primary(
            label: l10n.review_submit,
            loading: _sending,
            onPressed: _stars == 0 ? null : () => _submit(booking),
          ),
          secondary: LaneButton.ghost(label: l10n.photos_skip, onPressed: () => context.go(AppRoutes.home)),
          children: [
            Center(
              child: StarRating(value: _stars, label: l10n.review_stars_label(name), onChanged: _setStars),
            ),
            if (_stars > 0) ...[
              SizedBox(height: lane.space.s24),
              Text(_stars >= 4 ? l10n.review_tags_good : l10n.review_tags_bad, style: lane.text.label),
              SizedBox(height: lane.space.s8),
              Wrap(
                spacing: lane.space.s8,
                runSpacing: lane.space.s8,
                children: [
                  for (final tag in ReviewTags.forStars(_stars))
                    LaneChip(
                      label: _tagLabel(l10n, tag),
                      selected: _tags.contains(tag),
                      onSelected: (on) => setState(() => on ? _tags.add(tag) : _tags.remove(tag)),
                    ),
                ],
              ),
              SizedBox(height: lane.space.s24),
              LaneTextField(
                label: l10n.review_comment_label,
                maxLength: ReviewDraft.maxComment,
                maxLines: 4,
                textCapitalization: TextCapitalization.sentences,
                onChanged: (v) => _comment = v,
              ),
            ],
          ],
        );
      },
    );
  }
}
