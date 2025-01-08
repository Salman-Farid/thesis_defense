import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:lottie/lottie.dart';
import 'package:card_swiper/card_swiper.dart';

import 'generate_pdf.dart';
import 'home_page.dart';

class DisplayImagePage extends StatefulWidget {
  final Uint8List imageData;
  final String prediction;
  final double confidenceLevel;

  const DisplayImagePage({
    required this.imageData,
    required this.prediction,
    required this.confidenceLevel,
  });

  @override
  _DisplayImagePageState createState() => _DisplayImagePageState();
}

class _DisplayImagePageState extends State<DisplayImagePage> with SingleTickerProviderStateMixin {
  bool _showSymptoms = false;
  bool _showTreatments = false;
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    )..forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  String _getSymptoms(String disease) {
    // Keep your existing symptoms map
    Map<String, String> diseaseSymptoms = {
      "Blight": "1. Yellow spots on leaves\n2. Wilting\n3. Brown lesions on stems\n4. Premature leaf drop\n5. Fruit with dark spots\n6. Reduced yield.",
      "Common_Rust": "1. Orange pustules on leaves\n2. Yellowing of leaves\n3. Stunted growth\n4. Twisted and distorted leaves\n5. Powdery orange spores on stems\n6. Reduced fruit quality.",
      "Gray_Leaf_Spot": "1. Grayish spots on leaves\n2. Older leaves turning yellow\n3. Lesions along the veins of the leaves\n4. Spots becoming necrotic over time\n5. Premature leaf drop\n6. Reduced plant vigor.",
      "Healthy": "No symptoms. The plant is healthy.",
    };
    return diseaseSymptoms[disease] ?? "Symptoms not available.";
  }

  String _getTreatments(String disease) {
    // Keep your existing treatments map
    Map<String, String> diseaseTreatments = {
      "Blight": "1. Apply fungicides\n2. Ensure proper irrigation\n3. Remove infected plants to prevent spread\n4. Use resistant varieties of plants\n5. Implement crop rotation\n6. Maintain proper plant spacing to reduce humidity.",
      "Common_Rust": "1. Apply fungicides\n2. Remove affected leaves\n3. Use rust-resistant varieties of plants\n4. Apply appropriate fertilizers to enhance plant resistance\n5. Implement crop rotation to reduce infection\n6. Manage weeds which can harbor rust pathogens.",
      "Gray_Leaf_Spot": "1. Apply fungicides\n2. Manage plant debris to reduce infection sources\n3. Use resistant varieties of plants\n4. Implement crop rotation to break disease cycle\n5. Maintain proper plant spacing to improve air circulation\n6. Apply foliar fungicides at the first sign of infection.",
      "Healthy": "No treatments required. The plant is healthy.",
    };
    return diseaseTreatments[disease] ?? "Treatments not available.";
  }

  Widget _buildResultCard() {
    return Card(
      elevation: 8,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Container(
        padding: EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Analysis Results',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.green[800],
              ),
            ).animate().fadeIn(delay: 500.ms).slideY(begin: -0.3),
            SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.agriculture, color: Colors.green[600], size: 28),
                SizedBox(width: 8),
                Text(
                  widget.prediction.replaceAll('_', ' '),
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
                ),
              ],
            ).animate().fadeIn(delay: 700.ms).slideX(),
            SizedBox(height: 12),
            _buildConfidenceMeter(),
          ],
        ),
      ),
    );
  }

  Widget _buildConfidenceMeter() {
    return Column(
      children: [
        Text(
          'Confidence Level',
          style: TextStyle(fontSize: 16, color: Colors.grey[600]),
        ),
        SizedBox(height: 8),
        Stack(
          children: [
            Container(
              height: 20,
              decoration: BoxDecoration(
                color: Colors.grey[200],
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            AnimatedBuilder(
              animation: _controller,
              builder: (context, child) {
                return Container(
                  height: 20,
                  width: MediaQuery.of(context).size.width *
                      (widget.confidenceLevel / 100) * _controller.value,
                  decoration: BoxDecoration(
                    color: Colors.green[600],
                    borderRadius: BorderRadius.circular(10),
                  ),
                );
              },
            ),
          ],
        ),
        SizedBox(height: 4),
        Text(
          '${widget.confidenceLevel.toStringAsFixed(1)}%',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.green[800],
          ),
        ),
      ],
    ).animate().fadeIn(delay: 900.ms).slideY(begin: 0.3);
  }

  Widget _buildActionButton({
    required String text,
    required VoidCallback onPressed,
    required IconData icon,
  }) {
    return ElevatedButton.icon(
      onPressed: onPressed,
      icon: Icon(icon, color: Colors.white),
      label: Text(text),
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.green[700],
        padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(30),
        ),
      ),
    ).animate()
        .fadeIn(delay: 1100.ms)
        .slideX(begin: 0.3);
  }

  Widget _buildDetailSection({
    required String title,
    required String content,
    required IconData icon,
  }) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: Colors.green[700]),
                SizedBox(width: 8),
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.green[800],
                  ),
                ),
              ],
            ),
            Divider(),
            Text(
              content,
              style: TextStyle(fontSize: 16, height: 1.5),
            ),
          ],
        ),
      ),
    ).animate()
        .fadeIn(delay: 300.ms)
        .scale(begin: const Offset(0.8, 0.8));  // Fixed here
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.green[700],
        title: Text('Analysis Results', style: TextStyle(color: Colors.white)),
        actions: [
          IconButton(
            icon: Icon(Icons.info_outline, color: Colors.white),
            onPressed: () {
              // Show info dialog
              showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  title: Text('About Analysis'),
                  content: Text('This analysis is based on machine learning model predictions. Results may vary.'),
                  actions: [
                    TextButton(
                      child: Text('OK'),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          physics: BouncingScrollPhysics(),
          child: Padding(
            padding: EdgeInsets.all(16),
            child: Column(
              children: [
                Hero(
                  tag: 'plant_image',
                  child: Container(
                    height: 300,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.2),
                          spreadRadius: 2,
                          blurRadius: 10,
                        ),
                      ],
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(20),
                      child: Image.memory(
                        widget.imageData,
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                ).animate()
                    .fadeIn(duration: 600.ms)
                .scale(begin: const Offset(0.8, 0.8)),  // Fixed here

                SizedBox(height: 24),
                _buildResultCard(),
                SizedBox(height: 24),

                Row(
                  children: [
                    Expanded(
                      child: _buildActionButton(
                        text: 'Symptoms',
                        icon: Icons.sick,
                        onPressed: () => setState(() => _showSymptoms = !_showSymptoms),
                      ),
                    ),
                    SizedBox(width: 16),
                    Expanded(
                      child: _buildActionButton(
                        text: 'Treatments',
                        icon: Icons.healing,
                        onPressed: () => setState(() => _showTreatments = !_showTreatments),
                      ),
                    ),
                  ],
                ),

                if (_showSymptoms) ...[
                  SizedBox(height: 16),
                  _buildDetailSection(
                    title: 'Symptoms',
                    content: _getSymptoms(widget.prediction),
                    icon: Icons.visibility,
                  ),
                ],

                if (_showTreatments) ...[
                  SizedBox(height: 16),
                  _buildDetailSection(
                    title: 'Treatments',
                    content: _getTreatments(widget.prediction),
                    icon: Icons.medical_services,
                  ),
                ],

                SizedBox(height: 24),
                ElevatedButton.icon(
                  onPressed: () async {
                    await GeneratePdfPage.generatePdf(
                      imageData: widget.imageData,
                      prediction: widget.prediction,
                      confidenceLevel: widget.confidenceLevel,
                      symptoms: _getSymptoms(widget.prediction),
                      treatments: _getTreatments(widget.prediction),
                    );
                  },
                  icon: Icon(Icons.picture_as_pdf, color: Colors.white),
                  label: Text('Generate Report'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green[700],
                    padding: EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                  ),
                ).animate()
                    .fadeIn(delay: 1300.ms)
                    .slideY(begin: 0.3),
              ],
            ),
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => HomePage()),
          );
        },
        label: Text('Home'),
        icon: Icon(Icons.home),
        backgroundColor: Colors.green[700],
      ).animate()
          .fadeIn(delay: 1500.ms)
          .scale(begin: const Offset(0.8, 0.8)),  // Fixed here
    );
  }
}