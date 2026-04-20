import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';

import '../../../core/network/app_error.dart';
import '../../../core/routing/app_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../shared/widgets/app_scaffold.dart';
import '../../../shared/widgets/primary_button.dart';
import '../data/meal_repository.dart';

class MealCaptureScreen extends ConsumerStatefulWidget {
  const MealCaptureScreen({super.key});
  @override
  ConsumerState<MealCaptureScreen> createState() => _MealCaptureScreenState();
}

class _MealCaptureScreenState extends ConsumerState<MealCaptureScreen> {
  final _picker = ImagePicker();
  final _descCtrl = TextEditingController();
  String? _imagePath;
  bool _analyzing = false;

  Future<void> _pickFromCamera() async {
    final x = await _picker.pickImage(source: ImageSource.camera, imageQuality: 80);
    if (x != null) setState(() => _imagePath = x.path);
  }

  Future<void> _pickFromGallery() async {
    final x = await _picker.pickImage(source: ImageSource.gallery, imageQuality: 80);
    if (x != null) setState(() => _imagePath = x.path);
  }

  Future<String?> _readAsBase64(String path) async {
    try {
      final bytes = await File(path).readAsBytes();
      return base64Encode(bytes);
    } catch (_) {
      return null;
    }
  }

  Future<void> _analyze() async {
    if (_imagePath == null && _descCtrl.text.trim().isEmpty) return;

    setState(() => _analyzing = true);
    try {
      String? imageB64;
      if (_imagePath != null) {
        imageB64 = await _readAsBase64(_imagePath!);
      }

      final result = await ref.read(mealRepositoryProvider).analyze(
            imageB64: imageB64,
            description: _descCtrl.text.trim().isEmpty ? null : _descCtrl.text.trim(),
          );

      if (!mounted) return;
      context.pushReplacement(
        AppRoute.mealResult,
        extra: result,
      );
    } catch (e) {
      if (!mounted) return;
      final msg = e is AppError ? e.userMessage : 'Analiz yapılamadı.';
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
    } finally {
      if (mounted) setState(() => _analyzing = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      appBar: AppBar(title: const Text('Öğün Ekle')),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Fotoğraf veya açıklama', style: AppTextStyles.headingSmall),
            const SizedBox(height: 16),
            _ImageArea(imagePath: _imagePath),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: _pickFromCamera,
                    icon: const Icon(Icons.camera_alt_outlined),
                    label: const Text('Kamera'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: _pickFromGallery,
                    icon: const Icon(Icons.image_outlined),
                    label: const Text('Galeri'),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            TextField(
              controller: _descCtrl,
              maxLines: 3,
              decoration: const InputDecoration(
                hintText: 'Veya yemeği yaz (örn. tavuk göğsü, pilav, salata)',
              ),
            ),
            const Spacer(),
            PrimaryButton(
              label: 'Analiz Et',
              isLoading: _analyzing,
              onPressed: _analyze,
            ),
            const SizedBox(height: 12),
            Center(
              child: TextButton(
                onPressed: () => context.push(AppRoute.mealManual),
                child: const Text('Manuel giriş yap'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ImageArea extends StatelessWidget {
  const _ImageArea({this.imagePath});
  final String? imagePath;
  @override
  Widget build(BuildContext context) {
    return Container(
      height: 220,
      width: double.infinity,
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.divider),
      ),
      alignment: Alignment.center,
      child: imagePath == null
          ? Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: const [
                Icon(Icons.restaurant_outlined, size: 48, color: AppColors.textTertiary),
                SizedBox(height: 8),
                Text('Fotoğraf eklenmedi',
                    style: TextStyle(color: AppColors.textTertiary, fontSize: 13)),
              ],
            )
          : ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: Image.file(File(imagePath!), fit: BoxFit.cover, width: double.infinity),
            ),
    );
  }
}
