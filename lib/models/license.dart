import 'package:card_generator/utils.dart';
import 'package:equatable/equatable.dart';

class License extends Equatable {
  final String name;
  final int? maxCardsNumber;
  final DateTime? expirationDate;

  const License({
    required this.name,
    this.maxCardsNumber,
    this.expirationDate,
  });

  License.fromJson(JsonMap json)
      : name = json['name'],
        maxCardsNumber = json['maxCardsNumber'],
        expirationDate = DateTime.tryParse(json['expirationDate'] ?? '');

  License copyWith({
    String? name,
    int? maxCardsNumber,
    DateTime? expirationDate,
  }) =>
      License(
        name: name ?? this.name,
        maxCardsNumber: maxCardsNumber ?? this.maxCardsNumber,
        expirationDate: expirationDate ?? this.expirationDate,
      );

  @override
  String toString() => Utils.getPrettyString(toJson);

  JsonMap get toJson => {
        'name': name,
        'maxCardsNumber': maxCardsNumber,
        'expirationDate': expirationDate?.toIso8601String(),
      };

  @override
  List<Object?> get props => [
        name,
        maxCardsNumber,
        expirationDate,
      ];
}
