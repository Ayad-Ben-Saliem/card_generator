import 'package:card_generator/utils.dart';
import 'package:equatable/equatable.dart';
import 'package:isar/isar.dart';

part 'card.g.dart';

@Collection(accessor: 'Cards', ignore: {'props', 'hashCode', 'stringify'})
class Card extends Equatable {
  @Index(unique: true)
  final Id? id;

  final String? title;

  final double value;

  // @Index(unique: true)
  final String code;

  // @Index(unique: true)
  final String serial;

  final DateTime? createdAt;

  final DateTime? usedAt;

  const Card({
    this.id,
    this.title,
    required this.value,
    required this.code,
    required this.serial,
    this.createdAt,
    this.usedAt,
  });

  Card.fromJson(JsonMap json)
      : id = json['id'],
        title = json['title'],
        value = json['value'].toDouble(),
        code = json['code'],
        serial = json['serial'],
        createdAt = DateTime.tryParse(json['createdAt'] ?? ''),
        usedAt = DateTime.tryParse(json['usedAt'] ?? '');

  Card copyWith({
    Id? id,
    String? title,
    double? value,
    String? code,
    String? serial,
    DateTime? createdAt,
    DateTime? usedAt,
  }) {
    return Card(
      id: id ?? this.id,
      title: title ?? this.title,
      value: value ?? this.value,
      code: code ?? this.code,
      serial: serial ?? this.serial,
      createdAt: createdAt ?? this.createdAt,
      usedAt: usedAt ?? this.usedAt,
    );
  }

  @ignore
  JsonMap get toJson => {
        'id': id,
        'title': title,
        'value': value,
        'code': code,
        'serial': serial,
        'at': createdAt?.toIso8601String(),
        'usedAt': usedAt?.toIso8601String(),
      };

  @override
  List<Object?> get props => [
        id,
        title,
        value,
        code,
        serial,
        createdAt,
        usedAt,
      ];
}
