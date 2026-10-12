import 'package:flutter/material.dart';

import 'theme/app_theme.dart';
import 'widgets/app_widgets.dart';

class itemDetails extends StatefulWidget {
  itemDetails({
    required this.No,
    required this.Description,
    required this.description2,
    required this.basedUnit,
    required this.type,
    required this.itemCatCode,
    required this.pricesVat,
    required this.salesUnit,
    required this.itemTrackingCode,
    required this.lotsNos,
    required this.SerialNums,
    required this.block,
    required this.image,
  });

  String? No;
  String? Description;
  String? description2;
  String? basedUnit;
  String? type;
  String? itemCatCode;
  String? pricesVat;
  String? salesUnit;
  String? itemTrackingCode;
  String? lotsNos;
  String? SerialNums;
  String? block;
  String? image;

  @override
  State<itemDetails> createState() => _itemDetailsState();
}

class _itemDetailsState extends State<itemDetails> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
            onPressed: () {
              Navigator.pop(context);
            },
            icon: const Icon(Icons.arrow_back_ios_new_rounded)),
        title: const Text("Details"),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
        children: [
          Container(
            height: 200,
            decoration: BoxDecoration(
              color: AppColors.border,
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Center(
              child: Icon(
                Icons.liquor_rounded,
                size: 72,
                color: AppColors.textMuted,
              ),
            ),
          ),
          const SizedBox(height: 20),
          AppCard(
            margin: const EdgeInsets.only(bottom: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SmallCapsLabel("Product Description"),
                Padding(
                  padding: const EdgeInsets.only(left: 4),
                  child: Text(
                    displayValue(widget.Description),
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textDark,
                    ),
                  ),
                ),
                const SizedBox(height: 6),
                Padding(
                  padding: const EdgeInsets.only(left: 4),
                  child: Text(
                    "ID No: ${displayValue(widget.No)}",
                    style: const TextStyle(
                      fontSize: 14,
                      color: AppColors.textMuted,
                    ),
                  ),
                ),
              ],
            ),
          ),
          AppCard(
            margin: const EdgeInsets.only(bottom: 16),
            child: Column(
              children: [
                _infoRow("Category Name", displayValue(widget.itemCatCode)),
                _gap(),
                _infoRow("Description", displayValue(widget.description2)),
                _gap(),
                _infoRow("Blocked",
                    widget.block.toString().replaceAll("null", "false")),
                _gap(),
                _infoRow("Base Unit Measure", displayValue(widget.basedUnit)),
                _gap(),
                _infoRow(
                    "Item Category Code", displayValue(widget.itemCatCode)),
              ],
            ),
          ),
          AppCard(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: ExpansionTile(
              shape: const Border(),
              collapsedShape: const Border(),
              leading: const IconBadge(
                icon: Icons.inventory_2_outlined,
                color: AppColors.primary,
                size: 36,
              ),
              title: const Text(
                "Inventory",
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textDark,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _gap() => const SizedBox(height: 12);

  Widget _infoRow(String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(fontSize: 13.5, color: AppColors.textMuted),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            value,
            textAlign: TextAlign.right,
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w700,
              color: AppColors.textDark,
            ),
          ),
        ),
      ],
    );
  }
}
