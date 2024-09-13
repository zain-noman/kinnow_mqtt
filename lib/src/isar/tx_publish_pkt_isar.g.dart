// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'tx_publish_pkt_isar.dart';

// **************************************************************************
// IsarCollectionGenerator
// **************************************************************************

// coverage:ignore-file
// ignore_for_file: duplicate_ignore, non_constant_identifier_names, constant_identifier_names, invalid_use_of_protected_member, unnecessary_cast, prefer_const_constructors, lines_longer_than_80_chars, require_trailing_commas, inference_failure_on_function_invocation, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_checks, join_return_with_assignment, prefer_final_locals, avoid_js_rounded_ints, avoid_positional_boolean_parameters, always_specify_types

extension GetTxPublishPktIsarCollection on Isar {
  IsarCollection<TxPublishPktIsar> get txPublishPktIsars => this.collection();
}

const TxPublishPktIsarSchema = CollectionSchema(
  name: r'TxPublishPktIsar',
  id: 8467880516937327232,
  properties: {
    r'contentType': PropertySchema(
      id: 0,
      name: r'contentType',
      type: IsarType.string,
    ),
    r'correlationData': PropertySchema(
      id: 1,
      name: r'correlationData',
      type: IsarType.byteList,
    ),
    r'messageExpiryInterval': PropertySchema(
      id: 2,
      name: r'messageExpiryInterval',
      type: IsarType.long,
    ),
    r'payload': PropertySchema(
      id: 3,
      name: r'payload',
      type: IsarType.byteList,
    ),
    r'payloadFormat': PropertySchema(
      id: 4,
      name: r'payloadFormat',
      type: IsarType.int,
      enumMap: _TxPublishPktIsarpayloadFormatEnumValueMap,
    ),
    r'qos': PropertySchema(
      id: 5,
      name: r'qos',
      type: IsarType.byte,
      enumMap: _TxPublishPktIsarqosEnumValueMap,
    ),
    r'responseTopic': PropertySchema(
      id: 6,
      name: r'responseTopic',
      type: IsarType.string,
    ),
    r'retain': PropertySchema(
      id: 7,
      name: r'retain',
      type: IsarType.bool,
    ),
    r'topic': PropertySchema(
      id: 8,
      name: r'topic',
      type: IsarType.string,
    ),
    r'useAlias': PropertySchema(
      id: 9,
      name: r'useAlias',
      type: IsarType.bool,
    ),
    r'userPropertiesKeys': PropertySchema(
      id: 10,
      name: r'userPropertiesKeys',
      type: IsarType.stringList,
    ),
    r'userPropertiesValues': PropertySchema(
      id: 11,
      name: r'userPropertiesValues',
      type: IsarType.stringList,
    )
  },
  estimateSize: _txPublishPktIsarEstimateSize,
  serialize: _txPublishPktIsarSerialize,
  deserialize: _txPublishPktIsarDeserialize,
  deserializeProp: _txPublishPktIsarDeserializeProp,
  idName: r'id',
  indexes: {},
  links: {},
  embeddedSchemas: {},
  getId: _txPublishPktIsarGetId,
  getLinks: _txPublishPktIsarGetLinks,
  attach: _txPublishPktIsarAttach,
  version: '3.1.0+1',
);

