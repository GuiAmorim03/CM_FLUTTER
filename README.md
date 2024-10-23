# CM_FLUTTER
Projeto do Módulo de Flutter da Cadeira de Computação Móvel 2024/2025

**ScanPoint** is a mobile application that allows users to scan Points of Interest around the world. Play with your friends and see who can scan the most points!

## Define Ip Address
You need to define the ip address of the machine where the api is running in the following files:
- app/lib/services/api.dart
- api/api_url.py

## Start the Api
First, get the dependencies
```bash
pip install -r requirements.txt
```
Then, start the application
```bash
uvicorn main:app --reload --host <ip_address> --port 8000
```

## Start the App
First, get the dependencies
```bash
flutter pub get
```
Then, start the application
```bash
flutter run
```

## Apk

To generate the apk, run the following command:
```bash
flutter build apk
```