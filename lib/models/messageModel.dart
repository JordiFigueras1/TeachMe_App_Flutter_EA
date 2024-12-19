class MessageModel {
  final String senderId;
  final String senderName;
  final String roomId;
  final String messageContent;
  final DateTime timestamp;

  MessageModel({
    required this.senderId,
    required this.senderName,
    required this.roomId,
    required this.messageContent,
    required this.timestamp,
  });

  factory MessageModel.fromJson(Map<String, dynamic> json) {
    return MessageModel(
      senderId: json['senderId'],
      senderName: json['senderName'],
      roomId: json['roomId'],
      messageContent: json['messageContent'],
      timestamp: DateTime.parse(json['timestamp']),
    );
  }

  Map<String, dynamic> toJson() => {
    'senderId': senderId,
    'senderName': senderName,
    'roomId': roomId,
    'messageContent': messageContent,
    'timestamp': timestamp.toIso8601String(),
  };
}
