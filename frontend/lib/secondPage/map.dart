import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_map_location_marker/flutter_map_location_marker.dart';
import 'package:latlong2/latlong.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:google_fonts/google_fonts.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:geolocator/geolocator.dart';
import 'dart:async';
import 'package:collection/collection.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'settings_provider.dart';
import 'package:provider/provider.dart';

class MapPage extends StatefulWidget {
  const MapPage({Key? key}) : super(key: key);

  @override
  State<MapPage> createState() => _MapPageState();
}

class Place {
  final String id;
  final Map<String, String> name;
  final Map<String, String> description;
  final List<LatLng> polygon;

  Place({
    required this.id,
    required this.name,
    required this.description,
    required this.polygon,
  });

  factory Place.fromJson(Map<String, dynamic> json) {
    // ID = name["en"], lower_case, spaces → underscore
    final autoId = json["name"]["en"]
        .toLowerCase()
        .replaceAll(" ", "_")
        .replaceAll("-", "_");

    return Place(
      id: autoId,
      name: Map<String, String>.from(json['name']),
      description: Map<String, String>.from(json['description']),
      polygon: (json['polygon'] as List)
          .map((p) => LatLng(p['lat'], p['lon']))
          .toList(),
    );
  }
  String nearbyMessage(String lang) {
    switch (lang) {
      case 'kk':
        return "Сіз ${name['kk']} маңында жүрсіз.";
      case 'ru':
        return "Вы находитесь возле ${name['ru']}.";
      case 'en':
        return "You are near the ${name['en']}.";
      default:
        return "Сіз ${name['kk']} маңында жүрсіз.";
    }
  }

  String insideMessage(String lang) {
    switch (lang) {
      case 'kk':
        return "Сіз ${name['kk']} аумағында тұрсыз.";
      case 'ru':
        return "Вы находитесь на территории ${name['ru']}.";
      case 'en':
        return "You are inside the ${name['en']}.";
      default:
        return "Сіз ${name['kk']} аумағында тұрсыз.";
    }
  }
}

class _MapPageState extends State<MapPage> {
  final MapController _mapController = MapController();
  final TextEditingController _searchController = TextEditingController();
  final FlutterTts _flutterTts = FlutterTts();
  final FlutterLocalNotificationsPlugin _notifications =
      FlutterLocalNotificationsPlugin();
  String _currentLang = 'kk';

  LatLng _center = const LatLng(48.0196, 66.9237);
  //String? _weather;
  LatLng? _currentLocation;
  bool _isInfoVisible = true;
  String _ttsState = "stopped";
  double _currentZoom = 5; // бастапқы zoom
  Place? _selectedPlace;
  String? _weatherOriginal; // API-дан келген ағылшын мәтін
  double? _weatherTemp;
  Polyline? _currentRoute; // Қазіргі маршрут
  bool _isRouteVisible = false; // Маршрут көрінетінін сақтау
  bool _isWalkingRoute = true; // Walk/Drive түрі
  Map<String, bool> _notifiedPlaces = {};
  final Map<String, bool> _insideNotifiedPlaces = {};
  Place? _currentShownPlace;

  StreamSubscription<Position>? _positionSubscription;

