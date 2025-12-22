// This is a generated file - do not edit.
//
// Generated from tx_publish_pkt_storage.proto.

// @dart = 3.3

// ignore_for_file: annotate_overrides, camel_case_types, comment_references
// ignore_for_file: constant_identifier_names
// ignore_for_file: curly_braces_in_flow_control_structures
// ignore_for_file: deprecated_member_use_from_same_package, library_prefixes
// ignore_for_file: non_constant_identifier_names, prefer_relative_imports

import 'dart:core' as $core;

import 'package:protobuf/protobuf.dart' as $pb;

export 'package:protobuf/protobuf.dart' show GeneratedMessageGenericExtensions;

class tx_publish_pkt_storage extends $pb.GeneratedMessage {
  factory tx_publish_pkt_storage({
    $core.bool? retain,
    $core.String? topic,
    $core.List<$core.int>? payload,
    $core.bool? payloadFormat,
    $core.int? messageExpiryInterval,
    $core.bool? useAlias,
    $core.String? responseTopic,
    $core.List<$core.int>? correlationData,
    $core.Iterable<$core.MapEntry<$core.String, $core.String>>? userProperties,
    $core.String? contentType,
    $core.int? qos,
    $core.int? storageId,
  }) {
    final result = create();
    if (retain != null) result.retain = retain;
    if (topic != null) result.topic = topic;
    if (payload != null) result.payload = payload;
    if (payloadFormat != null) result.payloadFormat = payloadFormat;
    if (messageExpiryInterval != null)
      result.messageExpiryInterval = messageExpiryInterval;
    if (useAlias != null) result.useAlias = useAlias;
    if (responseTopic != null) result.responseTopic = responseTopic;
    if (correlationData != null) result.correlationData = correlationData;
    if (userProperties != null)
      result.userProperties.addEntries(userProperties);
    if (contentType != null) result.contentType = contentType;
    if (qos != null) result.qos = qos;
    if (storageId != null) result.storageId = storageId;
    return result;
  }

  tx_publish_pkt_storage._();

