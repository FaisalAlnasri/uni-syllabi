import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

import '../../../../core/theme/app_colors.dart';
import '../../domain/entities/course.dart';
import '../../domain/entities/deliverable.dart';
import '../courses_strings.dart';
import '../cubit/course_cubit.dart';
import 'type_glyph.dart';

Future<void> showDeliverableDetail(
  BuildContext context,
  Deliverable deliverable,
  Course course,
) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (_) => BlocProvider.value(
      value: context.read<CourseCubit>(),
      child: _DetailSheet(deliverable: deliverable, course: course),
    ),
  );
}

class _DetailSheet extends StatefulWidget {
  final Deliverable deliverable;
  final Course course;

  const _DetailSheet({required this.deliverable, required this.course});

  @override
  State<_DetailSheet> createState() => _DetailSheetState();
}

class _DetailSheetState extends State<_DetailSheet> {
  bool _editing = false;
  late TextEditingController _titleController;
  late DeliverableType _type;
  late String _weightText;
  late DateTime? _date;

  @override
  void initState() {
    super.initState();
    final d = widget.deliverable;
    _titleController = TextEditingController(text: d.title);
    _type = d.type;
    _weightText = d.weight != null ? (d.weight! * 100).toStringAsFixed(0) : '';
    _date = d.date;
  }

  @override
  void dispose() {
    _titleController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final raw = double.tryParse(_weightText);
    final weight =
        raw != null ? (raw / 100).clamp(0.0, 1.0) : widget.deliverable.weight;
    final updated = Deliverable(
      id: widget.deliverable.id,
      title: _titleController.text.trim().isEmpty
          ? widget.deliverable.title
          : _titleController.text.trim(),
      type: _type,
      date: _date,
      rawDateText: widget.deliverable.rawDateText,
      weight: weight,
      isClear: _date != null,
      confidenceNotes:
          _date != null ? null : widget.deliverable.confidenceNotes,
    );
    await context.read<CourseCubit>().updateDeliverable(
          widget.course.id,
          updated,
        );
    if (mounted) Navigator.of(context).pop();
  }

