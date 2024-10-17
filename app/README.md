# ScanPoint

Scan POI's around the world!

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
