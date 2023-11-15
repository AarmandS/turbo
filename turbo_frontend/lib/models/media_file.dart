class MediaFile {
  String thumbnail;
  String full_size;

  MediaFile.fromJson(Map<String, dynamic> json)
      : thumbnail = json['thumbnail'],
        full_size = json['full_size'];
}
