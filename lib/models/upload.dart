class UploadModel {
  final double pms;
  final DateTime? timestamp;

  UploadModel({required this.pms, this.timestamp,
  });

  factory UploadModel.fromJson(Map<String, dynamic> json) {
    return UploadModel(
      pms: double.parse(json['PMS_25'].toString()),
      timestamp: json['timestamp'] != null
          ? DateTime.fromMillisecondsSinceEpoch(json['timestamp'])
          : null,
    );
  }

  @override
  String toString() {
    return 'PMS: $pms';
  }
}

