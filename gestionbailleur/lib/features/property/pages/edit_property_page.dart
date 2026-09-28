import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../../core/constants/app_constants.dart';
import '../../../shared/design_system/spacing/ds_spacing.dart';
import '../../authentication/providers/auth_provider.dart';
import '../../home/models/property_model.dart';
import '../../home/providers/property_provider.dart';
import '../../property/repositories/media_repository.dart';

/// Page de modification d'un logement avec préchargement des données réelles depuis l'API
class EditPropertyPage extends ConsumerStatefulWidget {
  final String propertyId;

  const EditPropertyPage({super.key, required this.propertyId});

  @override
  ConsumerState<EditPropertyPage> createState() => _EditPropertyPageState();
}

class _EditPropertyPageState extends ConsumerState<EditPropertyPage> {
  final _formKey = GlobalKey<FormState>();
  final ImagePicker _picker = ImagePicker();
  final MediaRepository _mediaRepository = MediaRepository();

  // Contrôleurs de champs
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _rentPriceController = TextEditingController();
  String _selectedPropertyType = 'APARTMENT';
  bool _isSubmitting = false;
  bool _isLoading = true;
  bool _isUploadingImage = false;
  String? _errorMessage;
  List<String> _images = [];

  final List<Map<String, String>> _propertyTypes = [
    {'value': 'APARTMENT', 'label': 'Appartement'},
    {'value': 'HOUSE', 'label': 'Maison'},
    {'value': 'STUDIO', 'label': 'Studio'},
    {'value': 'LOFT', 'label': 'Loft'},
    {'value': 'VILLA', 'label': 'Villa'},
    {'value': 'TERRACE', 'label': 'Terrasse'},
    {'value': 'OTHER', 'label': 'Autre'},
  ];

  PropertyModel? _existingProperty;

