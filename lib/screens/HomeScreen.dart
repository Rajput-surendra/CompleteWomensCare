import 'dart:async';
import 'dart:convert';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:carousel_slider/carousel_slider.dart';

import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:singleclinic/AllText.dart';
import 'package:singleclinic/main.dart';
import 'package:singleclinic/modals/DoctorsList.dart';
import 'package:singleclinic/screens/BookAppointment.dart';
import 'package:singleclinic/screens/ChatScreen.dart';
import 'package:singleclinic/screens/DoctorDetail.dart';
import 'package:singleclinic/screens/DoctorList.dart';
import 'package:singleclinic/screens/LoginScreen.dart';
import 'package:singleclinic/screens/SearchScreen.dart';
import 'package:http/http.dart'as http;
import 'package:url_launcher/url_launcher.dart';

import '../modals/DocterProfileModel.dart';
import '../modals/GetSliderModel.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with WidgetsBindingObserver {
  DoctorsList doctorsList;
  ScrollController scrollController = ScrollController();
  bool isLoadingMore = false;
  List<InnerData> myList = [];
  SliderModel homeSliderList;
  DocterProfileModel homeDocterProfile;
  int currentindex = 0;
  String nextUrl = "";
  final DatabaseReference databaseReference =
      FirebaseDatabase.instance.reference();
  String myUid = "";
  Timer timer;

  bool isLoggedIn = false;

  @override
  void initState() {
    super.initState();
    fetchDoctorsList();
    getSlider();
     Future.delayed(Duration(seconds: 1),(){
       getDocterProgile();
     }
     );
    SharedPreferences.getInstance().then((value) {
      setState(() {
        isLoggedIn = value.getBool("isLoggedIn") ?? false;
        myUid = value.getString("uid");
      });
    }).then((value) {
      if (myUid != null) {
        updateUserPresence();
      }
    });
    WidgetsBinding.instance.addObserver(this);

    SharedPreferences.getInstance().then((value) {
      String data = value.getString("payload");
      if (data != null) {
        Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) =>
                  ChatScreen(data.split(",")[0], data.split(",")[1]),
            ));
      }
      print("0-> payload : ->${value.getString("payload")}");
    });

    FirebaseMessaging.onMessage.listen((event) async {
      print("\n\nonMessage: $event");
      print("\nchannel: ${event.notification}");
      await SharedPreferences.getInstance().then((value) {
        print(value.get(event.data['uid']) ?? "does not exist");
        if (value.get(event.data['uid']) ?? false) {
          notificationHelper.showMessagingNotification(
              data: event.data, context2: context);
        }
      });
    });

    FirebaseMessaging.onMessageOpenedApp.listen((event) {
      print("\n\nonAppOpened: $event");
      print("\nchannel: ${event.notification}");
      Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) =>
                  ChatScreen(event.notification.title, event.data['uid'])));
    });

    FirebaseMessaging.onBackgroundMessage(myBackgroundMessageHandler);

    scrollController.addListener(() {
      print(scrollController.position.pixels);
      if (scrollController.position.pixels ==
              scrollController.position.maxScrollExtent &&
          !isLoadingMore) {
        print("Loadmore");
        _loadMoreFunc();
      }
    });
    // callApi(){
    //   getSlider();
    //   getDocterProgile();
    // }
  }


  // Future _refresh(){
  //   return callApi();
  // }

  @override
  void dispose() {
    super.dispose();
    print("Dispose called");
    timer.cancel();
    Map<String, dynamic> presenceStatusFalse = {
      'presence': false,
      'last_seen': DateTime.now().toString(),
    };
    databaseReference.child(myUid).onDisconnect().update(presenceStatusFalse);
    WidgetsBinding.instance.removeObserver(this);
  }

  getDocterProgile() async {
    var request = http.Request('GET', Uri.parse('${SERVER_ADDRESS}/api/profile'));
    http.StreamedResponse response = await request.send();

    if (response.statusCode == 200) {
      final result = await response.stream.bytesToString();
      var NewResponce = DocterProfileModel.fromJson(jsonDecode(result));
      print(" this is a responce===========>${NewResponce.toString()}");
      setState(() {
        homeDocterProfile = NewResponce;
        print("this is a responce1111==========>${homeDocterProfile.data}");

      });
    }
    else {
    print(response.reasonPhrase);
    }

  }

  // async {
  //   var request = http.Request('GET', Uri.parse('${SERVER_ADDRESS}/api/profile'));
  //   http.StreamedResponse response = await request.send();
  //
  //   if (response.statusCode == 200) {
  //     final result = await response.stream.bytesToString();
  //     var finalData1 = DocterProfileModel.fromJson(jsonDecode(result));
  //     print("this is a data===>${finalData1.toString()}");
  //     setState(() {
  //       homeDocterProfile = finalData1;
  //       print("this is a data===>${homeDocterProfile.data}");
  //
  //     });
  //   }
  //   else {
  //   print(response.reasonPhrase);
  //   }
  //
  // }

  // var youTube;
  // var facebook;
  // var instagram;
  // var webSetting;

  getSlider() async {
    var request = http.Request('GET', Uri.parse('${SERVER_ADDRESS}/api/sliders'));
    http.StreamedResponse response = await request.send();

    if (response.statusCode == 200) {
      final result = await response.stream.bytesToString();
      var finalData = SliderModel.fromJson(jsonDecode(result));
      print("this is a responce===>${finalData.toString()}");
      setState(() {
        homeSliderList = finalData;

      });
    }
    else {
    print(response.reasonPhrase);
    }

  }
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        backgroundColor: LIGHT_GREY_SCREEN_BG,
        appBar: AppBar(
          backgroundColor: WHITE,
          flexibleSpace: header(),
        ),
        body: body(),
      ),
    );
  }

  header() {
    return SafeArea(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(15, 0, 15, 0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  HOME,
                  style: TextStyle(
                      color: BLACK, fontSize: 25, fontWeight: FontWeight.w800),
                ),
                // InkWell(
                //   onTap: () {
                //     Navigator.push(
                //         context,
                //         MaterialPageRoute(
                //           builder: (context) => SearchScreen(),
                //         ));
                //   },
                //   child: Image.asset(
                //     "assets/homescreen/search_header.png",
                //     height: 25,
                //     width: 25,
                //   ),
                // )
              ],
            ),
          ),
        ],
      ),
    );
  }

  body() {
    return SingleChildScrollView(
      controller: scrollController,
      child: Padding(
        padding: const EdgeInsets.all(10.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              height: 5,
            ),

            homeSliderList == null ? Center(child: CircularProgressIndicator(color: LIME,)):Container(
              height: 180,
              width: double.infinity,
              // width: double.infinity,
              child:  Padding(
                padding:  EdgeInsets.only(top: 18,bottom: 18,left: 0,right: 0),
                child: CarouselSlider(
                  options: CarouselOptions(
                    viewportFraction: 1.0,
                    initialPage: 0,
                    enableInfiniteScroll: true,
                    reverse: false,
                    autoPlay: true,
                    autoPlayInterval: Duration(seconds: 3),
                    autoPlayAnimationDuration:
                    Duration(milliseconds: 150),
                    enlargeCenterPage: false,
                    scrollDirection: Axis.horizontal,
                    height: 180,
                    onPageChanged: (position, reason) {
                      setState(() {
                        currentindex = position;
                      });
                      print(reason);
                      print(CarouselPageChangedReason.controller);
                    },
                  ),
                  items: homeSliderList.data.map((val) {
                    return Container(
                      width: MediaQuery.of(context).size.width,
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(20)
                      ),
                      // height: 180,
                      // width: MediaQuery.of(context).size.width,
                      child: ClipRRect(
                          borderRadius: BorderRadius.circular(20),
                          child: Image.network(
                            "${val.image}",
                            fit: BoxFit.fill,
                          )),
                    );
                  }).toList(),
                ),
              ),
              // ListView.builder(
              //   scrollDirection: Axis.horizontal,
              //   shrinkWrap: true,
              //   //physics: NeverScrollableScrollPhysics(),
              //   itemCount: homeSliderList!.banneritem!.length,
              //   itemBuilder: (context, index) {
              //     return
              //
              //     //   InkWell(
              //     //   onTap: () {
              //     //     // Get.to(ProductListScreen(
              //     //     //     parentScaffoldKey: widget.parentScaffoldKey));
              //     //     widget.callback!.call(11);
              //     //   },
              //     //   child: Image.network("${Urls.imageUrl}${sliderBanner!.banneritem![0].bimg}"),
              //     //   // Container(
              //     //   //   margin: getFirstNLastMergin(index, 5),
              //     //   //   width: MediaQuery.of(context).size.width * 0.8,
              //     //   //   decoration: BoxDecoration(
              //     //   //       color: (index + 1) % 2 == 0
              //     //   //           ? AppThemes.lightRedColor
              //     //   //           : AppThemes.lightYellowColor,
              //     //   //       borderRadius:
              //     //   //           BorderRadius.all(Radius.circular(10))
              //     //   //   ),
              //     //   // ),
              //     // );
              //   },
              // ),
            ),
            SizedBox(
              height: 5,
            ),

            homeDocterProfile == null  || homeDocterProfile == "" ? Text("No Item Found") :Container(
              padding: EdgeInsets.all(5),
              height: 100,
              decoration: BoxDecoration(
                color: WHITE,
                borderRadius: BorderRadius.circular(10)
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Container(
                    height: 90,
                    width: 90,
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                        child: Image.network("${homeDocterProfile.data.image}",fit: BoxFit.fill,)),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(left: 7),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text("${homeDocterProfile.data.name}",style: TextStyle(fontSize: 15,fontWeight: FontWeight.normal),),
                        SizedBox(
                          height: 5,
                        ),
                        Text("${homeDocterProfile.data.email}",style: TextStyle(fontSize: 15,fontWeight: FontWeight.normal),),
                        SizedBox(
                          height: 5,
                        ),
                        Text("${homeDocterProfile.data.phoneNo}",style: TextStyle(fontSize: 15,fontWeight: FontWeight.normal),),

                      ],
                    ),
                  )
                ],
              )

            ),

            SizedBox(
              height: 15,
            ),
            Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                color: WHITE
              ),
              width: double.infinity,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(left: 10,top: 10),
                    child: Text("About Us",style: TextStyle(fontSize: 18,fontWeight: FontWeight.bold,color: BLACK),),
                  ),
                  Divider(),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text("${homeDocterProfile.data.aboutUs}",style: TextStyle(fontSize: 14,fontWeight: FontWeight.normal)),
                  ),
                ],
              )

            ),


            SizedBox(
              height: 5,
            ),
            Container(
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  color: WHITE
              ),
              width: double.infinity,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(left: 10,top: 10),
                    child: Text("Service",style: TextStyle(fontSize: 18,fontWeight: FontWeight.bold,color: BLACK),),
                  ),
                  Divider(),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text("${homeDocterProfile.data.service}",style: TextStyle(fontSize: 14,fontWeight: FontWeight.normal),),
                  ),
                ],
              )
            ),

            SizedBox(
              height: 15,
            ),

            SizedBox(
              height: 5,
            ),
            Container(
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  color: WHITE
              ),
              width: double.infinity,
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("Social Links",style: TextStyle(fontSize: 18,fontWeight: FontWeight.bold,color: BLACK),),
                    Divider(),
                    InkWell(
                      onTap: () =>launch('${homeDocterProfile.data.facebookId}'),
                      child: Row(children: [
                        Icon(Icons.facebook,size: 25,color: Colors.blueAccent,),
                        SizedBox(width: 10,),
                        Text('${homeDocterProfile.data.facebookId}',style: TextStyle(
                          fontSize: 16
                        ),)
                      ],),
                    ),
                    SizedBox(
                      height: 5,
                    ),
                    InkWell(
                      onTap: () =>launch('${homeDocterProfile.data.twitterId}'),
                      child: Row(children: [
                        Image.asset("assets/twitter.png",height: 25,),
                        SizedBox(width: 10,),
                        Text('${homeDocterProfile.data.twitterId}',style: TextStyle(
                            fontSize: 16
                        ),)
                      ],),
                    ),
                    SizedBox(
                      height: 5,
                    ),
                    InkWell(
                      onTap: () =>launch('${homeDocterProfile.data.googleId}'),
                      child: Row(children: [
                        Image.asset("assets/google.png",height: 20,),
                        SizedBox(width: 10,),
                        Padding(
                          padding: const EdgeInsets.only(left: 5),
                          child: Text('${homeDocterProfile.data.googleId}',style: TextStyle(
                              fontSize: 16
                          ),),
                        )
                      ],),
                    ),
                    SizedBox(
                      height: 10,
                    ),
                    InkWell(
                      onTap: () =>launch('${homeDocterProfile.data.instagramId}'),
                      child: Row(children: [
                        Image.asset("assets/instagram.png",height: 20,),
                        SizedBox(width: 10,),
                        Padding(
                          padding: const EdgeInsets.only(left: 5),
                          child: Text('${homeDocterProfile.data.instagramId}',style: TextStyle(
                              fontSize: 16
                          ),),
                        )
                      ],),
                    ),

                  ],
                )
              ),
            ),

            SizedBox(
              height: 15,
            ),
            Container(
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    color: WHITE
                ),
                width: double.infinity,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(left: 10,top: 10),
                      child: Text("Working Hour",style: TextStyle(fontSize: 18,fontWeight: FontWeight.bold,color: BLACK),),
                    ),
                    Divider(),
                    ListView.builder(
                        shrinkWrap: true,
                        scrollDirection: Axis.vertical,
                        physics: ClampingScrollPhysics(),
                        itemCount: homeDocterProfile.data.workingHour.length,
                        // scrollDirection: Axis.vertical,
                        itemBuilder: (context, index) {
                          return Column(
                            children: [

                              Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Container(
                                  width: double.infinity,
                                  decoration: BoxDecoration(
                                    color: WHITE,
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: Column(

                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [

                                      Row(
                                        children: [
                                        Expanded(child: Text("${homeDocterProfile.data.workingHour[index].day}",style: TextStyle(color: BLACK,fontWeight: FontWeight.bold))),

                                          Expanded(
                                            child: Row(
                                              children: [
                                                Text("${homeDocterProfile.data.workingHour[index].from}",style: TextStyle(color: BLACK,fontWeight: FontWeight.bold)),
                                                SizedBox(width: 8,),
                                                Text("To",style: TextStyle(color: BLACK,),),
                                                SizedBox(width: 8,),
                                                Text("${homeDocterProfile.data.workingHour[index].to}",style: TextStyle(color: BLACK,fontWeight: FontWeight.bold))
                                              ],
                                            ),
                                          )
                                         // ${homeDocterProfile.data.workingHour[index].to}")
                                        ],
                                      ),

                                    ],
                                  ),
                                ),
                              )
                            ],
                          );
                        }),
                  ],
                ),

            ),

            InkWell(
              onTap: () {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) =>
                          isLoggedIn ? BookAppointment() : LoginScreen(),
                    ));
              },
              child: Stack(
                children: [
                  Container(
                    margin: EdgeInsets.all(14),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: Image.asset(
                        "assets/homescreen/Book-appointment-banner.png",
                        height: 180,
                        width: MediaQuery.of(context).size.width,
                        fit: BoxFit.fill,

                      ),
                    ),
                  ),
                  Container(
                    margin: EdgeInsets.all(10),
                    height: 180,
                    child: Row(
                      children: [
                        SizedBox(
                          width: 20,
                        ),
                        Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              BOOK,
                              style: TextStyle(
                                  fontSize: 17,
                                  color: WHITE,
                                  fontWeight: FontWeight.w600),
                            ),
                            Text(
                              APPOINTMENT,
                              style: TextStyle(
                                  fontSize: 17,
                                  color: WHITE,
                                  fontWeight: FontWeight.w600),
                            ),
                            SizedBox(
                              height: 10,
                            ),
                            Text(
                              QUICKLY_CREATE_FILES,
                              style: TextStyle(
                                fontSize: 10,
                                color: WHITE,
                              ),
                            ),
                            SizedBox(
                              height: 20,
                            ),
                            Container(
                              width: isLoggedIn ? 120 : 130,
                              height: 28,
                              child: Stack(
                                children: [
                                  Image.asset(
                                    "assets/homescreen/bookappointment.png",
                                    width: isLoggedIn ? 120 : 130,
                                    height: 28,
                                    fit: BoxFit.fill,
                                  ),
                                  Center(
                                    child: Text(
                                      isLoggedIn
                                          ? BOOKAPPOINTMENT
                                          : LOGIN_TO_BOOK_APPOINTMENT,
                                      style: TextStyle(
                                          fontSize: 9,
                                          color: LIME,
                                          fontWeight: FontWeight.w700),
                                    ),
                                  ),
                                ],
                              ),
                            )
                          ],
                        ),
                      ],
                    ),
                  )
                ],
              ),
            ),
            // Padding(
            //   padding: const EdgeInsets.fromLTRB(16, 0, 16, 0),
            //   child: Row(
            //     mainAxisAlignment: MainAxisAlignment.spaceBetween,
            //     children: [
            //       Text(
            //         DOCTOR_LIST,
            //         style: TextStyle(
            //             color: BLACK, fontSize: 17, fontWeight: FontWeight.w700),
            //       ),
            //       InkWell(
            //         onTap: () {
            //           Navigator.push(context,
            //               MaterialPageRoute(builder: (context) => DoctorList()));
            //         },
            //         child: Text(
            //           SEE_ALL,
            //           style: TextStyle(
            //               color: NAVY_BLUE,
            //               fontSize: 13,
            //               fontWeight: FontWeight.w700),
            //         ),
            //       ),
            //     ],
            //   ),
            // ),
            // doctorsList == null
            //     ? Container()
            //     : ListView.builder(
            //         shrinkWrap: true,
            //         itemCount: myList.length,
            //         physics: ClampingScrollPhysics(),
            //         itemBuilder: (context, index) {
            //           return doctorDetailTile(
            //             imageUrl: myList[index].image,
            //             name: myList[index].name,
            //             department: myList[index].departmentName,
            //             aboutUs: myList[index].aboutUs,
            //             id: myList[index].id,
            //           );
            //         },
            //       ),
            // nextUrl != "null"
            //     ? Padding(
            //         padding: const EdgeInsets.all(50.0),
            //         child: CircularProgressIndicator(
            //           strokeWidth: 2,
            //         ),
            //       )
            //     : Container(),
          ],
        ),
      ),
    );
  }

  doctorDetailTile(
      {String imageUrl,
      String name,
      String department,
      String aboutUs,
      int id}) {
    return InkWell(
      onTap: () {
        print("id ${id}");
        Navigator.push(context,
            MaterialPageRoute(builder: (context) => DoctorDetails(id)));
      },
      child: Container(
        decoration: BoxDecoration(
            color: LIGHT_GREY, borderRadius: BorderRadius.circular(10)),
        child: Row(
          children: [
            Padding(
              padding: const EdgeInsets.all(10.0),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: CachedNetworkImage(
                  height: 72,
                  width: 72,
                  fit: BoxFit.cover,
                  imageUrl: Uri.parse(imageUrl).toString(),
                  progressIndicatorBuilder: (context, url, downloadProgress) =>
                      Container(
                          height: 75,
                          width: 75,
                          child: Center(child: Icon(Icons.image))),
                  errorWidget: (context, url, error) => Container(
                    height: 75,
                    width: 75,
                    child: Center(
                      child: Icon(Icons.broken_image_rounded),
                    ),
                  ),
                ),
              ),
            ),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    name,
                    style: TextStyle(
                        color: BLACK,
                        fontSize: 17,
                        fontWeight: FontWeight.w800),
                  ),
                  SizedBox(
                    height: 5,
                  ),
                  Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(3),
                      color: LIME,
                    ),
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(5, 3, 5, 3),
                      child: Text(
                        department,
                        style: TextStyle(
                            color: WHITE,
                            fontSize: 10,
                            fontWeight: FontWeight.w700),
                      ),
                    ),
                  ),
                  SizedBox(
                    height: 5,
                  ),
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          aboutUs,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: LIGHT_GREY_TEXT,
                            fontSize: 10,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            SizedBox(
              width: 16,
            )
          ],
        ),
        margin: EdgeInsets.fromLTRB(16, 6, 16, 6),
      ),
    );
  }

  fetchDoctorsList() async {
    final response = await get(Uri.parse(
        "$SERVER_ADDRESS/api/listofdoctorbydepartment?department_id=0"));
    print(Uri.parse("$SERVER_ADDRESS/api/listofdoctorbydepartment?department_id=0"));

    final jsonResponse = jsonDecode(response.body);

    if (response.statusCode == 200 && jsonResponse['status'] == 1) {
      print(response.body);

      setState(() {
        doctorsList = DoctorsList.fromJson(jsonDecode(response.body));
        myList.addAll(doctorsList.data.data);
        nextUrl = doctorsList.data.nextPageUrl;
      });
    }
  }

  void _loadMoreFunc() async {
    print(nextUrl);
    if (nextUrl != "null" && !isLoadingMore) {
      setState(() {
        isLoadingMore = true;
      });

      final response = await get(
        Uri.parse("$nextUrl&department_id=0"),
      );

      final jsonResponse = jsonDecode(response.body);

      if (response.statusCode == 200 && jsonResponse['status'] == 1) {
        print(response.body);
        doctorsList = DoctorsList.fromJson(jsonDecode(response.body));
        setState(() {
          myList.addAll(doctorsList.data.data);
          nextUrl = doctorsList.data.nextPageUrl;
          isLoadingMore = false;
        });
      }
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) async {
    super.didChangeAppLifecycleState(state);
    print("\n\nLifecycle state $state");

    if (state == AppLifecycleState.resumed) {
      updateUserPresence();
    } else {
      if (timer != null) {
        timer.cancel();
      }
      Map<String, dynamic> presenceStatusFalse = {
        'presence': false,
        'last_seen': DateTime.now().toUtc().toString(),
      };

      if (myUid != null) {
        await databaseReference
            .child(myUid)
            .update(presenceStatusFalse)
            .whenComplete(() => print('Updated your presence.'))
            .catchError((e) => print(e));
      }
    }
  }

  checkIfLoggedInFromAnotherDevice() async {}

  updateUserPresence() async {
    Map<String, dynamic> presenceStatusTrue = {
      'presence': true,
      'last_seen': DateTime.now().toUtc().toString(),
    };

    await databaseReference
        .child(myUid)
        .update(presenceStatusTrue)
        .whenComplete(() => print('Updated your presence.'))
        .catchError((e) => print(e));

    Map<String, dynamic> presenceStatusFalse = {
      'presence': false,
      'last_seen': DateTime.now().toUtc().toString(),
    };

    databaseReference.child(myUid).onDisconnect().update(presenceStatusFalse);
  }

  updatePreferenceAgainAndAgain() {
    Map<String, dynamic> presenceStatusTrue = {
      'presence': true,
      'connections': true,
      'last_seen': DateTime.now().toString(),
    };

    databaseReference.child(myUid).update(presenceStatusTrue).whenComplete(() {
      updateUserPresence();
      print('Updated your presence.');
    }).catchError((e) => print(e));
  }

  alertDialog() {
    return showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) {
          return WillPopScope(
            onWillPop: _willPopScope,
            child: AlertDialog(
              title: Text("Log Out"),
              content: Text("Your account is logged In from another device"),
              actions: [
                TextButton(
                  child: Text("ok"),
                  onPressed: () async {},
                )
              ],
            ),
          );
        });
  }

  Future<bool> _willPopScope() async {
    Navigator.popUntil(context, (route) => route.isFirst);
    Navigator.pushReplacement(
        context, MaterialPageRoute(builder: (context) => LoginScreen()));
    return false;
  }
}
