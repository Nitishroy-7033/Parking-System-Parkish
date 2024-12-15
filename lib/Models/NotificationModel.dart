class NotificationModel {
  String? id;
  String? title;
  String? des;
  String? imageUrl;
  String? createdAt;

  NotificationModel({this.id, this.title, this.des, this.imageUrl, this.createdAt});

  NotificationModel.fromJson(Map<String, dynamic> json) {
    if (json["id"] is String) {
      id = json["id"];
    }
    if (json["title"] is String) {
      title = json["title"];
    }
    if (json["des"] is String) {
      des = json["des"];
    }
    if (json["imageUrl"] is String) {
      imageUrl = json["imageUrl"];
    }
    if (json["createdAt"] is String) {
      createdAt = json["createdAt"];
    }
  }

  static List<NotificationModel> fromList(List<Map<String, dynamic>> list) {
    return list.map(NotificationModel.fromJson).toList();
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data["id"] = id;
    data["title"] = title;
    data["des"] = des;
    data["imageUrl"] = imageUrl;
    data["createdAt"] = createdAt;
    return data;
  }
}
