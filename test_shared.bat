@echo off
SET engine_version_path=E:\src\flutter\bin\cache\engine.stamp
SET engine_stamp=E:\src\flutter\bin\cache\engine-dart-sdk.stamp
SET snapshot_path=E:\src\flutter\bin\cache\flutter_tools.snapshot
SET stamp_path=E:\src\flutter\bin\cache\flutter_tools.stamp
SET compilekey="6a19cca56475dbfba1478ee68d7bd0c2ef891da1:"

SET /P dart_required_version=<"%engine_version_path%"
SET /P dart_installed_version=<"%engine_stamp%"
echo dart_required_version: [%dart_required_version%]
echo dart_installed_version: [%dart_installed_version%]
IF %dart_required_version% NEQ %dart_installed_version% (
    echo Engine versions DO NOT MATCH!
    exit /b 1
) else (
    echo Engine versions MATCH!
)

IF NOT EXIST "%snapshot_path%" (
    echo Snapshot DOES NOT EXIST!
    exit /b 1
) else (
    echo Snapshot EXISTS!
)

IF NOT EXIST "%stamp_path%" (
    echo Stamp DOES NOT EXIST!
    exit /b 1
) else (
    echo Stamp EXISTS!
)

SET /P stamp_value=<"%stamp_path%"
echo stamp_value: [%stamp_value%]
echo compilekey:  [%compilekey%]
IF %stamp_value% NEQ %compilekey% (
    echo Compile keys DO NOT MATCH!
    exit /b 1
) else (
    echo Compile keys MATCH!
)

SET pubspec_yaml_path=E:\src\flutter\packages\flutter_tools\pubspec.yaml
SET pubspec_lock_path=E:\src\flutter\packages\flutter_tools\pubspec.lock
FOR %%i IN (%pubspec_yaml_path%) DO SET pubspec_yaml_timestamp=%%~ti
FOR %%i IN (%pubspec_lock_path%) DO SET pubspec_lock_timestamp=%%~ti
echo pubspec_yaml_timestamp: [%pubspec_yaml_timestamp%]
echo pubspec_lock_timestamp: [%pubspec_lock_timestamp%]
IF "%pubspec_yaml_timestamp%" == "%pubspec_lock_timestamp%" (
    echo Timestamps MATCH!
)

echo SUCCESS: Everything is up-to-date!
