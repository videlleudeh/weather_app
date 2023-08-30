import 'dart:convert';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:weather_app/add_info_item.dart';
import 'package:weather_app/env.dart';
import 'package:weather_app/hour_forecast_item.dart';
import 'package:http/http.dart' as http;

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  Future<Map<String, dynamic>> theCurrentWeather() async {
    try {
      String countryName = "Nigeria";
      final result = await http.get(
        Uri.parse(
          "https://api.openweathermap.org/data/2.5/forecast?q=$countryName&APPID=$openWeatherAPIKey",
        ),
      );

      final data = jsonDecode(result.body);

      if (data["cod"] != '200') {
        throw "An unexpected error occured";
      }

      return data;
    } catch (error) {
      throw error.toString();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Weather App",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        actions: [
          IconButton(
              onPressed: () {
                setState(() {});
              },
              icon: const Icon(Icons.refresh)),
        ],
      ),
      body: FutureBuilder(
        future: theCurrentWeather(),
        builder: (context, snapshot) {
          // print(snapshot);
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: RefreshProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(
              child: Text(snapshot.error.toString()),
            );
          }

          final data = snapshot.data!;

          final openWeatherData = data['list'][0];

          final currentTemp = openWeatherData['main']['temp'];
          final currentElement = openWeatherData['weather'][0]['main'];
          final humidity = openWeatherData['main']['humidity'];
          final windSpeed = openWeatherData['wind']['speed'];
          final pressure = openWeatherData['main']['pressure'];

          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Main Card
                SizedBox(
                  width: double.infinity,
                  child: Card(
                    elevation: 10,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(15),
                      child: BackdropFilter(
                        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            children: [
                              Text(
                                '$currentTemp K',
                                style: const TextStyle(
                                    fontSize: 32, fontWeight: FontWeight.bold),
                              ),
                              const SizedBox(
                                height: 15,
                              ),
                              Icon(
                                currentElement == 'Clouds' ||
                                        currentElement == 'Rain'
                                    ? Icons.cloud
                                    : Icons.sunny,
                                size: 64,
                              ),
                              const SizedBox(
                                height: 15,
                              ),
                              Text(
                                currentElement,
                                style: const TextStyle(fontSize: 20),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(
                  height: 20,
                ),
                // Weather forecast
                const Text(
                  'Hourly Forecast',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 15),
                SizedBox(
                  height: 130,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: 5,
                    itemBuilder: (context, index) {
                      final hourForecastData = data['list'][index];
                      final hourForecastIcon =
                          data['list'][1]['weather'][0]['main'];
                      final time =
                          DateTime.parse(hourForecastData['dt_txt'].toString());
                      return HourForecast(
                        time: DateFormat.Hm().format(time),
                        icon: hourForecastIcon == 'Clouds' ||
                                hourForecastIcon == 'Rain'
                            ? Icons.cloud
                            : Icons.sunny,
                        temperature:
                            hourForecastData['main']['temp'].toString(),
                      );
                    },
                  ),
                ),

                const SizedBox(height: 20),
                // Additional Information
                const Text(
                  'Additional information',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    AddInfo(
                      icon: Icons.water_drop,
                      elements: 'Humidity',
                      value: humidity.toString(),
                    ),
                    AddInfo(
                      icon: Icons.air,
                      elements: 'Wind Speed',
                      value: windSpeed.toString(),
                    ),
                    AddInfo(
                      icon: Icons.monitor_weight,
                      elements: 'Pressure',
                      value: pressure.toString(),
                    ),
                  ],
                )
              ],
            ),
          );
        },
      ),
    );
  }
}
