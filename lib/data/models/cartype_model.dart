class CarTypeModel {
  final int carTypeId;
  final String carTypeName;

  CarTypeModel({
    required this.carTypeId,
    required this.carTypeName,
  });

  factory CarTypeModel.fromJson(Map<String, dynamic> json) {
    return CarTypeModel(
      carTypeId: json['cartypeid'],
      carTypeName: json['cartypename'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'cartypeid': carTypeId,
      'cartypename': carTypeName,
    };
  }
}
