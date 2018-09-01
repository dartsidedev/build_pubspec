Include the version of your package in our source code.

1. Add `build_version` to `pubspec.yaml`. Also make sure there is a `version`
   field.

    ```yaml
    name: my_pkg
    version: 1.2.3
    dev_dependencies:
      build_runner:
      build_version: ^1.0.0
    ```

2. Configure `build_version` in `build.yaml`.

    ```yaml
    targets:
      $default:
        builders:
          build_version:
            enabled: true
    ```

3. Run a build.

    ```console
    > pub run build_runner build
    ```

    You should see a file created at `lib/src/version.dart`

    ```dart
    // Generated code. Do not modify.
    const version = '1.2.3';
    ```