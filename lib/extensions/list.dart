import 'package:z_m3u_handler/z_m3u_handler.dart';

extension ENTRY on List<M3uEntry> {
  List<M3uEntry> unique() {
    Set<M3uEntry> uniqueEntries = Set<M3uEntry>.from(this);
    return uniqueEntries.toList();
  }
}
