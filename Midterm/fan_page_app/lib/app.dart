import 'package:flutter/material.dart';
import 'package:logger/logger.dart' as log;
import 'package:stream_chat_flutter_core/stream_chat_flutter_core.dart';

const streamKey = "r827qcxq9tzt";

var logger = log.Logger();

extension StreamChatContext on BuildContext {
  String? get currentUserImage => currentUser?.image;

  User? get currentUser => StreamChatCore.of(this).currentUser;
}
