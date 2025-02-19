import 'package:signalr_core/signalr_core.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SignalRService {
  late final HubConnection hubConnection;

SignalRService(String hubUrl) {
    hubConnection = HubConnectionBuilder()
        .withUrl(
          hubUrl,
          HttpConnectionOptions(
            accessTokenFactory: () async {
              final prefs = await SharedPreferences.getInstance();
              final token = prefs.getString('accessToken');
              // Nếu token null, bạn có thể trả về chuỗi rỗng hoặc xử lý theo logic của mình
              return token ?? '';
            },
          ),
        )
        .withAutomaticReconnect()
        .build();
  }

  Future<void> start() async {
    try {
      await hubConnection.start();
      print("SignalR: Connection started");
    } catch (e) {
      print("SignalR: Connection failed: $e");
    }
  }

  void stop() async {
    await hubConnection.stop();
  }

  /// Đăng ký lắng nghe sự kiện "ReceiveMessage"
  void onReceiveMessage(void Function(List<dynamic>? args) handler) {
    hubConnection.on("ReceiveMessage", handler);
  }

  /// Gửi tin nhắn lên Hub với phương thức "SendMessage"
  Future<void> sendMessage(String? chatId, String userId, String message) async {
    try {
      await hubConnection.invoke("SendMessage", args: [chatId, userId, message]);
    } catch (e) {
      print("SignalR: Error sending message: $e");
    }
  }
}
