// flutter build web -t lib/main_prod.dart --dart-define-from-file=env/prod.json
import 'app/bootstrap.dart';
import 'app/flavor.dart';

void main() => bootstrap(AppFlavor.prod);
