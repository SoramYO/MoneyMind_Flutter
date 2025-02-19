class Message {
    final String? id;
    final String senderId;
    final String messageContent;
    final DateTime sentTime;
    final bool isBotResponse; 

    Message({
        this.id,
        required this.senderId,
        required this.messageContent,
        required this.sentTime,
        required this.isBotResponse,
    });

    factory Message.fromJson(Map<String, dynamic> json) {
        return Message(
            id: json['id'],
            senderId: json['senderId'],
            messageContent: json['messageContent'],
            sentTime: DateTime.parse(json['sentTime']),
            isBotResponse: json['isBotResponse'],
        );
    }

    Map<String, dynamic> toJson() {
        return {
            'id': id,
            'senderId': senderId,
            'messageContent': messageContent,
            'sentTime': sentTime.toIso8601String(),
            'isBotResponse': isBotResponse,
        };
    }

    factory Message.fromReceivedData(Map<String, dynamic> json) {
        return Message(
        id: json['id'], // Có thể null nếu không có trong dữ liệu
        senderId: json['senderId'] ?? '',
        messageContent: json['messageContent'] ?? '',
        // Nếu có key 'sentTime' thì parse, nếu không thì dùng thời gian hiện tại
        sentTime: json.containsKey('sentTime') && json['sentTime'] != null
            ? DateTime.parse(json['sentTime'])
            : DateTime.now(),
        isBotResponse: json['isBotResponse'] ?? false,
        );
    }

    @override
    String toString() {
        return 'Message(id: $id, senderId: $senderId, messageContent: $messageContent, sentTime: $sentTime, isBotResponse: $isBotResponse)';
    }
}