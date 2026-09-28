import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:permission_handler/permission_handler.dart';
import '../../../core/constants/app_constants.dart';
import '../../../shared/design_system/spacing/ds_spacing.dart';
import '../../../shared/design_system/buttons/ds_button.dart';
import '../../authentication/providers/auth_provider.dart';
import '../../authentication/models/enums/role_utilisateur.dart';
import '../../property/repositories/media_repository.dart';

/// Page de profil utilisateur avec upload réel de la photo vers Cloudinary
class ProfilePage extends ConsumerStatefulWidget {
  const ProfilePage({super.key});

  @override
  ConsumerState<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends ConsumerState<ProfilePage> {
  bool _isUploading = false;
  bool _isEditing = false;
  final ImagePicker _picker = ImagePicker();
  final MediaRepository _mediaRepository = MediaRepository();

  // Controllers pour l'édition du profil
  final _nomController = TextEditingController();
  final _prenomController = TextEditingController();
  final _biographieController = TextEditingController();
  final _professionController = TextEditingController();
  final _nationaliteController = TextEditingController();

  Future<void> _pickAndUploadPhoto(ImageSource source) async {
    try {
      debugPrint('Début _pickAndUploadPhoto avec source: $source');
      
      // Request camera permission if using camera
      if (source == ImageSource.camera) {
        debugPrint('Demande de permission caméra');
        final cameraStatus = await Permission.camera.request();
        debugPrint('Statut permission caméra: $cameraStatus');
        
        if (!cameraStatus.isGranted) {
          debugPrint('Permission caméra refusée');
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Permission caméra refusée. Veuillez l\'accorder dans les paramètres.'),
                backgroundColor: Colors.red,
              ),
            );
          }
          return;
        }
        
