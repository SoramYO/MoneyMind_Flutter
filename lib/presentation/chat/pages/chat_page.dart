import 'package:flutter/material.dart';
import 'package:my_project/core/constants/api_urls.dart';
import 'package:my_project/data/models/chat.dart';
import 'package:my_project/data/models/message.dart';
import 'package:my_project/domain/repository/chat.dart';
import 'package:my_project/domain/repository/message.dart';
import 'package:my_project/presentation/chat/widgets/chat_bubble.dart';
import 'package:my_project/presentation/chat/widgets/chat_input.dart';
import 'package:my_project/service_locator.dart';
import 'package:my_project/services/signalr_service.dart';

class ChatPage extends StatefulWidget {
  final String userId;

  const ChatPage({super.key, required this.userId});

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  ChatBox? chat;
  String? _chatId;
  List<Message> messages = [];
  int totalRecord = 0;
  int currentPage = 1;
  int pageSize = 15;
  bool isLoading = false;
  String? error;

  // Các biến liên quan đến lazy load tin nhắn cũ
  bool isLoadingOlder = false;
  bool hasMoreOlderMessages = true;
  bool canLoadOlder = true;

  final TextEditingController _controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  late SignalRService signalRService;

  @override
  void initState() {
    super.initState();
    _loadChatHistory();
    signalRService = SignalRService(ApiUrls.chatHub);
    _startSignalR();

    // Thêm listener để trigger lazy load tin nhắn cũ khi kéo đến đầu danh sách
    _scrollController.addListener(_onScroll);
  }

  void _onScroll() {
    // Nếu offset <= 50, không đang load tin nhắn cũ, còn có tin nhắn cũ, và cờ canLoadOlder cho phép
    if (_scrollController.offset <= 50 &&
        !isLoadingOlder &&
        hasMoreOlderMessages &&
        canLoadOlder) {
      canLoadOlder = false;
      _loadOlderMessages();
    }
  }

  Future<void> _loadOlderMessages() async {
    if (chat == null) return;

    setState(() {
      isLoadingOlder = true;
    });

    // Lưu lại chiều cao scroll trước khi thêm tin nhắn cũ
    double beforeScrollHeight = _scrollController.position.maxScrollExtent;

    // Tăng page index để tải tin nhắn cũ hơn (page 1 là mới nhất)
    currentPage++;

    final queryParams = {
      'chatId': chat!.id ?? '',
      'pageIndex': '$currentPage',
      'pageSize': '$pageSize'
    };

    final messageResult = await sl<MessageRepository>().getMessages(
      widget.userId,
      queryParams: queryParams,
    );

    // Delay 0,5 giây để hiển thị loading indicator nếu cần
    await Future.delayed(const Duration(milliseconds: 500));

    messageResult.fold(
      (errorMessage) {
        setState(() {
          isLoadingOlder = false;
        });
      },
      (data) {
        if (data.isEmpty || data.length < pageSize) {
          setState(() {
            hasMoreOlderMessages = false;
            isLoadingOlder = false;
          });
        } else {
          // Thêm tin nhắn cũ vào đầu danh sách
          setState(() {
            messages.insertAll(0, data);
            isLoadingOlder = false;
          });
          // Sau khi layout được cập nhật, tính toán delta và cuộn mượt
          WidgetsBinding.instance.addPostFrameCallback((_) {
            double afterScrollHeight =
                _scrollController.position.maxScrollExtent;
            double scrollOffsetDelta = afterScrollHeight - beforeScrollHeight;
            double newOffset = _scrollController.offset - scrollOffsetDelta;
            _scrollController.jumpTo(
              newOffset,
            );
          });
        }
      },
    );

    // Sau khi load xong, cho phép load tin nhắn cũ tiếp theo sau 1 giây
    Future.delayed(const Duration(seconds: 1), () {
      canLoadOlder = true;
    });
  }

