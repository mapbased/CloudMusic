import 'dart:async';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:date_format/date_format.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_app/base/CommonLoading.dart';
import 'package:flutter_app/base/res/gaps.dart';
import 'package:flutter_app/base/res/styles.dart';
import 'package:flutter_app/data/api/apis.dart';
import 'package:flutter_app/data/protocol/banner_model.dart';
import 'package:flutter_app/net/huyi_android_api.dart';
import 'package:flutter_app/pages/find/widget/FindBanner.dart';
import 'package:flutter_app/pages/find/widget/LearnInkWell.dart';
import 'package:flutter_app/pages/find/widget/SpinKitWaveType.dart';
import 'package:flutter_app/pages/leaderboard/LeaderboardPage.dart';
import 'package:flutter_app/pages/my/PageMy.dart';
import 'package:flutter_app/pages/page_songlist.dart';
import 'package:flutter_app/pages/radio/page_radio.dart';
import 'package:flutter_app/pages/user/page_user_detail.dart';
import 'package:flutter_app/widget/ListItemCustom.dart';
import 'package:flutter_app/widget/base_song_img_item.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_swiper/flutter_swiper.dart';

import 'FutureBuilderPage.dart';

class FindPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _FindPageState();
}

class _FindPageState extends State<FindPage>
    with AutomaticKeepAliveClientMixin {
  List<Banners> _bannerData = [];
  List widgets = [];

  @override
  void dispose() {
    super.dispose();
  }

  @override
  void initState() {
    getHttp();
    getSongListRecommend();
    super.initState();
  }

  Future getHttp() async {
    var dio = Dio();
    var response =
        await dio.get("http://www.mocky.io/v2/5cee0154300000592c6e9825");

    List<Banners> banners = BannerModel.fromJson(response.data).banners;

    _bannerData = banners;
    if (banners != null && mounted) {
      setState(() {
        _bannerData = banners;
      });
    }
  }

  Future getSongListRecommend() async {
    Map<String, dynamic> formData = {
      'limit': 6,
    };
    var response = await Http()
        .get(MusicApi.SONGLISTDRECOMMEND, queryParameters: formData);
    print(response);
    List rows = response.data['result'];
    widgets = rows;
    setState(() {});
  }

  List imageList = [
    'https://ss3.bdstatic.com/70cFv8Sh_Q1YnxGkpoWK1HF6hhy/it/u=500542857,4026327610&fm=26&gp=0.jpg',
  ];

  @override
  Widget build(BuildContext context) {
    var i = 1; //排行榜名次
    return RefreshIndicator(
      onRefresh: () async {
        getHttp();
      },
//      child: CustomScrollView(slivers: _listWidget(context)),
      child: ListView(
        children: <Widget>[
          FindBanner(bannerData: _bannerData),
          _buildMenu(context),
          Container(
            height: 100, // 高度
            child: new Swiper(
              itemBuilder: (BuildContext context, int index) {
                return new Image.network(
                  "http://via.placeholder.com/288x188",
                  fit: BoxFit.fill,
                );
              },
              itemCount: 3,
              viewportFraction: 0.333,
              scale: 0.4,
            ),
          ),
          Divider(
            height: 1,
            color: Colors.grey[300],
          ),
          _Header("推荐歌单", () {}),
          Container(
//            padding: EdgeInsets.only(left: 15, right: 0),
            height: 200,
            child: ListView(
              scrollDirection: Axis.horizontal,
              children: [
                Gaps.hGap15,
                Row(
                  children: widgets.map<Widget>((p) {
                    i++;
                    return Row(
                      children: [
                        BaseImgItem(
                          id: p['id'],
                          width: 120,
                          playCount: p['playCount'],
                          img: p['picUrl'],
                          describe: p['name'],
                        ),
                        i == widgets.length + 1 ? Gaps.hGap15 : Gaps.hGap8,
                      ],
                    );
                  }).toList(),
                ),
              ],
            ),
          ),
          NewSongAndDiscWidget(),
        ],
      ),
    );
  }

  @override
  bool get wantKeepAlive => true;
}

