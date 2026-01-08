// This is a generated file - do not edit.
//
// Generated from video_service.proto.

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

@$core.Deprecated('Use uploadRequestDescriptor instead')
const UploadRequest$json = {
  '1': 'UploadRequest',
  '2': [
    {'1': 'user_id', '3': 1, '4': 1, '5': 9, '10': 'userId'},
    {'1': 'file_name', '3': 2, '4': 1, '5': 9, '10': 'fileName'},
    {'1': 'chunk', '3': 3, '4': 1, '5': 12, '10': 'chunk'},
    {'1': 'chunk_index', '3': 4, '4': 1, '5': 5, '10': 'chunkIndex'},
    {'1': 'total_chunks', '3': 5, '4': 1, '5': 5, '10': 'totalChunks'},
    {'1': 'file_type', '3': 6, '4': 1, '5': 9, '10': 'fileType'},
  ],
};

/// Descriptor for `UploadRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List uploadRequestDescriptor = $convert.base64Decode(
    'Cg1VcGxvYWRSZXF1ZXN0EhcKB3VzZXJfaWQYASABKAlSBnVzZXJJZBIbCglmaWxlX25hbWUYAi'
    'ABKAlSCGZpbGVOYW1lEhQKBWNodW5rGAMgASgMUgVjaHVuaxIfCgtjaHVua19pbmRleBgEIAEo'
    'BVIKY2h1bmtJbmRleBIhCgx0b3RhbF9jaHVua3MYBSABKAVSC3RvdGFsQ2h1bmtzEhsKCWZpbG'
    'VfdHlwZRgGIAEoCVIIZmlsZVR5cGU=');

@$core.Deprecated('Use uploadResponseDescriptor instead')
const UploadResponse$json = {
  '1': 'UploadResponse',
  '2': [
    {'1': 'status', '3': 1, '4': 1, '5': 9, '10': 'status'},
    {'1': 'message', '3': 2, '4': 1, '5': 9, '10': 'message'},
    {'1': 'file_url', '3': 3, '4': 1, '5': 9, '10': 'fileUrl'},
    {'1': 'uploaded_chunks', '3': 4, '4': 1, '5': 5, '10': 'uploadedChunks'},
    {'1': 'total_chunks', '3': 5, '4': 1, '5': 5, '10': 'totalChunks'},
    {'1': 'progress', '3': 6, '4': 1, '5': 2, '10': 'progress'},
  ],
};

/// Descriptor for `UploadResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List uploadResponseDescriptor = $convert.base64Decode(
    'Cg5VcGxvYWRSZXNwb25zZRIWCgZzdGF0dXMYASABKAlSBnN0YXR1cxIYCgdtZXNzYWdlGAIgAS'
    'gJUgdtZXNzYWdlEhkKCGZpbGVfdXJsGAMgASgJUgdmaWxlVXJsEicKD3VwbG9hZGVkX2NodW5r'
    'cxgEIAEoBVIOdXBsb2FkZWRDaHVua3MSIQoMdG90YWxfY2h1bmtzGAUgASgFUgt0b3RhbENodW'
    '5rcxIaCghwcm9ncmVzcxgGIAEoAlIIcHJvZ3Jlc3M=');

@$core.Deprecated('Use createTaskRequestDescriptor instead')
const CreateTaskRequest$json = {
  '1': 'CreateTaskRequest',
  '2': [
    {'1': 'user_id', '3': 1, '4': 1, '5': 9, '10': 'userId'},
    {'1': 'image_url', '3': 2, '4': 1, '5': 9, '10': 'imageUrl'},
    {'1': 'video_url', '3': 3, '4': 1, '5': 9, '10': 'videoUrl'},
  ],
};

/// Descriptor for `CreateTaskRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List createTaskRequestDescriptor = $convert.base64Decode(
    'ChFDcmVhdGVUYXNrUmVxdWVzdBIXCgd1c2VyX2lkGAEgASgJUgZ1c2VySWQSGwoJaW1hZ2VfdX'
    'JsGAIgASgJUghpbWFnZVVybBIbCgl2aWRlb191cmwYAyABKAlSCHZpZGVvVXJs');

