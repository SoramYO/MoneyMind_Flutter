import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:my_project/presentation/auth/pages/signin.dart';
import '../../../common/bloc/button/button_state.dart';
import '../../../common/bloc/button/button_state_cubit.dart';
import '../../../common/widgets/button/basic_app_button.dart';
import '../../../domain/entities/user.dart';
import '../../../domain/usecases/logout.dart';
import '../../../service_locator.dart';
import '../bloc/user_display_cubit.dart';
import '../bloc/user_display_state.dart';
import '../../../core/constants/app_colors.dart';
import '../../../common/widgets/custom_arc_painter.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  Widget build(BuildContext context) {
    var media = MediaQuery.sizeOf(context);
    
    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Column(
          children: [
            Container(
              height: media.width * 1.1,
              decoration: BoxDecoration(
                color: Colors.grey[900],
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(25),
                  bottomRight: Radius.circular(25)
                )
              ),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Positioned(
                    top: media.width * 0.15,
                    child: Container(
                      width: media.width * 0.8,
                      height: media.width * 0.8,
                      child: CustomPaint(
                        painter: CustomArcPainter(
                          end: 180,
                          width: 12,
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    top: media.width * 0.4,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          "2.500.000đ",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 40,
                            fontWeight: FontWeight.w700
                          ),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          "Chi tiêu tháng này",
                          style: TextStyle(
                            color: Colors.grey[400],
                            fontSize: 16
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