  List<Place> _places = [];

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final newLang = context.locale.languageCode;
    if (_currentLang != newLang) {
      _currentLang = newLang;
      setState(() {}); // UI жаңаруы үшін
    }
  }

  @override
  void initState() {
    super.initState();
    _loadPlacesToMemory();

    _flutterTts.setCompletionHandler(() {
      setState(() {
        _ttsState = "stopped";
      });
    });

    _flutterTts.setErrorHandler((msg) {
      setState(() {
        _ttsState = "stopped";
      });
    });

    _listenToLocation();
    _checkPermission();
  }

  @override
  void dispose() {
    _positionSubscription?.cancel();
    super.dispose();
  }

  // 🔹 JSON оқимыз
  Future<void> _loadPlacesToMemory() async {
    final String response = await rootBundle.loadString('assets/places.json');
    final List<dynamic> data = json.decode(response);
    setState(() {
      _places = data.map((e) => Place.fromJson(e)).toList();
    });
  }

  // 🔹 Геолокация тыңдау

  void _listenToLocation() {
    final locationSettings = const LocationSettings(
      accuracy: LocationAccuracy.high,
      distanceFilter: 5,
    );

    _positionSubscription = Geolocator.getPositionStream(
      locationSettings: locationSettings,
    ).listen((Position pos) {
      LatLng userLatLng = LatLng(pos.latitude, pos.longitude);
      setState(() {
        _currentLocation = userLatLng;
      });

      for (var place in _places) {
        // 🔹 Polygon center
        double lat =
            place.polygon.map((p) => p.latitude).reduce((a, b) => a + b) /
                place.polygon.length;
        double lon =
            place.polygon.map((p) => p.longitude).reduce((a, b) => a + b) /
                place.polygon.length;

        double distance = Distance().as(
          LengthUnit.Kilometer,
          userLatLng,
          LatLng(lat, lon),
        );

        // 🔹 Notification
        if (distance <= 2.0 && (_notifiedPlaces[place.id] != true)) {
          _sendNotification(
            "Сіз жақын жердесіз",
            place.nearbyMessage(_currentLang),
          );

          _notifiedPlaces[place.id] = true;
        }

        if (distance > 2.2) {
          if (_notifiedPlaces.containsKey(place.id)) {
            _notifiedPlaces[place.id] = false;
          }
        }

        // 🔹 Polygon check
        bool isInside = _isPointInPolygon(userLatLng, place.polygon);

        if (isInside && (_insideNotifiedPlaces[place.id] != true)) {
          _sendNotification(
            "Сіз осы жерде тұрсыз",
            place.insideMessage(_currentLang),
          );

          _insideNotifiedPlaces[place.id] = true;
        }

        if (!isInside) {
          _insideNotifiedPlaces[place.id] = false;
        }

        /// 🔹 Place info көрсету
        if (isInside && _currentShownPlace != place) {
          _currentShownPlace = place;
          _showPlaceInfo(place);
          break;
        }
      }
    });
  }

  Future<void> _checkPermission() async {
    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }
    if (permission == LocationPermission.deniedForever) {
      return;
    }
  }

  // 🔹 Polygon ішіне кіргенін тексеру
  bool _isPointInPolygon(LatLng point, List<LatLng> polygon) {
    int intersectCount = 0;

    for (int i = 0; i < polygon.length; i++) {
      LatLng a = polygon[i];
      LatLng b = polygon[(i + 1) % polygon.length];

      double px = point.longitude;
      double py = point.latitude;
      double ax = a.longitude;
      double ay = a.latitude;
      double bx = b.longitude;
      double by = b.latitude;

      if ((ay > py) != (by > py)) {
        double atX = (bx - ax) * (py - ay) / (by - ay) + ax;
        if (px < atX) intersectCount++;
      }
    }
    return intersectCount % 2 == 1;
  }

  // 🔹 Place info көрсету
  void _showPlaceInfo(Place place) {
    final lat = place.polygon.map((p) => p.latitude).reduce((a, b) => a + b) /
        place.polygon.length;
    final lon = place.polygon.map((p) => p.longitude).reduce((a, b) => a + b) /
        place.polygon.length;

    setState(() {
      _center = LatLng(lat, lon);
      _selectedPlace = place;
    });

    // 🔹 Zoom логикасы
    double targetZoom = _currentZoom < 14.5 ? 14.5 : _currentZoom;

    _mapController.move(_center, targetZoom);

    _fetchWeather(lat, lon);
  }

  // 🔹 Іздеу
  Future<void> _searchPlace() async {
    final query = _searchController.text.trim();

    if (query.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('empty_search'.tr()),
        ),
      );
      return;
    }

    Place? match = _places.firstWhereOrNull((p) {
      return p.name.values.any(
        (value) => value.toLowerCase().contains(query.toLowerCase()),
      );
    });

    if (match == null) {
      // Нәтиже табылмағанда хабарлама шығару
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('no_results'.tr()),
        ),
      );
      return;
    }

    _showPlaceInfo(match);

    setState(() {
      _isInfoVisible = true;
    });
  }

  // 🔹 Weather
  Future<void> _fetchWeather(double lat, double lon) async {
    const apiKey = "3a760fcb0051ed9dab23de8a91f6b4b1";

    final url = "https://api.openweathermap.org/data/2.5/weather"
        "?lat=$lat"
        "&lon=$lon"
        "&units=metric"
        "&appid=$apiKey";

    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      _weatherOriginal = data['weather'][0]['description'];
      _weatherTemp = data["main"]["temp"];

      setState(() {}); // UI жаңаруы үшін
    }
  }

  // 🔹 Current location button
  Future<void> _userCurrentLocation() async {
    if (_currentLocation == null) return;

    print(
        "Current location: lat=${_currentLocation!.latitude}, lon=${_currentLocation!.longitude}");

    _mapController.move(_currentLocation!, 15);

    for (var place in _places) {
      if (_isPointInPolygon(_currentLocation!, place.polygon)) {
        _showPlaceInfo(place);
        setState(() {
          _isInfoVisible = true;
        });
        return;
      }
    }
    setState(() {
      _isInfoVisible = false;
    });
  }

  // 🔹 Walk / Drive батондарынан шақыратын функция
  Future<void> _drawRoute({required bool isWalking}) async {
    if (_currentLocation == null || _selectedPlace == null) return;

    if (_isPointInPolygon(_currentLocation!, _selectedPlace!.polygon)) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('you_are_here'.tr())),
      );
      return;
    }

    final start = _currentLocation!;
    final end = LatLng(
      _selectedPlace!.polygon.map((p) => p.latitude).reduce((a, b) => a + b) /
          _selectedPlace!.polygon.length,
      _selectedPlace!.polygon.map((p) => p.longitude).reduce((a, b) => a + b) /
          _selectedPlace!.polygon.length,
    );

    // OpenRouteService API қолданамыз (тегін нұсқада 2,500 сұраныс/ай)
    final apiKey =
        "eyJvcmciOiI1YjNjZTM1OTc4NTExMTAwMDFjZjYyNDgiLCJpZCI6ImIyYmFlNzU5YmIwNTRiZjY5YzJjNWUyNmYyZDM2MTQyIiwiaCI6Im11cm11cjY0In0=";
    final profile = isWalking ? "foot-walking" : "driving-car";

    final url = Uri.parse(
        "https://api.openrouteservice.org/v2/directions/$profile?api_key=$apiKey&start=${start.longitude},${start.latitude}&end=${end.longitude},${end.latitude}");

    final response = await http.get(url);
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      final coords = data['features'][0]['geometry']['coordinates'] as List;

      final points = coords.map((c) => LatLng(c[1], c[0])).toList();

      setState(() {
        _currentRoute = Polyline(
          points: points,
          strokeWidth: 5.0,
          color: isWalking ? Colors.blue : Colors.red,
        );
        // 🔹 Info panel-ді жасыру
        _isInfoVisible = false;
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Route error")),
      );
    }
  }