  Future<void> _loadChatHistory() async {
    setState(() {
      isLoading = true;
      error = null;
    });

    final result = await sl<ChatRepository>().getChats(widget.userId);
    setState(() {
      isLoading = false;
      result.fold(
        (errorMessage) => error = errorMessage,
        (data) {
          chat = data;
        },
      );
    });

    if (chat == null) {
      setState(() {
        isLoading = false;
        error = 'Không thể tải dữ liệu chat';
      });
      return;
    } else {
      setState(() {
        isLoading = true;
        error = null;
      });

      final queryParams = {
        'chatId': chat!.id ?? '',
        'pageIndex': '$currentPage',
        'pageSize': '$pageSize'
      };

      final messageResult = await sl<MessageRepository>().getMessages(
        widget.userId,
        queryParams: queryParams,
      );
      setState(() {
        isLoading = false;
        messageResult.fold(
          (errorMessage) {
            error = errorMessage;
            messages = [];
          },
          (data) {
            messages = data;
            totalRecord = messages.length;
          },
        );
      });

      // Sau khi tải xong, cuộn xuống cuối để hiển thị tin nhắn mới nhất
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _scrollToBottom();
      });
    }
  }

 void _startSignalR() async {
  await signalRService.start();

  // Đăng ký sự kiện nhận tin nhắn từ backend
  signalRService.onReceiveMessage((List<dynamic>? args) {
    if (args == null || args.length < 2) {
      print("SignalR: Received insufficient arguments");
      return;
    }
    print("SignalR: Received message: $args");

    final String sender = args[0].toString();
    final dynamic messageData = args[1];
    print("SignalR: Received message from $sender: $messageData");

    // Lấy chatId từ dữ liệu trả về
    String newChatId = messageData['chatId'];
    print("SignalR: Id $sender: $newChatId");

    // Nếu _chatId chưa được cập nhật, cập nhật ngay
    if (_chatId == null) {
      setState(() {
        _chatId = newChatId;
      });
    }

    // Cập nhật danh sách tin nhắn và tắt trạng thái loading
    if (mounted) {
      setState(() {
        messages.add(
          Message.fromReceivedData(
            Map<String, dynamic>.from(messageData),
          ),
        );
        isLoading = false;
      });
      // Sau khi cập nhật xong, cuộn xuống cuối
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _scrollToBottom();
      });
    }
  });
}


  void _sendMessage() {
    String text = _controller.text.trim();
    if (text.isEmpty || isLoading) return;
    // Lấy chatId từ đối tượng chat nếu có
    String? chatIdToSend = _chatId ?? chat?.id;
    // Thêm tin nhắn của người dùng vào danh sách
    setState(() {
      messages.add(
        Message(
          messageContent: text,
          senderId: widget.userId,
          sentTime: DateTime.now(),
          isBotResponse: false,
        ),
      );
      isLoading = true;
    });
    // Sau khi gửi, cuộn xuống cuối danh sách
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _scrollToBottom();
    });
    // Gửi tin nhắn qua SignalR
    signalRService.sendMessage(chatIdToSend, widget.userId, text);
    _controller.clear();
  }

  void _scrollToBottom() {
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }

  @override
  void dispose() {
    signalRService.stop();
    _controller.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white, // nền trắng
      appBar: AppBar(
        centerTitle: false,
        backgroundColor: Colors.white,
        elevation: 1,
        iconTheme: IconThemeData(color: Colors.green),
        title: Row(
          children: [
            Image.asset(
              'assets/images/logo_AI-removebg.png',
              width: 60,
              height: 60,
            ),
            const SizedBox(width: 10),
            const Text(
              'MoneyMind AI',
              style: TextStyle(
                color: Colors.green,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
      body: Column(
        children: [
          // Vùng hiển thị lịch sử chat với loading indicator ở đầu nếu đang load tin nhắn cũ
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              // Nếu đang load tin nhắn cũ, thêm 1 item ở đầu để hiển thị loading indicator
              itemCount: messages.length + (isLoadingOlder ? 1 : 0),
              itemBuilder: (context, index) {
                if (isLoadingOlder) {
                  if (index == 0) {
                    return const Padding(
                      padding: EdgeInsets.all(8.0),
                      child: Center(child: CircularProgressIndicator()),
                    );
                  }
                  index = index - 1;
                }
                final message = messages[index];
                return ChatBubble(message: message);
              },
            ),
          ),
          // Phần nhập tin nhắn
          MessageInput(
            controller: _controller,
            isLoading: isLoading,
            onSend: _sendMessage,
          ),
        ],
      ),
    );
  }
}
