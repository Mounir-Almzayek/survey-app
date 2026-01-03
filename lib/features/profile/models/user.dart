/// User Model
/// Represents a user in the system
class User {
  final int id;
  final String name;
  final String email;
  final String? emailVerifiedAt;
  final String createdAt;
  final String updatedAt;
  final int userLevelsId;
  final String? type;
  final String? regionsId; // Serialized PHP array (legacy)
  final List<String>? regions; // Parsed regions list when available
  final String? phone;
  final String? entity;
  final String? code;
  final String? inviteEntity;
  final String? image;
  final String? imageConfirmed;
  final String? reference;
  final String? company;
  final String? position;
  final String? registerLink;
  final int? categoriesId;
  final int? groupsId;
  final int? employeesCount;
  final String? statusesId;
  final String? printStatus;
  final String? printDate;
  final int? printCount;
  final String? recieverName;
  final String? recieverEmail;
  final String? recieverPhone;
  final String? cardStatus;
  final String? cardCode;
  final String? cardDate;
  final int? wristbandsId;
  final int? titlesId;
  final int? gendersId;
  final String? lastName;
  final String? nationality;
  final String? idNo;
  final String? idExpiry;
  final String? idImage;
  final int? locationsId;
  final String? car;
  final int? day1;
  final int? day2;
  final String? language;
  final int? systemId;
  final String? title;
  final String? horse;
  final String? companion;
  final String? code2;
  final String? horseName;
  final String? trainerName;
  final String? idType;
  final String? idNumber;
  final String? vehiclePlateNumber;
  final String? idPhoto;

  const User({
    required this.id,
    required this.name,
    required this.email,
    this.emailVerifiedAt,
    required this.createdAt,
    required this.updatedAt,
    required this.userLevelsId,
    this.type,
    this.regionsId,
    this.regions,
    this.phone,
    this.entity,
    this.code,
    this.inviteEntity,
    this.image,
    this.imageConfirmed,
    this.reference,
    this.company,
    this.position,
    this.registerLink,
    this.categoriesId,
    this.groupsId,
    this.employeesCount,
    this.statusesId,
    this.printStatus,
    this.printDate,
    this.printCount,
    this.recieverName,
    this.recieverEmail,
    this.recieverPhone,
    this.cardStatus,
    this.cardCode,
    this.cardDate,
    this.wristbandsId,
    this.titlesId,
    this.gendersId,
    this.lastName,
    this.nationality,
    this.idNo,
    this.idExpiry,
    this.idImage,
    this.locationsId,
    this.car,
    this.day1,
    this.day2,
    this.language,
    this.systemId,
    this.title,
    this.horse,
    this.companion,
    this.code2,
    this.horseName,
    this.trainerName,
    this.idType,
    this.idNumber,
    this.vehiclePlateNumber,
    this.idPhoto,
  });

  /// Helper method to safely convert dynamic value to int?
  static int? _parseInt(dynamic value) {
    if (value == null) return null;
    if (value is int) return value;
    if (value is String) {
      final parsed = int.tryParse(value);
      return parsed;
    }
    return null;
  }

