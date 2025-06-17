class HospitalBlock {
  final int id;
  final String name;
  final int noOfFloors;
  final String hospitalId;

  HospitalBlock({
    required this.id,
    required this.name,
    required this.noOfFloors,
    required this.hospitalId,
  });

  factory HospitalBlock.fromJson(Map<String, dynamic> json) {
  try {
    return HospitalBlock(
      id: json['id'] as int,
      name: json['name'] as String,
      noOfFloors: json['no_of_floors'] as int,
      hospitalId: json['hospital_id'].toString(),
    );
  } catch (e) {
    throw FormatException('Failed to parse HospitalBlock: $e');
  }
}
}

class HospitalWard {
  final int id;
  final String name;
  final int block;
  final int floor;
  final String hospitalId;

  HospitalWard({
    required this.id,
    required this.name,
    required this.block,
    required this.floor,
    required this.hospitalId,
  });

  factory HospitalWard.fromJson(Map<String, dynamic> json) {
    return HospitalWard(
      id: json['id'],
      name: json['name'],
      block: json['block'],
      floor: json['floor'],
      hospitalId: json['hospital_id'].toString(),
    );
  }
}