List<int> getDataList(int count) {
  List<int> list = [];
  for (int i = 0; i < count; i++) {
    list.add(i);
  }
  return list;
}

List<Widget> getWidgetList(List list) {
  return getDataList(list.length)
      .map((item) => getItemContainer(list[item]['picUrl']))
      .toList();
}

Widget getItemContainer(String picUrl) {
  return ListItemCustom(img: picUrl);
}

class _Header extends StatelessWidget {
  final String text;
  final GestureTapCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Container(
//      padding: EdgeInsets.only(top: 10, bottom: 10),
      margin: EdgeInsets.only(top: 20, bottom: 6),
      child: Stack(
        children: <Widget>[
          Positioned(
              child: Container(
            margin: EdgeInsets.only(
              left: 10,
            ),
            child: Text(
              text,
              style: Theme.of(context)
                  .textTheme
                  .subtitle1
                  .copyWith(fontWeight: FontWeight.w800, fontSize: 18),
            ),
          )),
          Positioned(
              right: 15,
              child: Container(
                padding: EdgeInsets.only(top: 2, bottom: 2, left: 6, right: 6),
                decoration: new BoxDecoration(
                  border: new Border.all(color: Colors.grey, width: 0.5),
                  // 边色与边宽度

                  // 底色
                  //        shape: BoxShape.circle, // 圆形，使用圆形时不可以使用borderRadius
                  shape: BoxShape.rectangle,
                  // 默认值也是矩形
                  borderRadius: new BorderRadius.circular((20.0)), // 圆角度
                ),
                margin: EdgeInsets.only(
                  left: 10,
                ),
                child: Text(
                  '歌单广场',
                  style: Theme.of(context)
                      .textTheme
                      .subtitle1
                      .copyWith(fontWeight: FontWeight.w800, fontSize: 14),
                ),
              )),
        ],
      ),
    );
  }

  _Header(this.text, this.onTap);
}

_buildMenu(BuildContext context) {
  return Container(
    padding: EdgeInsets.only(top: 15, bottom: 15),
//            color: Colors.green,
    child: Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        //将自由空间均匀地放置在孩子之间以及第一个和最后一个孩子之前和之后
        children: [
          InkWell(
            child: ListItem(
                image: "images/find/t_dragonball_icn_daily.png", text: "每日推荐"),
            onTap: () {
              Navigator.of(context)
                  .push(MaterialPageRoute(builder: (BuildContext context) {
                return NestedScrollDemoPage();
              }));
            },
          ),
          InkWell(
            child: ListItem(
                image: "images/find/t_dragonball_icn_playlist.png", text: "歌单"),
            onTap: () {
              Navigator.of(context)
                  .push(MaterialPageRoute(builder: (BuildContext context) {
                return SongListPage();
              }));
            },
          ),
          InkWell(
            child: ListItem(
                image: "images/find/t_dragonball_icn_rank.png", text: "排行榜"),
            onTap: () {
              Navigator.of(context)
                  .push(MaterialPageRoute(builder: (BuildContext context) {
                return LeaderBoardPage();
              }));
            },
          ),
          InkWell(
            child: ListItem(
                image: "images/find/t_dragonball_icn_radio.png", text: "电台"),
            onTap: () {
              Navigator.of(context)
                  .push(MaterialPageRoute(builder: (BuildContext context) {
                return RadioPage();
              }));
            },
          ),
          InkWell(
            child: ListItem(
                image: "images/find/t_dragonball_icn_look.png", text: "直播"),
            onTap: () {
              Navigator.of(context)
                  .push(MaterialPageRoute(builder: (BuildContext context) {
                return UserDetailPage();
              }));
            },
          ),
        ]),
  );
}

class ListItem extends StatelessWidget {
  final String text;
  final String image;

