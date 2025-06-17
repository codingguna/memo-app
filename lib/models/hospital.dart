class Hospital {
  final int id;
  final String name;
  final String? geolocationPoint;
  final int? radius;
  final String? address;

  Hospital({
    required this.id,
    required this.name,
    this.geolocationPoint,
    this.radius,
    this.address,
  });

  factory Hospital.fromJson(Map<String, dynamic> json) {
    return Hospital(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      geolocationPoint: json['geolocation_point'],
      radius: json['radius'],
      address: json['address'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'geolocation_point': geolocationPoint,
      'radius': radius,
      'address': address,
    };
  }
}