  @override
  void initState() {
    super.initState();
    // Déplacer l'appel hors de la construction du widget
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadPropertyData();
    });
  }

  Future<void> _loadPropertyData() async {
    setState(() => _isLoading = true);
    try {
      // Charger directement depuis l'API pour avoir les données à jour
      if (kDebugMode) {
        print('Loading property with ID: ${widget.propertyId}');
      }
      await ref.read(propertyProvider.notifier).loadPropertyById(widget.propertyId);
      
      final propertyState = ref.read(propertyProvider);
      final loadedProperty = propertyState.selectedProperty;
      
      if (loadedProperty == null || loadedProperty.id != widget.propertyId) {
        setState(() {
          _isLoading = false;
          _errorMessage = 'Logement non trouvé. Veuillez réessayer.';
        });
        return;
      }
      
      _existingProperty = loadedProperty;

      // Précharger les champs avec les données existantes
      _titleController.text = _existingProperty!.title;
      _descriptionController.text = _existingProperty!.description;
      _rentPriceController.text = _existingProperty!.rentPrice.toString();
      _selectedPropertyType = _existingProperty!.propertyType;
      _images = List.from(_existingProperty!.images);

      setState(() => _isLoading = false);
    } catch (e) {
      if (kDebugMode) {
        print('Error loading property: $e');
      }
      setState(() {
        _isLoading = false;
        _errorMessage = 'Erreur lors du chargement des données: $e';
      });
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _rentPriceController.dispose();
    super.dispose();
  }

  Future<void> _pickAndUploadImage() async {
    try {
      final XFile? file = await _picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1200,
        maxHeight: 800,
        imageQuality: 85,
      );

      if (file == null) return;

      setState(() => _isUploadingImage = true);

      final imageUrl = await _mediaRepository.uploadPropertyImage(file, propertyId: widget.propertyId);

      if (mounted) {
        setState(() {
          _isUploadingImage = false;
        });

        if (imageUrl != null && imageUrl.isNotEmpty) {
          setState(() {
            _images.add(imageUrl);
          });
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Image ajoutée avec succès!'),
              backgroundColor: Colors.green,
            ),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Échec de l\'upload de l\'image.'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isUploadingImage = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erreur: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _removeImage(int index) {
    setState(() {
      _images.removeAt(index);
    });
  }

  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() => _isSubmitting = true);

    try {
      // Préparer les données de base
      final propertyData = {
        'title': _titleController.text.trim(),
        'description': _descriptionController.text.trim(),
        'property_type': _selectedPropertyType,
        'rent_price': double.tryParse(_rentPriceController.text) ?? 0,
        'images': _images,
        'main_photo': _images.isNotEmpty ? _images.first : null,
      };

      // Appeler l'API pour mettre à jour la propriété
      await ref.read(propertyProvider.notifier).updateProperty(
        widget.propertyId,
        propertyData,
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Logement mis à jour avec succès!'),
            backgroundColor: Colors.green,
          ),
        );
        context.go(AppConstants.routeLandlordDashboard);
      }
    } catch (e) {
      setState(() => _isSubmitting = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erreur: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);
    final theme = Theme.of(context);

    if (!authState.estAuthentifie) {
      return Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.lock_outline, size: 64, color: Colors.grey),
              const SizedBox(height: 16),
              const Text('Vous devez être connecté pour modifier un logement'),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () => context.go(AppConstants.routeLogin),
                child: const Text('Se connecter'),
              ),
            ],
          ),
        ),
      );
    }

    if (_isLoading) {
      return Scaffold(
        appBar: AppBar(title: const Text('Chargement...')),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    if (_errorMessage != null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Erreur')),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.error_outline, size: 64, color: Colors.red),
                const SizedBox(height: 16),
                Text(_errorMessage!),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () => context.pop(),
                  child: const Text('Retour'),
                ),
              ],
            ),
          ),
        ),
      );
    }

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
        title: const Text('Modifier le logement'),
        backgroundColor: theme.colorScheme.primary,
        foregroundColor: Colors.white,
        actions: [
          if (_isSubmitting)
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              ),
            ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(DSSpacing.lg),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Informations de base
              Text(
                'Informations de base',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.blue,
                ),
              ),
              const SizedBox(height: DSSpacing.md),
              TextFormField(
                controller: _titleController,
                decoration: const InputDecoration(
                  labelText: 'Titre',
                  hintText: 'Ex: Appartement 3 pièces centre-ville',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Le titre est requis';
                  }
                  return null;
                },
              ),
              const SizedBox(height: DSSpacing.md),
              TextFormField(
                controller: _descriptionController,
                decoration: const InputDecoration(
                  labelText: 'Description',
                  hintText: 'Décrivez votre logement...',
                  border: OutlineInputBorder(),
                ),
                maxLines: 5,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'La description est requise';
                  }
                  return null;
                },
              ),
              const SizedBox(height: DSSpacing.lg),

              // Type de logement
              Text(
                'Type de logement',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.blue,
                ),
              ),
              const SizedBox(height: DSSpacing.md),
              DropdownButtonFormField<String>(
                initialValue: _selectedPropertyType,
                decoration: const InputDecoration(
                  labelText: 'Type',
                  border: OutlineInputBorder(),
                ),
                items: _propertyTypes.map((type) {
                  return DropdownMenuItem<String>(
                    value: type['value'],
                    child: Text(type['label']!),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() => _selectedPropertyType = value!);
                },
              ),
              const SizedBox(height: DSSpacing.lg),

              // Photos du logement
              Text(
                'Photos du logement',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.blue,
                ),
              ),
              const SizedBox(height: DSSpacing.md),
              if (_images.isNotEmpty)
                SizedBox(
                  height: 200,
                  child: GridView.builder(
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 3,
                      crossAxisSpacing: 8,
                      mainAxisSpacing: 8,
                    ),
                    itemCount: _images.length,
                    itemBuilder: (context, index) {
                      return Stack(
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: CachedNetworkImage(
                              imageUrl: _images[index],
                              width: double.infinity,
                              height: double.infinity,
                              fit: BoxFit.cover,
                              placeholder: (context, url) => Container(
                                color: Colors.grey[300],
                                child: const Center(child: CircularProgressIndicator()),
                              ),
                              errorWidget: (context, url, error) => Container(
                                color: Colors.grey[300],
                                child: const Icon(Icons.error),
                              ),
                            ),
                          ),
                          Positioned(
                            top: 4,
                            right: 4,
                            child: GestureDetector(
                              onTap: () => _removeImage(index),
                              child: Container(
                                padding: const EdgeInsets.all(4),
                                decoration: BoxDecoration(
                                  color: Colors.red,
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: const Icon(
                                  Icons.close,
                                  color: Colors.white,
                                  size: 16,
                                ),
                              ),
                            ),
                          ),
                        ],
                      );
                    },
                  ),
                ),
              const SizedBox(height: DSSpacing.md),
              ElevatedButton.icon(
                onPressed: _isUploadingImage ? null : _pickAndUploadImage,
                icon: _isUploadingImage
                    ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.add_photo_alternate),
                label: Text(_isUploadingImage ? 'Upload en cours...' : 'Ajouter une photo'),
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 48),
                ),
              ),
              const SizedBox(height: DSSpacing.xl),

              // Prix
              Text(
                'Prix',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.blue,
                ),
              ),
              const SizedBox(height: DSSpacing.md),
              TextFormField(
                controller: _rentPriceController,
                decoration: const InputDecoration(
                  labelText: 'Loyer (FCFA)',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Le prix est requis';
                  }
                  if (double.tryParse(value) == null) {
                    return 'Prix invalide';
                  }
                  return null;
                },
              ),
              const SizedBox(height: DSSpacing.xl),

              // Boutons d'action
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => context.pop(),
                      child: const Text('Annuler'),
                    ),
                  ),
                  const SizedBox(width: DSSpacing.md),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: _isSubmitting ? null : _submitForm,
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
            ],
          ),
        ),
      ),
    );
  }
}