  /// Helper method to safely convert dynamic value to String?
  static String? _parseString(dynamic value) {
    if (value == null) return null;
    if (value is String) return value;
    return value.toString();
  }

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'] as int? ?? 0,
      name: json['name'] as String? ?? '',
      email: json['email'] as String? ?? '',
      emailVerifiedAt: _parseString(json['email_verified_at']),
      createdAt: json['created_at'] as String? ?? '',
      updatedAt: json['updated_at'] as String? ?? '',
      userLevelsId: json['user_levels_id'] as int? ?? 0,
      type: _parseString(json['type']),
      regionsId: _parseString(json['regions_id']),
      regions: (json['regions'] as List<dynamic>?)
          ?.map((e) => e.toString())
          .toList(),
      phone: _parseString(json['phone']),
      entity: _parseString(json['entity']),
      code: _parseString(json['code']),
      inviteEntity: _parseString(json['invite_entity']),
      image: _parseString(json['image']),
      imageConfirmed: _parseString(json['image_confirmed']),
      reference: _parseString(json['reference']),
      company: _parseString(json['company']),
      position: _parseString(json['position']),
      registerLink: _parseString(json['register_link']),
      categoriesId: _parseInt(json['categories_id']),
      groupsId: _parseInt(json['groups_id']),
      employeesCount: _parseInt(json['employees_count']),
      statusesId: _parseString(json['statuses_id']),
      printStatus: _parseString(json['print_status']),
      printDate: _parseString(json['print_date']),
      printCount: _parseInt(json['print_count']),
      recieverName: _parseString(json['reciever_name']),
      recieverEmail: _parseString(json['reciever_email']),
      recieverPhone: _parseString(json['reciever_phone']),
      cardStatus: _parseString(json['card_status']),
      cardCode: _parseString(json['card_code']),
      cardDate: _parseString(json['card_date']),
      wristbandsId: _parseInt(json['wristbands_id']),
      titlesId: _parseInt(json['titles_id']),
      gendersId: _parseInt(json['genders_id']),
      lastName: _parseString(json['last_name']),
      nationality: _parseString(json['nationality']),
      idNo: _parseString(json['id_no']),
      idExpiry: _parseString(json['id_expiry']),
      idImage: _parseString(json['id_image']),
      locationsId: _parseInt(json['locations_id']),
      car: _parseString(json['car']),
      day1: _parseInt(json['day1']),
      day2: _parseInt(json['day2']),
      language: _parseString(json['language']),
      systemId: _parseInt(json['system_id']),
      title: _parseString(json['title']),
      horse: _parseString(json['horse']),
      companion: _parseString(json['companion']),
      code2: _parseString(json['code2']),
      horseName: _parseString(json['horse_name']),
      trainerName: _parseString(json['trainer_name']),
      idType: _parseString(json['id_type']),
      idNumber: _parseString(json['id_number']),
      vehiclePlateNumber: _parseString(json['vehicle_plate_number']),
      idPhoto: _parseString(json['id_photo']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'email_verified_at': emailVerifiedAt,
      'created_at': createdAt,
      'updated_at': updatedAt,
      'user_levels_id': userLevelsId,
      'type': type,
      'regions_id': regionsId,
      'regions': regions,
      'phone': phone,
      'entity': entity,
      'code': code,
      'invite_entity': inviteEntity,
      'image': image,
      'image_confirmed': imageConfirmed,
      'reference': reference,
      'company': company,
      'position': position,
      'register_link': registerLink,
      'categories_id': categoriesId,
      'groups_id': groupsId,
      'employees_count': employeesCount,
      'statuses_id': statusesId,
      'print_status': printStatus,
      'print_date': printDate,
      'print_count': printCount,
      'reciever_name': recieverName,
      'reciever_email': recieverEmail,
      'reciever_phone': recieverPhone,
      'card_status': cardStatus,
      'card_code': cardCode,
      'card_date': cardDate,
      'wristbands_id': wristbandsId,
      'titles_id': titlesId,
      'genders_id': gendersId,
      'last_name': lastName,
      'nationality': nationality,
      'id_no': idNo,
      'id_expiry': idExpiry,
      'id_image': idImage,
      'locations_id': locationsId,
      'car': car,
      'day1': day1,
      'day2': day2,
      'language': language,
      'system_id': systemId,
      'title': title,
      'horse': horse,
      'companion': companion,
      'code2': code2,
      'horse_name': horseName,
      'trainer_name': trainerName,
      'id_type': idType,
      'id_number': idNumber,
      'vehicle_plate_number': vehiclePlateNumber,
      'id_photo': idPhoto,
    };
  }

  /// Whether the user's card has already been delivered.
  bool get isCardDelivered {
    final status = cardStatus?.trim();
    if (status == null || status.isEmpty) return false;
    if (status == '1') return true;
    return false;
  }

  /// Create a copy of User with updated fields
  User copyWith({
    int? id,
    String? name,
    String? email,
    String? emailVerifiedAt,
    String? createdAt,
    String? updatedAt,
    int? userLevelsId,
    String? type,
    String? regionsId,
    List<String>? regions,
    String? phone,
    String? entity,
    String? code,
    String? inviteEntity,
    String? image,
    String? imageConfirmed,
    String? reference,
    String? company,
    String? position,
    String? registerLink,
    int? categoriesId,
    int? groupsId,
    int? employeesCount,
    String? statusesId,
    String? printStatus,
    String? printDate,
    int? printCount,
    String? recieverName,
    String? recieverEmail,
    String? recieverPhone,
    String? cardStatus,
    String? cardCode,
    String? cardDate,
    int? wristbandsId,
    int? titlesId,
    int? gendersId,
    String? lastName,
    String? nationality,
    String? idNo,
    String? idExpiry,
    String? idImage,
    int? locationsId,
    String? car,
    int? day1,
    int? day2,
    String? language,
    int? systemId,
    String? title,
    String? horse,
    String? companion,
    String? code2,
    String? horseName,
    String? trainerName,
    String? idType,
    String? idNumber,
    String? vehiclePlateNumber,
    String? idPhoto,
  }) {
    return User(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      emailVerifiedAt: emailVerifiedAt ?? this.emailVerifiedAt,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      userLevelsId: userLevelsId ?? this.userLevelsId,
      type: type ?? this.type,
      regionsId: regionsId ?? this.regionsId,
      regions: regions ?? this.regions,
      phone: phone ?? this.phone,
      entity: entity ?? this.entity,
      code: code ?? this.code,
      inviteEntity: inviteEntity ?? this.inviteEntity,
      image: image ?? this.image,
      imageConfirmed: imageConfirmed ?? this.imageConfirmed,
      reference: reference ?? this.reference,
      company: company ?? this.company,
      position: position ?? this.position,
      registerLink: registerLink ?? this.registerLink,
      categoriesId: categoriesId ?? this.categoriesId,
      groupsId: groupsId ?? this.groupsId,
      employeesCount: employeesCount ?? this.employeesCount,
      statusesId: statusesId ?? this.statusesId,
      printStatus: printStatus ?? this.printStatus,
      printDate: printDate ?? this.printDate,
      printCount: printCount ?? this.printCount,
      recieverName: recieverName ?? this.recieverName,
      recieverEmail: recieverEmail ?? this.recieverEmail,
      recieverPhone: recieverPhone ?? this.recieverPhone,
      cardStatus: cardStatus ?? this.cardStatus,
      cardCode: cardCode ?? this.cardCode,
      cardDate: cardDate ?? this.cardDate,
      wristbandsId: wristbandsId ?? this.wristbandsId,
      titlesId: titlesId ?? this.titlesId,
      gendersId: gendersId ?? this.gendersId,
      lastName: lastName ?? this.lastName,
      nationality: nationality ?? this.nationality,
      idNo: idNo ?? this.idNo,
      idExpiry: idExpiry ?? this.idExpiry,
      idImage: idImage ?? this.idImage,
      locationsId: locationsId ?? this.locationsId,
      car: car ?? this.car,
      day1: day1 ?? this.day1,
      day2: day2 ?? this.day2,
      language: language ?? this.language,
      systemId: systemId ?? this.systemId,
      title: title ?? this.title,
      horse: horse ?? this.horse,
      companion: companion ?? this.companion,
      code2: code2 ?? this.code2,
      horseName: horseName ?? this.horseName,
      trainerName: trainerName ?? this.trainerName,
      idType: idType ?? this.idType,
      idNumber: idNumber ?? this.idNumber,
      vehiclePlateNumber: vehiclePlateNumber ?? this.vehiclePlateNumber,
      idPhoto: idPhoto ?? this.idPhoto,
    );
  }
}