int _txPublishPktIsarEstimateSize(
  TxPublishPktIsar object,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  var bytesCount = offsets.last;
  {
    final value = object.contentType;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  {
    final value = object.correlationData;
    if (value != null) {
      bytesCount += 3 + value.length;
    }
  }
  bytesCount += 3 + object.payload.length;
  {
    final value = object.responseTopic;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  bytesCount += 3 + object.topic.length * 3;
  bytesCount += 3 + object.userPropertiesKeys.length * 3;
  {
    for (var i = 0; i < object.userPropertiesKeys.length; i++) {
      final value = object.userPropertiesKeys[i];
      bytesCount += value.length * 3;
    }
  }
  bytesCount += 3 + object.userPropertiesValues.length * 3;
  {
    for (var i = 0; i < object.userPropertiesValues.length; i++) {
      final value = object.userPropertiesValues[i];
      bytesCount += value.length * 3;
    }
  }
  return bytesCount;
}

void _txPublishPktIsarSerialize(
  TxPublishPktIsar object,
  IsarWriter writer,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  writer.writeString(offsets[0], object.contentType);
  writer.writeByteList(offsets[1], object.correlationData);
  writer.writeLong(offsets[2], object.messageExpiryInterval);
  writer.writeByteList(offsets[3], object.payload);
  writer.writeInt(offsets[4], object.payloadFormat?.index);
  writer.writeByte(offsets[5], object.qos.index);
  writer.writeString(offsets[6], object.responseTopic);
  writer.writeBool(offsets[7], object.retain);
  writer.writeString(offsets[8], object.topic);
  writer.writeBool(offsets[9], object.useAlias);
  writer.writeStringList(offsets[10], object.userPropertiesKeys);
  writer.writeStringList(offsets[11], object.userPropertiesValues);
}

TxPublishPktIsar _txPublishPktIsarDeserialize(
  Id id,
  IsarReader reader,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  final object = TxPublishPktIsar(
    _TxPublishPktIsarqosValueEnumMap[reader.readByteOrNull(offsets[5])] ??
        MqttQos.atMostOnce,
    reader.readBool(offsets[7]),
    reader.readString(offsets[8]),
    reader.readByteList(offsets[3]) ?? [],
    _TxPublishPktIsarpayloadFormatValueEnumMap[
        reader.readIntOrNull(offsets[4])],
    reader.readLongOrNull(offsets[2]),
    reader.readBool(offsets[9]),
    reader.readStringOrNull(offsets[6]),
    reader.readByteList(offsets[1]),
    reader.readStringList(offsets[10]) ?? [],
    reader.readStringList(offsets[11]) ?? [],
    reader.readStringOrNull(offsets[0]),
  );
  object.id = id;
  return object;
}

P _txPublishPktIsarDeserializeProp<P>(
  IsarReader reader,
  int propertyId,
  int offset,
  Map<Type, List<int>> allOffsets,
) {
  switch (propertyId) {
    case 0:
      return (reader.readStringOrNull(offset)) as P;
    case 1:
      return (reader.readByteList(offset)) as P;
    case 2:
      return (reader.readLongOrNull(offset)) as P;
    case 3:
      return (reader.readByteList(offset) ?? []) as P;
    case 4:
      return (_TxPublishPktIsarpayloadFormatValueEnumMap[
          reader.readIntOrNull(offset)]) as P;
    case 5:
      return (_TxPublishPktIsarqosValueEnumMap[reader.readByteOrNull(offset)] ??
          MqttQos.atMostOnce) as P;
    case 6:
      return (reader.readStringOrNull(offset)) as P;
    case 7:
      return (reader.readBool(offset)) as P;
    case 8:
      return (reader.readString(offset)) as P;
    case 9:
      return (reader.readBool(offset)) as P;
    case 10:
      return (reader.readStringList(offset) ?? []) as P;
    case 11:
      return (reader.readStringList(offset) ?? []) as P;
    default:
      throw IsarError('Unknown property with id $propertyId');
  }
}

const _TxPublishPktIsarpayloadFormatEnumValueMap = {
  'bytes': 0,
  'utf8': 1,
};
const _TxPublishPktIsarpayloadFormatValueEnumMap = {
  0: MqttFormatIndicator.bytes,
  1: MqttFormatIndicator.utf8,
};
const _TxPublishPktIsarqosEnumValueMap = {
  'atMostOnce': 0,
  'atLeastOnce': 1,
  'exactlyOnce': 2,
};
const _TxPublishPktIsarqosValueEnumMap = {
  0: MqttQos.atMostOnce,
  1: MqttQos.atLeastOnce,
  2: MqttQos.exactlyOnce,
};

Id _txPublishPktIsarGetId(TxPublishPktIsar object) {
  return object.id;
}

List<IsarLinkBase<dynamic>> _txPublishPktIsarGetLinks(TxPublishPktIsar object) {
  return [];
}

void _txPublishPktIsarAttach(
    IsarCollection<dynamic> col, Id id, TxPublishPktIsar object) {
  object.id = id;
}

extension TxPublishPktIsarQueryWhereSort
    on QueryBuilder<TxPublishPktIsar, TxPublishPktIsar, QWhere> {
  QueryBuilder<TxPublishPktIsar, TxPublishPktIsar, QAfterWhere> anyId() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(const IdWhereClause.any());
    });
  }
}

extension TxPublishPktIsarQueryWhere
    on QueryBuilder<TxPublishPktIsar, TxPublishPktIsar, QWhereClause> {
  QueryBuilder<TxPublishPktIsar, TxPublishPktIsar, QAfterWhereClause> idEqualTo(
      Id id) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(
        lower: id,
        upper: id,
      ));
    });
  }

  QueryBuilder<TxPublishPktIsar, TxPublishPktIsar, QAfterWhereClause>
      idNotEqualTo(Id id) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(
              IdWhereClause.lessThan(upper: id, includeUpper: false),
            )
            .addWhereClause(
              IdWhereClause.greaterThan(lower: id, includeLower: false),
            );
      } else {
        return query
            .addWhereClause(
              IdWhereClause.greaterThan(lower: id, includeLower: false),
            )
            .addWhereClause(
              IdWhereClause.lessThan(upper: id, includeUpper: false),
            );
      }
    });
  }

  QueryBuilder<TxPublishPktIsar, TxPublishPktIsar, QAfterWhereClause>
      idGreaterThan(Id id, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.greaterThan(lower: id, includeLower: include),
      );
    });
  }

  QueryBuilder<TxPublishPktIsar, TxPublishPktIsar, QAfterWhereClause>
      idLessThan(Id id, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.lessThan(upper: id, includeUpper: include),
      );
    });
  }

  QueryBuilder<TxPublishPktIsar, TxPublishPktIsar, QAfterWhereClause> idBetween(
    Id lowerId,
    Id upperId, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(
        lower: lowerId,
        includeLower: includeLower,
        upper: upperId,
        includeUpper: includeUpper,
      ));
    });
  }
}

