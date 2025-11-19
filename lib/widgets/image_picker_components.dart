import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:get/get.dart';

/// Image Picker and Preview Components for Product Images
class ImagePickerWidget extends StatefulWidget {
  final Function(Map<String, dynamic>?) onImageSelected; // Now returns image data map or null
  final String? initialImageUrl;
  final String? imagePath;
  final String labelText;
  final double? width;
  final double? height;

  const ImagePickerWidget({
    super.key,
    required this.onImageSelected,
    this.initialImageUrl,
    this.imagePath,
    this.labelText = 'Product Image',
    this.width = 120,
    this.height = 120,
  });

  @override
  State<ImagePickerWidget> createState() => _ImagePickerWidgetState();
}

class _ImagePickerWidgetState extends State<ImagePickerWidget> {
  final ImagePicker _picker = ImagePicker();
  XFile? _pickedFile;
  File? _imageFile;
  Uint8List? _imageBytes;

  @override
  void initState() {
    super.initState();
    if (widget.imagePath != null) {
      _imageFile = File(widget.imagePath!);
      _loadImageBytes();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          widget.labelText,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
        ),
        const SizedBox(height: 8),
        GestureDetector(
          onTap: () => _pickImage(ImageSource.gallery),
          child: Container(
            width: widget.width,
            height: widget.height,
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey.shade300),
              borderRadius: BorderRadius.circular(8),
              color: Colors.grey.shade50,
            ),
            child: _buildImageWidget(),
          ),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            TextButton.icon(
              onPressed: () => _pickImage(ImageSource.gallery),
              icon: const Icon(Icons.photo_library, size: 16),
              label: const Text('From Gallery'),
            ),
            if (_imageFile != null || widget.initialImageUrl != null)
              TextButton.icon(
                onPressed: _clearImage,
                icon: const Icon(Icons.clear, size: 16),
                label: const Text('Remove'),
                style: TextButton.styleFrom(foregroundColor: Colors.red),
              ),
          ],
        ),
      ],
    );
  }

  Widget _buildImageWidget() {
    // Priority: selected file > initial URL > placeholder
    if (_imageBytes != null) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(6),
        child: Image.memory(
          _imageBytes!,
          fit: BoxFit.cover,
          width: double.infinity,
          height: double.infinity,
        ),
      );
    } else if (widget.initialImageUrl != null) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(6),
        child: Image.network(
          widget.initialImageUrl!,
          fit: BoxFit.cover,
          width: double.infinity,
          height: double.infinity,
          loadingBuilder: (context, child, loadingProgress) {
            if (loadingProgress == null) return child;
            return const Center(child: CircularProgressIndicator());
          },
          errorBuilder: (context, error, stackTrace) {
            return const Center(child: Icon(Icons.broken_image, size: 40));
          },
        ),
      );
    } else {
      return Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.add_a_photo,
            size: 40,
            color: Colors.grey.shade400,
          ),
          const SizedBox(height: 8),
          Text(
            'Tap to add image',
            style: TextStyle(
              color: Colors.grey.shade500,
              fontSize: 14,
            ),
          ),
        ],
      );
    }
  }



  Future<void> _pickImage(ImageSource source) async {
    try {
      final XFile? pickedFile = await _picker.pickImage(
        source: source,
        maxWidth: 1920,
        maxHeight: 1080,
        imageQuality: 85,
      );

      if (pickedFile != null) {
        _pickedFile = pickedFile;

        // Convert XFile to proper data structure
        await _loadImageBytes();
        setState(() {});

        // Prepare image data
        final imageData = {
          'file': File(pickedFile.path),
          'bytes': _imageBytes,
          'path': pickedFile.path,
          'name': pickedFile.name,
        };

        widget.onImageSelected(imageData);
      }
    } catch (e) {
      print('Error picking image: $e');
      Get.snackbar(
        'Error',
        'Failed to select image: $e',
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  Future<void> _loadImageBytes() async {
    if (_pickedFile != null) {
      try {
        _imageBytes = await _pickedFile!.readAsBytes();
      } catch (e) {
        print('Error loading image bytes: $e');
        _imageBytes = null;
      }
    }
  }

  void _clearImage() {
    setState(() {
      _pickedFile = null;
      _imageFile = null;
      _imageBytes = null;
    });
    widget.onImageSelected(null);
  }
}

/// Simplified image display widget for product lists
class ProductImageWidget extends StatelessWidget {
  final String? imageUrl;
  final String fallbackText;
  final double size;

  const ProductImageWidget({
    super.key,
    this.imageUrl,
    required this.fallbackText,
    this.size = 40,
  });

  @override
  Widget build(BuildContext context) {
    if (imageUrl != null && imageUrl!.isNotEmpty) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: Image.network(
          imageUrl!,
          width: size,
          height: size,
          fit: BoxFit.cover,
          loadingBuilder: (context, child, loadingProgress) {
            if (loadingProgress == null) return child;
            return Container(
              width: size,
              height: size,
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(Icons.image, color: Colors.grey.shade400, size: size * 0.5),
            );
          },
          errorBuilder: (context, error, stackTrace) {
            return CircleAvatar(
              radius: size / 2,
              backgroundColor: Colors.blue.shade100,
              child: Text(
                fallbackText[0].toUpperCase(),
                style: TextStyle(
                  color: Colors.blue.shade700,
                  fontWeight: FontWeight.bold,
                  fontSize: size * 0.3,
                ),
              ),
            );
          },
        ),
      );
    } else {
      return CircleAvatar(
        radius: size / 2,
        backgroundColor: Colors.blue.shade100,
        child: Text(
          fallbackText[0].toUpperCase(),
          style: TextStyle(
            color: Colors.blue.shade700,
            fontWeight: FontWeight.bold,
            fontSize: size * 0.3,
          ),
        ),
      );
    }
  }
}

/// Image validation utilities
class ImageValidator {
  static const int maxFileSizeBytes = 5 * 1024 * 1024; // 5MB
  static const List<String> allowedExtensions = ['jpg', 'jpeg', 'png', 'gif', 'webp'];
  static const List<String> allowedMimeTypes = [
    'image/jpeg',
    'image/jpg',
    'image/png',
    'image/gif',
    'image/webp'
  ];

  static Future<String?> validateImage(File? imageFile) async {
    if (imageFile == null) return null;

    // Handle web blob URLs - trust image picker validation for web platform
    final filePath = imageFile.path.toLowerCase().trim();
    if (filePath.startsWith('blob:')) {
      return null; // Web blob URLs are already validated by image picker
    }

    // Simple file extension check for local files
    try {
      // Quick PNG check first (user-reported issue)
      if (filePath.endsWith('.png')) {
        return null; // PNG is explicitly supported
      }

      // Check all supported extensions
      for (final ext in allowedExtensions) {
        if (filePath.endsWith('.$ext')) {
          return null; // Valid extension found
        }
      }

      return 'Only JPG, JPEG, PNG, GIF, and WebP images are allowed';

    } catch (e) {
      // Ultimate fallback - if validation fails, let backend handle it
      return null; // Allow if we can't validate locally
    }
  }

  static Future<bool> isValidImageFile(File file) async {
    return await validateImage(file) == null;
  }
}
