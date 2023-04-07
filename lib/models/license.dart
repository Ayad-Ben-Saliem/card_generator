import 'package:card_generator/utils.dart';
import 'package:equatable/equatable.dart';

class License extends Equatable {
  final String name;
  final int? maxCardNumber;
  final DateTime? validUntil;

  const License({
    required this.name,
    this.maxCardNumber,
    this.validUntil,
  });

  License.fromJson(JsonMap json)
      : name = json['name'],
        maxCardNumber = json['maxCardNumber'],
        validUntil = DateTime.tryParse(json['validUntil'] ?? '');

  License copyWith({
    String? name,
    int? maxCardNumber,
    DateTime? validUntil,
  }) =>
      License(
        name: name ?? this.name,
        maxCardNumber: maxCardNumber ?? this.maxCardNumber,
        validUntil: validUntil ?? this.validUntil,
      );

  @override
  String toString() => Utils.getPrettyString(toJson);

  JsonMap get toJson => {
        'name': name,
        'maxCardNumber': maxCardNumber,
        'validUntil': validUntil,
      };

  @override
  List<Object?> get props => [
        name,
        maxCardNumber,
        validUntil,
      ];
}
