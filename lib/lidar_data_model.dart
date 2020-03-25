class LidarData {
  String radius, elevationAngle, horizontalAngle;
  LidarData({
    this.radius,
    this.elevationAngle,
    this.horizontalAngle,
  });
  static init() {
    return LidarData(radius: '0', elevationAngle: '0', horizontalAngle: '0');
  }

  factory LidarData.fromJson(Map<String, dynamic> json) {
    return LidarData(
      radius: json['radius'],
      elevationAngle: json['elevation_angle'],
      horizontalAngle: json['horizontal_angle'],
    );
  }
}