  factory tx_publish_pkt_storage.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory tx_publish_pkt_storage.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'tx_publish_pkt_storage',
      createEmptyInstance: create)
    ..aOB(1, _omitFieldNames ? '' : 'retain')
    ..aOS(2, _omitFieldNames ? '' : 'topic')
    ..a<$core.List<$core.int>>(
        3, _omitFieldNames ? '' : 'payload', $pb.PbFieldType.OY)
    ..aOB(4, _omitFieldNames ? '' : 'payloadFormat', protoName: 'payloadFormat')
    ..aI(5, _omitFieldNames ? '' : 'messageExpiryInterval',
        protoName: 'messageExpiryInterval')
    ..aOB(6, _omitFieldNames ? '' : 'useAlias', protoName: 'useAlias')
    ..aOS(7, _omitFieldNames ? '' : 'responseTopic', protoName: 'responseTopic')
    ..a<$core.List<$core.int>>(
        8, _omitFieldNames ? '' : 'correlationData', $pb.PbFieldType.OY,
        protoName: 'correlationData')
    ..m<$core.String, $core.String>(9, _omitFieldNames ? '' : 'userProperties',
        protoName: 'userProperties',
        entryClassName: 'tx_publish_pkt_storage.UserPropertiesEntry',
        keyFieldType: $pb.PbFieldType.OS,
        valueFieldType: $pb.PbFieldType.OS)
    ..aOS(10, _omitFieldNames ? '' : 'contentType', protoName: 'contentType')
    ..aI(11, _omitFieldNames ? '' : 'qos')
    ..aI(12, _omitFieldNames ? '' : 'storageId', protoName: 'storageId')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  tx_publish_pkt_storage clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  tx_publish_pkt_storage copyWith(
          void Function(tx_publish_pkt_storage) updates) =>
      super.copyWith((message) => updates(message as tx_publish_pkt_storage))
          as tx_publish_pkt_storage;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static tx_publish_pkt_storage create() => tx_publish_pkt_storage._();
  @$core.override
  tx_publish_pkt_storage createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static tx_publish_pkt_storage getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<tx_publish_pkt_storage>(create);
  static tx_publish_pkt_storage? _defaultInstance;

  @$pb.TagNumber(1)
  $core.bool get retain => $_getBF(0);
  @$pb.TagNumber(1)
  set retain($core.bool value) => $_setBool(0, value);
  @$pb.TagNumber(1)
  $core.bool hasRetain() => $_has(0);
  @$pb.TagNumber(1)
  void clearRetain() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.String get topic => $_getSZ(1);
  @$pb.TagNumber(2)
  set topic($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasTopic() => $_has(1);
  @$pb.TagNumber(2)
  void clearTopic() => $_clearField(2);

  @$pb.TagNumber(3)
  $core.List<$core.int> get payload => $_getN(2);
  @$pb.TagNumber(3)
  set payload($core.List<$core.int> value) => $_setBytes(2, value);
  @$pb.TagNumber(3)
  $core.bool hasPayload() => $_has(2);
  @$pb.TagNumber(3)
  void clearPayload() => $_clearField(3);

  @$pb.TagNumber(4)
  $core.bool get payloadFormat => $_getBF(3);
  @$pb.TagNumber(4)
  set payloadFormat($core.bool value) => $_setBool(3, value);
  @$pb.TagNumber(4)
  $core.bool hasPayloadFormat() => $_has(3);
  @$pb.TagNumber(4)
  void clearPayloadFormat() => $_clearField(4);

  @$pb.TagNumber(5)
  $core.int get messageExpiryInterval => $_getIZ(4);
  @$pb.TagNumber(5)
  set messageExpiryInterval($core.int value) => $_setSignedInt32(4, value);
  @$pb.TagNumber(5)
  $core.bool hasMessageExpiryInterval() => $_has(4);
  @$pb.TagNumber(5)
  void clearMessageExpiryInterval() => $_clearField(5);

  @$pb.TagNumber(6)
  $core.bool get useAlias => $_getBF(5);
  @$pb.TagNumber(6)
  set useAlias($core.bool value) => $_setBool(5, value);
  @$pb.TagNumber(6)
  $core.bool hasUseAlias() => $_has(5);
  @$pb.TagNumber(6)
  void clearUseAlias() => $_clearField(6);

  @$pb.TagNumber(7)
  $core.String get responseTopic => $_getSZ(6);
  @$pb.TagNumber(7)
  set responseTopic($core.String value) => $_setString(6, value);
  @$pb.TagNumber(7)
  $core.bool hasResponseTopic() => $_has(6);
  @$pb.TagNumber(7)
  void clearResponseTopic() => $_clearField(7);

  @$pb.TagNumber(8)
  $core.List<$core.int> get correlationData => $_getN(7);
  @$pb.TagNumber(8)
  set correlationData($core.List<$core.int> value) => $_setBytes(7, value);
  @$pb.TagNumber(8)
  $core.bool hasCorrelationData() => $_has(7);
  @$pb.TagNumber(8)
  void clearCorrelationData() => $_clearField(8);

  @$pb.TagNumber(9)
  $pb.PbMap<$core.String, $core.String> get userProperties => $_getMap(8);

  @$pb.TagNumber(10)
  $core.String get contentType => $_getSZ(9);
  @$pb.TagNumber(10)
  set contentType($core.String value) => $_setString(9, value);
  @$pb.TagNumber(10)
  $core.bool hasContentType() => $_has(9);
  @$pb.TagNumber(10)
  void clearContentType() => $_clearField(10);

  @$pb.TagNumber(11)
  $core.int get qos => $_getIZ(10);
  @$pb.TagNumber(11)
  set qos($core.int value) => $_setSignedInt32(10, value);
  @$pb.TagNumber(11)
  $core.bool hasQos() => $_has(10);
  @$pb.TagNumber(11)
  void clearQos() => $_clearField(11);

  @$pb.TagNumber(12)
  $core.int get storageId => $_getIZ(11);
  @$pb.TagNumber(12)
  set storageId($core.int value) => $_setSignedInt32(11, value);
  @$pb.TagNumber(12)
  $core.bool hasStorageId() => $_has(11);
  @$pb.TagNumber(12)
  void clearStorageId() => $_clearField(12);
}

const $core.bool _omitFieldNames =
    $core.bool.fromEnvironment('protobuf.omit_field_names');
const $core.bool _omitMessageNames =
    $core.bool.fromEnvironment('protobuf.omit_message_names');