// 🔹 Х батон маршруты жою үшін
  void _clearRoute() {
    setState(() {
      _currentRoute = null;
      _isRouteVisible = false;
    });
  }

  Future<void> _sendNotification(String title, String body) async {
    if (!context.read<SettingsProvider>().notificationsEnabled) return;
    // settings-тен өшірсе — шықпайды

    const AndroidNotificationDetails androidDetails =
        AndroidNotificationDetails(
      'location_channel',
      'Location Alerts',
      importance: Importance.max,
      priority: Priority.high,
    );

    const NotificationDetails details =
        NotificationDetails(android: androidDetails);

    await _notifications.show(
      DateTime.now().millisecondsSinceEpoch ~/ 1000, // unique ID
      title,
      body,
      details,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          FlutterMap(
            mapController: _mapController,
            options: MapOptions(
              initialCenter: _currentLocation ?? _center,
              initialZoom: 5,
              onPositionChanged: (position, hasGesture) {
                _currentZoom = position.zoom;
              },
              onTap: (tapPosition, point) {
                for (var place in _places) {
                  if (_isPointInPolygon(point, place.polygon)) {
                    _showPlaceInfo(place);
                    setState(() {
                      _isInfoVisible = true;
                    });
                    break; // Бір ғана place көрсету үшін
                  }
                }
              },
            ),
            children: [
              TileLayer(
                urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                userAgentPackageName: 'com.example.flutterapplication',
              ),
              // 🔹 Polygon layer
              PolygonLayer(
                polygons: _places
                    .map((place) => Polygon(
                          points: place.polygon,
                          color: Colors.blue.withOpacity(0.2),
                          borderColor: Colors.blue,
                          borderStrokeWidth: 2,
                        ))
                    .toList(),
              ),
              // 🔹 Marker layer (ортасына)
              MarkerLayer(
                markers: _places.map((place) {
                  double avgLat = place.polygon
                          .map((p) => p.latitude)
                          .reduce((a, b) => a + b) /
                      place.polygon.length;

                  double avgLon = place.polygon
                          .map((p) => p.longitude)
                          .reduce((a, b) => a + b) /
                      place.polygon.length;

                  return Marker(
                    point: LatLng(avgLat, avgLon),
                    width: 30,
                    height: 30,
                    child: GestureDetector(
                      onTap: () {
                        _showPlaceInfo(place);
                        setState(() {
                          _isInfoVisible = true;
                        });
                      },
                      child: const Icon(
                        Icons.location_on,
                        color: Colors.red,
                        size: 30,
                      ),
                    ),
                  );
                }).toList(),
              ),

              CurrentLocationLayer(
                followOnLocationUpdate: FollowOnLocationUpdate.never,
                style: const LocationMarkerStyle(
                  marker: DefaultLocationMarker(
                    child: Icon(Icons.location_pin, color: Colors.white),
                  ),
                  markerSize: Size(35, 36),
                  markerDirection: MarkerDirection.heading,
                ),
              ),
              if (_isRouteVisible && _currentRoute != null)
                PolylineLayer(
                  polylines: [_currentRoute!],
                ),
            ],
          ),

          // 🔍 Search bar
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(12.0),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _searchController,
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: Colors.white,
                        hintText: 'enter_name_to_search'.tr(),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(25),
                          borderSide: BorderSide.none,
                        ),
                        contentPadding:
                            const EdgeInsets.symmetric(horizontal: 20),
                      ),
                      textInputAction: TextInputAction.search,
                      onSubmitted: (_) => _searchPlace(),
                    ),
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton(
                    onPressed: _searchPlace,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.teal,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(25),
                      ),
                    ),
                    child: const Icon(
                      Icons.search,
                      color: Colors.white,
                      size: 20,
                    ),
                  )
                ],
              ),
            ),
          ),

          // 🔹 Info panel (сол қалпы)
          Positioned(
            bottom: 105,
            left: 25,
            right: 25,
            child: AnimatedOpacity(
              duration: const Duration(milliseconds: 300),
              opacity: _isInfoVisible && _selectedPlace != null ? 1 : 0,
              child: IgnorePointer(
                  ignoring: !_isInfoVisible,
                  child: Card(
                      color: Colors.transparent,
                      elevation: 0,
                      shadowColor: Colors.transparent,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Column(
                        children: [
                          Card(
                            color: Colors.white.withOpacity(0.75),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(0),
                              child: _selectedPlace == null
                                  ? const SizedBox.shrink()
                                  : Column(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Card(
                                          color: Colors.white.withOpacity(0.95),
                                          shape: RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(5),
                                          ),
                                          child: Container(
                                            width: double.infinity,
                                            constraints: const BoxConstraints(
                                              minHeight: 50,
                                              maxHeight: 280,
                                            ),
                                            padding: const EdgeInsets.symmetric(
                                                horizontal: 10, vertical: 10),
                                            child: SingleChildScrollView(
                                              child: Column(
                                                children: [
                                                  Text(
                                                    _selectedPlace!.name[context
                                                            .locale
                                                            .languageCode] ??
                                                        _selectedPlace!
                                                            .name["en"]!,
                                                    key: ValueKey(
                                                      "name_${context.locale.languageCode}",
                                                    ),
                                                    style: GoogleFonts.poppins(
                                                      fontSize: 20,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                    ),
                                                  ),
                                                  const SizedBox(height: 6),
                                                  Text(
                                                    _selectedPlace!.description[
                                                            context.locale
                                                                .languageCode] ??
                                                        _selectedPlace!
                                                            .description["en"]!,
                                                    key: ValueKey(
                                                      "desc_${context.locale.languageCode}",
                                                    ),
                                                    style: const TextStyle(
                                                        fontSize: 14,
                                                        color: Colors.black87),
                                                    textAlign: TextAlign.center,
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ),
                                        ),
                                        Card(
                                            color:
                                                Colors.white.withOpacity(0.95),
                                            shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(5),
                                            ),
                                            child: Container(
                                              width: double.infinity,
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                      horizontal: 10,
                                                      vertical: 10),
                                              child: SingleChildScrollView(
                                                child: Column(
                                                  children: [
                                                    if (_weatherOriginal !=
                                                            null &&
                                                        _weatherTemp != null)
                                                      Text(
                                                        "${'weather'.tr()}: ${weatherTranslations(_weatherOriginal!)}, ${_weatherTemp}°C",
                                                        key: ValueKey(
                                                            "weather_${context.locale.languageCode}"),
                                                        style: const TextStyle(
                                                            fontSize: 14,
                                                            color: Colors
                                                                .blueAccent),
                                                      ),
                                                  ],
                                                ),
                                              ),
                                            )),
                                        Card(
                                            color:
                                                Colors.white.withOpacity(0.95),
                                            shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(5),
                                            ),
                                            child: Container(
                                              width: double.infinity,
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                      horizontal: 10,
                                                      vertical: 10),
                                              child: SingleChildScrollView(
                                                child: Column(
                                                  children: [
                                                    Row(
                                                      mainAxisAlignment:
                                                          MainAxisAlignment
                                                              .center,
                                                      children: [
                                                        // Play
                                                        ElevatedButton(
                                                          onPressed: () async {
                                                            final text =
                                                                "${_selectedPlace!.name[context.locale.languageCode] ?? _selectedPlace!.name['en']}. "
                                                                "${_selectedPlace!.description[context.locale.languageCode] ?? _selectedPlace!.description['en']}. "
                                                                "${'weather'.tr()}: ${_weatherOriginal != null && _weatherTemp != null ? weatherTranslations(_weatherOriginal!) + ', ${_weatherTemp}°C' : ''}.";

                                                            if (_ttsState !=
                                                                "playing") {
                                                              await _flutterTts
                                                                  .setLanguage(
                                                                context.locale
                                                                            .languageCode ==
                                                                        "kk"
                                                                    ? "kk-KZ"
                                                                    : context.locale.languageCode ==
                                                                            "ru"
                                                                        ? "ru-RU"
                                                                        : "en-US",
                                                              );
                                                              await _flutterTts
                                                                  .setSpeechRate(
                                                                      0.35);
                                                              await _flutterTts
                                                                  .setPitch(
                                                                      1.0);
                                                              await _flutterTts
                                                                  .speak(text);
                                                              setState(() {
                                                                _ttsState =
                                                                    "playing";
                                                              });
                                                            }
                                                          },
                                                          style: ElevatedButton
                                                              .styleFrom(
                                                            padding: EdgeInsets
                                                                .symmetric(
                                                                    horizontal:
                                                                        2,
                                                                    vertical:
                                                                        2),
                                                            backgroundColor:
                                                                Colors.teal,
                                                            shape:
                                                                RoundedRectangleBorder(
                                                              borderRadius:
                                                                  BorderRadius
                                                                      .circular(
                                                                          15),
                                                            ),
                                                          ),
                                                          child: const Icon(
                                                              Icons.play_arrow,
                                                              color:
                                                                  Colors.white,
                                                              size: 25),
                                                        ),

                                                        const SizedBox(
                                                            width: 30),

                                                        // Stop
                                                        ElevatedButton(
                                                          onPressed: () async {
                                                            if (_ttsState ==
                                                                "playing") {
                                                              await _flutterTts
                                                                  .stop();
                                                              setState(() {
                                                                _ttsState =
                                                                    "stopped";
                                                              });
                                                            }
                                                          },
                                                          style: ElevatedButton
                                                              .styleFrom(
                                                            padding: EdgeInsets
                                                                .symmetric(
                                                                    horizontal:
                                                                        2,
                                                                    vertical:
                                                                        2),
                                                            backgroundColor:
                                                                Colors.red,
                                                            shape:
                                                                RoundedRectangleBorder(
                                                              borderRadius:
                                                                  BorderRadius
                                                                      .circular(
                                                                          15),
                                                            ),
                                                          ),
                                                          child: const Icon(
                                                              Icons.stop,
                                                              color:
                                                                  Colors.white,
                                                              size: 25),
                                                        ),
                                                      ],
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            )),
                                      ],
                                    ),
                            ),
                          ),
                          Padding(
                            padding: EdgeInsets.symmetric(
                                horizontal: 7, vertical: 5),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                // Walk батон
                                SizedBox(
                                  width: 45,
                                  height: 45,
                                  child: ElevatedButton(
                                    onPressed: () async {
                                      await _drawRoute(isWalking: true);
                                      setState(() {
                                        _isRouteVisible = true;
                                        _isWalkingRoute = true;
                                      });
                                    },
                                    style: IconButton.styleFrom(
                                      backgroundColor: Colors.teal,
                                      padding: const EdgeInsets.all(10),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(15),
                                      ),
                                    ),
                                    child: Icon(
                                      Icons.directions_walk,
                                      color: Colors.white,
                                      size: 20,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 10),
                                // Drive батон
                                SizedBox(
                                  width: 45,
                                  height: 45,
                                  child: ElevatedButton(
                                    onPressed: () async {
                                      await _drawRoute(isWalking: false);
                                      setState(() {
                                        _isRouteVisible = true;
                                        _isWalkingRoute = false;
                                      });
                                    },
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.teal,
                                      padding: const EdgeInsets.all(10),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(15),
                                      ),
                                    ),
                                    child: const Icon(
                                      Icons.directions_car,
                                      color: Colors.white,
                                      size: 25,
                                    ),
                                  ),
                                )
                              ],
                            ),
                          )
                        ],
                      ))),
            ),
          ),
          if (_isRouteVisible)
            Positioned(
                top: 140,
                right: 20,
                child: SizedBox(
                  width: 45,
                  height: 45,
                  child: ElevatedButton(
                    onPressed: _clearRoute,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.teal,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      padding: const EdgeInsets.all(10),
                    ),
                    child: const Icon(
                      Icons.close,
                      color: Colors.white,
                      size: 25,
                    ),
                  ),
                )),

          // Toggle info visibility
          Positioned(
            bottom: 17,
            left: 17,
            child: SizedBox(
              width: 55,
              height: 55,
              child: FloatingActionButton(
                elevation: 0,
                heroTag: "info-toggle",
                backgroundColor: Colors.teal,
                onPressed: () {
                  setState(() {
                    _isInfoVisible = !_isInfoVisible;
                  });
                },
                child: Icon(
                    _isInfoVisible ? Icons.expand_more : Icons.expand_less,
                    size: 40,
                    color: Colors.white),
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        elevation: 0,
        onPressed: _userCurrentLocation,
        backgroundColor: Colors.teal,
        child: const Icon(Icons.my_location, size: 30, color: Colors.white),
      ),
    );
  }

  String weatherTranslations(String desc) {
    desc = desc.toLowerCase();

    // ------------------------
    // Extreme / Special
    // ------------------------
    if (desc.contains("tornado")) {
      return {"kk": "Дауыл", "ru": "Торнадо", "en": "Tornado"}[_currentLang]!;
    }
    if (desc.contains("squall")) {
      return {
        "kk": "Жел құйындары",
        "ru": "Шквалы",
        "en": "Squalls"
      }[_currentLang]!;
    }
    if (desc.contains("volcanic ash")) {
      return {
        "kk": "Вулкан күлі",
        "ru": "Вулканический пепел",
        "en": "Volcanic ash"
      }[_currentLang]!;
    }
    if (desc.contains("sand")) {
      return {"kk": "Құм", "ru": "Песок", "en": "Sand"}[_currentLang]!;
    }
    if (desc.contains("dust")) {
      return {"kk": "Шаң", "ru": "Пыль", "en": "Dust"}[_currentLang]!;
    }
    if (desc.contains("haze")) {
      return {"kk": "Тұман", "ru": "Мгла", "en": "Haze"}[_currentLang]!;
    }
    if (desc.contains("smoke")) {
      return {"kk": "Түтін", "ru": "Дым", "en": "Smoke"}[_currentLang]!;
    }
    if (desc.contains("fog")) {
      return {"kk": "Тұман", "ru": "Туман", "en": "Fog"}[_currentLang]!;
    }
    if (desc.contains("mist")) {
      return {"kk": "Тұманшалық", "ru": "Мгла", "en": "Mist"}[_currentLang]!;
    }

    // ------------------------
    // Clouds
    // ------------------------
    if (desc.contains("clear sky")) {
      return {
        "kk": "Ашық ауа-райы",
        "ru": "Ясно",
        "en": "Clear sky"
      }[_currentLang]!;
    }
    if (desc.contains("few clouds")) {
      return {
        "kk": "Аздаған бұлттар",
        "ru": "Малооблачно",
        "en": "Few clouds"
      }[_currentLang]!;
    }
    if (desc.contains("scattered clouds")) {
      return {
        "kk": "Сирек бұлттар",
        "ru": "Рассеянные облака",
        "en": "Scattered clouds"
      }[_currentLang]!;
    }
    if (desc.contains("broken clouds")) {
      return {
        "kk": "Жартылай бұлтты",
        "ru": "Облачно с прояснениями",
        "en": "Broken clouds"
      }[_currentLang]!;
    }
    if (desc.contains("overcast clouds")) {
      return {
        "kk": "Қалың бұлтты",
        "ru": "Пасмурно",
        "en": "Overcast clouds"
      }[_currentLang]!;
    }

    // ------------------------
    // Rain
    // ------------------------
    if (desc.contains("light rain")) {
      return {
        "kk": "Жеңіл жаңбыр",
        "ru": "Небольшой дождь",
        "en": "Light rain"
      }[_currentLang]!;
    }
    if (desc.contains("moderate rain")) {
      return {
        "kk": "Орташа жаңбыр",
        "ru": "Умеренный дождь",
        "en": "Moderate rain"
      }[_currentLang]!;
    }
    if (desc.contains("heavy intensity rain")) {
      return {
        "kk": "Қатты жаңбыр",
        "ru": "Сильный дождь",
        "en": "Heavy rain"
      }[_currentLang]!;
    }
    if (desc.contains("very heavy rain")) {
      return {
        "kk": "Өте қатты жаңбыр",
        "ru": "Очень сильный дождь",
        "en": "Very heavy rain"
      }[_currentLang]!;
    }
    if (desc.contains("extreme rain")) {
      return {
        "kk": "Экстремалды жаңбыр",
        "ru": "Экстремальный дождь",
        "en": "Extreme rain"
      }[_currentLang]!;
    }
    if (desc.contains("freezing rain")) {
      return {
        "kk": "Мұзды жаңбыр",
        "ru": "Ледяной дождь",
        "en": "Freezing rain"
      }[_currentLang]!;
    }
    if (desc.contains("light intensity shower rain")) {
      return {
        "kk": "Жеңіл нөсер",
        "ru": "Небольшой ливень",
        "en": "Light shower rain"
      }[_currentLang]!;
    }
    if (desc.contains("shower rain")) {
      return {
        "kk": "Нөсер",
        "ru": "Ливень",
        "en": "Shower rain"
      }[_currentLang]!;
    }
    if (desc.contains("heavy intensity shower rain")) {
      return {
        "kk": "Қатты нөсер",
        "ru": "Сильный ливень",
        "en": "Heavy shower rain"
      }[_currentLang]!;
    }
    if (desc.contains("ragged shower rain")) {
      return {
        "kk": "Құбылмалы нөсер",
        "ru": "Рваный ливень",
        "en": "Ragged shower rain"
      }[_currentLang]!;
    }

    // ------------------------
    // Drizzle
    // ------------------------
    if (desc.contains("drizzle")) {
      return {"kk": "Сілем", "ru": "Морось", "en": "Drizzle"}[_currentLang]!;
    }
    if (desc.contains("light intensity drizzle")) {
      return {
        "kk": "Жеңіл морось",
        "ru": "Небольшая морось",
        "en": "Light drizzle"
      }[_currentLang]!;
    }
    if (desc.contains("heavy intensity drizzle")) {
      return {
        "kk": "Қатты морось",
        "ru": "Сильная морось",
        "en": "Heavy drizzle"
      }[_currentLang]!;
    }
    if (desc.contains("drizzle rain")) {
      return {
        "kk": "Моросянды жаңбыр",
        "ru": "Моросящий дождь",
        "en": "Drizzle rain"
      }[_currentLang]!;
    }

    // ------------------------
    // Snow
    // ------------------------
    if (desc.contains("light snow")) {
      return {
        "kk": "Жеңіл қар",
        "ru": "Небольшой снег",
        "en": "Light snow"
      }[_currentLang]!;
    }
    if (desc.contains("snow")) {
      return {"kk": "Қар", "ru": "Снег", "en": "Snow"}[_currentLang]!;
    }
    if (desc.contains("heavy snow")) {
      return {
        "kk": "Қатты қар",
        "ru": "Сильный снег",
        "en": "Heavy snow"
      }[_currentLang]!;
    }
    if (desc.contains("sleet")) {
      return {
        "kk": "Сулы қар",
        "ru": "Мокрый снег",
        "en": "Sleet"
      }[_currentLang]!;
    }
    if (desc.contains("light shower sleet")) {
      return {
        "kk": "Жеңіл сулы қар жаууы",
        "ru": "Небольшой мокрый снег",
        "en": "Light shower sleet"
      }[_currentLang]!;
    }
    if (desc.contains("shower sleet")) {
      return {
        "kk": "Сулы қар жаууы",
        "ru": "Мокрый снег",
        "en": "Shower sleet"
      }[_currentLang]!;
    }
    if (desc.contains("light rain and snow")) {
      return {
        "kk": "Жеңіл жаңбыр мен қар",
        "ru": "Небольшой дождь со снегом",
        "en": "Light rain and snow"
      }[_currentLang]!;
    }
    if (desc.contains("rain and snow")) {
      return {
        "kk": "Жаңбыр мен қар",
        "ru": "Дождь со снегом",
        "en": "Rain and snow"
      }[_currentLang]!;
    }
    if (desc.contains("light shower snow")) {
      return {
        "kk": "Жеңіл қар жаууы",
        "ru": "Небольшой снегопад",
        "en": "Light shower snow"
      }[_currentLang]!;
    }
    if (desc.contains("shower snow")) {
      return {
        "kk": "Қар жаууы",
        "ru": "Снегопад",
        "en": "Shower snow"
      }[_currentLang]!;
    }
    if (desc.contains("heavy shower snow")) {
      return {
        "kk": "Қатты қар жаууы",
        "ru": "Сильный снегопад",
        "en": "Heavy shower snow"
      }[_currentLang]!;
    }

    // ------------------------
    // Thunderstorm
    // ------------------------
    if (desc.contains("thunderstorm with light rain")) {
      return {
        "kk": "Жеңіл жаңбырлы найзағай",
        "ru": "Гроза с небольшим дождем",
        "en": "Thunderstorm with light rain"
      }[_currentLang]!;
    }
    if (desc.contains("thunderstorm with rain")) {
      return {
        "kk": "Жаңбырлы найзағай",
        "ru": "Гроза с дождем",
        "en": "Thunderstorm with rain"
      }[_currentLang]!;
    }
    if (desc.contains("thunderstorm")) {
      return {
        "kk": "Найзағай",
        "ru": "Гроза",
        "en": "Thunderstorm"
      }[_currentLang]!;
    }
    if (desc.contains("heavy thunderstorm")) {
      return {
        "kk": "Қатты найзағай",
        "ru": "Сильная гроза",
        "en": "Heavy thunderstorm"
      }[_currentLang]!;
    }
    if (desc.contains("ragged thunderstorm")) {
      return {
        "kk": "Құбылмалы найзағай",
        "ru": "Рваная гроза",
        "en": "Ragged thunderstorm"
      }[_currentLang]!;
    }
    return desc;
  }
}
