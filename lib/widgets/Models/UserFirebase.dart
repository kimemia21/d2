class UserCredential {
  final AdditionalUserInfo? additionalUserInfo;
  final dynamic credential;
  final User? user;

  UserCredential({
    this.additionalUserInfo,
    this.credential,
    this.user,
  });

  factory UserCredential.fromJson(Map<String, dynamic> json) {
    return UserCredential(
      additionalUserInfo: json['additionalUserInfo'] != null
          ? AdditionalUserInfo.fromJson(json['additionalUserInfo'])
          : null,
      credential: json['credential'],
      user: json['user'] != null ? User.fromJson(json['user']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'additionalUserInfo': additionalUserInfo?.toJson(),
      'credential': credential,
      'user': user?.toJson(),
    };
  }
}

class AdditionalUserInfo {
  final bool? isNewUser;
  final Map<String, dynamic>? profile;
  final String? providerId;
  final String? username;
  final String? authorizationCode;

  AdditionalUserInfo({
    this.isNewUser,
    this.profile,
    this.providerId,
    this.username,
    this.authorizationCode,
  });

  factory AdditionalUserInfo.fromJson(Map<String, dynamic> json) {
    return AdditionalUserInfo(
      isNewUser: json['isNewUser'],
      profile: json['profile'],
      providerId: json['providerId'],
      username: json['username'],
      authorizationCode: json['authorizationCode'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'isNewUser': isNewUser,
      'profile': profile,
      'providerId': providerId,
      'username': username,
      'authorizationCode': authorizationCode,
    };
  }
}

class User {
  final String? displayName;
  final String? email;
  final bool? isEmailVerified;
  final bool? isAnonymous;
  final UserMetadata? metadata;
  final String? phoneNumber;
  final String? photoURL;
  final List<UserInfo>? providerData;
  final String? refreshToken;
  final String? tenantId;
  final String? uid;

  User({
    this.displayName,
    this.email,
    this.isEmailVerified,
    this.isAnonymous,
    this.metadata,
    this.phoneNumber,
    this.photoURL,
    this.providerData,
    this.refreshToken,
    this.tenantId,
    this.uid,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      displayName: json['displayName'],
      email: json['email'],
      isEmailVerified: json['isEmailVerified'],
      isAnonymous: json['isAnonymous'],
      metadata: json['metadata'] != null
          ? UserMetadata.fromJson(json['metadata'])
          : null,
      phoneNumber: json['phoneNumber'],
      photoURL: json['photoURL'],
      providerData: json['providerData'] != null
          ? List<UserInfo>.from(
              json['providerData'].map((x) => UserInfo.fromJson(x)))
          : null,
      refreshToken: json['refreshToken'],
      tenantId: json['tenantId'],
      uid: json['uid'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'displayName': displayName,
      'email': email,
      'isEmailVerified': isEmailVerified,
      'isAnonymous': isAnonymous,
      'metadata': metadata?.toJson(),
      'phoneNumber': phoneNumber,
      'photoURL': photoURL,
      'providerData': providerData?.map((x) => x.toJson()).toList(),
      'refreshToken': refreshToken,
      'tenantId': tenantId,
      'uid': uid,
    };
  }
}

class UserMetadata {
  final DateTime? creationTime;
  final DateTime? lastSignInTime;

  UserMetadata({
    this.creationTime,
    this.lastSignInTime,
  });

  factory UserMetadata.fromJson(Map<String, dynamic> json) {
    return UserMetadata(
      creationTime: json['creationTime'] != null
          ? DateTime.parse(json['creationTime'])
          : null,
      lastSignInTime: json['lastSignInTime'] != null
          ? DateTime.parse(json['lastSignInTime'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'creationTime': creationTime?.toIso8601String(),
      'lastSignInTime': lastSignInTime?.toIso8601String(),
    };
  }
}

class UserInfo {
  final String? displayName;
  final String? email;
  final String? phoneNumber;
  final String? photoURL;
  final String? providerId;
  final String? uid;

  UserInfo({
    this.displayName,
    this.email,
    this.phoneNumber,
    this.photoURL,
    this.providerId,
    this.uid,
  });

  factory UserInfo.fromJson(Map<String, dynamic> json) {
    return UserInfo(
      displayName: json['displayName'],
      email: json['email'],
      phoneNumber: json['phoneNumber'],
      photoURL: json['photoURL'],
      providerId: json['providerId'],
      uid: json['uid'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'displayName': displayName,
      'email': email,
      'phoneNumber': phoneNumber,
      'photoURL': photoURL,
      'providerId': providerId,
      'uid': uid,
    };
  }
}