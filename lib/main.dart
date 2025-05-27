// lib/main.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // Required for FilteringTextInputFormatter

void main() {
  runApp(const TemperatureConverterApp());
}

// Define an enum for the conversion types to make the code cleaner and more readable
enum ConversionType {
  fahrenheitToCelsius,
  celsiusToFahrenheit,
}

class TemperatureConverterApp extends StatelessWidget {
  const TemperatureConverterApp({super.key});

  @override
  Widget build(BuildContext context) {
    // MaterialApp sets up the basic visual structure of a Flutter app
    return MaterialApp(
      title: 'Temperature Converter', // Title for the app in the task switcher
      theme: ThemeData(
        primarySwatch: Colors.blue, // Defines the primary color for the app
        visualDensity: VisualDensity.adaptivePlatformDensity, // Adapts density based on platform
      ),
      home: const ConverterScreen(), // The main screen of our application
    );
  }
}

class ConverterScreen extends StatefulWidget {
  const ConverterScreen({super.key});

  @override
  State<ConverterScreen> createState() => _ConverterScreenState();
}

class _ConverterScreenState extends State<ConverterScreen> {
  // State variables to manage the app's dynamic content
  ConversionType _selectedConversion = ConversionType.fahrenheitToCelsius; // Default conversion type
  final TextEditingController _inputController = TextEditingController(); // Controller for the input text field
  String _convertedValue = '0.00'; // Stores the calculated converted value, initialized to 0.00
  final List<String> _conversionHistory = []; // List to store all past conversions
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>(); // Key for form validation

  @override
  void dispose() {
    // Clean up the controller when the widget is removed from the widget tree
    _inputController.dispose();
    super.dispose();
  }

  // Function to perform the temperature conversion
  void _performConversion() {
    // Validate the input field before performing conversion
    if (_formKey.currentState!.validate()) {
      // Attempt to parse the input text into a double
      final double? inputValue = double.tryParse(_inputController.text);

      // Handle case where input is not a valid number
      if (inputValue == null) {
        setState(() {
          _convertedValue = 'Invalid Input'; // Display error message
        });
        return; // Exit function if input is invalid
      }

      double result; // Variable to store the conversion result
      String historyEntry; // String to store the history log

      // Perform conversion based on the selected type
      if (_selectedConversion == ConversionType.fahrenheitToCelsius) {
        // Formula: °C = (°F - 32) x 5/9
        result = (inputValue - 32) * 5 / 9;
        // Format history entry
        historyEntry =
            'F to C: ${inputValue.toStringAsFixed(1)} => ${result.toStringAsFixed(2)}';
      } else {
        // Formula: °F = °C x 9/5 + 32
        result = (inputValue * 9 / 5) + 32;
        // Format history entry
        historyEntry =
            'C to F: ${inputValue.toStringAsFixed(1)} => ${result.toStringAsFixed(2)}';
      }

      // Update the UI state
      setState(() {
        _convertedValue = result.toStringAsFixed(2); // Format result to 2 decimal places
        _conversionHistory.insert(0, historyEntry); // Add new entry to the top of the history list
      });
    }
  }

  // Function to clear the conversion history
  void _clearHistory() {
    setState(() {
      _conversionHistory.clear(); // Clear all items from the history list
    });
  }

