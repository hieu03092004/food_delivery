import 'package:permission_handler/permission_handler.dart';

Future<bool> requestPermission(Permission permission) async{
  if(await permission.isGranted)
    return true;

  PermissionStatus status = await permission.request();

  if(status.isGranted)
    return true;

  if(status.isPermanentlyDenied)
    await openAppSettings();

  return false;
}