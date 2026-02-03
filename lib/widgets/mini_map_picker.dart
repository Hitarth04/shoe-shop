import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart'; // New Map Package
import 'package:latlong2/latlong.dart'; // New Coordinates Package
import 'package:geolocator/geolocator.dart';
import '../utils/constants.dart';

class MiniMapPicker extends StatefulWidget {
  final Function(LatLng) onLocationChanged;

  const MiniMapPicker({super.key, required this.onLocationChanged});

  @override
  State<MiniMapPicker> createState() => _MiniMapPickerState();
}

class _MiniMapPickerState extends State<MiniMapPicker> {
  final MapController _mapController = MapController();
  LatLng _currentPosition = const LatLng(20.5937, 78.9629); // Default: India
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _determinePosition();
  }

  Future<void> _determinePosition() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      setState(() => _isLoading = false);
      return;
    }

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        setState(() => _isLoading = false);
        return;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      setState(() => _isLoading = false);
      return;
    }

    final pos = await Geolocator.getCurrentPosition();
    final latLng = LatLng(pos.latitude, pos.longitude);

    setState(() {
      _currentPosition = latLng;
      _isLoading = false;
    });

    widget.onLocationChanged(_currentPosition);
    _mapController.move(_currentPosition, 15);
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const SizedBox(
        height: 200,
        child: Center(child: CircularProgressIndicator()),
      );
    }

    return SizedBox(
      height: 200,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Stack(
          alignment: Alignment.center,
          children: [
            FlutterMap(
              mapController: _mapController,
              options: MapOptions(
                initialCenter: _currentPosition,
                initialZoom: 15.0,
                // Trigger updates when the map stops moving
                onPositionChanged: (camera, hasGesture) {
                  if (hasGesture) {
                    widget.onLocationChanged(camera.center);
                  }
                },
              ),
              children: [
                TileLayer(
                  // This URL is the free OpenStreetMap tile server
                  urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                  userAgentPackageName:
                      'com.example.shoe_shop', // Required by OSM
                ),
              ],
            ),
            // Centered Marker (Stays in middle while map moves underneath)
            const Icon(Icons.location_on,
                size: 40, color: AppConstants.primaryColor),
          ],
        ),
      ),
    );
  }
}
