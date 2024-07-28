import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class PredictionFormPage extends StatefulWidget {
  @override
  _PredictionFormPageState createState() => _PredictionFormPageState();
}

class _PredictionFormPageState extends State<PredictionFormPage> {
  final _formKey = GlobalKey<FormState>();
  final Map<String, dynamic> _formData = {
    "weight": null,
    "resolution": null,
    "pixels_per_inch": null,
    "cpu_core": null,
    "cpu_freq": '',
    "internal_mem": '',
    "ram": null,
    "RearCam": null,
    "Front_Cam": null,
    "battery": '',
    "thickness": '',
  };
  String _predictedPrice = '';
  bool _isLoading = false;
  double _formOpacity = 1.0;
  List<Map<String, dynamic>> _previousPredictions = [];

  Future<void> _submitForm() async {
    try {
      setState(() {
        _isLoading = true;
        _formOpacity = 0.5;
      });

      final url = Uri.parse(
          'https://linear-regression-model-w1my.onrender.com/predict');
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          "weight": double.parse(_formData["weight"].toString()),
          "resoloution": double.parse(_formData["resolution"].toString()),
          "ppi": int.parse(_formData["pixels_per_inch"].toString()),
          "cpu_core": int.parse(_formData["cpu_core"].toString()),
          "cpu_freq": double.parse(_formData["cpu_freq"].toString()),
          "internal_mem": double.parse(_formData["internal_mem"].toString()),
          "ram": double.parse(_formData["ram"].toString()),
          "RearCam": double.parse(_formData["RearCam"].toString()),
          "Front_Cam": double.parse(_formData["Front_Cam"].toString()),
          "battery": int.parse(_formData["battery"].toString()),
          "thickness": double.parse(_formData["thickness"].toString()),
        }),
      );

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        setState(() {
          _predictedPrice =
              double.parse(responseData['predicted_price'].toString())
                  .toStringAsFixed(3);
          _previousPredictions
              .add({..._formData, "predicted_price": _predictedPrice});
          _isLoading = false;
          _formOpacity = 1.0;
        });
      } else {
        throw Exception('Failed to load data from API');
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
        _formOpacity = 1.0;
        _predictedPrice = "Error occurred: $e";
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Predict Cell Phone Price'),
        backgroundColor: Colors.blueAccent,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.all(16.0),
          child: Column(
            children: [
              Text(
                'Welcome to the Cell Phone Price Predictor!',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 10),
              Text(
                'Fill in the specifications below to get an estimated price for your device.',
                style: TextStyle(fontSize: 16),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 20),
              Form(
                key: _formKey,
                child: Column(
                  children: [
                    AnimatedOpacity(
                      opacity: _formOpacity,
                      duration: Duration(milliseconds: 500),
                      child: Column(
                        children: [
                          _buildDropdownField("Weight", "weight",
                              [110.0, 125.0, 135.0, 150.0, 170.0, 202.0]),
                          _buildDropdownField("Resolution", "resolution",
                              [4.0, 4.7, 5.2, 5.5, 6.0]),
                          _buildDropdownField("Pixels per inch",
                              "pixels_per_inch", [233, 312, 401, 424, 534]),
                          _buildDropdownField(
                              "CPU Core", "cpu_core", [2, 4, 8]),
                          _buildTextField("CPU Freq", "cpu_freq"),
                          _buildTextField("Internal Memory", "internal_mem"),
                          _buildDropdownField(
                              "RAM", "ram", [0.512, 1.0, 1.5, 3.0, 4.0, 6.0]),
                          _buildDropdownField("Rear Camera", "RearCam",
                              [3.15, 12.0, 13.0, 20.0, 21.5]),
                          _buildDropdownField("Front Camera", "Front_Cam",
                              [0.0, 5.0, 8.0, 16.0, 20.0]),
                          _buildTextField("Battery", "battery"),
                          _buildTextField("Thickness", "thickness"),
                          const SizedBox(height: 20),
                          AnimatedContainer(
                            duration: Duration(milliseconds: 500),
                            width: _isLoading
                                ? 50
                                : MediaQuery.of(context).size.width * 0.9,
                            child: ElevatedButton(
                              onPressed: () {
                                if (_formKey.currentState!.validate()) {
                                  _formKey.currentState!.save();
                                  _submitForm();
                                }
                              },
                              style: ElevatedButton.styleFrom(
                                foregroundColor: Colors.white,
                                backgroundColor: Colors.blueAccent,
                                padding: EdgeInsets.symmetric(vertical: 16.0),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8.0),
                                ),
                              ),
                              child: _isLoading
                                  ? SizedBox(
                                      width: 24,
                                      height: 24,
                                      child: CircularProgressIndicator(
                                        color: Colors.white,
                                      ),
                                    )
                                  : Text('Predict'),
                            ),
                          ),
                          SizedBox(height: 20),
                          if (_predictedPrice.isNotEmpty)
                            AnimatedOpacity(
                              opacity: _predictedPrice.isNotEmpty ? 1.0 : 0.0,
                              duration: Duration(milliseconds: 500),
                              child: Text(
                                'Predicted Price: $_predictedPrice',
                                style: TextStyle(
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.green,
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 20),
              if (_previousPredictions.isNotEmpty)
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Previous Predictions:',
                      style:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    ..._previousPredictions.map((prediction) {
                      return Card(
                        margin: EdgeInsets.symmetric(vertical: 8.0),
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Text(
                            'Weight: ${prediction["weight"]}, Resolution: ${prediction["resolution"]}, PPI: ${prediction["pixels_per_inch"]}, CPU Core: ${prediction["cpu_core"]}, CPU Freq: ${prediction["cpu_freq"]}, Internal Mem: ${prediction["internal_mem"]}, RAM: ${prediction["ram"]}, RearCam: ${prediction["RearCam"]}, FrontCam: ${prediction["Front_Cam"]}, Battery: ${prediction["battery"]}, Thickness: ${prediction["thickness"]} => Predicted Price: \$${prediction["predicted_price"]}',
                            style: TextStyle(fontSize: 14),
                          ),
                        ),
                      );
                    }).toList(),
                  ],
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDropdownField(String label, String key, List<dynamic> options) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: DropdownButtonFormField<dynamic>(
        decoration: InputDecoration(
          labelText: label,
          border: OutlineInputBorder(),
          filled: true,
          fillColor: Colors.grey[200],
        ),
        value: _formData[key],
        items: options.map((dynamic value) {
          return DropdownMenuItem<dynamic>(
            value: value,
            child: Text(value.toString()),
          );
        }).toList(),
        onChanged: (newValue) {
          setState(() {
            _formData[key] = newValue;
          });
        },
        validator: (value) {
          if (value == null) {
            return 'Please select a value';
          }
          return null;
        },
      ),
    );
  }

  Widget _buildTextField(String label, String key) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: TextFormField(
        decoration: InputDecoration(
          labelText: label,
          border: OutlineInputBorder(),
          filled: true,
          fillColor: Colors.grey[200],
        ),
        keyboardType: key.contains('Core') || key.contains('battery')
            ? TextInputType.number
            : TextInputType.numberWithOptions(decimal: true),
        onSaved: (value) {
          _formData[key] = value;
        },
        validator: (value) {
          if (value == null || value.isEmpty) {
            return 'Please enter a value';
          }
          return null;
        },
      ),
    );
  }
}

void main() {
  runApp(MaterialApp(
    home: PredictionFormPage(),
    theme: ThemeData(
      primarySwatch: Colors.blue,
      visualDensity: VisualDensity.adaptivePlatformDensity,
    ),
  ));
}
