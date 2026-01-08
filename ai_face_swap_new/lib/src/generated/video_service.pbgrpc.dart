// This is a generated file - do not edit.
//
// Generated from video_service.proto.

// @dart = 3.3

// ignore_for_file: annotate_overrides, camel_case_types, comment_references
// ignore_for_file: constant_identifier_names
// ignore_for_file: curly_braces_in_flow_control_structures
// ignore_for_file: deprecated_member_use_from_same_package, library_prefixes
// ignore_for_file: non_constant_identifier_names, prefer_relative_imports

import 'dart:async' as $async;
import 'dart:core' as $core;

import 'package:grpc/service_api.dart' as $grpc;
import 'package:protobuf/protobuf.dart' as $pb;

import 'video_service.pb.dart' as $0;

export 'video_service.pb.dart';

/// 视频服务定义
@$pb.GrpcServiceName('video.VideoService')
class VideoServiceClient extends $grpc.Client {
  /// The hostname for this service.
  static const $core.String defaultHost = '';

  /// OAuth scopes needed for the client.
  static const $core.List<$core.String> oauthScopes = [
    '',
  ];

  VideoServiceClient(super.channel, {super.options, super.interceptors});

  /// 流式上传视频
  $grpc.ResponseStream<$0.UploadResponse> uploadVideo(
    $async.Stream<$0.UploadRequest> request, {
    $grpc.CallOptions? options,
  }) {
    return $createStreamingCall(_$uploadVideo, request, options: options);
  }

  /// 创建换脸任务
  $grpc.ResponseFuture<$0.TaskResponse> createTask(
    $0.CreateTaskRequest request, {
    $grpc.CallOptions? options,
  }) {
    return $createUnaryCall(_$createTask, request, options: options);
  }

  /// 获取任务状态
  $grpc.ResponseFuture<$0.TaskResponse> getTaskStatus(
    $0.TaskStatusRequest request, {
    $grpc.CallOptions? options,
  }) {
    return $createUnaryCall(_$getTaskStatus, request, options: options);
  }

  /// 获取用户任务列表
  $grpc.ResponseFuture<$0.UserTasksResponse> getUserTasks(
    $0.UserTasksRequest request, {
    $grpc.CallOptions? options,
  }) {
    return $createUnaryCall(_$getUserTasks, request, options: options);
  }

  // method descriptors

  static final _$uploadVideo =
      $grpc.ClientMethod<$0.UploadRequest, $0.UploadResponse>(
          '/video.VideoService/UploadVideo',
          ($0.UploadRequest value) => value.writeToBuffer(),
          $0.UploadResponse.fromBuffer);
  static final _$createTask =
      $grpc.ClientMethod<$0.CreateTaskRequest, $0.TaskResponse>(
          '/video.VideoService/CreateTask',
          ($0.CreateTaskRequest value) => value.writeToBuffer(),
          $0.TaskResponse.fromBuffer);
  static final _$getTaskStatus =
      $grpc.ClientMethod<$0.TaskStatusRequest, $0.TaskResponse>(
          '/video.VideoService/GetTaskStatus',
          ($0.TaskStatusRequest value) => value.writeToBuffer(),
          $0.TaskResponse.fromBuffer);
  static final _$getUserTasks =
      $grpc.ClientMethod<$0.UserTasksRequest, $0.UserTasksResponse>(
          '/video.VideoService/GetUserTasks',
          ($0.UserTasksRequest value) => value.writeToBuffer(),
          $0.UserTasksResponse.fromBuffer);
}

@$pb.GrpcServiceName('video.VideoService')
abstract class VideoServiceBase extends $grpc.Service {
  $core.String get $name => 'video.VideoService';

  VideoServiceBase() {
    $addMethod($grpc.ServiceMethod<$0.UploadRequest, $0.UploadResponse>(
        'UploadVideo',
        uploadVideo,
        true,
        true,
        ($core.List<$core.int> value) => $0.UploadRequest.fromBuffer(value),
        ($0.UploadResponse value) => value.writeToBuffer()));
    $addMethod($grpc.ServiceMethod<$0.CreateTaskRequest, $0.TaskResponse>(
        'CreateTask',
        createTask_Pre,
        false,
        false,
        ($core.List<$core.int> value) => $0.CreateTaskRequest.fromBuffer(value),
        ($0.TaskResponse value) => value.writeToBuffer()));
    $addMethod($grpc.ServiceMethod<$0.TaskStatusRequest, $0.TaskResponse>(
        'GetTaskStatus',
        getTaskStatus_Pre,
        false,
        false,
        ($core.List<$core.int> value) => $0.TaskStatusRequest.fromBuffer(value),
        ($0.TaskResponse value) => value.writeToBuffer()));
    $addMethod($grpc.ServiceMethod<$0.UserTasksRequest, $0.UserTasksResponse>(
        'GetUserTasks',
        getUserTasks_Pre,
        false,
        false,
        ($core.List<$core.int> value) => $0.UserTasksRequest.fromBuffer(value),
        ($0.UserTasksResponse value) => value.writeToBuffer()));
  }

  $async.Stream<$0.UploadResponse> uploadVideo(
      $grpc.ServiceCall call, $async.Stream<$0.UploadRequest> request);

  $async.Future<$0.TaskResponse> createTask_Pre($grpc.ServiceCall $call,
      $async.Future<$0.CreateTaskRequest> $request) async {
    return createTask($call, await $request);
  }

  $async.Future<$0.TaskResponse> createTask(
      $grpc.ServiceCall call, $0.CreateTaskRequest request);

  $async.Future<$0.TaskResponse> getTaskStatus_Pre($grpc.ServiceCall $call,
      $async.Future<$0.TaskStatusRequest> $request) async {
    return getTaskStatus($call, await $request);
  }

  $async.Future<$0.TaskResponse> getTaskStatus(
      $grpc.ServiceCall call, $0.TaskStatusRequest request);

  $async.Future<$0.UserTasksResponse> getUserTasks_Pre($grpc.ServiceCall $call,
      $async.Future<$0.UserTasksRequest> $request) async {
    return getUserTasks($call, await $request);
  }

  $async.Future<$0.UserTasksResponse> getUserTasks(
      $grpc.ServiceCall call, $0.UserTasksRequest request);
}
