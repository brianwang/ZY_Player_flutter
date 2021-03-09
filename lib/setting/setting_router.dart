import 'package:ZY_Player_flutter/routes/router_init.dart';
import 'package:ZY_Player_flutter/setting/page/player_record_page.dart';
import 'package:ZY_Player_flutter/setting/page/player_video_page.dart';
import 'package:ZY_Player_flutter/setting/page/theme_page.dart';
import 'package:fluro/fluro.dart';

import 'page/about_page.dart';
import 'page/account_manager_page.dart';
import 'page/setting_page.dart';

class SettingRouter implements IRouterProvider {
  static String settingPage = '/setting';
  static String aboutPage = '/setting/about';
  static String themePage = '/setting/theme';
  static String playerRecordPage = '/setting/playerRecord';
  static String playerVideoPage = '/setting/playerVideoPage';
  static String accountManagerPage = '/setting/accountManager';

  @override
  void initRouter(FluroRouter router) {
    router.define(settingPage, handler: Handler(handlerFunc: (_, __) => SettingPage()));
    router.define(aboutPage, handler: Handler(handlerFunc: (_, __) => AboutPage()));
    router.define(themePage, handler: Handler(handlerFunc: (_, __) => ThemePage()));
    router.define(playerRecordPage, handler: Handler(handlerFunc: (_, __) => PlayerRecordPage()));
    router.define(playerVideoPage,
        handler: Handler(
            handlerFunc: (_, params) => PlayerVideoPage(
                url: params["url"]?.first,
                title: params["title"]?.first,
                cover: params["cover"]?.first,
                videoId: params["videoId"]?.first,
                startAt: params["startAt"]?.first)));
    router.define(accountManagerPage, handler: Handler(handlerFunc: (_, __) => AccountManagerPage()));
  }
}
