import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

void main() {
  runApp(const TemperatureConverterApp());
}

enum ConversionType {
  fahrenheitToCelsius,
  celsiusToFahrenheit,
}

class TemperatureConverterApp extends StatelessWidget {
  const TemperatureConverterApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Temperature Converter',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: const ConverterScreen(),
    );
  }
}

class ConverterScreen extends StatefulWidget {
  const ConverterScreen({super.key});

  @override
  State<ConverterScreen> createState() => _ConverterScreenState();
}

class _ConverterScreenState extends State<ConverterScreen> {
  ConversionType _selectedConversion = ConversionType.fahrenheitToCelsius;
  final TextEditingController _inputController = TextEditingController();
  String _convertedValue = '0.00';
  final List<String> _conversionHistory = [];
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    _inputController.dispose();
    super.dispose();
  }

  void _performConversion() {
    if (_formKey.currentState!.validate()) {
      final double? inputValue = double.tryParse(_inputController.text);
      if (inputValue == null) {
        setState(() {
          _convertedValue = 'Invalid Input';
        });
        return;
      }

      double result;
      String historyEntry;

      if (_selectedConversion == ConversionType.fahrenheitToCelsius) {
        result = (inputValue - 32) * 5 / 9;
        historyEntry =
        'F to C: ${inputValue.toStringAsFixed(1)} => ${result.toStringAsFixed(2)}';
      } else {
        result = (inputValue * 9 / 5) + 32;
        historyEntry =
        'C to F: ${inputValue.toStringAsFixed(1)} => ${result.toStringAsFixed(2)}';
      }

      setState(() {
        _convertedValue = result.toStringAsFixed(2);
        _conversionHistory.insert(0, historyEntry);
      });
    }
  }

  void _clearHistory() {
    setState(() {
      _conversionHistory.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    final Orientation orientation = MediaQuery.of(context).orientation;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Temperature Converter'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.clear_all),
            tooltip: 'Clear History',
            onPressed: _clearHistory,
          ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: orientation == Orientation.portrait
            ? _buildPortraitLayout()
            : _buildLandscapeLayout(),
      ),
    );
  }

  Widget _buildConversionControls() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
          child: Text(
            'Conversion selections:',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
        ),
        RadioListTile<ConversionType>(
          title: const Text('Fahrenheit to Celsius'),
          value: ConversionType.fahrenheitToCelsius,
          groupValue: _selectedConversion,
          onChanged: (ConversionType? value) {
            setState(() {
              _selectedConversion = value!;
              _inputController.clear();
              _convertedValue = '0.00';
            });
          },
        ),
        RadioListTile<ConversionType>(
          title: const Text('Celsius to Fahrenheit'),
          value: ConversionType.celsiusToFahrenheit,
          groupValue: _selectedConversion,
          onChanged: (ConversionType? value) {
            setState(() {
              _selectedConversion = value!;
              _inputController.clear();
              _convertedValue = '0.00';
            });
          },
        ),
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: [
              Expanded(
                child: TextFormField(
                  controller: _inputController,
                  keyboardType: const TextInputType.numberWithOptions(decimal: true, signed: true),
                  inputFormatters: [
                    FilteringTextInputFormatter.allow(RegExp(r'^-?\d+\.?\d*')),
                  ],
                  decoration: InputDecoration(
                    labelText: 'Enter temperature',
                    border: const OutlineInputBorder(),
                    suffixText: _selectedConversion == ConversionType.fahrenheitToCelsius ? '°F' : '°C',
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter a value';
                    }
                    if (double.tryParse(value) == null) {
                      return 'Please enter a valid number';
                    }
                    return null;
                  },
                ),
              ),
              const SizedBox(width: 10),
              const Text('=', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
              const SizedBox(width: 10),
              Expanded(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 16.0),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey),
                    borderRadius: BorderRadius.circular(5.0),
                  ),
                  child: Text(
                    _convertedValue,
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
              const SizedBox(width: 5),
              Text(
                _selectedConversion == ConversionType.fahrenheitToCelsius ? '°C' : '°F',
                style: TextStyle(fontSize: 16, color: Colors.grey[700]),
              ),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: ElevatedButton(
            onPressed: _performConversion,
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 15),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8.0),
              ),
            ),
            child: const Text(
              'CONVERT',
              style: TextStyle(fontSize: 18),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildHistoryList() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
          child: Text(
            'Conversion History:',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
        ),
        Expanded(
          child: _conversionHistory.isEmpty
              ? const Center(child: Text('No conversions yet.'))
              : ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            itemCount: _conversionHistory.length,
            itemBuilder: (context, index) {
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 4.0),
                child: Text(
                  _conversionHistory[index],
                  style: const TextStyle(fontSize: 15),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildPortraitLayout() {
    return Column(
      children: [
        _buildConversionControls(),
        const SizedBox(height: 16),
        Expanded(child: _buildHistoryList()),
      ],
    );
  }

  Widget _buildLandscapeLayout() {
    return Row(
      children: [
        Expanded(
          flex: 2,
          child: SingleChildScrollView(
            child: _buildConversionControls(),
          ),
        ),
        const VerticalDivider(width: 20, thickness: 1),
        Expanded(
          flex: 3,
          child: _buildHistoryList(),
        ),
      ],
    );
  }
}