  Future<void> _pickDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: _date ?? now,
      firstDate: DateTime(now.year - 1),
      lastDate: DateTime(now.year + 3),
    );
    if (picked != null) setState(() => _date = picked);
  }

  @override
  Widget build(BuildContext context) {
    final c = context.c;
    final color = courseColor(context, widget.course.color);
    final hasDate = _date != null;

    return Padding(
      padding:
          EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      child: Container(
        decoration: BoxDecoration(
          color: c.surface,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        ),
        padding: EdgeInsets.fromLTRB(
          20,
          12,
          20,
          20 + MediaQuery.of(context).padding.bottom,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: c.border,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(typeIcon(_type), color: color),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.course.title,
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: color,
                          letterSpacing: 0.2,
                        ),
                      ),
                      const SizedBox(height: 2),
                      if (_editing)
                        TextField(
                          controller: _titleController,
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            color: c.textPrimary,
                          ),
                          decoration: InputDecoration(
                            isDense: true,
                            contentPadding: EdgeInsets.zero,
                            border: InputBorder.none,
                            hintText: CoursesStrings.title,
                            hintStyle: TextStyle(color: c.textMuted),
                          ),
                        )
                      else
                        Text(
                          widget.deliverable.title,
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                            color: c.textPrimary,
                            height: 1.2,
                          ),
                        ),
                    ],
                  ),
                ),
                IconButton(
                  onPressed: () => setState(() => _editing = !_editing),
                  icon: Icon(
                    _editing ? Icons.close_rounded : Icons.edit_rounded,
                    size: 20,
                    color: c.textMuted,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            if (_editing) ...[
              _EditSection(
                label: CoursesStrings.type,
                child: DropdownButton<DeliverableType>(
                  value: _type,
                  isDense: true,
                  underline: const SizedBox(),
                  onChanged: (v) {
                    if (v != null) setState(() => _type = v);
                  },
                  items: DeliverableType.values
                      .map((t) => DropdownMenuItem(
                            value: t,
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(typeIcon(t),
                                    size: 14, color: c.textSecondary),
                                const SizedBox(width: 6),
                                Text(typeLabel(t),
                                    style: TextStyle(
                                        fontSize: 13, color: c.textPrimary)),
                              ],
                            ),
                          ))
                      .toList(),
                ),
              ),
              const SizedBox(height: 8),
              _EditSection(
                label: CoursesStrings.weightPercentLabel,
                child: SizedBox(
                  width: 80,
                  child: TextField(
                    controller: TextEditingController(text: _weightText)
                      ..selection =
                          TextSelection.collapsed(offset: _weightText.length),
                    keyboardType: TextInputType.number,
                    textAlign: TextAlign.end,
                    style: TextStyle(fontSize: 13, color: c.textPrimary),
                    decoration: InputDecoration(
                      isDense: true,
                      contentPadding: EdgeInsets.zero,
                      border: InputBorder.none,
                      hintText: '—',
                      hintStyle: TextStyle(color: c.textMuted),
                    ),
                    onChanged: (v) => _weightText = v,
                  ),
                ),
              ),
              const SizedBox(height: 8),
              _EditSection(
                label: CoursesStrings.dueDate,
                child: GestureDetector(
                  onTap: _pickDate,
                  child: Text(
                    hasDate
                        ? DateFormat('EEE، d MMM yyyy', 'ar').format(_date!)
                        : CoursesStrings.tapToSet,
                    style: TextStyle(
                      fontSize: 13,
                      color: hasDate ? c.textPrimary : c.accent,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: _PrimaryButton(
                  icon: Icons.check_rounded,
                  label: CoursesStrings.saveChanges,
                  onTap: _save,
                ),
              ),
            ] else ...[
              _InfoRow(
                icon: Icons.calendar_today_outlined,
                label: CoursesStrings.dueDate,
                value: hasDate
                    ? DateFormat('EEEE، d MMMM yyyy', 'ar').format(_date!)
                    : (widget.deliverable.rawDateText ??
                        CoursesStrings.notSpecified),
                valueColor: hasDate ? c.textPrimary : c.warning,
              ),
              _InfoRow(
                icon: Icons.bar_chart_rounded,
                label: CoursesStrings.weight,
                value: widget.deliverable.weight != null
                    ? widget.deliverable.weightPercentage
                    : CoursesStrings.notSpecified,
              ),
              _InfoRow(
                icon: typeIcon(widget.deliverable.type),
                label: CoursesStrings.type,
                value: typeLabel(widget.deliverable.type),
              ),
              if (widget.deliverable.confidenceNotes != null) ...[
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: c.warningBg,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(Icons.auto_awesome, size: 16, color: c.warningFg),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          widget.deliverable.confidenceNotes!,
                          style: TextStyle(
                            fontSize: 12.5,
                            color: c.warningFg,
                            height: 1.4,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: _PrimaryButton(
                  icon: Icons.edit_calendar_rounded,
                  label: hasDate
                      ? CoursesStrings.changeDate
                      : CoursesStrings.setADate,
                  onTap: _pickDate,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

// ── Edit row ──────────────────────────────────────────────────────────────────

class _EditSection extends StatelessWidget {
  final String label;
  final Widget child;
  const _EditSection({required this.label, required this.child});

  @override
  Widget build(BuildContext context) {
    final c = context.c;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: c.surfaceAlt,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: c.border),
      ),
      child: Row(
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 13,
              color: c.textSecondary,
              fontWeight: FontWeight.w500,
            ),
          ),
          const Spacer(),
          child,
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color? valueColor;

  const _InfoRow({
    required this.icon,
    required this.label,
    required this.value,
    this.valueColor,
  });

  @override
  Widget build(BuildContext context) {
    final c = context.c;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(icon, size: 18, color: c.textMuted),
          const SizedBox(width: 12),
          Text(
            label,
            style: TextStyle(
              fontSize: 13,
              color: c.textSecondary,
              fontWeight: FontWeight.w500,
            ),
          ),
          const Spacer(),
          Flexible(
            child: Text(
              value,
              textAlign: TextAlign.end,
              style: TextStyle(
                fontSize: 13.5,
                color: valueColor ?? c.textPrimary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _PrimaryButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _PrimaryButton({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final c = context.c;
    return Material(
      color: c.accent,
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 15),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 18, color: Colors.white),
              const SizedBox(width: 8),
              Text(
                label,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                  fontSize: 15,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
