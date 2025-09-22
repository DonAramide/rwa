import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:camera/camera.dart';
import 'package:image_picker/image_picker.dart';
import 'package:geolocator/geolocator.dart';
import 'dart:io';
import '../../services/location_service.dart';
import '../../services/offline_service.dart';
import '../../providers/jobs_provider.dart';

class CameraScreen extends ConsumerStatefulWidget {
  final String jobId;

  const CameraScreen({super.key, required this.jobId});

  @override
  ConsumerState<CameraScreen> createState() => _CameraScreenState();
}

class _CameraScreenState extends ConsumerState<CameraScreen> {
  CameraController? _cameraController;
  List<CameraDescription>? _cameras;
  bool _isInitialized = false;
  final List<String> _capturedImages = [];
  Position? _currentLocation;

  @override
  void initState() {
    super.initState();
    _initializeCamera();
    _getCurrentLocation();
  }

  @override
  void dispose() {
    _cameraController?.dispose();
    super.dispose();
  }

  Future<void> _initializeCamera() async {
    try {
      _cameras = await availableCameras();
      if (_cameras!.isNotEmpty) {
        _cameraController = CameraController(
          _cameras![0],
          ResolutionPreset.high,
          enableAudio: false,
        );

        await _cameraController!.initialize();
        
        if (mounted) {
          setState(() {
            _isInitialized = true;
          });
        }
      }
    } catch (e) {
      print('Error initializing camera: $e');
    }
  }

  Future<void> _getCurrentLocation() async {
    _currentLocation = await LocationService.instance.getCurrentLocation();
    setState(() {});
  }

  Future<void> _captureImage() async {
    if (!_cameraController!.value.isInitialized) return;

    try {
      final XFile image = await _cameraController!.takePicture();
      
      // Add location metadata if available
      if (_currentLocation != null) {
        // TODO: Add EXIF data with location
      }

      setState(() {
        _capturedImages.add(image.path);
      });

      // Cache for offline sync
      await OfflineService.instance.cacheMediaFile(image.path, widget.jobId);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Image captured (${_capturedImages.length} total)'),
          action: SnackBarAction(
            label: 'View',
            onPressed: _showCapturedImages,
          ),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error capturing image: $e')),
      );
    }
  }

  Future<void> _pickImageFromGallery() async {
    final picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);
    
    if (image != null) {
      setState(() {
        _capturedImages.add(image.path);
      });

      await OfflineService.instance.cacheMediaFile(image.path, widget.jobId);
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Image added (${_capturedImages.length} total)')),
      );
    }
  }

  void _showCapturedImages() {
    showModalBottomSheet(
      context: context,
      builder: (context) => SizedBox(
        height: 400,
        child: Column(
          children: [
            const Padding(
              padding: EdgeInsets.all(16),
              child: Text(
                'Captured Images',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),
            Expanded(
              child: GridView.builder(
                padding: const EdgeInsets.all(16),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  crossAxisSpacing: 8,
                  mainAxisSpacing: 8,
                ),
                itemCount: _capturedImages.length,
                itemBuilder: (context, index) {
                  return Stack(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Image.file(
                          File(_capturedImages[index]),
                          fit: BoxFit.cover,
                          width: double.infinity,
                          height: double.infinity,
                        ),
                      ),
                      Positioned(
                        top: 4,
                        right: 4,
                        child: GestureDetector(
                          onTap: () => _removeImage(index),
                          child: Container(
                            decoration: const BoxDecoration(
                              color: Colors.red,
                              shape: BoxShape.circle,
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
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      onPressed: Navigator.of(context).pop,
                      child: const Text('Close'),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: _capturedImages.isNotEmpty ? _submitImages : null,
                      child: const Text('Submit All'),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _removeImage(int index) {
    setState(() {
      _capturedImages.removeAt(index);
    });
    Navigator.of(context).pop();
    if (_capturedImages.isNotEmpty) {
      _showCapturedImages();
    }
  }

  Future<void> _submitImages() async {
    if (_capturedImages.isEmpty) return;

    try {
      // Update job with captured media
      await ref.read(jobsProvider.notifier).updateJobMedia(
        widget.jobId,
        _capturedImages,
      );

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Images submitted successfully')),
      );

      Navigator.of(context).pop(); // Close bottom sheet
      Navigator.of(context).pop(); // Return to previous screen
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error submitting images: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!_isInitialized) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Verification Camera'),
        actions: [
          IconButton(
            onPressed: _showCapturedImages,
            icon: Badge(
              label: Text(_capturedImages.length.toString()),
              child: const Icon(Icons.photo_library),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          // Location info
          if (_currentLocation != null)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              color: Colors.green.withOpacity(0.1),
              child: Row(
                children: [
                  const Icon(Icons.location_on, color: Colors.green),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'GPS: ${_currentLocation!.latitude.toStringAsFixed(6)}, ${_currentLocation!.longitude.toStringAsFixed(6)}',
                      style: const TextStyle(
                        color: Colors.green,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ),

          // Camera preview
          Expanded(
            child: ClipRRect(
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(16),
                bottomRight: Radius.circular(16),
              ),
              child: CameraPreview(_cameraController!),
            ),
          ),

          // Camera controls
          Container(
            padding: const EdgeInsets.all(24),
            child: Column(
              children: [
                // Instructions
                Text(
                  'Capture verification photos of the asset',
                  style: Theme.of(context).textTheme.titleMedium,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),

                // Control buttons
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    // Gallery button
                    FloatingActionButton(
                      onPressed: _pickImageFromGallery,
                      heroTag: 'gallery',
                      backgroundColor: Colors.grey[300],
                      child: const Icon(Icons.photo_library, color: Colors.black),
                    ),

                    // Capture button
                    FloatingActionButton(
                      onPressed: _captureImage,
                      heroTag: 'capture',
                      backgroundColor: Theme.of(context).primaryColor,
                      child: const Icon(Icons.camera_alt, size: 32),
                    ),

                    // Switch camera button
                    FloatingActionButton(
                      onPressed: _switchCamera,
                      heroTag: 'switch',
                      backgroundColor: Colors.grey[300],
                      child: const Icon(Icons.flip_camera_ios, color: Colors.black),
                    ),
                  ],
                ),

                const SizedBox(height: 16),

                // Submit button
                if (_capturedImages.isNotEmpty)
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: _submitImages,
                      icon: const Icon(Icons.cloud_upload),
                      label: Text('Submit ${_capturedImages.length} Images'),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _switchCamera() async {
    if (_cameras == null || _cameras!.length <= 1) return;

    final currentIndex = _cameras!.indexOf(_cameraController!.description);
    final nextIndex = (currentIndex + 1) % _cameras!.length;

    await _cameraController!.dispose();
    
    _cameraController = CameraController(
      _cameras![nextIndex],
      ResolutionPreset.high,
      enableAudio: false,
    );

    await _cameraController!.initialize();
    setState(() {});
  }
}