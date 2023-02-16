import 'dart:convert';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:singleclinic/AllText.dart';
import 'package:singleclinic/main.dart';
import 'package:singleclinic/modals/UpcomingAppointmrnts.dart';
import 'package:singleclinic/screens/ChatScreen.dart';
import 'package:http/http.dart'as http;
import 'package:url_launcher/url_launcher.dart';

import '../modals/DocterProfileModel.dart';

class AppointmentDetailScreen extends StatefulWidget {
  InnerData upcomingList;
  AppointmentDetailScreen({this.upcomingList});




  @override
  State<AppointmentDetailScreen> createState() => _AppointmentDetailScreenState();
}

class _AppointmentDetailScreenState extends State<AppointmentDetailScreen> {

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    Future.delayed(Duration(seconds: 1),(){
      return getProfile();
    });
  }

  DocterProfileModel  homeDocterProfile;

  getProfile() async {
    var request = http.Request('GET', Uri.parse('${SERVER_ADDRESS}/api/profile'));
    http.StreamedResponse response = await request.send();

    if (response.statusCode == 200) {
      final result = await response.stream.bytesToString();
      var NewResponce = DocterProfileModel.fromJson(jsonDecode(result));
      print("this is a responce1111111===========>${NewResponce.toString()}");
      setState(() {
        homeDocterProfile = NewResponce;
        //print("this is a new==========>${homeDocterProfile.data.email}");

      });
    }
    else {
      print(response.reasonPhrase);
    }

  }
  @override
  Widget build(BuildContext context) {
    return widget.upcomingList == null
        ? Container(
      child: Center(
        child: CircularProgressIndicator(
          strokeWidth: 2,
        ),
      ),
      color: WHITE,
    )
        : SafeArea(
      child: Scaffold(
        backgroundColor: LIGHT_GREY_SCREEN_BG,
        appBar: AppBar(
          leading: Container(),
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
            padding: const EdgeInsets.fromLTRB(15, 0, 10, 0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  width: MediaQuery.of(context).size.width * 0.67,
                  child: Row(
                    // crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      IconButton(
                        icon: Icon(
                          Icons.arrow_back_ios,
                          size: 18,
                          color: BLACK,
                        ),
                        constraints: BoxConstraints(maxWidth: 30, minWidth: 10),
                        padding: EdgeInsets.zero,
                        onPressed: () {
                          Navigator.pop(context);
                        },
                      ),
                      SizedBox(
                        width: 5,
                      ),
                      Center(
                        child: Container(
                          width: MediaQuery.of(context).size.width * 0.57,
                          child: Text(
                            widget.upcomingList.doctorName,
                            style: TextStyle(
                              color: BLACK, fontSize: 22, fontWeight: FontWeight.w800,
                              overflow: TextOverflow.ellipsis,
                            ),
                            // textAlign: TextAlign.center,
                            maxLines: 1,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    InkWell(
                      onTap: () => launch('${homeDocterProfile.data.phoneNo}'),
                      child: Image.asset(
                        "assets/doctordetails/Phone.png",
                        height: 40,
                        width: 40,
                        fit: BoxFit.fill,
                      ),
                    ),
                    SizedBox(
                      width: 5,
                    ),
                    InkWell(
                     onTap: () => launch('${homeDocterProfile.data.email}'),
                      // {
                      //    _sendEmail(doctorDetail.data.email);
                      // },
                      child: Image.asset(
                        "assets/doctordetails/email.png",
                        height: 40,
                        width: 40,
                        fit: BoxFit.fill,
                      ),
                    ),
                  ],
                )
              ],
            ),
          ),
        ],
      ),
    );
  }

  body() {
    return Column(
      children: [
        Expanded(
          child: SingleChildScrollView(
            child: Column(
              children: [
                doctorProfileCard(),
                workingTimeAndServiceCard(),
              ],
            ),
          ),
        ),
        //bottomButtons(),
      ],
    );
  }

  doctorProfileCard() {
    return Container(
      margin: EdgeInsets.all(16),
      padding: EdgeInsets.all(10),
      decoration: BoxDecoration(
          color: Colors.white, borderRadius: BorderRadius.circular(10)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(15),
                  child: CachedNetworkImage(
                    height: 90,
                    width: 110,
                    fit: BoxFit.cover,
                    imageUrl: Uri.parse(widget.upcomingList.image).toString(),
                    progressIndicatorBuilder:
                        (context, url, downloadProgress) => Container(
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
              SizedBox(
                width: 15,
              ),
              Expanded(
                child: Container(
                  height: 90,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            widget.upcomingList.doctorName,
                            style: TextStyle(fontWeight: FontWeight.w800, fontSize: 16),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          // SizedBox(height: 8,),
                          Text(
                            widget.upcomingList.departmentName,
                            style: TextStyle(color: NAVY_BLUE, fontSize: 10),
                          ),
                          SizedBox(height: 7,),
                          Text(
                            widget.upcomingList.date.toString() + " " + widget.upcomingList.time.toString(),
                            style: TextStyle(color: NAVY_BLUE, fontSize: 10),
                          ),
                          SizedBox(height: 6,),
                          Container(
                            height: 15,
                            width: 50,
                            decoration: BoxDecoration(
                              color: LIME,
                              borderRadius: BorderRadius.circular(5),
                            ),
                            child: Center(
                              child: Text(
                                widget.upcomingList.status,
                                style: TextStyle(color: WHITE, fontSize: 8),
                              ),
                            ),
                          )
                        ],
                      ),
                      // InkWell(
                      //   onTap: () {
                      //     Navigator.push(
                      //         context,
                      //         MaterialPageRoute(
                      //             builder: (context) => ReviewScreen(
                      //                 doctorDetail.data.userId.toString())));
                      //   },
                      //   child: Column(
                      //     mainAxisAlignment: MainAxisAlignment.start,
                      //     crossAxisAlignment: CrossAxisAlignment.start,
                      //     children: [
                      //       Row(
                      //         children: [
                      //           Image.asset(
                      //             doctorDetail.data.ratting > 0
                      //                 ? "assets/doctordetails/star_active.png"
                      //                 : "assets/doctordetails/star_unactive.png",
                      //             height: 12,
                      //             width: 12,
                      //
                      //           ),
                      //           SizedBox(
                      //             width: 5,
                      //           ),
                      //           Image.asset(
                      //             doctorDetail.data.ratting > 1
                      //                 ? "assets/doctordetails/star_active.png"
                      //                 : "assets/doctordetails/star_unactive.png",
                      //             height: 12,
                      //             width: 12,
                      //           ),
                      //           SizedBox(
                      //             width: 5,
                      //           ),
                      //           Image.asset(
                      //             doctorDetail.data.ratting > 2
                      //                 ? "assets/doctordetails/star_active.png"
                      //                 : "assets/doctordetails/star_unactive.png",
                      //             height: 12,
                      //             width: 12,
                      //           ),
                      //           SizedBox(
                      //             width: 5,
                      //           ),
                      //           Image.asset(
                      //             doctorDetail.data.ratting > 3
                      //                 ? "assets/doctordetails/star_active.png"
                      //                 : "assets/doctordetails/star_unactive.png",
                      //             height: 12,
                      //             width: 12,
                      //           ),
                      //           SizedBox(
                      //             width: 5,
                      //           ),
                      //           Image.asset(
                      //             doctorDetail.data.ratting > 4
                      //                 ? "assets/doctordetails/star_active.png"
                      //                 : "assets/doctordetails/star_unactive.png",
                      //             height: 12,
                      //             width: 12,
                      //           ),
                      //         ],
                      //       ),
                      //       SizedBox(
                      //         height: 2,
                      //       ),
                      //       Text(
                      //         "See all reviews",
                      //         style:
                      //         TextStyle(color: LIGHT_GREY_TEXT, fontSize: 10),
                      //       ),
                      //     ],
                      //   ),
                      // ),
                      // Row(
                      //   children: [
                      //     GestureDetector(
                      //       onTap: () {
                      //         _launchURL(doctorDetail.data.facebookId);
                      //       },
                      //       child: Image.asset(
                      //         "assets/doctordetails/facebook.png",
                      //         height: 15,
                      //         width: 15,
                      //       ),
                      //     ),
                      //     SizedBox(
                      //       width: 7,
                      //     ),
                      //     GestureDetector(
                      //       onTap: () {
                      //         _launchURL(doctorDetail.data.twitterId);
                      //       },
                      //       child: Image.asset(
                      //         "assets/doctordetails/twitter.png",
                      //         height: 15,
                      //         width: 15,
                      //       ),
                      //     ),
                      //     SizedBox(
                      //       width: 7,
                      //     ),
                      //     GestureDetector(
                      //       onTap: () {
                      //         _launchURL(doctorDetail.data.googleId);
                      //       },
                      //       child: Image.asset(
                      //         "assets/doctordetails/google+.png",
                      //         height: 15,
                      //         width: 15,
                      //       ),
                      //     ),
                      //     SizedBox(
                      //       width: 7,
                      //     ),
                      //     GestureDetector(
                      //       onTap: () {
                      //         _launchURL(doctorDetail.data.instagramId);
                      //       },
                      //       child: Image.asset(
                      //         "assets/doctordetails/instagram.png",
                      //         height: 15,
                      //         width: 15,
                      //       ),
                      //     ),
                      //   ],
                      // )
                    ],
                  ),
                ),
              )
            ],
          ),
          SizedBox(
            height: 10,
          ),
          // Text(
          //   doctorDetail.data.aboutUs,
          //   style: TextStyle(color: LIGHT_GREY_TEXT, fontSize: 11),
          //   textAlign: TextAlign.justify,
          // ),
        ],
      ),
    );
  }

  workingTimeAndServiceCard() {
    return Container(
      color: WHITE,
      width: MediaQuery.of(context).size.width,
      height: MediaQuery.of(context).size.height,
      padding: EdgeInsets.all(16),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              WORKING_TIME,
              style: TextStyle(fontWeight: FontWeight.w700, fontSize: 19),
            ),
            SizedBox(
              height: 5,
            ),
            Text(
              widget.upcomingList.date.toString() + "" + widget.upcomingList.time.toString(),
              style: TextStyle(fontSize: 13, color: LIGHT_GREY_TEXT),
              textAlign: TextAlign.justify,
            ),
            SizedBox(
              height: 15,
            ),
            Text(
              SERVICES,
              style: TextStyle(fontWeight: FontWeight.w700, fontSize: 19),
            ),
            SizedBox(
              height: 5,
            ),
            Text(
              widget.upcomingList.serviceName.toString(),
              style: TextStyle(fontSize: 13, color: LIGHT_GREY_TEXT),
              textAlign: TextAlign.justify,
            ),
            SizedBox(
              height: 15,
            ),
            Text(
              DEPARTMENTS,
              style: TextStyle(fontWeight: FontWeight.w700, fontSize: 19),
            ),
            SizedBox(
              height: 5,
            ),
            Text(
              widget.upcomingList.departmentName.toString(),
              style: TextStyle(fontSize: 13, color: LIGHT_GREY_TEXT),
              textAlign: TextAlign.justify,
            ),
            SizedBox(
              height: 15,
            ),
            Text(
              MESSAGE,
              style: TextStyle(fontWeight: FontWeight.w700, fontSize: 19),
            ),
            SizedBox(
              height: 5,
            ),
            Text(
              widget.upcomingList.messages.toString(),
              style: TextStyle(fontSize: 13, color: LIGHT_GREY_TEXT),
              textAlign: TextAlign.justify,
            ),
            SizedBox(
              height: 15,
            ),
            Text(
              STATUS,
              style: TextStyle(fontWeight: FontWeight.w700, fontSize: 19),
            ),
            SizedBox(
              height: 5,
            ),
            Text(
              widget.upcomingList.status.toString(),
              style: TextStyle(fontSize: 13, color: LIGHT_GREY_TEXT),
              textAlign: TextAlign.justify,
            ),
            SizedBox(
              height: 20,
            ),
          ],
        ),
      ),
    );
  }

  bottomButtons() {
    return Container(
      color: Colors.white,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // SizedBox(
          //   width: 10,
          // ),
          InkWell(
            onTap: () {
              print("upcomingList ${widget.upcomingList}");
              print("doctorDetail.data.userId ${widget.upcomingList.userId}");
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => ChatScreen(
                          widget.upcomingList.doctorName,
                          widget.upcomingList.doctorId.toString())));
            },
            child: Container(
              margin: EdgeInsets.fromLTRB(6, 5, 12, 15),
              height: 50,
              width: MediaQuery.of(context).size.width * 0.9,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(25),
                color: LIME,
              ),
              child: Center(
                child: Text(
                  CHAT_WITH_DOCTOR,
                  style: TextStyle(fontWeight: FontWeight.w700, fontSize: 17, color: WHITE),
                ),
              ),
            ),
          )
        ],
      ),
    );
  }

}
