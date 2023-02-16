class DocterProfileModel {
  int status;
  String msg;
  Data data;

  DocterProfileModel({this.status, this.msg, this.data});

  DocterProfileModel.fromJson(Map<String, dynamic> json) {
    status = json['status'];
    msg = json['msg'];
    data = json['data'] != null?  new Data.fromJson(json['data']) : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['status'] = this.status;
    data['msg'] = this.msg;
    if (this.data != null) {
      data['data'] = this.data?.toJson();
    }
    return data;
  }
}

class Data {
  int id;
  int userId;
  int departmentId;
  String name;
  String email;
  String password;
  String phoneNo;
  List<WorkingHour> workingHour;
  String aboutUs;
  String service;
  String image;
  String facebookId;
  String twitterId;
  String googleId;
  String instagramId;
  String createdAt;
  String updatedAt;

  Data(
      {this.id,
        this.userId,
        this.departmentId,
        this.name,
        this.email,
        this.password,
        this.phoneNo,
        this.workingHour,
        this.aboutUs,
        this.service,
        this.image,
        this.facebookId,
        this.twitterId,
        this.googleId,
        this.instagramId,
        this.createdAt,
        this.updatedAt});

  Data.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    userId = json['user_id'];
    departmentId = json['department_id'];
    name = json['name'];
    email = json['email'];
    password = json['password'];
    phoneNo = json['phone_no'];
    if (json['working_hour'] != null) {
      workingHour = <WorkingHour>[];
      json['working_hour'].forEach((v) {
        workingHour?.add(new WorkingHour.fromJson(v));
      });
    }
    aboutUs = json['about_us'];
    service = json['service'];
    image = json['image'];
    facebookId = json['facebook_id'];
    twitterId = json['twitter_id'];
    googleId = json['google_id'];
    instagramId = json['instagram_id'];
    createdAt = json['created_at'];
    updatedAt = json['updated_at'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['user_id'] = this.userId;
    data['department_id'] = this.departmentId;
    data['name'] = this.name;
    data['email'] = this.email;
    data['password'] = this.password;
    data['phone_no'] = this.phoneNo;
    if (this.workingHour != null) {
      data['working_hour'] = this.workingHour?.map((v) => v.toJson()).toList();
    }
    data['about_us'] = this.aboutUs;
    data['service'] = this.service;
    data['image'] = this.image;
    data['facebook_id'] = this.facebookId;
    data['twitter_id'] = this.twitterId;
    data['google_id'] = this.googleId;
    data['instagram_id'] = this.instagramId;
    data['created_at'] = this.createdAt;
    data['updated_at'] = this.updatedAt;
    return data;
  }
}

class WorkingHour {
  int id;
  int doctorId;
  String day;
  String from;
  String to;
  String createdAt;
  String updatedAt;

  WorkingHour(
      {this.id,
        this.doctorId,
        this.day,
        this.from,
        this.to,
        this.createdAt,
        this.updatedAt});

  WorkingHour.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    doctorId = json['doctor_id'];
    day = json['day'];
    from = json['from'];
    to = json['to'];
    createdAt = json['created_at'];
    updatedAt = json['updated_at'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['doctor_id'] = this.doctorId;
    data['day'] = this.day;
    data['from'] = this.from;
    data['to'] = this.to;
    data['created_at'] = this.createdAt;
    data['updated_at'] = this.updatedAt;
    return data;
  }
}