  @override
  Widget build(BuildContext context) {
    // Determine current device orientation
    final Orientation orientation = MediaQuery.of(context).orientation;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Temperature Converter'), // App bar title
        centerTitle: true, // Center the title
        actions: [
          // Action button in the app bar to clear history
          IconButton(
            icon: const Icon(Icons.clear_all),
            tooltip: 'Clear History', // Tooltip for accessibility
            onPressed: _clearHistory, // Call clear history function
          ),
        ],
      ),
      body: Form(
        key: _formKey, // Associate the form key for validation
        // Use different layouts based on orientation
        child: orientation == Orientation.portrait
            ? _buildPortraitLayout() // Portrait mode layout
            : _buildLandscapeLayout(), // Landscape mode layout
      ),
    );
  }

  // Helper widget to build the conversion controls section (radio buttons, input/output, convert button)
  Widget _buildConversionControls() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch, // Stretch children horizontally
      children: [
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
          child: Text(
            'Conversion selections:', // Label for conversion type selection
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
        ),
        // Radio button for Fahrenheit to Celsius
        RadioListTile<ConversionType>(
          title: const Text('Fahrenheit to Celsius'),
          value: ConversionType.fahrenheitToCelsius,
          groupValue: _selectedConversion,
          onChanged: (ConversionType? value) {
            setState(() {
              _selectedConversion = value!; // Update selected conversion type
              // Optionally clear input and output when conversion type changes
              _inputController.clear();
              _convertedValue = '0.00';
            });
          },
        ),
        // Radio button for Celsius to Fahrenheit
        RadioListTile<ConversionType>(
          title: const Text('Celsius to Fahrenheit'),
          value: ConversionType.celsiusToFahrenheit,
          groupValue: _selectedConversion,
          onChanged: (ConversionType? value) {
            setState(() {
              _selectedConversion = value!; // Update selected conversion type
              // Optionally clear input and output when conversion type changes
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
                  controller: _inputController, // Link controller to text field
                  keyboardType:
                      const TextInputType.numberWithOptions(decimal: true, signed: true), // Allow numbers, decimals, and signs
                  inputFormatters: [
                    FilteringTextInputFormatter.allow(
                        RegExp(r'^-?\d+\.?\d*')), // Regex to allow numbers (positive/negative) and optional decimal
                  ],
                  decoration: InputDecoration(
                    labelText: 'User temperature entry field', // Label for input field
                    border: const OutlineInputBorder(), // Add a border
                    // Dynamically display unit suffix (°F or °C)
                    suffixText: _selectedConversion == ConversionType.fahrenheitToCelsius ? '°F' : '°C',
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter a value'; // Validation for empty input
                    }
                    if (double.tryParse(value) == null) {
                      return 'Please enter a valid number'; // Validation for non-numeric input
                    }
                    return null; // Return null if input is valid
                  },
                ),
              ),
              const SizedBox(width: 10), // Space between input and '='
              const Text(
                '=', // Equality sign
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              const SizedBox(width: 10), // Space between '=' and output
              Expanded(
                child: Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 12.0, vertical: 16.0),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey), // Border for the output box
                    borderRadius: BorderRadius.circular(5.0), // Rounded corners
                  ),
                  child: Text(
                    _convertedValue, // Display converted value
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    textAlign: TextAlign.center, // Center align the text
                  ),
                ),
              ),
              const SizedBox(width: 5), // Small space for suffix text
              Text(
                // Dynamically display unit suffix (°C or °F) for converted value
                _selectedConversion == ConversionType.fahrenheitToCelsius ? '°C' : '°F',
                style: TextStyle(fontSize: 16, color: Colors.grey[700]),
              ),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: ElevatedButton(
            onPressed: _performConversion, // Call conversion function on press
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 15),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8.0), // Rounded corners for button
              ),
            ),
            child: const Text(
              'CONVERT', // Button text
              style: TextStyle(fontSize: 18),
            ),
          ),
        ),
      ],
    );
  }

  // Helper widget to build the conversion history list
  Widget _buildHistoryList() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start, // Align children to the start
      children: [
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
          child: Text(
            'History of conversions made in this execution (most recent at the top):', // History label
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
        ),
        Expanded(
          // Use Expanded to make ListView take available space
          child: _conversionHistory.isEmpty
              ? const Center(
                  child: Text('No conversions yet.'), // Message when history is empty
                )
              : ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  itemCount: _conversionHistory.length, // Number of items in history
                  itemBuilder: (context, index) {
                    // Build each history item as a Text widget
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

  // Layout for portrait orientation
  Widget _buildPortraitLayout() {
    return Column(
      children: [
        _buildConversionControls(), // Top section with controls
        const SizedBox(height: 16), // Space between controls and history
        Expanded(
          child: _buildHistoryList(), // Bottom section with history, takes remaining space
        ),
      ],
    );
  }

  // Layout for landscape orientation
  Widget _buildLandscapeLayout() {
    return Row(
      children: [
        Expanded(
          flex: 2, // Controls section takes 2/3 of the space
          child: SingleChildScrollView(
            // Allows scrolling if controls content exceeds screen height in landscape
            child: _buildConversionControls(),
          ),
        ),
        const VerticalDivider(width: 20, thickness: 1), // Visual separator
        Expanded(
          flex: 1, // History section takes 1/3 of the space
          child: _buildHistoryList(),
        ),
      ],
    );
  }
}