extension TxPublishPktIsarQueryFilter
    on QueryBuilder<TxPublishPktIsar, TxPublishPktIsar, QFilterCondition> {
  QueryBuilder<TxPublishPktIsar, TxPublishPktIsar, QAfterFilterCondition>
      contentTypeIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'contentType',
      ));
    });
  }

  QueryBuilder<TxPublishPktIsar, TxPublishPktIsar, QAfterFilterCondition>
      contentTypeIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'contentType',
      ));
    });
  }

  QueryBuilder<TxPublishPktIsar, TxPublishPktIsar, QAfterFilterCondition>
      contentTypeEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'contentType',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<TxPublishPktIsar, TxPublishPktIsar, QAfterFilterCondition>
      contentTypeGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'contentType',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<TxPublishPktIsar, TxPublishPktIsar, QAfterFilterCondition>
      contentTypeLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'contentType',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<TxPublishPktIsar, TxPublishPktIsar, QAfterFilterCondition>
      contentTypeBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'contentType',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<TxPublishPktIsar, TxPublishPktIsar, QAfterFilterCondition>
      contentTypeStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'contentType',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<TxPublishPktIsar, TxPublishPktIsar, QAfterFilterCondition>
      contentTypeEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'contentType',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<TxPublishPktIsar, TxPublishPktIsar, QAfterFilterCondition>
      contentTypeContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'contentType',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<TxPublishPktIsar, TxPublishPktIsar, QAfterFilterCondition>
      contentTypeMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'contentType',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<TxPublishPktIsar, TxPublishPktIsar, QAfterFilterCondition>
      contentTypeIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'contentType',
        value: '',
      ));
    });
  }

  QueryBuilder<TxPublishPktIsar, TxPublishPktIsar, QAfterFilterCondition>
      contentTypeIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'contentType',
        value: '',
      ));
    });
  }

  QueryBuilder<TxPublishPktIsar, TxPublishPktIsar, QAfterFilterCondition>
      correlationDataIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'correlationData',
      ));
    });
  }

  QueryBuilder<TxPublishPktIsar, TxPublishPktIsar, QAfterFilterCondition>
      correlationDataIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'correlationData',
      ));
    });
  }

  QueryBuilder<TxPublishPktIsar, TxPublishPktIsar, QAfterFilterCondition>
      correlationDataElementEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'correlationData',
        value: value,
      ));
    });
  }

  QueryBuilder<TxPublishPktIsar, TxPublishPktIsar, QAfterFilterCondition>
      correlationDataElementGreaterThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'correlationData',
        value: value,
      ));
    });
  }

  QueryBuilder<TxPublishPktIsar, TxPublishPktIsar, QAfterFilterCondition>
      correlationDataElementLessThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'correlationData',
        value: value,
      ));
    });
  }

  QueryBuilder<TxPublishPktIsar, TxPublishPktIsar, QAfterFilterCondition>
      correlationDataElementBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'correlationData',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<TxPublishPktIsar, TxPublishPktIsar, QAfterFilterCondition>
      correlationDataLengthEqualTo(int length) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'correlationData',
        length,
        true,
        length,
        true,
      );
    });
  }

  QueryBuilder<TxPublishPktIsar, TxPublishPktIsar, QAfterFilterCondition>
      correlationDataIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'correlationData',
        0,
        true,
        0,
        true,
      );
    });
  }

  QueryBuilder<TxPublishPktIsar, TxPublishPktIsar, QAfterFilterCondition>
      correlationDataIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'correlationData',
        0,
        false,
        999999,
        true,
      );
    });
  }

  QueryBuilder<TxPublishPktIsar, TxPublishPktIsar, QAfterFilterCondition>
      correlationDataLengthLessThan(
    int length, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'correlationData',
        0,
        true,
        length,
        include,
      );
    });
  }

  QueryBuilder<TxPublishPktIsar, TxPublishPktIsar, QAfterFilterCondition>
      correlationDataLengthGreaterThan(
    int length, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'correlationData',
        length,
        include,
        999999,
        true,
      );
    });
  }

  QueryBuilder<TxPublishPktIsar, TxPublishPktIsar, QAfterFilterCondition>
      correlationDataLengthBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'correlationData',
        lower,
        includeLower,
        upper,
        includeUpper,
      );
    });
  }

  QueryBuilder<TxPublishPktIsar, TxPublishPktIsar, QAfterFilterCondition>
      idEqualTo(Id value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'id',
        value: value,
      ));
    });
  }

  QueryBuilder<TxPublishPktIsar, TxPublishPktIsar, QAfterFilterCondition>
      idGreaterThan(
    Id value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'id',
        value: value,
      ));
    });
  }

  QueryBuilder<TxPublishPktIsar, TxPublishPktIsar, QAfterFilterCondition>
      idLessThan(
    Id value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'id',
        value: value,
      ));
    });
  }

  QueryBuilder<TxPublishPktIsar, TxPublishPktIsar, QAfterFilterCondition>
      idBetween(
    Id lower,
    Id upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'id',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<TxPublishPktIsar, TxPublishPktIsar, QAfterFilterCondition>
      messageExpiryIntervalIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'messageExpiryInterval',
      ));
    });
  }

  QueryBuilder<TxPublishPktIsar, TxPublishPktIsar, QAfterFilterCondition>
      messageExpiryIntervalIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'messageExpiryInterval',
      ));
    });
  }

  QueryBuilder<TxPublishPktIsar, TxPublishPktIsar, QAfterFilterCondition>
      messageExpiryIntervalEqualTo(int? value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'messageExpiryInterval',
        value: value,
      ));
    });
  }

  QueryBuilder<TxPublishPktIsar, TxPublishPktIsar, QAfterFilterCondition>
      messageExpiryIntervalGreaterThan(
    int? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'messageExpiryInterval',
        value: value,
      ));
    });
  }

  QueryBuilder<TxPublishPktIsar, TxPublishPktIsar, QAfterFilterCondition>
      messageExpiryIntervalLessThan(
    int? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'messageExpiryInterval',
        value: value,
      ));
    });
  }

  QueryBuilder<TxPublishPktIsar, TxPublishPktIsar, QAfterFilterCondition>
      messageExpiryIntervalBetween(
    int? lower,
    int? upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'messageExpiryInterval',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<TxPublishPktIsar, TxPublishPktIsar, QAfterFilterCondition>
      payloadElementEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'payload',
        value: value,
      ));
    });
  }

  QueryBuilder<TxPublishPktIsar, TxPublishPktIsar, QAfterFilterCondition>
      payloadElementGreaterThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'payload',
        value: value,
      ));
    });
  }

  QueryBuilder<TxPublishPktIsar, TxPublishPktIsar, QAfterFilterCondition>
      payloadElementLessThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'payload',
        value: value,
      ));
    });
  }

  QueryBuilder<TxPublishPktIsar, TxPublishPktIsar, QAfterFilterCondition>
      payloadElementBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'payload',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<TxPublishPktIsar, TxPublishPktIsar, QAfterFilterCondition>
      payloadLengthEqualTo(int length) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'payload',
        length,
        true,
        length,
        true,
      );
    });
  }

  QueryBuilder<TxPublishPktIsar, TxPublishPktIsar, QAfterFilterCondition>
      payloadIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'payload',
        0,
        true,
        0,
        true,
      );
    });
  }

  QueryBuilder<TxPublishPktIsar, TxPublishPktIsar, QAfterFilterCondition>
      payloadIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'payload',
        0,
        false,
        999999,
        true,
      );
    });
  }

  QueryBuilder<TxPublishPktIsar, TxPublishPktIsar, QAfterFilterCondition>
      payloadLengthLessThan(
    int length, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'payload',
        0,
        true,
        length,
        include,
      );
    });
  }

  QueryBuilder<TxPublishPktIsar, TxPublishPktIsar, QAfterFilterCondition>
      payloadLengthGreaterThan(
    int length, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'payload',
        length,
        include,
        999999,
        true,
      );
    });
  }

  QueryBuilder<TxPublishPktIsar, TxPublishPktIsar, QAfterFilterCondition>
      payloadLengthBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'payload',
        lower,
        includeLower,
        upper,
        includeUpper,
      );
    });
  }

  QueryBuilder<TxPublishPktIsar, TxPublishPktIsar, QAfterFilterCondition>
      payloadFormatIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'payloadFormat',
      ));
    });
  }

  QueryBuilder<TxPublishPktIsar, TxPublishPktIsar, QAfterFilterCondition>
      payloadFormatIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'payloadFormat',
      ));
    });
  }

  QueryBuilder<TxPublishPktIsar, TxPublishPktIsar, QAfterFilterCondition>
      payloadFormatEqualTo(MqttFormatIndicator? value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'payloadFormat',
        value: value,
      ));
    });
  }

  QueryBuilder<TxPublishPktIsar, TxPublishPktIsar, QAfterFilterCondition>
      payloadFormatGreaterThan(
    MqttFormatIndicator? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'payloadFormat',
        value: value,
      ));
    });
  }

  QueryBuilder<TxPublishPktIsar, TxPublishPktIsar, QAfterFilterCondition>
      payloadFormatLessThan(
    MqttFormatIndicator? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'payloadFormat',
        value: value,
      ));
    });
  }

  QueryBuilder<TxPublishPktIsar, TxPublishPktIsar, QAfterFilterCondition>
      payloadFormatBetween(
    MqttFormatIndicator? lower,
    MqttFormatIndicator? upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'payloadFormat',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<TxPublishPktIsar, TxPublishPktIsar, QAfterFilterCondition>
      qosEqualTo(MqttQos value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'qos',
        value: value,
      ));
    });
  }

  QueryBuilder<TxPublishPktIsar, TxPublishPktIsar, QAfterFilterCondition>
      qosGreaterThan(
    MqttQos value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'qos',
        value: value,
      ));
    });
  }

  QueryBuilder<TxPublishPktIsar, TxPublishPktIsar, QAfterFilterCondition>
      qosLessThan(
    MqttQos value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'qos',
        value: value,
      ));
    });
  }

  QueryBuilder<TxPublishPktIsar, TxPublishPktIsar, QAfterFilterCondition>
      qosBetween(
    MqttQos lower,
    MqttQos upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'qos',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<TxPublishPktIsar, TxPublishPktIsar, QAfterFilterCondition>
      responseTopicIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'responseTopic',
      ));
    });
  }

  QueryBuilder<TxPublishPktIsar, TxPublishPktIsar, QAfterFilterCondition>
      responseTopicIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'responseTopic',
      ));
    });
  }

  QueryBuilder<TxPublishPktIsar, TxPublishPktIsar, QAfterFilterCondition>
      responseTopicEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'responseTopic',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<TxPublishPktIsar, TxPublishPktIsar, QAfterFilterCondition>
      responseTopicGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'responseTopic',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<TxPublishPktIsar, TxPublishPktIsar, QAfterFilterCondition>
      responseTopicLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'responseTopic',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<TxPublishPktIsar, TxPublishPktIsar, QAfterFilterCondition>
      responseTopicBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'responseTopic',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<TxPublishPktIsar, TxPublishPktIsar, QAfterFilterCondition>
      responseTopicStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'responseTopic',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<TxPublishPktIsar, TxPublishPktIsar, QAfterFilterCondition>
      responseTopicEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'responseTopic',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<TxPublishPktIsar, TxPublishPktIsar, QAfterFilterCondition>
      responseTopicContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'responseTopic',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<TxPublishPktIsar, TxPublishPktIsar, QAfterFilterCondition>
      responseTopicMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'responseTopic',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<TxPublishPktIsar, TxPublishPktIsar, QAfterFilterCondition>
      responseTopicIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'responseTopic',
        value: '',
      ));
    });
  }

  QueryBuilder<TxPublishPktIsar, TxPublishPktIsar, QAfterFilterCondition>
      responseTopicIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'responseTopic',
        value: '',
      ));
    });
  }

  QueryBuilder<TxPublishPktIsar, TxPublishPktIsar, QAfterFilterCondition>
      retainEqualTo(bool value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'retain',
        value: value,
      ));
    });
  }

  QueryBuilder<TxPublishPktIsar, TxPublishPktIsar, QAfterFilterCondition>
      topicEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'topic',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<TxPublishPktIsar, TxPublishPktIsar, QAfterFilterCondition>
      topicGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'topic',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<TxPublishPktIsar, TxPublishPktIsar, QAfterFilterCondition>
      topicLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'topic',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<TxPublishPktIsar, TxPublishPktIsar, QAfterFilterCondition>
      topicBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'topic',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<TxPublishPktIsar, TxPublishPktIsar, QAfterFilterCondition>
      topicStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'topic',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<TxPublishPktIsar, TxPublishPktIsar, QAfterFilterCondition>
      topicEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'topic',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<TxPublishPktIsar, TxPublishPktIsar, QAfterFilterCondition>
      topicContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'topic',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<TxPublishPktIsar, TxPublishPktIsar, QAfterFilterCondition>
      topicMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'topic',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<TxPublishPktIsar, TxPublishPktIsar, QAfterFilterCondition>
      topicIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'topic',
        value: '',
      ));
    });
  }

  QueryBuilder<TxPublishPktIsar, TxPublishPktIsar, QAfterFilterCondition>
      topicIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'topic',
        value: '',
      ));
    });
  }

  QueryBuilder<TxPublishPktIsar, TxPublishPktIsar, QAfterFilterCondition>
      useAliasEqualTo(bool value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'useAlias',
        value: value,
      ));
    });
  }

  QueryBuilder<TxPublishPktIsar, TxPublishPktIsar, QAfterFilterCondition>
      userPropertiesKeysElementEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'userPropertiesKeys',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<TxPublishPktIsar, TxPublishPktIsar, QAfterFilterCondition>
      userPropertiesKeysElementGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'userPropertiesKeys',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<TxPublishPktIsar, TxPublishPktIsar, QAfterFilterCondition>
      userPropertiesKeysElementLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'userPropertiesKeys',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<TxPublishPktIsar, TxPublishPktIsar, QAfterFilterCondition>
      userPropertiesKeysElementBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'userPropertiesKeys',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<TxPublishPktIsar, TxPublishPktIsar, QAfterFilterCondition>
      userPropertiesKeysElementStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'userPropertiesKeys',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<TxPublishPktIsar, TxPublishPktIsar, QAfterFilterCondition>
      userPropertiesKeysElementEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'userPropertiesKeys',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<TxPublishPktIsar, TxPublishPktIsar, QAfterFilterCondition>
      userPropertiesKeysElementContains(String value,
          {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'userPropertiesKeys',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<TxPublishPktIsar, TxPublishPktIsar, QAfterFilterCondition>
      userPropertiesKeysElementMatches(String pattern,
          {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'userPropertiesKeys',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<TxPublishPktIsar, TxPublishPktIsar, QAfterFilterCondition>
      userPropertiesKeysElementIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'userPropertiesKeys',
        value: '',
      ));
    });
  }

  QueryBuilder<TxPublishPktIsar, TxPublishPktIsar, QAfterFilterCondition>
      userPropertiesKeysElementIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'userPropertiesKeys',
        value: '',
      ));
    });
  }

  QueryBuilder<TxPublishPktIsar, TxPublishPktIsar, QAfterFilterCondition>
      userPropertiesKeysLengthEqualTo(int length) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'userPropertiesKeys',
        length,
        true,
        length,
        true,
      );
    });
  }

  QueryBuilder<TxPublishPktIsar, TxPublishPktIsar, QAfterFilterCondition>
      userPropertiesKeysIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'userPropertiesKeys',
        0,
        true,
        0,
        true,
      );
    });
  }

  QueryBuilder<TxPublishPktIsar, TxPublishPktIsar, QAfterFilterCondition>
      userPropertiesKeysIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'userPropertiesKeys',
        0,
        false,
        999999,
        true,
      );
    });
  }

  QueryBuilder<TxPublishPktIsar, TxPublishPktIsar, QAfterFilterCondition>
      userPropertiesKeysLengthLessThan(
    int length, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'userPropertiesKeys',
        0,
        true,
        length,
        include,
      );
    });
  }

  QueryBuilder<TxPublishPktIsar, TxPublishPktIsar, QAfterFilterCondition>
      userPropertiesKeysLengthGreaterThan(
    int length, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'userPropertiesKeys',
        length,
        include,
        999999,
        true,
      );
    });
  }

  QueryBuilder<TxPublishPktIsar, TxPublishPktIsar, QAfterFilterCondition>
      userPropertiesKeysLengthBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'userPropertiesKeys',
        lower,
        includeLower,
        upper,
        includeUpper,
      );
    });
  }

  QueryBuilder<TxPublishPktIsar, TxPublishPktIsar, QAfterFilterCondition>
      userPropertiesValuesElementEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'userPropertiesValues',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<TxPublishPktIsar, TxPublishPktIsar, QAfterFilterCondition>
      userPropertiesValuesElementGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'userPropertiesValues',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<TxPublishPktIsar, TxPublishPktIsar, QAfterFilterCondition>
      userPropertiesValuesElementLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'userPropertiesValues',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<TxPublishPktIsar, TxPublishPktIsar, QAfterFilterCondition>
      userPropertiesValuesElementBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'userPropertiesValues',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<TxPublishPktIsar, TxPublishPktIsar, QAfterFilterCondition>
      userPropertiesValuesElementStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'userPropertiesValues',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<TxPublishPktIsar, TxPublishPktIsar, QAfterFilterCondition>
      userPropertiesValuesElementEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'userPropertiesValues',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<TxPublishPktIsar, TxPublishPktIsar, QAfterFilterCondition>
      userPropertiesValuesElementContains(String value,
          {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'userPropertiesValues',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<TxPublishPktIsar, TxPublishPktIsar, QAfterFilterCondition>
      userPropertiesValuesElementMatches(String pattern,
          {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'userPropertiesValues',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<TxPublishPktIsar, TxPublishPktIsar, QAfterFilterCondition>
      userPropertiesValuesElementIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'userPropertiesValues',
        value: '',
      ));
    });
  }

  QueryBuilder<TxPublishPktIsar, TxPublishPktIsar, QAfterFilterCondition>
      userPropertiesValuesElementIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'userPropertiesValues',
        value: '',
      ));
    });
  }

  QueryBuilder<TxPublishPktIsar, TxPublishPktIsar, QAfterFilterCondition>
      userPropertiesValuesLengthEqualTo(int length) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'userPropertiesValues',
        length,
        true,
        length,
        true,
      );
    });
  }

  QueryBuilder<TxPublishPktIsar, TxPublishPktIsar, QAfterFilterCondition>
      userPropertiesValuesIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'userPropertiesValues',
        0,
        true,
        0,
        true,
      );
    });
  }

  QueryBuilder<TxPublishPktIsar, TxPublishPktIsar, QAfterFilterCondition>
      userPropertiesValuesIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'userPropertiesValues',
        0,
        false,
        999999,
        true,
      );
    });
  }

  QueryBuilder<TxPublishPktIsar, TxPublishPktIsar, QAfterFilterCondition>
      userPropertiesValuesLengthLessThan(
    int length, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'userPropertiesValues',
        0,
        true,
        length,
        include,
      );
    });
  }

  QueryBuilder<TxPublishPktIsar, TxPublishPktIsar, QAfterFilterCondition>
      userPropertiesValuesLengthGreaterThan(
    int length, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'userPropertiesValues',
        length,
        include,
        999999,
        true,
      );
    });
  }

  QueryBuilder<TxPublishPktIsar, TxPublishPktIsar, QAfterFilterCondition>
      userPropertiesValuesLengthBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'userPropertiesValues',
        lower,
        includeLower,
        upper,
        includeUpper,
      );
    });
  }
}

