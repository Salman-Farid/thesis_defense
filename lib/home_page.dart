import 'dart:typed_data';
import 'dart:convert';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_animate/flutter_animate.dart';
import 'package:plant_treatmonty/services/auth_service.dart';
import 'display_image_page.dart';
import 'feedback_page.dart';
import 'screens/login_page.dart';






class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}
final AuthService _authService = AuthService();

class _HomePageState extends State<HomePage>
    with SingleTickerProviderStateMixin {
  Stream<User?> userStream = FirebaseAuth.instance.authStateChanges();
  User? _user;
  String? _fullName;
  Uint8List? _imageData;
  String? _prediction;
  double? _confidenceLevel;
  bool _isModelReady = true;
  bool _isLoading = false;
  late AnimationController _animationController;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    )..forward();
    userStream.listen((user) {
      setState(() {
        _user = user;
        _fetchFullName();
      });
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _fetchFullName() async {
    if (_user != null) {
      DatabaseReference userRef =
          FirebaseDatabase.instance.ref().child('users').child(_user!.uid);
      DataSnapshot snapshot = await userRef.get();

      if (snapshot.value != null) {
        Map<String, dynamic> userData = Map<String, dynamic>.from(snapshot.value as Map);
        setState(() {
          _fullName = userData['full_name'];
        });
      }

    }
  }

  Future<void> _pickImage(ImageSource source) async {
    try {
      final pickedImage = await ImagePicker().pickImage(source: source);
      if (pickedImage == null) return;
      final imageData = await pickedImage.readAsBytes();
      setState(() {
        _imageData = imageData;
      });
    } catch (e) {
      _showErrorSnackBar('Failed to process image: $e');
    }
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red[700],
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        margin: EdgeInsets.all(16),
      ),
    );
  }

  Future<void> _runModelOnImage() async {
    if (_isModelReady && _imageData != null) {
      setState(() => _isLoading = true);
      try {
        var request = http.MultipartRequest('POST', Uri.parse('https://maizediseasepredict.onrender.com/predict'),);
        request.files.add(
          http.MultipartFile.fromBytes('file', _imageData!,
              filename: 'image.jpg'),
        );

        var response = await request.send();
        var result = await response.stream.bytesToString();
        var jsonResult = json.decode(result);

        setState(() {
          _prediction = jsonResult['prediction'] as String;
          _confidenceLevel = (jsonResult['confidence_level'] as double) * 100;
          _isLoading = false;
        });

        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => DisplayImagePage(
              imageData: _imageData!,
              prediction: _prediction!,
              confidenceLevel: _confidenceLevel!,
            ),
          ),
        );
      } catch (e) {
        setState(() => _isLoading = false);
        _showErrorSnackBar('Failed to analyze image: $e');
      }
    } else {
      _showErrorSnackBar('Please select an image first');
    }
  }

  Widget _buildImagePreview() {
    return AnimatedContainer(
      duration: Duration(milliseconds: 300),
      curve: Curves.easeInOut,
      height: _imageData != null ? 300 : 0,
      child: _imageData != null
          ? Hero(
              tag: 'preview_image',
              child: Container(
                margin: EdgeInsets.all(16),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.2),
                      blurRadius: 10,
                      spreadRadius: 2,
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(20),
                  child: Image.memory(
                    _imageData!,
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            )
          : SizedBox.shrink(),
    ).animate().fadeIn().scale(begin: const Offset(0.8, 0.8));
  }

  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required VoidCallback onPressed,
    required Color color,
  }) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        padding: EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        elevation: 4,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: Colors.white),
          SizedBox(width: 8),
          Text(
            label,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
          ),
        ],
      ),
    ).animate().fadeIn(delay: 200.ms).slideX(begin: 0.3);
  }

  Widget _buildDrawerHeader() {
    return DrawerHeader(
      decoration: BoxDecoration(
        color: Colors.green[700],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            radius: 30,
            backgroundImage:AssetImage('assets/profile.png'
            ),
          ).animate().scale(begin: const Offset(0, 0)),
          SizedBox(height: 12),
          Text(
            _fullName ?? 'Guest',
            style: TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ).animate().fadeIn(delay: 200.ms).slideX(),
          Text(
            _user?.email ?? 'No Email',
            style: TextStyle(
              color: Colors.white70,
              fontSize: 14,
            ),
          ).animate().fadeIn(delay: 400.ms).slideX(),
        ],
      ),
    );
  }

  @override
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: Text(
          'Plant Disease Detection',
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
          ),
        ),
        iconTheme: IconThemeData(color: Colors.black),
        actions: [
          IconButton(
            icon: Icon(Icons.logout),
            onPressed: () async {
              await FirebaseAuth.instance.signOut();
              Navigator.of(context).pushReplacement(
                MaterialPageRoute(builder: (context) => LoginPage(authService: _authService,)),
              );
            },
          ),
        ],
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            _buildDrawerHeader(),
            ListTile(
              leading: Icon(Icons.eco, color: Colors.green[700]),
              title: Text('Plant Care Guide'),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => PlantCarePage()),
                );
              },
            ),
            ListTile(
              leading: Icon(Icons.medical_services, color: Colors.green[700]),
              title: Text('Disease Library'),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => DiseaseLibraryPage()),
                );
              },
            ),
            ListTile(
              leading: Icon(Icons.feedback_outlined, color: Colors.green[700]),
              title: Text('Feedback'),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => FeedbackPage()),
                );
              },
            ),
          ],
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          physics: BouncingScrollPhysics(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Container(
                margin: EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Welcome, ${_fullName ?? 'User'}!',
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 8),
                    Text(
                      'Let\'s check your plant\'s health',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),
              if (!_isLoading) ...[
                Container(
                  margin: EdgeInsets.symmetric(horizontal: 20),
                  padding: EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 10,
                        spreadRadius: 0,
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      if (_imageData != null) _buildImagePreview(),
                      if (_imageData == null) ...[
                        Icon(
                          Icons.add_a_photo,
                          size: 48,
                          color: Colors.green[700],
                        ),
                        SizedBox(height: 16),
                        Text(
                          'Take or Upload a Photo',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: 8),
                        Text(
                          'Get instant disease detection results',
                          textAlign: TextAlign.center,
                          style: TextStyle(color: Colors.grey[600]),
                        ),
                      ],
                      SizedBox(height: 24),
                      Row(
                        children: [
                          Expanded(
                            child: _buildActionButton(
                              icon: Icons.photo_library,
                              label: 'Gallery',
                              onPressed: () => _pickImage(ImageSource.gallery),
                              color: Colors.deepOrange[200]!,
                            ),
                          ),
                          SizedBox(width: 12),
                          Expanded(
                            child: _buildActionButton(
                              icon: Icons.camera_alt,
                              label: 'Camera',
                              onPressed: () => _pickImage(ImageSource.camera),
                              color: Colors.lightBlue[300]!,
                            ),
                          ),
                        ],
                      ),
                      if (_imageData != null) ...[
                        SizedBox(height: 12),
                        _buildActionButton(
                          icon: Icons.search,
                          label: 'Analyze Plant',
                          onPressed: _runModelOnImage,
                          color: Colors.green[700]!,
                        ),
                      ],
                    ],
                  ),
                ),
                SizedBox(height: 24),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 20),
                  child: Text(
                    'Quick Actions',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                SizedBox(height: 16),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  padding: EdgeInsets.symmetric(horizontal: 20),
                  child: Row(
                    children: [
                      _buildQuickActionCard(
                        'Plant Care',
                        Icons.eco,
                        Colors.green,
                        () => Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => PlantCarePage()),
                        ),
                      ),
                      SizedBox(width: 16),
                      _buildQuickActionCard(
                        'Disease Library',
                        Icons.medical_services,
                        Colors.orange,
                        () => Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => DiseaseLibraryPage()),
                        ),
                      ),
                      SizedBox(width: 16),
                      _buildQuickActionCard(
                        'History',
                        Icons.history,
                        Colors.blue,
                        () {
                          // Add history functionality
                        },
                      ),
                    ],
                  ),
                ),
              ],
              if (_isLoading)
                Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.green),
                      ),
                      SizedBox(height: 16),
                      Text(
                        'Analyzing your plant...',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildQuickActionCard(
      String title, IconData icon, Color color, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      child: Container(
        width: 120,
        padding: EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: color, size: 32),
            SizedBox(height: 8),
            Text(
              title,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
          ],
        ),
      ),
    ).animate().fadeIn().scale(delay: 200.ms);
  }
}
class DiseaseLibraryPage extends StatelessWidget {
  final List<Map<String, dynamic>> diseases = [
    {
      'name': 'Northern Corn Leaf Blight',
      'symptoms': 'Long, cigar-shaped lesions on leaves',
      'treatment': 'Apply fungicides, use resistant varieties',
      'severity': 'High',
      'color': Colors.red,
    },
    {
      'name': 'Common Rust',
      'symptoms': 'Small, reddish-brown pustules on leaves',
      'treatment': 'Early fungicide application, crop rotation',
      'severity': 'Medium',
      'color': Colors.orange,
    },
    {
      'name': 'Gray Leaf Spot',
      'symptoms': 'Rectangular lesions between leaf veins',
      'treatment': 'Fungicide treatment, improve air circulation',
      'severity': 'High',
      'color': Colors.red,
    },
    {
      'name': 'Southern Corn Leaf Blight',
      'symptoms': 'Small, tan lesions with dark borders',
      'treatment': 'Resistant hybrids, proper field management',
      'severity': 'Medium',
      'color': Colors.orange,
    },
  ];

