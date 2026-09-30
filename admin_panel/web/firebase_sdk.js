// Loads the Firebase JS SDK before Flutter starts, so FlutterFire doesn't inject its own inline
// <script> tags, which the console's strict Content-Security-Policy blocks (firebase/firebase.json,
// PLAN §12.11). FlutterFire skips injection when window.firebase_core already exists.
//
// FIREBASE_JS_SDK must equal `supportedFirebaseJsSdkVersion` in firebase_core_web; the test
// test/firebase_sdk_version_test.dart fails when a plugin upgrade changes it.
// Add a service here (and its bundle to the CSP path) when the panel starts using it.

const FIREBASE_JS_SDK = '12.19.0';
const base = `https://www.gstatic.com/firebasejs/${FIREBASE_JS_SDK}`;

// firebase-app.js first: the component bundles import it (see FlutterFire issue #18436).
window.firebase_core = await import(`${base}/firebase-app.js`);
const [appCheck, auth, firestore, functions] = await Promise.all([
  import(`${base}/firebase-app-check.js`),
  import(`${base}/firebase-auth.js`),
  import(`${base}/firebase-firestore-pipelines.js`),
  import(`${base}/firebase-functions.js`),
]);
window.firebase_app_check = appCheck;
window.firebase_auth = auth;
window.firebase_firestore = firestore;
window.firebase_functions = functions;

const bootstrap = document.createElement('script');
bootstrap.src = 'flutter_bootstrap.js';
document.body.appendChild(bootstrap);
