import 'package:secure_dotenv/secure_dotenv.dart';

part 'env.g.dart';

@DotEnvGen(
  filename: '.env',
  fieldRename: FieldRename.screamingSnake,
)
abstract class Env {
  static Env create() {
    String encryptionKey = const String.fromEnvironment(
        "ENV_ENCRYPTION_KEY"); // On build, change with your generated encryption key in launch.json.example into launch.json (VS Code)
    String iv = const String.fromEnvironment(
        "ENV_IV_KEY"); // On build, change with your generated iv in launch.json.example into launch.json (VS Code)
    return Env(encryptionKey, iv);
  }

  const factory Env(String encryptionKey, String iv) =
      _$Env; // You can call const env = Env('encryption-key', 'iv') from another Dart file using this

  const Env._();

  // Declare your environment variables as abstract getters
  @FieldKey(defaultValue: "")
  String get generativeAiApiKey;

  // Firebase Web
  @FieldKey(defaultValue: "")
  String get firebaseWebApiKey;

  @FieldKey(defaultValue: "")
  String get firebaseWebAppId;

  @FieldKey(defaultValue: "")
  String get firebaseWebMessagingSenderId;

  @FieldKey(defaultValue: "")
  String get firebaseWebProjectId;

  @FieldKey(defaultValue: "")
  String get firebaseWebAuthDomain;

  @FieldKey(defaultValue: "")
  String get firebaseWebStorageBucket;

  @FieldKey(defaultValue: "")
  String get firebaseWebMeasurementId;

  // Firebase Android
  @FieldKey(defaultValue: "")
  String get firebaseAndroidApiKey;

  @FieldKey(defaultValue: "")
  String get firebaseAndroidAppId;

  @FieldKey(defaultValue: "")
  String get firebaseAndroidMessagingSenderId;

  @FieldKey(defaultValue: "")
  String get firebaseAndroidProjectId;

  @FieldKey(defaultValue: "")
  String get firebaseAndroidStorageBucket;

  // Firebase iOS
  @FieldKey(defaultValue: "")
  String get firebaseIosApiKey;

  @FieldKey(defaultValue: "")
  String get firebaseIosAppId;

  @FieldKey(defaultValue: "")
  String get firebaseIosMessagingSenderId;

  @FieldKey(defaultValue: "")
  String get firebaseIosProjectId;

  @FieldKey(defaultValue: "")
  String get firebaseIosStorageBucket;

  @FieldKey(defaultValue: "")
  String get firebaseIosBundleId;

  // Firebase MacOS
  @FieldKey(defaultValue: "")
  String get firebaseMacosApiKey;

  @FieldKey(defaultValue: "")
  String get firebaseMacosAppId;

  @FieldKey(defaultValue: "")
  String get firebaseMacosMessagingSenderId;

  @FieldKey(defaultValue: "")
  String get firebaseMacosProjectId;

  @FieldKey(defaultValue: "")
  String get firebaseMacosStorageBucket;

  @FieldKey(defaultValue: "")
  String get firebaseMacosBundleId;

  // Firebase Windows
  @FieldKey(defaultValue: "")
  String get firebaseWindowsApiKey;

  @FieldKey(defaultValue: "")
  String get firebaseWindowsAppId;

  @FieldKey(defaultValue: "")
  String get firebaseWindowsMessagingSenderId;

  @FieldKey(defaultValue: "")
  String get firebaseWindowsProjectId;

  @FieldKey(defaultValue: "")
  String get firebaseWindowsAuthDomain;

  @FieldKey(defaultValue: "")
  String get firebaseWindowsStorageBucket;

  @FieldKey(defaultValue: "")
  String get firebaseWindowsMeasurementId;
}
