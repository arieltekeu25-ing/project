import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import '../repositories/media_repository.dart';
import '../../../core/constants/app_constants.dart';
import '../../../shared/design_system/buttons/ds_button.dart';
import '../../../shared/design_system/inputs/ds_text_field.dart';
import '../../../shared/design_system/spacing/ds_spacing.dart';
import '../../authentication/models/enums/statut_compte.dart';
import '../../authentication/providers/auth_provider.dart';
import '../../home/providers/property_provider.dart';

/// Page de publication d'un nouveau logement avec design révisé et responsive
class PublishPropertyPage extends ConsumerStatefulWidget {
  const PublishPropertyPage({super.key});

  @override
  ConsumerState<PublishPropertyPage> createState() => _PublishPropertyPageState();
}

class _PublishPropertyPageState extends ConsumerState<PublishPropertyPage> {
  final _formKey = GlobalKey<FormState>();
  final ImagePicker _picker = ImagePicker();
  final MediaRepository _mediaRepository = MediaRepository();

  // Contrôleurs de champs
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _cityController = TextEditingController();
  final _districtController = TextEditingController();
  final _streetController = TextEditingController();
  final _rentPriceController = TextEditingController();
  final _chargesController = TextEditingController();
  final _depositController = TextEditingController();
  final _surfaceController = TextEditingController();
  final _roomsController = TextEditingController(text: '1');
  final _bedroomsController = TextEditingController(text: '1');
  final _bathroomsController = TextEditingController(text: '1');
  final _floorController = TextEditingController();
  final _latitudeController = TextEditingController();
  final _longitudeController = TextEditingController();
  String _selectedPropertyType = 'APARTMENT';
  bool _furnished = false;
  bool _parking = false;
  bool _balcony = false;
  bool _terrace = false;
  bool _elevator = false;
  bool _garden = false;
  bool _pool = false;
  bool _airConditioning = false;
  bool _heating = false;

  final List<XFile> _pickedImageFiles = [];
  XFile? _pickedVideoFile;
  bool _isSubmitting = false;
  double _uploadProgress = 0.0;
  String _uploadStatusMessage = '';

