class MediaFile {
  String thumbnail;
  String fullSize;

  MediaFile.fromJson(Map<String, dynamic> json)
      : thumbnail = json['thumbnail'],
        fullSize = json['full_size'];
}