extension TxPublishPktIsarQueryObject
    on QueryBuilder<TxPublishPktIsar, TxPublishPktIsar, QFilterCondition> {}

extension TxPublishPktIsarQueryLinks
    on QueryBuilder<TxPublishPktIsar, TxPublishPktIsar, QFilterCondition> {}

extension TxPublishPktIsarQuerySortBy
    on QueryBuilder<TxPublishPktIsar, TxPublishPktIsar, QSortBy> {
  QueryBuilder<TxPublishPktIsar, TxPublishPktIsar, QAfterSortBy>
      sortByContentType() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'contentType', Sort.asc);
    });
  }

  QueryBuilder<TxPublishPktIsar, TxPublishPktIsar, QAfterSortBy>
      sortByContentTypeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'contentType', Sort.desc);
    });
  }

  QueryBuilder<TxPublishPktIsar, TxPublishPktIsar, QAfterSortBy>
      sortByMessageExpiryInterval() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'messageExpiryInterval', Sort.asc);
    });
  }

  QueryBuilder<TxPublishPktIsar, TxPublishPktIsar, QAfterSortBy>
      sortByMessageExpiryIntervalDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'messageExpiryInterval', Sort.desc);
    });
  }

  QueryBuilder<TxPublishPktIsar, TxPublishPktIsar, QAfterSortBy>
      sortByPayloadFormat() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'payloadFormat', Sort.asc);
    });
  }

  QueryBuilder<TxPublishPktIsar, TxPublishPktIsar, QAfterSortBy>
      sortByPayloadFormatDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'payloadFormat', Sort.desc);
    });
  }

  QueryBuilder<TxPublishPktIsar, TxPublishPktIsar, QAfterSortBy> sortByQos() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'qos', Sort.asc);
    });
  }

  QueryBuilder<TxPublishPktIsar, TxPublishPktIsar, QAfterSortBy>
      sortByQosDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'qos', Sort.desc);
    });
  }

  QueryBuilder<TxPublishPktIsar, TxPublishPktIsar, QAfterSortBy>
      sortByResponseTopic() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'responseTopic', Sort.asc);
    });
  }

  QueryBuilder<TxPublishPktIsar, TxPublishPktIsar, QAfterSortBy>
      sortByResponseTopicDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'responseTopic', Sort.desc);
    });
  }

  QueryBuilder<TxPublishPktIsar, TxPublishPktIsar, QAfterSortBy>
      sortByRetain() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'retain', Sort.asc);
    });
  }

  QueryBuilder<TxPublishPktIsar, TxPublishPktIsar, QAfterSortBy>
      sortByRetainDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'retain', Sort.desc);
    });
  }

  QueryBuilder<TxPublishPktIsar, TxPublishPktIsar, QAfterSortBy> sortByTopic() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'topic', Sort.asc);
    });
  }

  QueryBuilder<TxPublishPktIsar, TxPublishPktIsar, QAfterSortBy>
      sortByTopicDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'topic', Sort.desc);
    });
  }

  QueryBuilder<TxPublishPktIsar, TxPublishPktIsar, QAfterSortBy>
      sortByUseAlias() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'useAlias', Sort.asc);
    });
  }

  QueryBuilder<TxPublishPktIsar, TxPublishPktIsar, QAfterSortBy>
      sortByUseAliasDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'useAlias', Sort.desc);
    });
  }
}

