// TrustPass: the mechanic card laid out like an ID (PLAN.md §6.5 ⑧, §10.0).
import 'package:flutter/material.dart';

import '../theme/lane_theme.dart';
import 'lane_badges.dart';
import 'lane_feedback.dart';
import 'lane_icons.dart';
import 'lane_numbers.dart';

/// What the customer sees once a mechanic accepts: photo, name, verified badge, rating,
/// the vehicle types they handle and the start code.
///
/// Two variants, picked by the app from `booking.mechanicCard.mechanicType`:
/// [TrustPass.workshop] shows the shop name; [TrustPass.independent] shows
/// "Verified independent mechanic · N yrs" and the plate of the vehicle they're riding in on.
class TrustPass extends StatelessWidget {
  const TrustPass.workshop({
    super.key,
    required this.name,
    required String this.shopName,
    this.photo,
    this.verified = true,
    this.rating,
    this.jobs = 0,
    this.vehicleTypes = const [],
    this.startCode,
  }) : years = null,
       travelRegNo = null;

  const TrustPass.independent({
    super.key,
    required this.name,
    required int this.years,
    required String this.travelRegNo,
    this.photo,
    this.verified = true,
    this.rating,
    this.jobs = 0,
    this.vehicleTypes = const [],
    this.startCode,
  }) : shopName = null;

  final String name;
  final ImageProvider? photo;

  /// Only `approved` + KYC-checked mechanics get the badge.
  final bool verified;

  /// 1.0–5.0; null hides the rating (new mechanics).
  final double? rating;
  final int jobs;

  /// PLAN §8 vehicle types they handle (`bike`, `scooter`, `car`, `ev`).
  final List<String> vehicleTypes;

  /// The 4-digit start code (PLAN §9); null hides the section.
  final String? startCode;

  final String? shopName;
  final int? years;
  final String? travelRegNo;

  bool get isWorkshop => shopName != null;

  @override
  Widget build(BuildContext context) {
    final lane = context.lane;
    final c = lane.color;
    final strings = laneStrings(context);
    final avatar = lane.touch.critical;

    // "Verified independent mechanic · N yrs" only makes the claim when it's true.
    final subtitle = isWorkshop ? shopName : (verified ? strings.trust_verified_independent(years!) : null);

    return Container(
      decoration: BoxDecoration(
        color: c.surface,
        borderRadius: lane.radius.r24,
        border: Border.all(color: c.line, width: lane.stroke.hairline),
        boxShadow: lane.shadow.float,
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: [
          // The lanyard band: a Beacon strip across the top, like an access card.
          SizedBox(
            height: lane.space.s8,
            child: ColoredBox(color: c.beacon),
          ),
          Padding(
            padding: EdgeInsets.all(lane.space.s16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ClipRRect(
                      borderRadius: lane.radius.r16,
                      child: SizedBox.square(
                        dimension: avatar,
                        child: photo != null
                            ? Image(image: photo!, fit: BoxFit.cover, excludeFromSemantics: true)
                            : ColoredBox(
                                color: c.surfaceSunken,
                                child: Center(child: LaneIcon(LaneIcons.mechanic, size: lane.space.s32)),
                              ),
                      ),
                    ),
                    SizedBox(width: lane.space.s16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(name, style: lane.text.title, maxLines: 2, overflow: TextOverflow.ellipsis),
                          if (subtitle != null) ...[
                            SizedBox(height: lane.space.s4),
                            Text(subtitle, style: lane.text.body.copyWith(color: c.inkMuted)),
                          ],
                          if (rating != null) ...[
                            SizedBox(height: lane.space.s4),
                            _Rating(rating: rating!, jobs: jobs),
                          ],
                        ],
                      ),
                    ),
                  ],
                ),
                SizedBox(height: lane.space.s12),
                Wrap(
                  spacing: lane.space.s8,
                  runSpacing: lane.space.s8,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    if (verified)
                      SignalBadge(
                        signal: LaneSignal.go,
                        icon: LaneIcons.checkCircle,
                        label: isWorkshop ? strings.trust_verified_workshop : strings.trust_verified,
                      ),
                    if (travelRegNo != null) PlateChip(regNo: travelRegNo!),
                    for (final type in vehicleTypes)
                      LaneIcon(LaneIcons.forVehicle(type), size: lane.space.s32, semanticLabel: type),
                  ],
                ),
                if (startCode != null) ...[
                  SizedBox(height: lane.space.s16),
                  Divider(height: lane.space.s4, thickness: lane.stroke.hairline, color: c.line),
                  SizedBox(height: lane.space.s12),
                  Text(
                    strings.trust_start_code.toUpperCase(),
                    style: lane.text.caps.copyWith(color: c.inkMuted),
                  ),
                  SizedBox(height: lane.space.s8),
                  Center(child: LaneOtpDisplay(code: startCode!)),
                  SizedBox(height: lane.space.s8),
                  Text(strings.trust_start_code_hint, style: lane.text.caption.copyWith(color: c.inkMuted)),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _Rating extends StatelessWidget {
  const _Rating({required this.rating, required this.jobs});

  final double rating;
  final int jobs;

  @override
  Widget build(BuildContext context) {
    final lane = context.lane;
    final strings = laneStrings(context);
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        LaneIcon(LaneIcons.star, size: lane.space.s16, color: lane.color.signal.wait),
        SizedBox(width: lane.space.s4),
        Text(rating.toStringAsFixed(1), style: lane.text.label),
        SizedBox(width: lane.space.s8),
        Flexible(
          child: Text(
            strings.trust_jobs(jobs),
            style: lane.text.caption.copyWith(color: lane.color.inkMuted),
          ),
        ),
      ],
    );
  }
}
