import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'package:hrm/core/constants/constants.dart';

class CustomAppBar extends StatefulWidget implements PreferredSizeWidget {
  final String userName;
  final String greeting;
  final String? avatarUrl;
  final VoidCallback? onMenuPressed;
  final VoidCallback? onNotificationPressed;
  final bool showLocation;
  final Color textColor;
  final Color iconColor;

    const CustomAppBar({
    super.key,
    required this.userName,
    this.greeting = '',
    this.avatarUrl,
    this.onMenuPressed,
    this.onNotificationPressed,
    this.showLocation = true,
    this.textColor = Colors.white,
    this.iconColor = Colors.white,
  });

  @override
  State<CustomAppBar> createState() => _CustomAppBarState();

  @override
  Size get preferredSize => const Size.fromHeight(160);
}

class _CustomAppBarState extends State<CustomAppBar> {
  // String _currentLocation = 'Fetching location...';
  bool _isLoadingLocation = true;

  @override
  void initState() {
    super.initState();
    if (widget.showLocation) {
      _getCurrentLocation();
    }
  }

  Future<void> _getCurrentLocation() async {
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        setState(() {
          // _currentLocation = 'Location services disabled';
          _isLoadingLocation = false;
        });
        return;
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          setState(() {
            // _currentLocation = 'Location permission denied';
            _isLoadingLocation = false;
          });
          return;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        setState(() {
          // _currentLocation = 'Location permission permanently denied';
          _isLoadingLocation = false;
        });
        return;
      }

      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      List<Placemark> placemarks = await placemarkFromCoordinates(
        position.latitude,
        position.longitude,
      );

      if (placemarks.isNotEmpty) {
        Placemark place = placemarks[0];
        setState(() {
          // _currentLocation =
          //     '${place.locality}, ${place.administrativeArea}, ${place.country}';
          _isLoadingLocation = false;
        });
      }
    } catch (e) {
      setState(() {
        // _currentLocation = 'Unable to fetch location';
        _isLoadingLocation = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Constants.color.lightColors['primary'],
      padding: const EdgeInsets.only(top: 16, left: 16, right: 16, bottom: 20),
      child: SafeArea(
        bottom: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                IconButton(
                  icon: Icon(Icons.menu, color: widget.iconColor),
                  onPressed: widget.onMenuPressed ?? () {},
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                ),
                Row(
                  children: [
                    IconButton(
                      icon: Icon(
                        Icons.notifications_outlined,
                        color: widget.iconColor,
                      ),
                      onPressed: widget.onNotificationPressed ?? () {},
                    ),
                    const SizedBox(width: 8),
                    // CircleAvatar(
                    //   radius: 18,
                    //   backgroundImage: widget.avatarUrl != null
                    //       ? NetworkImage(widget.avatarUrl!)
                    //       : const NetworkImage(
                    //           'https://i.pravatar.cc/150?img=1'),
                    // ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 16),
            Align(
              alignment: Alignment.centerLeft,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.greeting,
                    style: TextStyle(
                      color: widget.textColor.withOpacity(0.7),
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    widget.userName,
                    style: TextStyle(
                      color: widget.textColor,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  if (widget.showLocation) ...[
                    const SizedBox(height: 8),
                    // Location Display
                    Row(
                      children: [
                        Icon(
                          Icons.location_on,
                          color: widget.textColor.withOpacity(0.7),
                          size: 16,
                        ),
                        const SizedBox(width: 4),
                        // Expanded(
                        //   child: _isLoadingLocation
                        //       ? Row(
                        //           children: [
                        //             SizedBox(
                        //               width: 12,
                        //               height: 12,
                        //               child: CircularProgressIndicator(
                        //                 strokeWidth: 2,
                        //                 valueColor:
                        //                     AlwaysStoppedAnimation<Color>(
                        //                   widget.textColor.withOpacity(0.7),
                        //                 ),
                        //               ),
                        //             ),
                        //             const SizedBox(width: 8),
                        //             Text(
                        //               'Getting location...',
                        //               style: TextStyle(
                        //                 color: widget.textColor.withOpacity(0.7),
                        //                 fontSize: 12,
                        //               ),
                        //             ),
                        //           ],
                        //         )
                        //       : Text(
                        //           // _currentLocation,
                        //           style: TextStyle(
                        //             color: widget.textColor.withOpacity(0.7),
                        //             fontSize: 12,
                        //           ),
                        //           maxLines: 1,
                        //           overflow: TextOverflow.ellipsis,
                        //         ),
                        // ),
                        const SizedBox(width: 4),
                        IconButton(
                          icon: Icon(
                            Icons.refresh,
                            color: widget.textColor.withOpacity(0.7),
                            size: 16,
                          ),
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(),
                          onPressed: () {
                            setState(() {
                              _isLoadingLocation = true;
                              // _currentLocation = 'Fetching location...';
                            });
                            _getCurrentLocation();
                          },
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}