extension TxPublishPktIsarQuerySortThenBy
    on QueryBuilder<TxPublishPktIsar, TxPublishPktIsar, QSortThenBy> {
  QueryBuilder<TxPublishPktIsar, TxPublishPktIsar, QAfterSortBy>
      thenByContentType() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'contentType', Sort.asc);
    });
  }

  QueryBuilder<TxPublishPktIsar, TxPublishPktIsar, QAfterSortBy>
      thenByContentTypeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'contentType', Sort.desc);
    });
  }

  QueryBuilder<TxPublishPktIsar, TxPublishPktIsar, QAfterSortBy> thenById() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.asc);
    });
  }

  QueryBuilder<TxPublishPktIsar, TxPublishPktIsar, QAfterSortBy>
      thenByIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.desc);
    });
  }

  QueryBuilder<TxPublishPktIsar, TxPublishPktIsar, QAfterSortBy>
      thenByMessageExpiryInterval() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'messageExpiryInterval', Sort.asc);
    });
  }

  QueryBuilder<TxPublishPktIsar, TxPublishPktIsar, QAfterSortBy>
      thenByMessageExpiryIntervalDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'messageExpiryInterval', Sort.desc);
    });
  }

  QueryBuilder<TxPublishPktIsar, TxPublishPktIsar, QAfterSortBy>
      thenByPayloadFormat() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'payloadFormat', Sort.asc);
    });
  }

  QueryBuilder<TxPublishPktIsar, TxPublishPktIsar, QAfterSortBy>
      thenByPayloadFormatDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'payloadFormat', Sort.desc);
    });
  }

  QueryBuilder<TxPublishPktIsar, TxPublishPktIsar, QAfterSortBy> thenByQos() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'qos', Sort.asc);
    });
  }

  QueryBuilder<TxPublishPktIsar, TxPublishPktIsar, QAfterSortBy>
      thenByQosDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'qos', Sort.desc);
    });
  }

  QueryBuilder<TxPublishPktIsar, TxPublishPktIsar, QAfterSortBy>
      thenByResponseTopic() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'responseTopic', Sort.asc);
    });
  }

  QueryBuilder<TxPublishPktIsar, TxPublishPktIsar, QAfterSortBy>
      thenByResponseTopicDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'responseTopic', Sort.desc);
    });
  }

  QueryBuilder<TxPublishPktIsar, TxPublishPktIsar, QAfterSortBy>
      thenByRetain() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'retain', Sort.asc);
    });
  }

  QueryBuilder<TxPublishPktIsar, TxPublishPktIsar, QAfterSortBy>
      thenByRetainDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'retain', Sort.desc);
    });
  }

  QueryBuilder<TxPublishPktIsar, TxPublishPktIsar, QAfterSortBy> thenByTopic() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'topic', Sort.asc);
    });
  }

  QueryBuilder<TxPublishPktIsar, TxPublishPktIsar, QAfterSortBy>
      thenByTopicDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'topic', Sort.desc);
    });
  }

  QueryBuilder<TxPublishPktIsar, TxPublishPktIsar, QAfterSortBy>
      thenByUseAlias() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'useAlias', Sort.asc);
    });
  }

  QueryBuilder<TxPublishPktIsar, TxPublishPktIsar, QAfterSortBy>
      thenByUseAliasDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'useAlias', Sort.desc);
    });
  }
}

