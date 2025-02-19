class MessageEntity{
    final String id;
    final String senderId;
    final String messageContent;
    final DateTime sentTime;
    final bool isBotResponse; 

    MessageEntity({
        required this.id,
        required this.senderId,
        required this.messageContent,
        required this.sentTime,
        required this.isBotResponse,
    });
}