  ListItem({this.image, this.text});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        Container(
          width: 40.0,
          decoration: BoxDecoration(
            //圆形渐变
            color: Colors.white,
            shape: BoxShape.circle,
            gradient: const LinearGradient(colors: [
              Colors.redAccent,
              Colors.redAccent,
              Colors.red,
            ]),
          ),
          child: Image.asset(
            image,
            color: Colors.white,
            width: 50,
          ),
        ),
        Container(
            margin: EdgeInsets.only(top: 5), //上边距
            child: Text(text,
                style: TextStyle(
                  fontSize: 12,
                )))
      ],
    );
  }
}

//新歌和新碟
class NewSongAndDiscWidget extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return NewSongAndDiscWidgetState();
  }
}

class NewSongAndDiscWidgetState extends State<NewSongAndDiscWidget> {
  bool isNewSong = true; //新歌
  List _newSong = [];
  List _newAlbum = [];

  @override
  void initState() {
    getNewSongList();
    getNewAlbumList();
    super.initState();
  }

  Future getNewSongList() async {
    Map<String, dynamic> formData = {
      'limit': 6,
    };
    var response =
        await Http().get(MusicApi.NewSong, queryParameters: formData);
    print(response);
    List rows = response.data['result'];
    _newSong = rows;
    setState(() {});
  }