@$core.Deprecated('Use taskResponseDescriptor instead')
const TaskResponse$json = {
  '1': 'TaskResponse',
  '2': [
    {'1': 'task_id', '3': 1, '4': 1, '5': 9, '10': 'taskId'},
    {'1': 'status', '3': 2, '4': 1, '5': 9, '10': 'status'},
    {'1': 'progress', '3': 3, '4': 1, '5': 5, '10': 'progress'},
    {'1': 'result_url', '3': 4, '4': 1, '5': 9, '10': 'resultUrl'},
    {'1': 'error_message', '3': 5, '4': 1, '5': 9, '10': 'errorMessage'},
    {'1': 'created_at', '3': 6, '4': 1, '5': 9, '10': 'createdAt'},
    {'1': 'updated_at', '3': 7, '4': 1, '5': 9, '10': 'updatedAt'},
  ],
};

/// Descriptor for `TaskResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List taskResponseDescriptor = $convert.base64Decode(
    'CgxUYXNrUmVzcG9uc2USFwoHdGFza19pZBgBIAEoCVIGdGFza0lkEhYKBnN0YXR1cxgCIAEoCV'
    'IGc3RhdHVzEhoKCHByb2dyZXNzGAMgASgFUghwcm9ncmVzcxIdCgpyZXN1bHRfdXJsGAQgASgJ'
    'UglyZXN1bHRVcmwSIwoNZXJyb3JfbWVzc2FnZRgFIAEoCVIMZXJyb3JNZXNzYWdlEh0KCmNyZW'
    'F0ZWRfYXQYBiABKAlSCWNyZWF0ZWRBdBIdCgp1cGRhdGVkX2F0GAcgASgJUgl1cGRhdGVkQXQ=');

@$core.Deprecated('Use taskStatusRequestDescriptor instead')
const TaskStatusRequest$json = {
  '1': 'TaskStatusRequest',
  '2': [
    {'1': 'task_id', '3': 1, '4': 1, '5': 9, '10': 'taskId'},
  ],
};

/// Descriptor for `TaskStatusRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List taskStatusRequestDescriptor = $convert.base64Decode(
    'ChFUYXNrU3RhdHVzUmVxdWVzdBIXCgd0YXNrX2lkGAEgASgJUgZ0YXNrSWQ=');

@$core.Deprecated('Use userTasksRequestDescriptor instead')
const UserTasksRequest$json = {
  '1': 'UserTasksRequest',
  '2': [
    {'1': 'user_id', '3': 1, '4': 1, '5': 9, '10': 'userId'},
  ],
};

/// Descriptor for `UserTasksRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List userTasksRequestDescriptor = $convert.base64Decode(
    'ChBVc2VyVGFza3NSZXF1ZXN0EhcKB3VzZXJfaWQYASABKAlSBnVzZXJJZA==');

@$core.Deprecated('Use userTasksResponseDescriptor instead')
const UserTasksResponse$json = {
  '1': 'UserTasksResponse',
  '2': [
    {
      '1': 'tasks',
      '3': 1,
      '4': 3,
      '5': 11,
      '6': '.video.TaskResponse',
      '10': 'tasks'
    },
    {'1': 'total_tasks', '3': 2, '4': 1, '5': 5, '10': 'totalTasks'},
  ],
};

/// Descriptor for `UserTasksResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List userTasksResponseDescriptor = $convert.base64Decode(
    'ChFVc2VyVGFza3NSZXNwb25zZRIpCgV0YXNrcxgBIAMoCzITLnZpZGVvLlRhc2tSZXNwb25zZV'
    'IFdGFza3MSHwoLdG90YWxfdGFza3MYAiABKAVSCnRvdGFsVGFza3M=');
