import 'package:flutter/cupertino.dart';
import 'package:jtrips_app/core/theme/app_colors.dart';

class StatItem {
  final String label;
  final String value;
  final Color valueColor;
  final Color accentColor; // new

  const StatItem({
    required this.label,
    required this.value,
    this.valueColor = AppColors.textPrimary,
    required this.accentColor ,
  });
}

class StatsRow extends StatelessWidget {
  final List<StatItem> items;

  const StatsRow({super.key, required this.items});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: List.generate(items.length, (index) {
        final item = items[index];
        return Expanded(
          child: Padding(
            padding: EdgeInsets.only(
              right: index == items.length - 1 ? 0 : 10,
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(16,) ,

              child: Container(
                decoration: BoxDecoration(
                  color: AppColors.cardDeepBlue,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: AppColors.gradientStart.withOpacity(0.4),
                    width: 2,
                  ), boxShadow: [
                  BoxShadow(
                      color: AppColors.accentYellow,
                      blurRadius: 6,
                      offset: const Offset(0, 4)
                  )
                ]

                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // top accent strip
                    Container(
                      height: 4,
                     decoration: BoxDecoration(
                       color: item.accentColor,
                       borderRadius: BorderRadius.circular(50),
                       boxShadow: [
                         BoxShadow(
                           color: item.accentColor,
                           blurRadius: 6,
                           offset: const Offset(0, 2)
                         )
                       ]
                     ),

                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 12),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            item.label.toUpperCase(),
                            style: const TextStyle(
                              color: AppColors.textSecondary,
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              letterSpacing: 0.5,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            item.value,
                            style: TextStyle(
                              color: item.valueColor,
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      }),
    );
  }
}