  final List<Map<String, String>> _propertyTypes = [
    {'value': 'APARTMENT', 'label': 'Appartement'},
    {'value': 'HOUSE', 'label': 'Maison'},
    {'value': 'STUDIO', 'label': 'Studio'},
    {'value': 'LOFT', 'label': 'Loft'},
    {'value': 'VILLA', 'label': 'Villa'},
    {'value': 'TERRACE', 'label': 'Terrasse'},
    {'value': 'OTHER', 'label': 'Autre'},
  ];

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _cityController.dispose();
    _districtController.dispose();
    _streetController.dispose();
    _rentPriceController.dispose();
    _chargesController.dispose();
    _depositController.dispose();
    _surfaceController.dispose();
    _roomsController.dispose();
    _bedroomsController.dispose();
    _bathroomsController.dispose();
    _floorController.dispose();
    _latitudeController.dispose();
    _longitudeController.dispose();
    super.dispose();
  }

  Future<void> _pickImages() async {
    try {
      final selected = await _picker.pickMultiImage(
        imageQuality: 85,
        maxWidth: 1920,
        maxHeight: 1920,
        requestFullMetadata: false,
      );
      if (selected.isNotEmpty) {
        final validFiles = <XFile>[];
        for (final f in selected) {
          try {
            final len = await f.length();
            if (len <= 0) {
              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Fichier inaccessible : ${f.name.isEmpty ? 'image' : f.name}'),
                    backgroundColor: Colors.orange,
                  ),
                );
              }
              continue;
            }
            if (len <= 10 * 1024 * 1024) {
              // Valider la lisibilité immédiatement (évite "Ressource non disponible" plus tard)
              await f.readAsBytes();
              validFiles.add(f);
            } else {
              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Impossible d\'envoyer « ${f.name} ». Taille maximale : 10 Mo.'),
                    backgroundColor: Colors.orange,
                  ),
                );
              }
            }
          } catch (fileErr) {
            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    'Impossible de lire le fichier sélectionné. '
                    'Rouvrez la galerie et réessayez. (${fileErr.toString()})',
                  ),
                  backgroundColor: Colors.red,
                ),
              );
            }
          }
        }
        setState(() {
          _pickedImageFiles.addAll(validFiles);
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erreur sélection images: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _pickVideo() async {
    try {
      final selected = await _picker.pickVideo(
        source: ImageSource.gallery,
        maxDuration: const Duration(minutes: 3),
      );
      if (selected != null) {
        try {
          final len = await selected.length();
          if (len <= 0) {
            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('La vidéo sélectionnée est inaccessible.'),
                  backgroundColor: Colors.orange,
                ),
              );
            }
            return;
          }
          if (len > 100 * 1024 * 1024) {
            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Impossible d\'envoyer cette vidéo. Taille maximale : 100 Mo.'),
                  backgroundColor: Colors.orange,
                ),
              );
            }
            return;
          }
          await selected.readAsBytes();
          setState(() {
            _pickedVideoFile = selected;
          });
        } catch (fileErr) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  'Impossible de lire la vidéo sélectionnée. '
                  'Rouvrez la galerie et réessayez. (${fileErr.toString()})',
                ),
                backgroundColor: Colors.red,
              ),
            );
          }
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erreur sélection vidéo: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _removeImage(int index) {
    setState(() {
      _pickedImageFiles.removeAt(index);
    });
  }

  void _removeVideo() {
    setState(() {
      _pickedVideoFile = null;
    });
  }

  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) return;

    final authState = ref.read(authProvider);
    final utilisateur = authState.utilisateur;

    if (utilisateur?.statut != StatutCompte.actif) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Votre compte doit être validé par un administrateur avant de publier.'),
          backgroundColor: Colors.orange,
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    setState(() {
      _isSubmitting = true;
      _uploadProgress = 0.1;
      _uploadStatusMessage = 'Création du logement dans la base de données...';
    });

    final propertyData = {
      'title': _titleController.text.trim(),
      'description': _descriptionController.text.trim(),
      'property_type': _selectedPropertyType,
      'rent_price': double.tryParse(_rentPriceController.text.trim()) ?? 0.0,
      'charges': double.tryParse(_chargesController.text.trim()),
      'deposit': double.tryParse(_depositController.text.trim()),
      'surface': double.tryParse(_surfaceController.text.trim()) ?? 0.0,
      'rooms': int.tryParse(_roomsController.text.trim()) ?? 1,
      'bedrooms': int.tryParse(_bedroomsController.text.trim()) ?? 1,
      'bathrooms': int.tryParse(_bathroomsController.text.trim()) ?? 1,
      'floor': int.tryParse(_floorController.text.trim()),
      'furnished': _furnished,
      'parking': _parking,
      'balcony': _balcony,
      'terrace': _terrace,
      'elevator': _elevator,
      'garden': _garden,
      'pool': _pool,
      'air_conditioning': _airConditioning,
      'heating': _heating,
      'latitude': double.tryParse(_latitudeController.text.trim()),
      'longitude': double.tryParse(_longitudeController.text.trim()),
      'address_details': {
        'city': _cityController.text.trim(),
        'district': _districtController.text.trim(),
        'street': _streetController.text.trim(),
      },
    };

    try {
      final createdProperty = await ref.read(propertyProvider.notifier).createProperty(propertyData);

      final filesToUpload = <XFile>[..._pickedImageFiles];
      if (_pickedVideoFile != null) {
        filesToUpload.add(_pickedVideoFile!);
      }

      if (filesToUpload.isNotEmpty) {
        setState(() {
          _uploadStatusMessage = 'Téléversement réel de ${filesToUpload.length} média(s) vers Cloudinary...';
        });

        try {
          await _mediaRepository.uploadPropertyMedia(
            propertyId: createdProperty.id,
            files: filesToUpload,
            onProgress: (progress) {
              if (mounted) {
                setState(() {
                  _uploadProgress = 0.2 + (progress * 0.6);
                });
              }
            },
          );
        } catch (uploadError) {
          if (kDebugMode) {
            debugPrint('[UPLOAD] Erreur upload: $uploadError');
          }
          if (mounted) {
            setState(() {
              _isSubmitting = false;
              _uploadProgress = 0.0;
            });
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Erreur lors de l\'upload: ${uploadError.toString()}'),
                backgroundColor: Colors.red,
                duration: const Duration(seconds: 5),
              ),
            );
            return;
          }
        }
      }

      setState(() {
        _uploadStatusMessage = 'Publication du logement...';
        _uploadProgress = 0.85;
      });

      await ref.read(propertyProvider.notifier).publishProperty(createdProperty.id);

      if (mounted) {
        setState(() {
          _uploadProgress = 1.0;
          _uploadStatusMessage = 'Publication terminée avec succès !';
          _isSubmitting = false;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Logement et médias Cloudinary publiés avec succès !'),
            backgroundColor: Colors.green,
            behavior: SnackBarBehavior.floating,
          ),
        );
        context.go(AppConstants.routeLandlordDashboard);
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isSubmitting = false;
          _uploadProgress = 0.0;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erreur lors de la publication: ${e.toString()}'),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  Widget _buildSectionCard(BuildContext context, {required String title, required IconData icon, required Widget child}) {
    final theme = Theme.of(context);
    return LayoutBuilder(
      builder: (context, constraints) {
        final isSmallMobile = constraints.maxWidth < 400;
        final padding = isSmallMobile ? DSSpacing.md : DSSpacing.lg;
        
        return Card(
          elevation: 2,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          child: Padding(
            padding: EdgeInsets.all(padding),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: EdgeInsets.all(isSmallMobile ? 6 : 8),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.primary.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(icon, color: theme.colorScheme.primary, size: isSmallMobile ? 18 : 22),
                    ),
                    SizedBox(width: isSmallMobile ? DSSpacing.sm : DSSpacing.md),
                    Expanded(
                      child: Text(
                        title,
                        style: theme.textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                          fontSize: isSmallMobile ? 18 : 20,
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: isSmallMobile ? DSSpacing.md : DSSpacing.lg),
                child,
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final authState = ref.watch(authProvider);
    final utilisateur = authState.utilisateur;
    final isVerified = utilisateur?.statut == StatutCompte.actif;

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          tooltip: 'Retour',
          onPressed: () {
            if (Navigator.of(context).canPop()) {
              Navigator.of(context).pop();
            } else {
              context.go(AppConstants.routeLandlordDashboard);
            }
          },
        ),
        title: const Text('Publier un logement', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: theme.colorScheme.primary,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.asset(
                'assetes/images/logo.png',
                width: 24,
                height: 24,
                fit: BoxFit.contain,
                errorBuilder: (context, error, stackTrace) {
                  return const Icon(Icons.home_outlined);
                },
              ),
            ),
            tooltip: 'Accueil',
            onPressed: () => context.go(AppConstants.routeHome),
          ),
          IconButton(
            icon: const Icon(Icons.dashboard_outlined),
            tooltip: 'Mon Dashboard',
            onPressed: () => context.go(AppConstants.routeLandlordDashboard),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          final isSmallMobile = constraints.maxWidth < 400;
          final isMobile = constraints.maxWidth < 600;
          final maxWidth = isMobile ? double.infinity : 850.0;
          final padding = isSmallMobile ? DSSpacing.md : DSSpacing.lg;
          
          return SingleChildScrollView(
            child: Column(
              children: [
                // Banner d'en-tête héroïque
                Container(
                  width: double.infinity,
                  padding: EdgeInsets.symmetric(vertical: isSmallMobile ? DSSpacing.lg : DSSpacing.xl, horizontal: padding),
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
                  child: Center(
                    child: ConstrainedBox(
                      constraints: BoxConstraints(maxWidth: maxWidth),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Container(
                                padding: EdgeInsets.all(isSmallMobile ? 8 : 12),
                                decoration: BoxDecoration(
                                  color: Colors.white.withValues(alpha: 0.2),
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                child: Icon(Icons.add_home_work_rounded, color: Colors.white, size: isSmallMobile ? 24 : 32),
                              ),
                              SizedBox(width: isSmallMobile ? DSSpacing.sm : DSSpacing.md),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Formulaire de Publication',
                                      style: TextStyle(color: Colors.white, fontSize: isSmallMobile ? 18 : 24, fontWeight: FontWeight.bold),
                                    ),
                                    Text(
                                      'Remplissez les détails réels de votre bien pour le rendre visible auprès des clients.',
                                      style: TextStyle(color: Colors.white.withValues(alpha: 0.9), fontSize: isSmallMobile ? 12 : 14),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),

                Padding(
                  padding: EdgeInsets.all(padding),
                  child: Center(
                    child: ConstrainedBox(
                      constraints: BoxConstraints(maxWidth: maxWidth),
                      child: Form(
                        key: _formKey,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Alerte si compte non vérifié
                            if (!isVerified)
                              Container(
                                padding: EdgeInsets.all(isSmallMobile ? DSSpacing.sm : DSSpacing.md),
                                margin: EdgeInsets.only(bottom: isSmallMobile ? DSSpacing.md : DSSpacing.lg),
                                decoration: BoxDecoration(
                                  color: Colors.orange.withValues(alpha: 0.15),
                                  borderRadius: BorderRadius.circular(16),
                                  border: Border.all(color: Colors.orange.withValues(alpha: 0.4)),
                                ),
                                child: Row(
                                  children: [
                                    Icon(Icons.warning_amber_rounded, color: Colors.orange, size: isSmallMobile ? 28 : 36),
                                    SizedBox(width: isSmallMobile ? DSSpacing.sm : DSSpacing.md),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            'Compte en attente de validation',
                                            style: TextStyle(fontWeight: FontWeight.bold, color: Colors.orange, fontSize: isSmallMobile ? 14 : 16),
                                          ),
                                          SizedBox(height: isSmallMobile ? 2 : 4),
                                          Text(
                                            'Votre compte bailleur doit être approuvé par un administrateur avant d\'activer la publication publique.',
                                            style: TextStyle(color: theme.colorScheme.onSurface.withValues(alpha: 0.8), fontSize: isSmallMobile ? 12 : 14),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),

                        // Section 1 : Informations générales
                        _buildSectionCard(
                          context,
                          title: '1. Informations Générales',
                          icon: Icons.info_outline,
                          child: Column(
                            children: [
                              DSTextField(
                                label: 'Titre de l\'annonce',
                                hint: 'Ex: Superbe appartement 3 pièces au centre-ville',
                                controller: _titleController,
                                validator: (v) => v == null || v.trim().isEmpty ? 'Veuillez saisir un titre' : null,
                              ),
                              const SizedBox(height: DSSpacing.md),
                              DSTextField(
                                label: 'Description détaillée',
                                hint: 'Décrivez précisément le logement, les pièces, les atouts...',
                                controller: _descriptionController,
                                type: DSTextFieldType.multiline,
                                maxLines: 4,
                                validator: (v) => v == null || v.trim().isEmpty ? 'Veuillez saisir une description' : null,
                              ),
                              const SizedBox(height: DSSpacing.md),
                              DropdownButtonFormField<String>(
                                initialValue: _selectedPropertyType,
                                decoration: const InputDecoration(
                                  labelText: 'Type de logement',
                                  border: OutlineInputBorder(),
                                ),
                                items: _propertyTypes.map((pt) {
                                  return DropdownMenuItem(value: pt['value'], child: Text(pt['label']!));
                                }).toList(),
                                onChanged: (val) {
                                  if (val != null) setState(() => _selectedPropertyType = val);
                                },
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: DSSpacing.lg),

                        // Section 2 : Localisation & Géolocalisation
                        _buildSectionCard(
                          context,
                          title: '2. Localisation & Géolocalisation',
                          icon: Icons.location_on_outlined,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              LayoutBuilder(
                                builder: (context, constraints) {
                                  final isSmallMobile = constraints.maxWidth < 400;
                                  final isMobile = constraints.maxWidth < 600;
                                  
                                  if (isMobile) {
                                    return Column(
                                      children: [
                                        DSTextField(
                                          label: 'Ville',
                                          hint: 'Ex: Douala',
                                          controller: _cityController,
                                          validator: (v) => v == null || v.trim().isEmpty ? 'Veuillez préciser la ville' : null,
                                        ),
                                        SizedBox(height: isSmallMobile ? DSSpacing.sm : DSSpacing.md),
                                        DSTextField(
                                          label: 'Quartier',
                                          hint: 'Ex: Akwa',
                                          controller: _districtController,
                                          validator: (v) => v == null || v.trim().isEmpty ? 'Veuillez préciser le quartier' : null,
                                        ),
                                      ],
                                    );
                                  } else {
                                    return Row(
                                      children: [
                                        Expanded(
                                          child: DSTextField(
                                            label: 'Ville',
                                            hint: 'Ex: Douala',
                                            controller: _cityController,
                                            validator: (v) => v == null || v.trim().isEmpty ? 'Veuillez préciser la ville' : null,
                                          ),
                                        ),
                                        SizedBox(width: isSmallMobile ? DSSpacing.sm : DSSpacing.md),
                                        Expanded(
                                          child: DSTextField(
                                            label: 'Quartier',
                                            hint: 'Ex: Akwa',
                                            controller: _districtController,
                                            validator: (v) => v == null || v.trim().isEmpty ? 'Veuillez préciser le quartier' : null,
                                          ),
                                        ),
                                      ],
                                    );
                                  }
                                },
                              ),
                              const SizedBox(height: DSSpacing.md),
                              DSTextField(
                                label: 'Adresse exacte',
                                hint: 'Ex: Rue Boué de Lapeyrère',
                                controller: _streetController,
                              ),
                              LayoutBuilder(
                                builder: (context, constraints) {
                                  final isSmallMobile = constraints.maxWidth < 400;
                                  final isMobile = constraints.maxWidth < 600;
                                  
                                  if (isMobile) {
                                    return Column(
                                      children: [
                                        DSTextField(
                                          label: 'Latitude (GPS)',
                                          hint: 'Ex: 4.0511',
                                          controller: _latitudeController,
                                          type: DSTextFieldType.price,
                                        ),
                                        SizedBox(height: isSmallMobile ? DSSpacing.sm : DSSpacing.md),
                                        DSTextField(
                                          label: 'Longitude (GPS)',
                                          hint: 'Ex: 9.7679',
                                          controller: _longitudeController,
                                          type: DSTextFieldType.price,
                                        ),
                                      ],
                                    );
                                  } else {
                                    return Row(
                                      children: [
                                        Expanded(
                                          child: DSTextField(
                                            label: 'Latitude (GPS)',
                                            hint: 'Ex: 4.0511',
                                            controller: _latitudeController,
                                            type: DSTextFieldType.price,
                                          ),
                                        ),
                                        SizedBox(width: isSmallMobile ? DSSpacing.sm : DSSpacing.md),
                                        Expanded(
                                          child: DSTextField(
                                            label: 'Longitude (GPS)',
                                            hint: 'Ex: 9.7679',
                                            controller: _longitudeController,
                                            type: DSTextFieldType.price,
                                          ),
                                        ),
                                      ],
                                    );
                                  }
                                },
                              ),
                              const SizedBox(height: DSSpacing.md),
                              OutlinedButton.icon(
                                onPressed: () {
                                  setState(() {
                                    _latitudeController.text = '4.0511';
                                    _longitudeController.text = '9.7679';
                                    if (_cityController.text.isEmpty) _cityController.text = 'Douala';
                                    if (_districtController.text.isEmpty) _districtController.text = 'Akwa';
                                  });
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text('Coordonnées GPS capturées (Douala - 4.0511, 9.7679).'),
                                      behavior: SnackBarBehavior.floating,
                                    ),
                                  );
                                },
                                icon: const Icon(Icons.my_location, size: 18),
                                label: const Text('Utiliser ma position GPS actuelle'),
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: DSSpacing.lg),

                        // Section 3 : Tarification
                        _buildSectionCard(
                          context,
                          title: '3. Tarification & Conditions',
                          icon: Icons.payments_outlined,
                          child: Column(
                            children: [
                              LayoutBuilder(
                                builder: (context, constraints) {
                                  if (constraints.maxWidth > 500) {
                                    return Row(
                                      children: [
                                        Expanded(
                                          child: DSTextField(
                                            label: 'Prix du loyer (FCFA/mois)',
                                            hint: 'Ex: 150000',
                                            controller: _rentPriceController,
                                            type: DSTextFieldType.price,
                                            validator: (v) => v == null || v.trim().isEmpty ? 'Saisissez le prix du loyer' : null,
                                          ),
                                        ),
                                        const SizedBox(width: DSSpacing.md),
                                        Expanded(
                                          child: DSTextField(
                                            label: 'Charges (FCFA/mois)',
                                            hint: 'Ex: 10000 (optionnel)',
                                            controller: _chargesController,
                                            type: DSTextFieldType.price,
                                          ),
                                        ),
                                      ],
                                    );
                                  } else {
                                    return Column(
                                      children: [
                                        DSTextField(
                                          label: 'Prix du loyer (FCFA/mois)',
                                          hint: 'Ex: 150000',
                                          controller: _rentPriceController,
                                          type: DSTextFieldType.price,
                                          validator: (v) => v == null || v.trim().isEmpty ? 'Saisissez le prix du loyer' : null,
                                        ),
                                        const SizedBox(height: DSSpacing.md),
                                        DSTextField(
                                          label: 'Charges (FCFA/mois)',
                                          hint: 'Ex: 10000 (optionnel)',
                                          controller: _chargesController,
                                          type: DSTextFieldType.price,
                                        ),
                                      ],
                                    );
                                  }
                                },
                              ),
                              const SizedBox(height: DSSpacing.md),
                              DSTextField(
                                label: 'Caution demandée (FCFA)',
                                hint: 'Ex: 300000 (optionnel)',
                                controller: _depositController,
                                type: DSTextFieldType.price,
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: DSSpacing.lg),

                        // Section 4 : Caractéristiques & Équipements
                        _buildSectionCard(
                          context,
                          title: '4. Caractéristiques & Prestations',
                          icon: Icons.straighten_outlined,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Expanded(
                                    child: DSTextField(
                                      label: 'Surface (m²)',
                                      hint: 'Ex: 75',
                                      controller: _surfaceController,
                                      type: DSTextFieldType.price,
                                      validator: (v) => v == null || v.trim().isEmpty ? 'Saisissez la surface' : null,
                                    ),
                                  ),
                                  const SizedBox(width: DSSpacing.md),
                                  Expanded(
                                    child: DSTextField(
                                      label: 'Nombre de pièces',
                                      hint: 'Ex: 3',
                                      controller: _roomsController,
                                      type: DSTextFieldType.price,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: DSSpacing.md),
                              Row(
                                children: [
                                  Expanded(
                                    child: DSTextField(
                                      label: 'Chambres',
                                      hint: 'Ex: 2',
                                      controller: _bedroomsController,
                                      type: DSTextFieldType.price,
                                    ),
                                  ),
                                  const SizedBox(width: DSSpacing.md),
                                  Expanded(
                                    child: DSTextField(
                                      label: 'Salles de bain',
                                      hint: 'Ex: 1',
                                      controller: _bathroomsController,
                                      type: DSTextFieldType.price,
                                    ),
                                  ),
                                  const SizedBox(width: DSSpacing.md),
                                  Expanded(
                                    child: DSTextField(
                                      label: 'Étage',
                                      hint: 'Ex: 2',
                                      controller: _floorController,
                                      type: DSTextFieldType.price,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: DSSpacing.lg),
                              Text('Équipements & Commodités', style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
                              const SizedBox(height: DSSpacing.sm),
                              LayoutBuilder(
                                builder: (context, constraints) {
                                  final isSmallMobile = constraints.maxWidth < 400;
                                  
                                  return Wrap(
                                    spacing: isSmallMobile ? 6 : 8,
                                    runSpacing: isSmallMobile ? 6 : 8,
                                    children: [
                                      FilterChip(label: const Text('Meublé'), selected: _furnished, onSelected: (v) => setState(() => _furnished = v)),
                                      FilterChip(label: const Text('Parking'), selected: _parking, onSelected: (v) => setState(() => _parking = v)),
                                      FilterChip(label: const Text('Balcon'), selected: _balcony, onSelected: (v) => setState(() => _balcony = v)),
                                      FilterChip(label: const Text('Terrasse'), selected: _terrace, onSelected: (v) => setState(() => _terrace = v)),
                                      FilterChip(label: const Text('Ascenseur'), selected: _elevator, onSelected: (v) => setState(() => _elevator = v)),
                                      FilterChip(label: const Text('Jardin'), selected: _garden, onSelected: (v) => setState(() => _garden = v)),
                                      FilterChip(label: const Text('Piscine'), selected: _pool, onSelected: (v) => setState(() => _pool = v)),
                                      FilterChip(label: const Text('Climatisation'), selected: _airConditioning, onSelected: (v) => setState(() => _airConditioning = v)),
                                      FilterChip(label: const Text('Chauffage'), selected: _heating, onSelected: (v) => setState(() => _heating = v)),
                                    ],
                                  );
                                },
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: DSSpacing.lg),

                        // Section 5 : Photos & Vidéo du Logement (Cloudinary)
                        _buildSectionCard(
                          context,
                          title: '5. Médias du Logement (Cloudinary)',
                          icon: Icons.photo_library_outlined,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Wrap(
                                spacing: 12,
                                runSpacing: 12,
                                children: [
                                  ElevatedButton.icon(
                                    onPressed: _isSubmitting ? null : _pickImages,
                                    icon: const Icon(Icons.add_photo_alternate, size: 20),
                                    label: Text('Ajouter des photos (${_pickedImageFiles.length})'),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: const Color(0xFF1E88E5),
                                      foregroundColor: Colors.white,
                                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                                    ),
                                  ),
                                  OutlinedButton.icon(
                                    onPressed: _isSubmitting ? null : _pickVideo,
                                    icon: Icon(
                                      _pickedVideoFile != null ? Icons.check_circle : Icons.video_call,
                                      size: 20,
                                      color: _pickedVideoFile != null ? Colors.green : const Color(0xFF1E88E5),
                                    ),
                                    label: Text(
                                      _pickedVideoFile != null ? 'Vidéo sélectionnée' : 'Ajouter une vidéo (MP4/MOV)',
                                    ),
                                    style: OutlinedButton.styleFrom(
                                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                                    ),
                                  ),
                                ],
                              ),

                              if (_pickedImageFiles.isNotEmpty || _pickedVideoFile != null) ...[
                                const SizedBox(height: DSSpacing.md),
                                Text(
                                  'Aperçu des médias avant envoi Cloudinary :',
                                  style: theme.textTheme.bodySmall?.copyWith(fontWeight: FontWeight.bold),
                                ),
                                const SizedBox(height: DSSpacing.sm),
                                Wrap(
                                  spacing: 12,
                                  runSpacing: 12,
                                  children: [
                                    ..._pickedImageFiles.asMap().entries.map((entry) {
                                      final idx = entry.key;
                                      final file = entry.value;
                                      return Stack(
                                        children: [
                                          Container(
                                            width: 100,
                                            height: 100,
                                            decoration: BoxDecoration(
                                              borderRadius: BorderRadius.circular(12),
                                              border: Border.all(
                                                color: idx == 0 ? theme.colorScheme.primary : theme.dividerColor,
                                                width: idx == 0 ? 2 : 1,
                                              ),
                                              color: Colors.grey.shade200,
                                            ),
                                            clipBehavior: Clip.antiAlias,
                                            child: FutureBuilder<Uint8List>(
                                              future: file.readAsBytes(),
                                              builder: (context, snapshot) {
                                                if (snapshot.hasData) {
                                                  return Image.memory(
                                                    snapshot.data!,
                                                    fit: BoxFit.cover,
                                                    width: 100,
                                                    height: 100,
                                                    errorBuilder: (context, error, stackTrace) => const Column(
                                                      mainAxisAlignment: MainAxisAlignment.center,
                                                      children: [
                                                        Icon(Icons.broken_image, color: Colors.grey, size: 28),
                                                        SizedBox(height: 4),
                                                        Text('Illisible', style: TextStyle(fontSize: 10)),
                                                      ],
                                                    ),
                                                  );
                                                }
                                                if (snapshot.hasError) {
                                                  return const Column(
                                                    mainAxisAlignment: MainAxisAlignment.center,
                                                    children: [
                                                      Icon(Icons.error_outline, color: Colors.red, size: 28),
                                                      SizedBox(height: 4),
                                                      Text('Erreur', style: TextStyle(fontSize: 10)),
                                                    ],
                                                  );
                                                }
                                                return const Center(
                                                  child: SizedBox(
                                                    width: 20,
                                                    height: 20,
                                                    child: CircularProgressIndicator(strokeWidth: 2),
                                                  ),
                                                );
                                              },
                                            ),
                                          ),
                                          if (idx == 0)
                                            Positioned(
                                              bottom: 4,
                                              left: 4,
                                              child: Container(
                                                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                                decoration: BoxDecoration(
                                                  color: theme.colorScheme.primary,
                                                  borderRadius: BorderRadius.circular(4),
                                                ),
                                                child: const Text(
                                                  'Principale',
                                                  style: TextStyle(color: Colors.white, fontSize: 9, fontWeight: FontWeight.bold),
                                                ),
                                              ),
                                            ),
                                          Positioned(
                                            top: 4,
                                            right: 4,
                                            child: GestureDetector(
                                              onTap: () => _removeImage(idx),
                                              child: Container(
                                                padding: const EdgeInsets.all(4),
                                                decoration: const BoxDecoration(color: Colors.red, shape: BoxShape.circle),
                                                child: const Icon(Icons.close, size: 12, color: Colors.white),
                                              ),
                                            ),
                                          ),
                                        ],
                                      );
                                    }),
                                    if (_pickedVideoFile != null)
                                      Stack(
                                        children: [
                                          Container(
                                            width: 100,
                                            height: 100,
                                            decoration: BoxDecoration(
                                              borderRadius: BorderRadius.circular(12),
                                              color: Colors.black87,
                                            ),
                                            child: const Column(
                                              mainAxisAlignment: MainAxisAlignment.center,
                                              children: [
                                                Icon(Icons.play_circle_fill, color: Colors.amber, size: 36),
                                                SizedBox(height: 4),
                                                Text('Vidéo', style: TextStyle(color: Colors.white, fontSize: 10)),
                                              ],
                                            ),
                                          ),
                                          Positioned(
                                            top: 4,
                                            right: 4,
                                            child: GestureDetector(
                                              onTap: _removeVideo,
                                              child: Container(
                                                padding: const EdgeInsets.all(4),
                                                decoration: const BoxDecoration(color: Colors.red, shape: BoxShape.circle),
                                                child: const Icon(Icons.close, size: 12, color: Colors.white),
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                  ],
                                ),
                              ],

                              if (_isSubmitting) ...[
                                const SizedBox(height: DSSpacing.lg),
                                Container(
                                  padding: const EdgeInsets.all(DSSpacing.md),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFF1E88E5).withValues(alpha: 0.1),
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(color: const Color(0xFF1E88E5).withValues(alpha: 0.3)),
                                  ),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        children: [
                                          const SizedBox(
                                            width: 18,
                                            height: 18,
                                            child: CircularProgressIndicator(strokeWidth: 2, color: Color(0xFF1E88E5)),
                                          ),
                                          const SizedBox(width: 12),
                                          Expanded(
                                            child: Text(
                                              _uploadStatusMessage,
                                              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                                            ),
                                          ),
                                          Text(
                                            '${(_uploadProgress * 100).toInt()}%',
                                            style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF1E88E5)),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 8),
                                      LinearProgressIndicator(
                                        value: _uploadProgress,
                                        backgroundColor: Colors.grey.shade300,
                                        color: const Color(0xFF1E88E5),
                                        minHeight: 6,
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ),

                        LayoutBuilder(
                          builder: (context, constraints) {
                            final isSmallMobile = constraints.maxWidth < 400;
                            
                            return Column(
                              children: [
                                SizedBox(height: isSmallMobile ? DSSpacing.lg : DSSpacing.xxl),

                                // Bouton principal de soumission
                                DSButton(
                                  text: _isSubmitting ? 'Publication en cours...' : 'Publier mon logement',
                                  icon: Icons.publish_rounded,
                                  onPressed: isVerified && !_isSubmitting ? _submitForm : null,
                                  isFullWidth: true,
                                  size: isSmallMobile ? DSButtonSize.medium : DSButtonSize.large,
                                ),

                                SizedBox(height: isSmallMobile ? DSSpacing.lg : DSSpacing.xl),
                              ],
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      );
    },
  ),
  );
  }
}
