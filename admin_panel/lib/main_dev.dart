// flutter run -d chrome -t lib/main_dev.dart --dart-define-from-file=env/dev.json
// With USE_EMULATORS=true, start the emulators first (firebase/README.md).
import 'app/bootstrap.dart';
import 'app/flavor.dart';

void main() => bootstrap(AppFlavor.dev);
