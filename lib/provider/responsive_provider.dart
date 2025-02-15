import 'package:flutter/material.dart';

/// 반응형 UI를 위한 ResponsiveProvider
class ResponsiveProvider with ChangeNotifier, WidgetsBindingObserver {
  Size _screenSize = Size.zero;
  bool _isLandscape = false;
  bool _isPortrait = true;
  DeviceType _deviceType = DeviceType.mobile;

  Size get screenSize => _screenSize;
  double get screenWidth => _screenSize.width;
  double get screenHeight => _screenSize.height;
  bool get isLandscape => _isLandscape;
  bool get isPortrait => _isPortrait;
  DeviceType get deviceType => _deviceType;

  /// 생성자 - 앱이 실행되면서 자동으로 화면 크기 감지 시작
  ResponsiveProvider() {
    WidgetsBinding.instance.addObserver(this);
  }

  /// 화면 크기 변경 감지 (자동 업데이트)
  @override
  void didChangeMetrics() {
    _updateSize();
  }

  /// 화면 크기 및 디바이스 타입 업데이트 (자동 실행됨)
  void _updateSize() {
    final window = WidgetsBinding.instance.platformDispatcher.views.first;
    final newSize = window.physicalSize / window.devicePixelRatio;

    if (newSize != _screenSize) {
      _screenSize = newSize;
      _isLandscape = _screenSize.width > _screenSize.height;
      _isPortrait = !_isLandscape;
      _deviceType = _getDeviceType();
      notifyListeners();
    }
  }

  /// 디바이스 유형 감지 (모바일, 태블릿, 폴더블, 데스크톱)
  DeviceType _getDeviceType() {
    final double aspectRatio = _screenSize.width / _screenSize.height;
    if (_screenSize.width >= 1024) {
      return DeviceType.desktop;
    } else if (_screenSize.width >= 768) {
      return DeviceType.tablet;
    } else if (aspectRatio >= 1.2 && aspectRatio <= 1.8) {
      return DeviceType.foldable; // Z 플립 & 폴드 감지
    } else {
      return DeviceType.mobile;
    }
  }

  /// 위젯 바인딩 해제 (메모리 누수 방지)
  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }
}

/// 디바이스 유형 Enum (Z 플립 & 아이패드 포함)
enum DeviceType { mobile, tablet, foldable, desktop }
