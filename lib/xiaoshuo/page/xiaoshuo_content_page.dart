import 'package:ZY_Player_flutter/event/event_bus.dart';
import 'package:ZY_Player_flutter/event/event_model.dart';
import 'package:ZY_Player_flutter/model/xiaoshuo_content.dart';
import 'package:ZY_Player_flutter/net/dio_utils.dart';
import 'package:ZY_Player_flutter/net/http_api.dart';
import 'package:ZY_Player_flutter/provider/app_state_provider.dart';
import 'package:ZY_Player_flutter/provider/base_list_provider.dart';
import 'package:ZY_Player_flutter/res/colors.dart';
import 'package:ZY_Player_flutter/util/provider.dart';
import 'package:ZY_Player_flutter/util/toast.dart';
import 'package:ZY_Player_flutter/widgets/my_refresh_list.dart';
import 'package:ZY_Player_flutter/widgets/state_layout.dart';
import 'package:ZY_Player_flutter/xiaoshuo/provider/xiaoshuo_provider.dart';
import 'package:ZY_Player_flutter/xiaoshuo/widget/reader_memu.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screen_wake/flutter_screen_wake.dart';
import 'package:provider/provider.dart';

class XiaoShuoContentPage extends StatefulWidget {
  XiaoShuoContentPage({
    Key? key,
    required this.id,
    required this.chpId,
    required this.title,
  }) : super(key: key);

  final int id;
  final String chpId;
  final String title;

  @override
  _XiaoShuoContentPageState createState() => _XiaoShuoContentPageState();
}

class _XiaoShuoContentPageState extends State<XiaoShuoContentPage> with TickerProviderStateMixin {
  AppStateProvider? _appStateProvider;
  XiaoShuoProvider? _xiaoShuoProvider;
  BaseListProvider<XiaoshuoContent> _baseListProvider = BaseListProvider();
  ScrollController scrollController = ScrollController();

  List<Map<String, int>>? chpPage;

  bool hasMore = false;
  int chapid = 0;
  String title = "";
  int? currentChpid;

  bool loadMoreFlag = false;
  double light = 0;
  int currentIndex = 0;

  @override
  void initState() {
    _appStateProvider = Store.value<AppStateProvider>(context);
    _xiaoShuoProvider = Store.value<XiaoShuoProvider>(context);
    _appStateProvider!.setConfig();
    title = widget.title;

    Future.microtask(() => fetchData(int.parse(widget.chpId)));
    ApplicationEvent.event.on<LoadXiaoShuoEvent>().listen((event) {
      _baseListProvider.clear();
      title = event.title;
      _appStateProvider!.setOpcity(0.0);
      fetchData(event.chpId);
    });
    getLight();

    super.initState();
  }

  Future getLight() async {
    light = _appStateProvider!.lightLevel;
  }

  Future setLight() async {
    FlutterScreenWake.setBrightness(-1);
    _appStateProvider?.setLightLevel(-1);
  }

  @override
  void dispose() {
    setLight();
    super.dispose();
  }

  Future fetchData([int? chaId]) async {
    _baseListProvider.setStateType(StateType.loading);
    await DioUtils.instance.requestNetwork(Method.get, HttpApi.getxiaoshuoDetail, queryParameters: {"id": widget.id, "capid": chaId}, onSuccess: (result) {
      _xiaoShuoProvider!.setReadList("${widget.id}_${result['cid']}_${result['cname']}");
      currentChpid = result['cid'];
      _baseListProvider.add(XiaoshuoContent.fromJson(result));
      _baseListProvider.setStateType(StateType.empty);
      loadMoreFlag = false;
    }, onError: (_, msg) {
      loadMoreFlag = false;
      Toast.show(msg);
      _baseListProvider.setStateType(StateType.order);
    });
  }

  Future loadMore() async {
    if (loadMoreFlag) return;
    if (_baseListProvider.list[_baseListProvider.list.length - 1].nid != -1) {
      loadMoreFlag = true;
      fetchData(_baseListProvider.list[_baseListProvider.list.length - 1].nid);
    } else {
      _baseListProvider.setHasMore(false);
      setState(() {});
      Toast.show("已经到最后了");
    }
  }

  Future _onRefresh() async {
    _baseListProvider.clear();
    fetchData(int.parse(widget.chpId));
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<BaseListProvider<XiaoshuoContent>>(
        create: (_) => _baseListProvider,
        child: Consumer2<BaseListProvider<XiaoshuoContent>, AppStateProvider>(builder: (_, _baseListProvider, appStateProvider, __) {
          return Scaffold(
              backgroundColor: appStateProvider.xsColor,
              body: SafeArea(
                child: Stack(
                  children: <Widget>[
                    // ReaderOverlayer(title: title, page: 1, topSafeHeight: Screen.topSafeHeight),
                    MediaQuery.removePadding(
                        context: context,
                        removeTop: true,
                        child: DeerListView(
                          itemCount: _baseListProvider.list.length,
                          stateType: _baseListProvider.stateType,
                          onRefresh: _onRefresh,
                          hasRefresh: false,
                          pageSize: _baseListProvider.list.length,
                          hasMore: _baseListProvider.hasMore,
                          loadMore: loadMore,
                          itemBuilder: (_, index) {
                            return GestureDetector(
                                onTap: () {
                                  var opacityLevel = _appStateProvider!.opacityLevel == 0 ? 1.0 : 0.0;
                                  _appStateProvider!.setOpcity(opacityLevel);
                                },
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Container(
                                      margin: EdgeInsets.only(left: 10, top: 10),
                                      child: Text(
                                        _baseListProvider.list[index].cname,
                                        style: TextStyle(fontSize: 14, color: Colours.golden),
                                      ),
                                    ),
                                    Container(
                                      color: Colors.transparent,
                                      margin: EdgeInsets.fromLTRB(10, 10, 5, 10),
                                      child: Text.rich(
                                        TextSpan(children: [TextSpan(text: _baseListProvider.list[index].content, style: TextStyle(wordSpacing: -5, fontSize: appStateProvider.xsFontSize, color: appStateProvider.xsColor == Colours.cunhei ? Color(0xff4c4c4c) : Colours.text))]),
                                        textAlign: TextAlign.justify,
                                      ),
                                    ),
                                  ],
                                ));
                          },
                        )),
                    ReaderMenu(title: currentIndex == 0 ? title : _baseListProvider.list[currentIndex].cname, id: currentIndex == 0 ? widget.id : _baseListProvider.list[currentIndex].id, chpId: currentChpid)
                  ],
                ),
              ));
        }));
  }
}
