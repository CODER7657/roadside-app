// Release builds: see .github/workflows/release-android.yml (obfuscated, split debug info).
import 'app/bootstrap.dart';
import 'app/flavor.dart';

void main() => bootstrap(AppFlavor.prod);
