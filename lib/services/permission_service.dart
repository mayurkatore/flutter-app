import 'package:permission_handler/permission_handler.dart';
import 'package:flutter/material.dart';

class PermissionService {
  static Future<bool> requestUsageAccessPermission(BuildContext context) async {
    // Check if we already have permission
    PermissionStatus status = await Permission.systemAlertWindow.status;
    bool granted = status == PermissionStatus.granted;
    
    if (granted) {
      return true;
    }
    
    // Show a dialog explaining why we need this permission
    bool? accepted = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Usage Access Permission Required'),
          content: const Text(
            'This app needs usage access permission to track your screen time and help you manage your digital wellness. '
            'Please grant this permission in the next screen.'
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: const Text('Continue'),
            ),
          ],
        );
      },
    );
    
    if (accepted != true) {
      return false;
    }
    
    // Request the permission
    status = await Permission.systemAlertWindow.request();
    granted = status == PermissionStatus.granted;
    
    return granted;
  }
  
  static Future<bool> checkUsageAccessPermission() async {
    PermissionStatus status = await Permission.systemAlertWindow.status;
    return status == PermissionStatus.granted;
  }
}