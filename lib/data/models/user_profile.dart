/// User profile model representing authenticated or guest session.
class UserProfile {
  final String id;
  final String name;
  final String email;
  final String phone;
  final String avatarUrl;
  final bool isGuest;
  final DateTime joinedDate;

  const UserProfile({
    required this.id,
    required this.name,
    required this.email,
    this.phone = '',
    this.avatarUrl = 'https://images.unsplash.com/photo-1534528741775-53994a69daeb?w=150',
    this.isGuest = false,
    required this.joinedDate,
  });

  /// Factory for default authenticated user in demo.
  factory UserProfile.defaultUser({String? name, String? email, String? phone}) {
    return UserProfile(
      id: 'usr_nova_01',
      name: name ?? 'Explorer',
      email: email ?? 'member@nova.app',
      phone: phone ?? '+91 9876543210',
      avatarUrl: 'https://images.unsplash.com/photo-1535713875002-d1d0cf377fde?w=200',
      isGuest: false,
      joinedDate: DateTime(2026, 1, 1),
    );
  }

  /// Factory for guest browsing mode.
  factory UserProfile.guest() {
    return UserProfile(
      id: 'usr_guest',
      name: 'Guest Explorer',
      email: 'guest@nova.lifestyle',
      phone: '',
      avatarUrl: 'https://images.unsplash.com/photo-1534528741775-53994a69daeb?w=150',
      isGuest: true,
      joinedDate: DateTime.now(),
    );
  }

  factory UserProfile.fromJson(Map<String, dynamic> json) {
    return UserProfile(
      id: json['id'] as String? ?? 'usr_guest',
      name: json['name'] as String? ?? 'Guest',
      email: json['email'] as String? ?? '',
      phone: json['phone'] as String? ?? '',
      avatarUrl: json['avatarUrl'] as String? ?? '',
      isGuest: json['isGuest'] as bool? ?? false,
      joinedDate: json['joinedDate'] != null
          ? DateTime.tryParse(json['joinedDate'].toString()) ?? DateTime.now()
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'email': email,
        'phone': phone,
        'avatarUrl': avatarUrl,
        'isGuest': isGuest,
        'joinedDate': joinedDate.toIso8601String(),
      };
}