extension TxPublishPktIsarQueryWhereDistinct
    on QueryBuilder<TxPublishPktIsar, TxPublishPktIsar, QDistinct> {
  QueryBuilder<TxPublishPktIsar, TxPublishPktIsar, QDistinct>
      distinctByContentType({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'contentType', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<TxPublishPktIsar, TxPublishPktIsar, QDistinct>
      distinctByCorrelationData() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'correlationData');
    });
  }

  QueryBuilder<TxPublishPktIsar, TxPublishPktIsar, QDistinct>
      distinctByMessageExpiryInterval() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'messageExpiryInterval');
    });
  }

  QueryBuilder<TxPublishPktIsar, TxPublishPktIsar, QDistinct>
      distinctByPayload() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'payload');
    });
  }

  QueryBuilder<TxPublishPktIsar, TxPublishPktIsar, QDistinct>
      distinctByPayloadFormat() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'payloadFormat');
    });
  }

  QueryBuilder<TxPublishPktIsar, TxPublishPktIsar, QDistinct> distinctByQos() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'qos');
    });
  }

  QueryBuilder<TxPublishPktIsar, TxPublishPktIsar, QDistinct>
      distinctByResponseTopic({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'responseTopic',
          caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<TxPublishPktIsar, TxPublishPktIsar, QDistinct>
      distinctByRetain() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'retain');
    });
  }

  QueryBuilder<TxPublishPktIsar, TxPublishPktIsar, QDistinct> distinctByTopic(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'topic', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<TxPublishPktIsar, TxPublishPktIsar, QDistinct>
      distinctByUseAlias() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'useAlias');
    });
  }

  QueryBuilder<TxPublishPktIsar, TxPublishPktIsar, QDistinct>
      distinctByUserPropertiesKeys() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'userPropertiesKeys');
    });
  }

  QueryBuilder<TxPublishPktIsar, TxPublishPktIsar, QDistinct>
      distinctByUserPropertiesValues() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'userPropertiesValues');
    });
  }
}