  //新碟
  Future getNewAlbumList() async {
//    Map<String, dynamic> formData = {
//      'limit': 6,
//    };
    var response = await Http().get(MusicApi.NewAlbum);
    print(response);
    List rows = response.data['albums'];
    _newAlbum = rows;
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final width = size.width;
    final height = size.height;
    print('width is $width; height is $height');
    String getText(Map tracks) {
      StringBuffer stringBuffer = new StringBuffer();

      String name = tracks['song']['album']['name'];
      stringBuffer.write(name);
      List artists = tracks['song']['album']['artists'];
      var length = artists.length;
      if (length > 0) {
        stringBuffer.write('-');
      }
      artists.forEach((item) {
        if (length == 1) {
          stringBuffer.write(item['name']);
        }
        if (length > 1) {
          stringBuffer.write(item['name']);
          stringBuffer.write('/');
        }

        length--;
      });

      return stringBuffer.toString();
    }

    return Container(
      child: Column(
        children: [
          Container(
            margin: EdgeInsets.only(left: 15, right: 15),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                InkWell(
                  child: Text(
                    '新歌',
                    style: isNewSong
                        ? TextStyles.textBoldDark16
                        : TextStyles.textDark16,
                  ),
                  onTap: () {
                    isNewSong = !isNewSong;
                    setState(() {});
                  },
                ),
                Container(
                  margin: EdgeInsets.only(left: 5, right: 5),
                  color: Colors.grey,
                  height: 15,
                  width: 1,
                ),
                InkWell(
                  child: Text(
                    '新碟',
                    style: isNewSong
                        ? TextStyles.textDark16
                        : TextStyles.textBoldDark16,
                  ),
                  onTap: () {
                    isNewSong = !isNewSong;
                    setState(() {});
                  },
                ),
                Spacer(),
                Container(
                  padding:
                      EdgeInsets.only(left: 15, right: 15, top: 5, bottom: 5),
                  child: Text(
                    isNewSong ? '更多新歌' : '更多新碟',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.black,
                    ),
                  ),
                  decoration: BoxDecoration(
                    shape: BoxShape.rectangle, // 默认值也是矩形
                    borderRadius: BorderRadius.circular((20.0)), // 圆角度
                    border: Border.all(color: Colors.grey, width: 0.5),
                  ),
                ),
              ],
            ),
          ),
          Visibility(
            visible: isNewSong,
            child: Container(
              height: 200,
              child: PageView(
                controller: PageController(
                    initialPage: 0, viewportFraction: (width - 30) / width),
                children: TestDatas.map((color) {
                  return Container(
                    width: 100,
                    height: 200,
//                  color: color,
                    child: Column(
                      children: _newSong.sublist(0, 3).map((e) {
                        return Container(
                          height: 60,
                          child: Row(
                            mainAxisSize: MainAxisSize.max,
                            children: <Widget>[
                              Center(
                                  child: Container(
                                width: 40,
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(circular),
                                  child: CachedNetworkImage(
                                    fit: BoxFit.fill,
                                    imageUrl: e['picUrl'],
                                    placeholder: (context, url) =>
                                        ProgressView(),
                                    errorWidget: (context, url, error) =>
                                        Icon(Icons.error),
                                  ),
                                ),
                              )),
                              Expanded(
                                child: Container(
//                                color: Colors.amberAccent,
                                  padding: EdgeInsets.only(
                                      top: 10, bottom: 10, left: 8),
                                  child: Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      //将自由空间均匀地放置在孩子之间以及第一个和最后一个孩子之前和之后
                                      children: [
                                        Expanded(
                                          child: Container(
//                      color: Colors.green,
                                              child: Center(
                                            child: Align(
                                              alignment:
                                                  FractionalOffset.centerLeft,
                                              child: Text(
                                                e['name'],
                                                style: TextStyle(
                                                    fontSize: 12,
                                                    color: Colors.black),
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                            ),
                                          )),
                                        ),
                                        Expanded(
                                          child: Container(
//                                            color: Colors.green,
                                              child: Center(
                                            child: Align(
                                              alignment:
                                                  FractionalOffset.centerLeft,
                                              child: Text(
                                                getText(e),
                                                style: TextStyle(
                                                    fontSize: 8,
                                                    color: Colors.grey[600]),
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                            ),
                                          )),
                                        ),
                                      ]),
                                ),
                              ),
                              Container(
                                margin: EdgeInsets.only(right: 15),
                                child: Image.asset(
                                  'images/album/track_mv.png',
                                  width: 25,
                                ),
                              ),
                            ],
                          ),
                        );
                      }).toList(),
                    ),
                  );
                }).toList(),
              ),
            ),
          ),
          Visibility(
            visible: !isNewSong,
            child: Container(
              height: 200,
              child: PageView(
                controller: PageController(
                    initialPage: 0, viewportFraction: (width - 30) / width),
                children: [
                  Container(
                    width: 100,
                    height: 200,
//                  color: color,
                    child: Column(
                      children: _newAlbum.sublist(0, 3).map((e) {
                        return Container(
                          height: 60,
                          child: Row(
                            mainAxisSize: MainAxisSize.max,
                            children: <Widget>[
                              Center(
                                  child: Container(
                                width: 40,
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(circular),
                                  child: CachedNetworkImage(
                                    fit: BoxFit.fill,
                                    imageUrl: e['blurPicUrl'],
                                    placeholder: (context, url) =>
                                        ProgressView(),
                                    errorWidget: (context, url, error) =>
                                        Icon(Icons.error),
                                  ),
                                ),
                              )),
                              Expanded(
                                child: Container(
//                                color: Colors.amberAccent,
                                  padding: EdgeInsets.only(
                                      top: 10, bottom: 10, left: 8),
                                  child: Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      //将自由空间均匀地放置在孩子之间以及第一个和最后一个孩子之前和之后
                                      children: [
                                        Expanded(
                                          child: Container(
//                      color: Colors.green,
                                              child: Center(
                                            child: Align(
                                              alignment:
                                                  FractionalOffset.centerLeft,
                                              child: Text(
                                                e['name'],
                                                style: TextStyle(
                                                    fontSize: 12,
                                                    color: Colors.black),
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                            ),
                                          )),
                                        ),
                                        Expanded(
                                          child: Container(
//                                            color: Colors.green,
                                              child: Center(
                                            child: Align(
                                              alignment:
                                                  FractionalOffset.centerLeft,
                                              child: Text(
                                                e['artist']['name'],
                                                style: TextStyle(
                                                    fontSize: 8,
                                                    color: Colors.grey[600]),
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                            ),
                                          )),
                                        ),
                                      ]),
                                ),
                              ),
                            ],
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                  Container(
                    width: 100,
                    height: 200,
//                  color: color,
                    child: Column(
                      children: _newAlbum.sublist(3, 6).map((e) {
                        return Container(
                          height: 60,
                          child: Row(
                            mainAxisSize: MainAxisSize.max,
                            children: <Widget>[
                              Center(
                                  child: Container(
                                width: 40,
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(circular),
                                  child: CachedNetworkImage(
                                    fit: BoxFit.fill,
                                    imageUrl: e['blurPicUrl'],
                                    placeholder: (context, url) =>
                                        ProgressView(),
                                    errorWidget: (context, url, error) =>
                                        Icon(Icons.error),
                                  ),
                                ),
                              )),
                              Expanded(
                                child: Container(
//                                color: Colors.amberAccent,
                                  padding: EdgeInsets.only(
                                      top: 10, bottom: 10, left: 8),
                                  child: Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      //将自由空间均匀地放置在孩子之间以及第一个和最后一个孩子之前和之后
                                      children: [
                                        Expanded(
                                          child: Container(
//                      color: Colors.green,
                                              child: Center(
                                            child: Align(
                                              alignment:
                                                  FractionalOffset.centerLeft,
                                              child: Text(
                                                e['name'],
                                                style: TextStyle(
                                                    fontSize: 12,
                                                    color: Colors.black),
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                            ),
                                          )),
                                        ),
                                        Expanded(
                                          child: Container(
//                                            color: Colors.green,
                                              child: Center(
                                            child: Align(
                                              alignment:
                                                  FractionalOffset.centerLeft,
                                              child: Text(
                                                e['artist']['name'],
                                                style: TextStyle(
                                                    fontSize: 8,
                                                    color: Colors.grey[600]),
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                            ),
                                          )),
                                        ),
                                      ]),
                                ),
                              ),
                            ],
                          ),
                        );
                      }).toList(),
                    ),
                  )
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class PagingScrollPhysics extends ScrollPhysics {
  final double itemDimension; // ListView children item 固定宽度
  final double leadingSpacing; // 选中 item 离左边缘留白
  final double maxSize; // 最大可滑动区域

  PagingScrollPhysics(
      {this.maxSize,
      this.leadingSpacing,
      this.itemDimension,
      ScrollPhysics parent})
      : super(parent: parent);

  @override
  PagingScrollPhysics applyTo(ScrollPhysics ancestor) {
    return PagingScrollPhysics(
        maxSize: maxSize,
        itemDimension: itemDimension,
        leadingSpacing: leadingSpacing,
        parent: buildParent(ancestor));
  }

  double _getPage(ScrollPosition position, double leading) {
    return (position.pixels + leading) / itemDimension;
  }

  double _getPixels(double page, double leading) {
    return (page * itemDimension) - leading;
  }

  double _getTargetPixels(
    ScrollPosition position,
    Tolerance tolerance,
    double velocity,
    double leading,
  ) {
    double page = _getPage(position, leading);

    if (position.pixels < 0) {
      return 0;
    }

    if (position.pixels >= maxSize) {
      return maxSize;
    }

    if (position.pixels > 0) {
      if (velocity < -tolerance.velocity) {
        page -= 0.5;
      } else if (velocity > tolerance.velocity) {
        page += 0.5;
      }
      return _getPixels(page.roundToDouble(), leading);
    }
  }

  @override
  Simulation createBallisticSimulation(
      ScrollMetrics position, double velocity) {
    // If we're out of range and not headed back in range, defer to the parent
    // ballistics, which should put us back in range at a page boundary.

    if ((velocity <= 0.0 && position.pixels <= position.minScrollExtent))
      return super.createBallisticSimulation(position, velocity);

    final Tolerance tolerance = this.tolerance;

    final double target =
        _getTargetPixels(position, tolerance, velocity, leadingSpacing);
    if (target != position.pixels)
      return ScrollSpringSimulation(spring, position.pixels, target, velocity,
          tolerance: tolerance);
    return null;
  }

  @override
  bool get allowImplicitScrolling => false;
}

const List<int> TestDatas = const <int>[
  0,
  1,
];
