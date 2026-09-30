// flutter run --flavor dev -t lib/main_dev.dart --dart-define-from-file=env/dev.json
import 'app/bootstrap.dart';
import 'app/flavor.dart';

void main() => bootstrap(AppFlavor.dev);