extension TxPublishPktIsarQueryProperty
    on QueryBuilder<TxPublishPktIsar, TxPublishPktIsar, QQueryProperty> {
  QueryBuilder<TxPublishPktIsar, int, QQueryOperations> idProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'id');
    });
  }

  QueryBuilder<TxPublishPktIsar, String?, QQueryOperations>
      contentTypeProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'contentType');
    });
  }

  QueryBuilder<TxPublishPktIsar, List<int>?, QQueryOperations>
      correlationDataProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'correlationData');
    });
  }

  QueryBuilder<TxPublishPktIsar, int?, QQueryOperations>
      messageExpiryIntervalProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'messageExpiryInterval');
    });
  }

  QueryBuilder<TxPublishPktIsar, List<int>, QQueryOperations>
      payloadProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'payload');
    });
  }

  QueryBuilder<TxPublishPktIsar, MqttFormatIndicator?, QQueryOperations>
      payloadFormatProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'payloadFormat');
    });
  }

  QueryBuilder<TxPublishPktIsar, MqttQos, QQueryOperations> qosProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'qos');
    });
  }

  QueryBuilder<TxPublishPktIsar, String?, QQueryOperations>
      responseTopicProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'responseTopic');
    });
  }

  QueryBuilder<TxPublishPktIsar, bool, QQueryOperations> retainProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'retain');
    });
  }

  QueryBuilder<TxPublishPktIsar, String, QQueryOperations> topicProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'topic');
    });
  }

  QueryBuilder<TxPublishPktIsar, bool, QQueryOperations> useAliasProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'useAlias');
    });
  }

  QueryBuilder<TxPublishPktIsar, List<String>, QQueryOperations>
      userPropertiesKeysProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'userPropertiesKeys');
    });
  }

  QueryBuilder<TxPublishPktIsar, List<String>, QQueryOperations>
      userPropertiesValuesProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'userPropertiesValues');
    });
  }
}
