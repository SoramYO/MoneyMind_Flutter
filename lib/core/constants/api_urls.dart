class ApiUrls {
  static const baseURL = 'http://10.0.2.2:8080/api/';
  static const register = '${baseURL}Authentications/Register';
  static const userProfile = '${baseURL}user/profile';
  static const login = '${baseURL}Authentications/Login';
  static const refreshToken = '${baseURL}Authentications/RefreshToken';
  static const registerToken = '${baseURL}Authentications/register-token';
  static const transactions = '${baseURL}Transaction';
  static const wallet = '${baseURL}Wallet';
  static const walletCategory = '${baseURL}WalletCategory';
  static const goalItem = '${baseURL}GoalItem';
  static const monthlyGoal = '${baseURL}MonthlyGoal';
  static const message = '${baseURL}Message';
  static const googleSignIn = '${baseURL}Authentications/GoogleLogin';
  static const activity = '${baseURL}Activity';
  static const addSheet = '${baseURL}Sheet/add';
  static const syncSheet = '${baseURL}GoogleSheetSync/sync';
  static const checkSheetExists = '${baseURL}Sheet/isExists';
  static const walletType = '${baseURL}WalletType';
  static const chat = 'https://10.0.2.2:5079/chathub';
}
