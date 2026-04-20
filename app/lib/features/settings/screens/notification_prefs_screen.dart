import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../shared/widgets/app_scaffold.dart';

class NotificationPrefsScreen extends StatefulWidget {
  const NotificationPrefsScreen({super.key});
  @override
  State<NotificationPrefsScreen> createState() => _NotificationPrefsScreenState();
}

class _NotificationPrefsScreenState extends State<NotificationPrefsScreen> {
  bool _mealReminders = true;
  bool _coachNudges = true;
  bool _weeklySummary = true;
  TimeOfDay _quietStart = const TimeOfDay(hour: 22, minute: 0);
  TimeOfDay _quietEnd = const TimeOfDay(hour: 8, minute: 0);

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      appBar: AppBar(title: const Text('Bildirimler')),
      body: ListView(
        children: [
          SwitchListTile(
            value: _mealReminders,
            onChanged: (v) => setState(() => _mealReminders = v),
            title: const Text('Öğün Hatırlatıcıları'),
          ),
          SwitchListTile(
            value: _coachNudges,
            onChanged: (v) => setState(() => _coachNudges = v),
            title: const Text('Koç Nüdgleri'),
          ),
          SwitchListTile(
            value: _weeklySummary,
            onChanged: (v) => setState(() => _weeklySummary = v),
            title: const Text('Haftalık Özet'),
          ),
          const Divider(),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
            child: Text('Sessiz Saatler', style: AppTextStyles.labelSmall),
          ),
          ListTile(
            title: const Text('Başlangıç'),
            trailing: Text(_quietStart.format(context), style: AppTextStyles.bodyMedium),
            onTap: () async {
              final t = await showTimePicker(context: context, initialTime: _quietStart);
              if (t != null) setState(() => _quietStart = t);
            },
          ),
          ListTile(
            title: const Text('Bitiş'),
            trailing: Text(_quietEnd.format(context), style: AppTextStyles.bodyMedium),
            onTap: () async {
              final t = await showTimePicker(context: context, initialTime: _quietEnd);
              if (t != null) setState(() => _quietEnd = t);
            },
          ),
        ],
      ),
    );
  }
}
