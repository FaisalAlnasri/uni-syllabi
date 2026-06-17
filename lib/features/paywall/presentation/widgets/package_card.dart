import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:purchases_flutter/purchases_flutter.dart' show Package;

import '../../../../core/utils/extensions/context_extensions.dart';

class PackageCard extends StatelessWidget {
  final Package package;

  const PackageCard({super.key, required this.package});

  @override
  Widget build(BuildContext context) {
    final product = package.storeProduct;
    final hasTrial = product.introductoryPrice != null;

    return Card(
      color: context.colors.surfaceContainerLow,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16.r),
      ),
      child: Padding(
        padding: EdgeInsets.all(16.r),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    product.priceString,
                    style: context.textTheme.headlineLarge,
                  ),
                  SizedBox(height: 4.h),
                  Text(
                    product.title,
                    style: context.textTheme.bodyMedium
                        ?.copyWith(color: context.colors.outline),
                  ),
                ],
              ),
            ),
            if (hasTrial) ...[
              SizedBox(width: 12.w),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
                decoration: BoxDecoration(
                  color: context.colors.primaryContainer,
                  borderRadius: BorderRadius.circular(8.r),
                ),
                child: Text(
                  'تجربة مجانية',
                  style: context.textTheme.labelMedium
                      ?.copyWith(color: context.colors.onPrimaryContainer),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
