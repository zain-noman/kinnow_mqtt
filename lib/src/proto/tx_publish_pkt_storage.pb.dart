//
//  Generated code. Do not modify.
//  source: tx_publish_pkt_storage.proto
//
// @dart = 2.12

// ignore_for_file: annotate_overrides, camel_case_types, comment_references
// ignore_for_file: constant_identifier_names, library_prefixes
// ignore_for_file: non_constant_identifier_names, prefer_final_fields
// ignore_for_file: unnecessary_import, unnecessary_this, unused_import

import 'dart:core' as $core;

import 'package:protobuf/protobuf.dart' as $pb;

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
    $core.Map<$core.String, $core.String>? userProperties,
    $core.String? contentType,
    $core.int? qos,
    $core.int? storageId,
  }) {
    final $result = create();
    if (retain != null) {
      $result.retain = retain;
    }
    if (topic != null) {
      $result.topic = topic;
    }
    if (payload != null) {
      $result.payload = payload;
    }
    if (payloadFormat != null) {
      $result.payloadFormat = payloadFormat;
    }
    if (messageExpiryInterval != null) {
      $result.messageExpiryInterval = messageExpiryInterval;
    }
    if (useAlias != null) {
      $result.useAlias = useAlias;
    }
    if (responseTopic != null) {
      $result.responseTopic = responseTopic;
    }
    if (correlationData != null) {
      $result.correlationData = correlationData;
    }
    if (userProperties != null) {
      $result.userProperties.addAll(userProperties);
    }
    if (contentType != null) {
      $result.contentType = contentType;
    }
    if (qos != null) {
      $result.qos = qos;
    }
    if (storageId != null) {
      $result.storageId = storageId;
    }
    return $result;
  }
  tx_publish_pkt_storage._() : super();
  factory tx_publish_pkt_storage.fromBuffer($core.List<$core.int> i,
          [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(i, r);
  factory tx_publish_pkt_storage.fromJson($core.String i,
          [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'tx_publish_pkt_storage',
      createEmptyInstance: create)
    ..aOB(1, _omitFieldNames ? '' : 'retain')
    ..aOS(2, _omitFieldNames ? '' : 'topic')
    ..a<$core.List<$core.int>>(
        3, _omitFieldNames ? '' : 'payload', $pb.PbFieldType.OY)
    ..aOB(4, _omitFieldNames ? '' : 'payloadFormat', protoName: 'payloadFormat')
    ..a<$core.int>(
        5, _omitFieldNames ? '' : 'messageExpiryInterval', $pb.PbFieldType.O3,
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
    ..a<$core.int>(11, _omitFieldNames ? '' : 'qos', $pb.PbFieldType.O3)
    ..a<$core.int>(12, _omitFieldNames ? '' : 'storageId', $pb.PbFieldType.O3,
        protoName: 'storageId')
    ..hasRequiredFields = false;

  @$core.Deprecated('Using this can add significant overhead to your binary. '
      'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
      'Will be removed in next major version')
  tx_publish_pkt_storage clone() =>
      tx_publish_pkt_storage()..mergeFromMessage(this);
  @$core.Deprecated('Using this can add significant overhead to your binary. '
      'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
      'Will be removed in next major version')
  tx_publish_pkt_storage copyWith(
          void Function(tx_publish_pkt_storage) updates) =>
      super.copyWith((message) => updates(message as tx_publish_pkt_storage))
          as tx_publish_pkt_storage;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static tx_publish_pkt_storage create() => tx_publish_pkt_storage._();
  tx_publish_pkt_storage createEmptyInstance() => create();
  static $pb.PbList<tx_publish_pkt_storage> createRepeated() =>
      $pb.PbList<tx_publish_pkt_storage>();
  @$core.pragma('dart2js:noInline')
  static tx_publish_pkt_storage getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<tx_publish_pkt_storage>(create);
  static tx_publish_pkt_storage? _defaultInstance;

  @$pb.TagNumber(1)
  $core.bool get retain => $_getBF(0);
  @$pb.TagNumber(1)
  set retain($core.bool v) {
    $_setBool(0, v);
  }

  @$pb.TagNumber(1)
  $core.bool hasRetain() => $_has(0);
  @$pb.TagNumber(1)
  void clearRetain() => clearField(1);

  @$pb.TagNumber(2)
  $core.String get topic => $_getSZ(1);
  @$pb.TagNumber(2)
  set topic($core.String v) {
    $_setString(1, v);
  }

  @$pb.TagNumber(2)
  $core.bool hasTopic() => $_has(1);
  @$pb.TagNumber(2)
  void clearTopic() => clearField(2);

  @$pb.TagNumber(3)
  $core.List<$core.int> get payload => $_getN(2);
  @$pb.TagNumber(3)
  set payload($core.List<$core.int> v) {
    $_setBytes(2, v);
  }

  @$pb.TagNumber(3)
  $core.bool hasPayload() => $_has(2);
  @$pb.TagNumber(3)
  void clearPayload() => clearField(3);

  @$pb.TagNumber(4)
  $core.bool get payloadFormat => $_getBF(3);
  @$pb.TagNumber(4)
  set payloadFormat($core.bool v) {
    $_setBool(3, v);
  }

  @$pb.TagNumber(4)
  $core.bool hasPayloadFormat() => $_has(3);
  @$pb.TagNumber(4)
  void clearPayloadFormat() => clearField(4);

  @$pb.TagNumber(5)
  $core.int get messageExpiryInterval => $_getIZ(4);
  @$pb.TagNumber(5)
  set messageExpiryInterval($core.int v) {
    $_setSignedInt32(4, v);
  }

  @$pb.TagNumber(5)
  $core.bool hasMessageExpiryInterval() => $_has(4);
  @$pb.TagNumber(5)
  void clearMessageExpiryInterval() => clearField(5);

  @$pb.TagNumber(6)
  $core.bool get useAlias => $_getBF(5);
  @$pb.TagNumber(6)
  set useAlias($core.bool v) {
    $_setBool(5, v);
  }

  @$pb.TagNumber(6)
  $core.bool hasUseAlias() => $_has(5);
  @$pb.TagNumber(6)
  void clearUseAlias() => clearField(6);

  @$pb.TagNumber(7)
  $core.String get responseTopic => $_getSZ(6);
  @$pb.TagNumber(7)
  set responseTopic($core.String v) {
    $_setString(6, v);
  }

  @$pb.TagNumber(7)
  $core.bool hasResponseTopic() => $_has(6);
  @$pb.TagNumber(7)
  void clearResponseTopic() => clearField(7);

  @$pb.TagNumber(8)
  $core.List<$core.int> get correlationData => $_getN(7);
  @$pb.TagNumber(8)
  set correlationData($core.List<$core.int> v) {
    $_setBytes(7, v);
  }

  @$pb.TagNumber(8)
  $core.bool hasCorrelationData() => $_has(7);
  @$pb.TagNumber(8)
  void clearCorrelationData() => clearField(8);

  @$pb.TagNumber(9)
  $core.Map<$core.String, $core.String> get userProperties => $_getMap(8);

  @$pb.TagNumber(10)
  $core.String get contentType => $_getSZ(9);
  @$pb.TagNumber(10)
  set contentType($core.String v) {
    $_setString(9, v);
  }

  @$pb.TagNumber(10)
  $core.bool hasContentType() => $_has(9);
  @$pb.TagNumber(10)
  void clearContentType() => clearField(10);

  @$pb.TagNumber(11)
  $core.int get qos => $_getIZ(10);
  @$pb.TagNumber(11)
  set qos($core.int v) {
    $_setSignedInt32(10, v);
  }

  @$pb.TagNumber(11)
  $core.bool hasQos() => $_has(10);
  @$pb.TagNumber(11)
  void clearQos() => clearField(11);

  @$pb.TagNumber(12)
  $core.int get storageId => $_getIZ(11);
  @$pb.TagNumber(12)
  set storageId($core.int v) {
    $_setSignedInt32(11, v);
  }

  @$pb.TagNumber(12)
  $core.bool hasStorageId() => $_has(11);
  @$pb.TagNumber(12)
  void clearStorageId() => clearField(12);
}

const _omitFieldNames = $core.bool.fromEnvironment('protobuf.omit_field_names');
const _omitMessageNames =
    $core.bool.fromEnvironment('protobuf.omit_message_names');
