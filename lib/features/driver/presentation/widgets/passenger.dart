import 'package:flutter/material.dart';
import 'package:jtrips_app/core/theme/app_colors.dart';
import '../widgets/common.dart';
class Passenger {
  final String name;
  final String role;
  final Color roleColor;

  const Passenger({required this.name, required this.role, required this.roleColor});
}

class PassengersSection extends StatelessWidget {
  const PassengersSection({super.key});

  static const List<Passenger> _passengers = [
    Passenger(name: 'Mark cruz Tulabing', role: 'Requester', roleColor: AppColors.textPrimary),
    Passenger(name: 'Christian Gonzaga', role: 'Passenger', roleColor: AppColors.textSecondary),
    Passenger(name: 'Mr.Lee Cyberz4', role: 'Passenger', roleColor: AppColors.textSecondary),
  ];

  @override
  Widget build(BuildContext context) {
    return SectionCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SectionHeader(
            icon: Icons.people_alt_outlined,
            iconColor: AppColors.statusBlue,
            title: 'Passengers',
            trailing: Container(
              width: 26,
              height: 26,
              alignment: Alignment.center,
              decoration: const BoxDecoration(
                color: AppColors.statusBlue,
                shape: BoxShape.circle,
              ),
              child: Text(
                '${_passengers.length}',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),
          for (int i = 0; i < _passengers.length; i++) ...[
            _PassengerTile(passenger: _passengers[i]),
            if (i != _passengers.length - 1) const Divider(color: AppColors.cardDeepBlue, height: 24),
          ],
        ],
      ),
    );
  }
}

class _PassengerTile extends StatelessWidget {
  final Passenger passenger;
  const _PassengerTile({required this.passenger});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        InitialsAvatar(name: passenger.name, radius: 18, color: AppColors.gradientStart),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            passenger.name,
            style: const TextStyle(
              color: AppColors.textPrimary,
              fontSize: 14.5,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        StatusBadge(text: passenger.role, color: passenger.roleColor),
      ],
    );
  }
}