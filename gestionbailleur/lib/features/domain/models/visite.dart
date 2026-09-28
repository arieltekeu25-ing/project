// Modèle de visite (Visit Request)
class Visite {
  final String id;
  final String propertyId;
  final String clientId;
  final String landlordId;
  final DateTime requestedDate;
  final String requestedTime;
  final String? message;
  final String status;
  final String? landlordResponse;
  final DateTime? rescheduledDate;
  final String? rescheduledTime;
  final String? rescheduledMessage;
  final DateTime createdAt;
  final DateTime updatedAt;
  
  // Embedded data from API
  final String? propertyTitle;
  final String? propertyAddress;
  final String? propertyMainPhoto;
  final String? clientName;
  final String? clientEmail;
  final String? landlordName;
  final String? landlordEmail;

  Visite({
    required this.id,
    required this.propertyId,
    required this.clientId,
    required this.landlordId,
    required this.requestedDate,
    required this.requestedTime,
    this.message,
    this.status = 'PENDING',
    this.landlordResponse,
    this.rescheduledDate,
    this.rescheduledTime,
    this.rescheduledMessage,
    required this.createdAt,
    required this.updatedAt,
    this.propertyTitle,
    this.propertyAddress,
    this.propertyMainPhoto,
    this.clientName,
    this.clientEmail,
    this.landlordName,
    this.landlordEmail,
  });

  Visite copyWith({
    String? id,
    String? propertyId,
    String? clientId,
    String? landlordId,
    DateTime? requestedDate,
    String? requestedTime,
    String? message,
    String? status,
    String? landlordResponse,
    DateTime? rescheduledDate,
    String? rescheduledTime,
    String? rescheduledMessage,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? propertyTitle,
    String? propertyAddress,
    String? propertyMainPhoto,
    String? clientName,
    String? clientEmail,
    String? landlordName,
    String? landlordEmail,
  }) {
    return Visite(
      id: id ?? this.id,
      propertyId: propertyId ?? this.propertyId,
      clientId: clientId ?? this.clientId,
      landlordId: landlordId ?? this.landlordId,
      requestedDate: requestedDate ?? this.requestedDate,
      requestedTime: requestedTime ?? this.requestedTime,
      message: message ?? this.message,
      status: status ?? this.status,
      landlordResponse: landlordResponse ?? this.landlordResponse,
      rescheduledDate: rescheduledDate ?? this.rescheduledDate,
      rescheduledTime: rescheduledTime ?? this.rescheduledTime,
      rescheduledMessage: rescheduledMessage ?? this.rescheduledMessage,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      propertyTitle: propertyTitle ?? this.propertyTitle,
      propertyAddress: propertyAddress ?? this.propertyAddress,
      propertyMainPhoto: propertyMainPhoto ?? this.propertyMainPhoto,
      clientName: clientName ?? this.clientName,
      clientEmail: clientEmail ?? this.clientEmail,
      landlordName: landlordName ?? this.landlordName,
      landlordEmail: landlordEmail ?? this.landlordEmail,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'property': propertyId,
      'client': clientId,
      'landlord': landlordId,
      'requested_date': requestedDate.toIso8601String().split('T')[0],
      'requested_time': requestedTime,
      'message': message,
      'status': status,
      'landlord_response': landlordResponse,
      'rescheduled_date': rescheduledDate?.toIso8601String().split('T')[0],
      'rescheduled_time': rescheduledTime,
      'rescheduled_message': rescheduledMessage,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  factory Visite.fromMap(Map<String, dynamic> map) {
    return Visite(
      id: map['id'] as String,
      propertyId: map['property'] as String? ?? map['property_id'] as String,
      clientId: map['client'] as String? ?? map['client_id'] as String,
      landlordId: map['landlord'] as String? ?? map['landlord_id'] as String,
      requestedDate: DateTime.parse(map['requested_date'] as String),
      requestedTime: map['requested_time'] as String,
      message: map['message'] as String?,
      status: map['status'] as String,
      landlordResponse: map['landlord_response'] as String?,
      rescheduledDate: map['rescheduled_date'] != null 
          ? DateTime.parse(map['rescheduled_date'] as String) 
          : null,
      rescheduledTime: map['rescheduled_time'] as String?,
      rescheduledMessage: map['rescheduled_message'] as String?,
      createdAt: DateTime.parse(map['created_at'] as String),
      updatedAt: DateTime.parse(map['updated_at'] as String),
      propertyTitle: map['property_title'] as String?,
      propertyAddress: map['property_address'] as String?,
      propertyMainPhoto: map['property_main_photo'] as String?,
      clientName: map['client_name'] as String?,
      clientEmail: map['client_email'] as String?,
      landlordName: map['landlord_name'] as String?,
      landlordEmail: map['landlord_email'] as String?,
    );
  }

  String toJson() => toMap().toString();

  factory Visite.fromJson(String source) =>
      Visite.fromMap(Map<String, dynamic>.from(
          source as Map<String, dynamic>));

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Visite && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}

// Enum pour les statuts de visite
enum VisitStatus {
  pending('PENDING', 'En attente'),
  accepted('ACCEPTED', 'Acceptée'),
  rejected('REJECTED', 'Refusée'),
  rescheduled('RESCHEDULED', 'Reprogrammée'),
  cancelled('CANCELLED', 'Annulée'),
  completed('COMPLETED', 'Terminée');

  final String value;
  final String label;

  const VisitStatus(this.value, this.label);

  static VisitStatus fromString(String value) {
    return VisitStatus.values.firstWhere(
      (status) => status.value == value,
      orElse: () => VisitStatus.pending,
    );
  }
}
