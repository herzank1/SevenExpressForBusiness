
import 'dart:async';

import 'package:seven_express_api/dto/ApiResponse.dart';
import 'package:seven_express_api/entities/Business.dart';
import 'package:seven_express_api/methods/Businesess.dart';
import 'package:seven_express_api/utils/TokenManager.dart';

class AccountService {
  static Business? business;

  static final StreamController<Business?> _businessController = StreamController<Business?>.broadcast();

  static Stream<Business?> get businessStream => _businessController.stream;

  static Future<void>getAccount()async{

    ApiResponse<Business>? response = await  Businesess.account();

    business = response?.data;
    _businessController.add(business); // Emitir el nuevo valor
  }

  static void startAutoUpdate() {
    Timer.periodic(const Duration(minutes:1), (timer) async {
      await getAccount();
    });
  }

  static Future<bool?> logout() async{

    ApiResponse<bool>?response= await Businesess.logout();

    return response?.data ??false;

  }

  static Future<void> clearToken() async {
   await TokenManager.clearAuthToken();
  }
}