        // Vérifier si la permission est permanently denied
        if (cameraStatus.isPermanentlyDenied) {
          debugPrint('Permission caméra permanently denied');
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Permission caméra refusée définitivement. Veuillez l\'activer dans les paramètres de l\'application.'),
                backgroundColor: Colors.red,
                duration: Duration(seconds: 5),
              ),
            );
          }
          return;
        }
      }

      debugPrint('Appel de _picker.pickImage');
      final XFile? file = await _picker.pickImage(
        source: source,
        maxWidth: 800,
        maxHeight: 800,
        imageQuality: 85,
        preferredCameraDevice: CameraDevice.front,
      );

      debugPrint('Résultat pickImage: ${file != null ? "succès" : "null"}');

      if (file == null) {
        debugPrint('Aucun fichier sélectionné');
        return;
      }

      setState(() {
        _isUploading = true;
      });

      debugPrint('Début du crop de l\'image');
      // Cropper l'image avant l'upload
      CroppedFile? croppedFile;
      try {
        croppedFile = await ImageCropper().cropImage(
          sourcePath: file.path,
          compressFormat: ImageCompressFormat.jpg,
          compressQuality: 85,
          uiSettings: [
            AndroidUiSettings(
              toolbarTitle: 'Rogner la photo',
              toolbarColor: Colors.blue,
              toolbarWidgetColor: Colors.white,
              initAspectRatio: CropAspectRatioPreset.original,
              lockAspectRatio: false,
            ),
            IOSUiSettings(
              title: 'Rogner la photo',
            ),
          ],
        );
      } catch (cropError) {
        debugPrint('Erreur lors du crop: $cropError');
        // Si le crop échoue, utiliser l'image originale
        croppedFile = null;
      }

      debugPrint('Résultat crop: ${croppedFile != null ? "succès" : "null"}');

      // Utiliser l'image originale si le crop échoue ou est annulé
      final xFile = croppedFile != null ? XFile(croppedFile.path) : file;

      debugPrint('Début upload vers Cloudinary');
      final newPhotoUrl = await _mediaRepository.uploadProfilePhoto(xFile);
      debugPrint('Résultat upload: ${newPhotoUrl != null ? "succès" : "null"}');

      if (mounted) {
        setState(() {
          _isUploading = false;
        });

        if (newPhotoUrl != null && newPhotoUrl.isNotEmpty) {
          ref.read(authProvider.notifier).updateProfilePhoto(newPhotoUrl);
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Photo de profil mise à jour avec succès sur Cloudinary !'),
              backgroundColor: Colors.green,
            ),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Échec de la mise à jour de la photo de profil.'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e) {
      debugPrint('Erreur dans _pickAndUploadPhoto: $e');
      if (mounted) {
        setState(() {
          _isUploading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erreur: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }



  Future<void> _deletePhoto() async {
    try {
      setState(() {
        _isUploading = true;
      });

      await _mediaRepository.deleteProfilePhoto();

      if (mounted) {
        setState(() {
          _isUploading = false;
        });

        ref.read(authProvider.notifier).updateProfilePhoto(null);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Photo de profil supprimée avec succès.'),
            backgroundColor: Colors.blueGrey,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isUploading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Échec de la suppression: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _showPhotoOptions(BuildContext context, bool hasPhoto) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(DSSpacing.md),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  'Photo de profil',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                ),
                const SizedBox(height: 16),
                ListTile(
                  leading: const Icon(Icons.photo_library, color: Color(0xFF1E88E5)),
                  title: const Text('Choisir dans la galerie'),
                  onTap: () {
                    Navigator.pop(context);
                    _pickAndUploadPhoto(ImageSource.gallery);
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.camera_alt, color: Color(0xFF1E88E5)),
                  title: const Text('Prendre une photo'),
                  onTap: () {
                    Navigator.pop(context);
                    _pickAndUploadPhoto(ImageSource.camera);
                  },
                ),
                if (hasPhoto)
                  ListTile(
                    leading: const Icon(Icons.delete_outline, color: Colors.red),
                    title: const Text('Supprimer la photo', style: TextStyle(color: Colors.red)),
                    onTap: () {
                      Navigator.pop(context);
                      _deletePhoto();
                    },
                  ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  void dispose() {
    _nomController.dispose();
    _prenomController.dispose();
    _biographieController.dispose();
    _professionController.dispose();
    _nationaliteController.dispose();
    super.dispose();
  }

  void _startEditing(dynamic utilisateur) {
    setState(() {
      _isEditing = true;
      _nomController.text = utilisateur.nom ?? '';
      _prenomController.text = utilisateur.prenom ?? '';
      _biographieController.text = utilisateur.biographie ?? '';
      _professionController.text = utilisateur.profession ?? '';
      _nationaliteController.text = utilisateur.nationalite ?? '';
    });
  }

  Future<void> _saveProfileChanges() async {
    try {
      setState(() => _isUploading = true);

      // Appeler l'API pour mettre à jour le profil
      await ref.read(authProvider.notifier).updateProfile(
        nom: _nomController.text.trim().isEmpty ? null : _nomController.text.trim(),
        prenom: _prenomController.text.trim().isEmpty ? null : _prenomController.text.trim(),
        biographie: _biographieController.text.trim().isEmpty ? null : _biographieController.text.trim(),
        profession: _professionController.text.trim().isEmpty ? null : _professionController.text.trim(),
        nationalite: _nationaliteController.text.trim().isEmpty ? null : _nationaliteController.text.trim(),
      );

      if (mounted) {
        setState(() {
          _isUploading = false;
          _isEditing = false;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Profil mis à jour avec succès'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isUploading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erreur: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Widget _buildEditField(String label, TextEditingController controller, IconData icon, {int maxLines = 1}) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        border: const OutlineInputBorder(),
        prefixIcon: Icon(icon),
      ),
      maxLines: maxLines,
    );
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);
    final utilisateur = authState.utilisateur;
    final theme = Theme.of(context);

    if (utilisateur == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Profil')),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    final hasPhoto = utilisateur.photoUrl != null && utilisateur.photoUrl!.isNotEmpty;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Mon Profil'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            if (Navigator.of(context).canPop()) {
              Navigator.of(context).pop();
            } else {
              context.go(AppConstants.routeHome);
            }
          },
          tooltip: 'Retour',
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Header avec photo de profil Cloudinary
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(DSSpacing.xl),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    theme.colorScheme.primary,
                    theme.colorScheme.primary.withValues(alpha: 0.8),
                  ],
                ),
              ),
              child: Column(
                children: [
                  Stack(
                    children: [
                      GestureDetector(
                        onTap: () => _showPhotoOptions(context, hasPhoto),
                        child: CircleAvatar(
                          radius: 52,
                          backgroundColor: Colors.white,
                          child: CircleAvatar(
                            radius: 49,
                            backgroundColor: theme.colorScheme.primaryContainer,
                            backgroundImage: hasPhoto
                                ? CachedNetworkImageProvider(utilisateur.photoUrl!)
                                : null,
                            child: _isUploading
                                ? const CircularProgressIndicator(color: Colors.white)
                                : (!hasPhoto
                                    ? Text(
                                        utilisateur.prenom.isNotEmpty
                                            ? utilisateur.prenom[0].toUpperCase()
                                            : 'U',
                                        style: TextStyle(
                                          color: theme.colorScheme.primary,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 36,
                                        ),
                                      )
                                    : null),
                          ),
                        ),
                      ),
                      Positioned(
                        bottom: 0,
                        right: 0,
                        child: GestureDetector(
                          onTap: () => _showPhotoOptions(context, hasPhoto),
                          child: Container(
                            padding: const EdgeInsets.all(8),
                            decoration: const BoxDecoration(
                              color: Color(0xFF1E88E5),
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black26,
                                  blurRadius: 4,
                                ),
                              ],
                            ),
                            child: const Icon(
                              Icons.camera_alt,
                              color: Colors.white,
                              size: 18,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: DSSpacing.lg),
                  Text(
                    '${utilisateur.prenom} ${utilisateur.nom}'.trim(),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: DSSpacing.sm),
                  _buildRoleBadge(context, utilisateur.role, theme),
                ],
              ),
            ),
            
            const SizedBox(height: DSSpacing.xl),
            
            // Informations personnelles
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: DSSpacing.xl),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Informations personnelles',
                        style: theme.textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      if (!_isEditing)
                        TextButton.icon(
                          onPressed: () => _startEditing(utilisateur),
                          icon: const Icon(Icons.edit, size: 18),
                          label: const Text('Modifier'),
                        ),
                    ],
                  ),
                  const SizedBox(height: DSSpacing.lg),
                  if (_isEditing) ...[
                    _buildEditField('Nom', _nomController, Icons.person),
                    const SizedBox(height: DSSpacing.md),
                    _buildEditField('Prénom', _prenomController, Icons.person_outline),
                    const SizedBox(height: DSSpacing.md),
                    _buildEditField('Biographie', _biographieController, Icons.description, maxLines: 3),
                    const SizedBox(height: DSSpacing.md),
                    _buildEditField('Profession', _professionController, Icons.work),
                    const SizedBox(height: DSSpacing.md),
                    _buildEditField('Nationalité', _nationaliteController, Icons.flag),
                    const SizedBox(height: DSSpacing.lg),
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton(
                            onPressed: () => setState(() => _isEditing = false),
                            child: const Text('Annuler'),
                          ),
                        ),
                        const SizedBox(width: DSSpacing.md),
                        Expanded(
                          child: ElevatedButton(
                            onPressed: () => _saveProfileChanges(),
                            child: const Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(Icons.save, size: 18),
                                SizedBox(width: 8),
                                Text('Enregistrer'),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ] else ...[
                    _buildInfoCard(
                      context,
                      'Email',
                      utilisateur.email,
                      Icons.email,
                      theme,
                    ),
                    const SizedBox(height: DSSpacing.md),
                    _buildInfoCard(
                      context,
                      'Téléphone',
                      utilisateur.telephone ?? 'Non renseigné',
                      Icons.phone,
                      theme,
                    ),
                    const SizedBox(height: DSSpacing.md),
                    _buildInfoCard(
                      context,
                      'Nom',
                      utilisateur.nom,
                      Icons.person,
                      theme,
                    ),
                    const SizedBox(height: DSSpacing.md),
                    _buildInfoCard(
                      context,
                      'Prénom',
                      utilisateur.prenom,
                      Icons.person_outline,
                      theme,
                    ),
                  ],
                ],
              ),
            ),
            
            const SizedBox(height: DSSpacing.xl),
            
            // Statut du compte
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: DSSpacing.xl),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Statut du compte',
                    style: theme.textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: DSSpacing.lg),
                  _buildInfoCard(
                    context,
                    'Statut',
                    _getStatutLabel(utilisateur.statut.toString()),
                    Icons.verified_user,
                    theme,
                  ),
                  const SizedBox(height: DSSpacing.md),
                  _buildInfoCard(
                    context,
                    'Email vérifié',
                    utilisateur.estVerifie ? 'Oui' : 'Non',
                    Icons.verified,
                    theme,
                  ),
                  const SizedBox(height: DSSpacing.md),
                  if (utilisateur.derniereConnexion != null)
                    _buildInfoCard(
                      context,
                      'Dernière connexion',
                      _formatDate(utilisateur.derniereConnexion!),
                      Icons.access_time,
                      theme,
                    ),
                ],
              ),
            ),
            
            const SizedBox(height: DSSpacing.xl),
            
            // Actions
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: DSSpacing.xl),
              child: DSButton(
                text: 'Changer ma photo de profil',
                icon: Icons.photo_camera,
                onPressed: () => _showPhotoOptions(context, hasPhoto),
                isFullWidth: true,
              ),
            ),
            
            const SizedBox(height: DSSpacing.md),
            
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: DSSpacing.xl),
              child: DSButton(
                text: 'Changer mon mot de passe',
                icon: Icons.lock,
                type: DSButtonType.secondary,
                onPressed: () {},
                isFullWidth: true,
              ),
            ),
            
            const SizedBox(height: DSSpacing.xl),
          ],
        ),
      ),
    );
  }

  Widget _buildRoleBadge(BuildContext context, RoleUtilisateur role, ThemeData theme) {
    String label;
    Color color;
    
    switch (role) {
      case RoleUtilisateur.bailleur:
        label = 'Bailleur';
        color = Colors.orange;
        break;
      case RoleUtilisateur.administrateur:
        label = 'Administrateur';
        color = Colors.red;
        break;
      case RoleUtilisateur.client:
        label = 'Client';
        color = Colors.blue;
        break;
    }
    
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: DSSpacing.md,
        vertical: DSSpacing.sm,
      ),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withValues(alpha: 0.5)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.badge, size: 16, color: color),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              color: color,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoCard(
    BuildContext context,
    String label,
    String value,
    IconData icon,
    ThemeData theme,
  ) {
    return Container(
      padding: const EdgeInsets.all(DSSpacing.md),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: theme.dividerColor),
      ),
      child: Row(
        children: [
          Icon(icon, color: theme.colorScheme.primary),
          const SizedBox(width: DSSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                  ),
                ),
                Text(
                  value,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year} à ${date.hour}:${date.minute.toString().padLeft(2, '0')}';
  }

  String _getStatutLabel(String statut) {
    switch (statut.toUpperCase()) {
      case 'ACTIF':
        return 'Actif';
      case 'EN_ATTENTE':
        return 'En attente';
      case 'BLOQUE':
        return 'Bloqué';
      case 'INACTIF':
        return 'Inactif';
      default:
        return statut;
    }
  }
}
