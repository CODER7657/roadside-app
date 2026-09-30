// Default entry point (`flutter build web` in CI). Release builds use main_prod.dart.
import 'app/bootstrap.dart';
import 'app/flavor.dart';

void main() => bootstrap(AppFlavor.prod);
