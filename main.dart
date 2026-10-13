import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:async';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  // делаем статус бар прозрачным
  SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
    statusBarIconBrightness: Brightness.light,
  ));
  runApp(const TimerApp());
}

class TimerApp extends StatelessWidget {
  const TimerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark(),
      home: const TransparentTimerWidget(),
    );
  }
}

class TransparentTimerWidget extends StatefulWidget {
  const TransparentTimerWidget({super.key});

  @override
  State<TransparentTimerWidget> createState() => _TransparentTimerWidgetState();
}

class _TransparentTimerWidgetState extends State<TransparentTimerWidget> {
  String _timeLeft = "00:00:00";
  DateTime _targetDate = DateTime(2026, 12, 31, 23, 59);
  
  // стили
  final List<String> _styles = ['classic', 'winter', 'newyear', 'rain', 'neon', 'gothic'];
  int _currentStyleIndex = 0;
  Color _currentColor = Colors.white;
  
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _startTimer();
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        final now = DateTime.now();
        final diff = _targetDate.difference(now);
        
        if (diff.isNegative) {
          _timeLeft = "00:00:00";
        } else {
          final hours = diff.inHours.toString().padLeft(2, '0');
          final minutes = (diff.inMinutes % 60).toString().padLeft(2, '0');
          final seconds = (diff.inSeconds % 60).toString().padLeft(2, '0');
          _timeLeft = "$hours:$minutes:$seconds";
        }
      });
    });
  }

  void _cycleStyle() {
    setState(() {
      _currentStyleIndex = (_currentStyleIndex + 1) % _styles.length;
      _updateTheme();
    });
  }

  void _changeColor() {
    // простой перебор цветов для примера
    setState(() {
      if (_currentColor == Colors.white) _currentColor = Colors.red;
      else if (_currentColor == Colors.red) _currentColor = Colors.blue;
      else if (_currentColor == Colors.blue) _currentColor = Colors.yellow;
      else _currentColor = Colors.white;
    });
  }

  void _updateTheme() {
    // здесь можно менять шрифт или эффекты в зависимости от стиля
    // для простоты меняем только цвет если стиль classic
    if (_styles[_currentStyleIndex] == 'classic') {
      _currentColor = Colors.white; // сброс на дефолт или оставление текущего
    } else if (_styles[_currentStyleIndex] == 'neon') {
      _currentColor = const Color(0xFF00FF00);
    } else if (_styles[_currentStyleIndex] == 'gothic') {
      _currentColor = Colors.deepPurple;
    }
  }

  TextStyle _getTextStyle() {
    String styleName = _styles[_currentStyleIndex];
    
    switch (styleName) {
      case 'winter':
        return TextStyle(color: Colors.lightBlueAccent, fontSize: 48, fontWeight: FontWeight.bold, shadows: [Shadow(blurRadius: 10, color: Colors.white)]);
      case 'newyear':
        return TextStyle(color: Colors.red, fontSize: 48, fontWeight: FontWeight.bold, fontFamily: 'serif');
      case 'neon':
        return TextStyle(color: _currentColor, fontSize: 48, fontWeight: FontWeight.bold, shadows: [Shadow(blurRadius: 20, color: _currentColor)]);
      case 'gothic':
        return TextStyle(color: _currentColor, fontSize: 48, fontWeight: FontWeight.w900, letterSpacing: 2);
      case 'rain':
        return TextStyle(color: Colors.grey, fontSize: 48, fontWeight: FontWeight.normal);
      default: // classic
        return TextStyle(color: _currentColor, fontSize: 48, fontWeight: FontWeight.bold);
    }
  }

  @override
  Widget build(BuildContext context) {
    // Scaffold с прозрачным фоном
    return Scaffold(
      backgroundColor: Colors.transparent, 
      body: Stack(
        children: [
          // сам таймер по центру
          Center(
            child: Text(_timeLeft, style: _getTextStyle()),
          ),
          
          // кнопки управления внизу (полупрозрачные)
          Positioned(
            bottom: 50,
            left: 0,
            right: 0,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                IconButton(
                  icon: const Icon(Icons.palette, color: Colors.white54),
                  onPressed: _cycleStyle,
                ),
                if (_styles[_currentStyleIndex] == 'classic')
                  IconButton(
                    icon: const Icon(Icons.color_lens, color: Colors.white54),
                    onPressed: _changeColor,
                  ),
              ],
            ),
          )
        ],
      ),
    );
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }
}