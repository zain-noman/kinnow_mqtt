// This is a generated file - do not edit.
//
// Generated from tx_publish_pkt_storage.proto.

// @dart = 3.3

// ignore_for_file: annotate_overrides, camel_case_types, comment_references
// ignore_for_file: constant_identifier_names
// ignore_for_file: curly_braces_in_flow_control_structures
// ignore_for_file: deprecated_member_use_from_same_package, library_prefixes
// ignore_for_file: non_constant_identifier_names, prefer_relative_imports
// ignore_for_file: unused_import

import 'dart:convert' as $convert;
import 'dart:core' as $core;
import 'dart:typed_data' as $typed_data;

@$core.Deprecated('Use tx_publish_pkt_storageDescriptor instead')
const tx_publish_pkt_storage$json = {
  '1': 'tx_publish_pkt_storage',
  '2': [
    {'1': 'retain', '3': 1, '4': 1, '5': 8, '10': 'retain'},
    {'1': 'topic', '3': 2, '4': 1, '5': 9, '10': 'topic'},
    {'1': 'payload', '3': 3, '4': 1, '5': 12, '10': 'payload'},
    {
      '1': 'payloadFormat',
      '3': 4,
      '4': 1,
      '5': 8,
      '9': 0,
      '10': 'payloadFormat',
      '17': true
    },
    {
      '1': 'messageExpiryInterval',
      '3': 5,
      '4': 1,
      '5': 5,
      '9': 1,
      '10': 'messageExpiryInterval',
      '17': true
    },
    {'1': 'useAlias', '3': 6, '4': 1, '5': 8, '10': 'useAlias'},
    {
      '1': 'responseTopic',
      '3': 7,
      '4': 1,
      '5': 9,
      '9': 2,
      '10': 'responseTopic',
      '17': true
    },
    {
      '1': 'correlationData',
      '3': 8,
      '4': 1,
      '5': 12,
      '9': 3,
      '10': 'correlationData',
      '17': true
    },
    {
      '1': 'userProperties',
      '3': 9,
      '4': 3,
      '5': 11,
      '6': '.tx_publish_pkt_storage.UserPropertiesEntry',
      '10': 'userProperties'
    },
    {
      '1': 'contentType',
      '3': 10,
      '4': 1,
      '5': 9,
      '9': 4,
      '10': 'contentType',
      '17': true
    },
    {'1': 'qos', '3': 11, '4': 1, '5': 5, '10': 'qos'},
    {'1': 'storageId', '3': 12, '4': 1, '5': 5, '10': 'storageId'},
  ],
  '3': [tx_publish_pkt_storage_UserPropertiesEntry$json],
  '8': [
    {'1': '_payloadFormat'},
    {'1': '_messageExpiryInterval'},
    {'1': '_responseTopic'},
    {'1': '_correlationData'},
    {'1': '_contentType'},
  ],
};

@$core.Deprecated('Use tx_publish_pkt_storageDescriptor instead')
const tx_publish_pkt_storage_UserPropertiesEntry$json = {
  '1': 'UserPropertiesEntry',
  '2': [
    {'1': 'key', '3': 1, '4': 1, '5': 9, '10': 'key'},
    {'1': 'value', '3': 2, '4': 1, '5': 9, '10': 'value'},
  ],
  '7': {'7': true},
};

/// Descriptor for `tx_publish_pkt_storage`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List tx_publish_pkt_storageDescriptor = $convert.base64Decode(
    'ChZ0eF9wdWJsaXNoX3BrdF9zdG9yYWdlEhYKBnJldGFpbhgBIAEoCFIGcmV0YWluEhQKBXRvcG'
    'ljGAIgASgJUgV0b3BpYxIYCgdwYXlsb2FkGAMgASgMUgdwYXlsb2FkEikKDXBheWxvYWRGb3Jt'
    'YXQYBCABKAhIAFINcGF5bG9hZEZvcm1hdIgBARI5ChVtZXNzYWdlRXhwaXJ5SW50ZXJ2YWwYBS'
    'ABKAVIAVIVbWVzc2FnZUV4cGlyeUludGVydmFsiAEBEhoKCHVzZUFsaWFzGAYgASgIUgh1c2VB'
    'bGlhcxIpCg1yZXNwb25zZVRvcGljGAcgASgJSAJSDXJlc3BvbnNlVG9waWOIAQESLQoPY29ycm'
    'VsYXRpb25EYXRhGAggASgMSANSD2NvcnJlbGF0aW9uRGF0YYgBARJTCg51c2VyUHJvcGVydGll'
    'cxgJIAMoCzIrLnR4X3B1Ymxpc2hfcGt0X3N0b3JhZ2UuVXNlclByb3BlcnRpZXNFbnRyeVIOdX'
    'NlclByb3BlcnRpZXMSJQoLY29udGVudFR5cGUYCiABKAlIBFILY29udGVudFR5cGWIAQESEAoD'
    'cW9zGAsgASgFUgNxb3MSHAoJc3RvcmFnZUlkGAwgASgFUglzdG9yYWdlSWQaQQoTVXNlclByb3'
    'BlcnRpZXNFbnRyeRIQCgNrZXkYASABKAlSA2tleRIUCgV2YWx1ZRgCIAEoCVIFdmFsdWU6AjgB'
    'QhAKDl9wYXlsb2FkRm9ybWF0QhgKFl9tZXNzYWdlRXhwaXJ5SW50ZXJ2YWxCEAoOX3Jlc3Bvbn'
    'NlVG9waWNCEgoQX2NvcnJlbGF0aW9uRGF0YUIOCgxfY29udGVudFR5cGU=');
