import 'package:firebase_auth/firebase_auth.dart';
import 'package:login_social_example/feature/social_login/domain/entities/user_entity.dart';

class UserModel extends UserEntity {
  const UserModel({
    required super.id,
    super.email,
    super.displayName,
    super.photoUrl,
  });

  factory UserModel.fromFirebaseUser(User user, {String? facebookPhotoUrl}) {
    return UserModel(
      id: user.uid,
      email: user.email,
      displayName: user.displayName,
      photoUrl: facebookPhotoUrl ?? user.photoURL,
    );
  }

  UserEntity toEntity() {
    return UserEntity(
      id: id,
      email: email,
      displayName: displayName,
      photoUrl: photoUrl,
    );
  }
}