  Widget _buildSeverityBadge(String severity, Color color) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        severity,
        style: TextStyle(
          color: color,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: Text('Disease Library'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
      ),
      body: ListView.builder(
        padding: EdgeInsets.all(16),
        itemCount: diseases.length,
        itemBuilder: (context, index) {
          final disease = diseases[index];
          return Card(
            margin: EdgeInsets.only(bottom: 16),
            elevation: 2,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            child: Padding(
              padding: EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          disease['name'],
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      _buildSeverityBadge(
                        disease['severity'],
                        disease['color'],
                      ),
                    ],
                  ),
                  SizedBox(height: 16),
                  _buildInfoRow(
                    Icons.warning_amber,
                    'Symptoms',
                    disease['symptoms'],
                  ),
                  SizedBox(height: 12),
                  _buildInfoRow(
                    Icons.healing,
                    'Treatment',
                    disease['treatment'],
                  ),
                ],
              ),
            ),
          ).animate().fadeIn().slideX();
        },
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String text) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 20, color: Colors.grey[600]),
        SizedBox(width: 8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  color: Colors.grey[600],
                  fontWeight: FontWeight.w500,
                ),
              ),
              SizedBox(height: 4),
              Text(text),
            ],
          ),
        ),
      ],
    );
  }
}
class PlantCarePage extends StatelessWidget {
  final List<Map<String, dynamic>> careGuides = [
    {
      'title': 'Watering Guide',
      'icon': Icons.water_drop,
      'color': Colors.blue,
      'tips': [
        'Water deeply and less frequently',
        'Best time: Early morning',
        'Check soil moisture before watering',
        'Avoid waterlogging the roots'
      ]
    },
    {
      'title': 'Fertilization',
      'icon': Icons.grass,
      'color': Colors.green,
      'tips': [
        'Apply NPK fertilizer every 3-4 weeks',
        'Use organic compost for better results',
        'Monitor leaf color for nutrient deficiency',
        'Avoid over-fertilization'
      ]
    },
    {
      'title': 'Pest Control',
      'icon': Icons.bug_report,
      'color': Colors.orange,
      'tips': [
        'Regular inspection for pest damage',
        'Use natural pest deterrents',
        'Maintain plant hygiene',
        'Remove affected leaves promptly'
      ]
    },
    {
      'title': 'Growth Conditions',
      'icon': Icons.wb_sunny,
      'color': Colors.amber,
      'tips': [
        'Ensure proper sunlight exposure',
        'Maintain optimal spacing',
        'Control weed growth',
        'Monitor temperature conditions'
      ]
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: Text('Plant Care Guide'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
      ),
      body: ListView.builder(
        padding: EdgeInsets.all(16),
        itemCount: careGuides.length,
        itemBuilder: (context, index) {
          final guide = careGuides[index];
          return Card(
            margin: EdgeInsets.only(bottom: 16),
            elevation: 2,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            child: ExpansionTile(
              leading: Container(
                padding: EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: guide['color'].withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(guide['icon'], color: guide['color']),
              ),
              title: Text(
                guide['title'],
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
              ),
              children: [
                Padding(
                  padding: EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: (guide['tips'] as List<String>).map((tip) {
                      return Padding(
                        padding: EdgeInsets.only(bottom: 8),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Icon(Icons.check_circle,
                                size: 20, color: guide['color']),
                            SizedBox(width: 8),
                            Expanded(child: Text(tip)),
                          ],
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ],
            ),
          ).animate().fadeIn().slideX();
        },
      ),
    );
  }
}
