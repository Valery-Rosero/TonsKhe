import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';

import '../../../core/errors/app_exception.dart';
import '../../../core/router/app_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/utils/extensions.dart';
import '../../../domain/entities/stories/story_entity.dart';
import '../../../domain/repositories/stories_repository.dart';
import '../../providers/stories/stories_provider.dart';
import '../../widgets/common/custom_button.dart';
import '../../widgets/common/custom_text_field.dart';
import '../../widgets/stories/invite_code_widget.dart';

const _validImageExtensions = {'jpg', 'jpeg', 'png', 'webp'};

class CreateStoryPage extends ConsumerStatefulWidget {
  const CreateStoryPage({super.key});

  @override
  ConsumerState<CreateStoryPage> createState() => _CreateStoryPageState();
}

class _CreateStoryPageState extends ConsumerState<CreateStoryPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _picker = ImagePicker();

  XFile? _pickedImage;
  bool _isSubmitting = false;
  StoryEntity? _createdStory;

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _pickCoverImage() async {
    final file = await _picker.pickImage(source: ImageSource.gallery, imageQuality: 85);
    if (file != null) setState(() => _pickedImage = file);
  }

  Future<void> _submit() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;

    setState(() => _isSubmitting = true);
    try {
      StoryCoverImage? coverImage;
      if (_pickedImage != null) {
        final extension = _pickedImage!.name.split('.').last.toLowerCase();
        coverImage = StoryCoverImage(
          bytes: await _pickedImage!.readAsBytes(),
          extension: _validImageExtensions.contains(extension) ? extension : 'jpg',
        );
      }

      final story = await ref.read(createStoryUseCaseProvider).call(
            name: _nameController.text.trim(),
            coverImage: coverImage,
          );
      if (mounted) setState(() => _createdStory = story);
    } on AppException catch (error) {
      if (mounted) context.showErrorSnackBar(error.message);
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: DecoratedBox(
        decoration: const BoxDecoration(gradient: AppColors.backgroundGradient),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(24, 8, 24, 24),
            child: _createdStory == null ? _buildForm() : _buildSuccess(_createdStory!),
          ),
        ),
      ),
    );
  }

  Widget _buildForm() {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          IconButton(
            onPressed: _isSubmitting ? null : () => context.pop(),
            icon: const Icon(Icons.arrow_back, color: AppColors.textPrimary),
          ),
          Text('Nueva Historia', style: AppTextStyles.heading(fontSize: 21)),
          const SizedBox(height: 20),
          GestureDetector(
            onTap: _isSubmitting ? null : _pickCoverImage,
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: AppColors.secondaryAccent, width: 2, style: BorderStyle.solid),
                image: _pickedImage == null
                    ? null
                    : DecorationImage(image: FileImage(File(_pickedImage!.path)), fit: BoxFit.cover),
              ),
              child: _pickedImage == null
                  ? Column(
                      children: [
                        const Icon(Icons.add_a_photo_outlined, color: AppColors.secondaryAccent, size: 28),
                        const SizedBox(height: 8),
                        const Text(
                          'Agregar foto de portada',
                          style: TextStyle(color: AppColors.secondaryAccent, fontWeight: FontWeight.w700, fontSize: 12),
                        ),
                        const Text(
                          '(opcional)',
                          style: TextStyle(color: AppColors.textMuted, fontWeight: FontWeight.w600, fontSize: 11),
                        ),
                      ],
                    )
                  : null,
            ),
          ),
          const SizedBox(height: 20),
          AppTextField(
            label: 'Nombre de la historia',
            controller: _nameController,
            prefixIcon: Icons.favorite_border,
            validator: (value) =>
                (value == null || value.trim().isEmpty) ? 'El nombre es obligatorio' : null,
          ),
          const SizedBox(height: 24),
          AppPrimaryButton(
            label: 'Crear Historia',
            isLoading: _isSubmitting,
            onPressed: _isSubmitting ? null : _submit,
          ),
        ],
      ),
    );
  }

  Widget _buildSuccess(StoryEntity story) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const Icon(Icons.check_circle, color: AppColors.secondaryAccent, size: 56),
        const SizedBox(height: 16),
        Text(
          '¡"${story.name}" fue creada!',
          textAlign: TextAlign.center,
          style: AppTextStyles.heading(fontSize: 20),
        ),
        const SizedBox(height: 8),
        const Text(
          'Comparte este código con tu pareja para que se una',
          textAlign: TextAlign.center,
          style: TextStyle(color: AppColors.textSecondary, fontSize: 13, fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 24),
        InviteCodeWidget(code: story.inviteCode),
        const SizedBox(height: 32),
        AppPrimaryButton(
          label: 'Ir a mi Historia',
          onPressed: () => context.go(AppRoutes.storyCategories(story.id)),
        ),
      ],
    );
  }
}
