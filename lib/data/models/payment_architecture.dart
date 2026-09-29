import 'package:equatable/equatable.dart';

/// Supported and planned payment gateways for Travella
enum PaymentGateway {
  stripe,
  paymob,
  fawry,
  cashOnArrival,
  bankTransfer;

  String get label {
    switch (this) {
      case PaymentGateway.stripe:
        return 'Stripe (Credit / Debit Card)';
      case PaymentGateway.paymob:
        return 'Paymob (Cards / Wallets / ValU)';
      case PaymentGateway.fawry:
        return 'Fawry (Reference Code & Cash Outlets)';
      case PaymentGateway.cashOnArrival:
        return 'Pay Upon Confirmation / On Arrival';
      case PaymentGateway.bankTransfer:
        return 'Direct Wire / Bank Transfer';
    }
  }

  String get providerCode {
    switch (this) {
      case PaymentGateway.stripe:
        return 'STRIPE_V3';
      case PaymentGateway.paymob:
        return 'PAYMOB_EGY';
      case PaymentGateway.fawry:
        return 'FAWRY_PAY';
      case PaymentGateway.cashOnArrival:
        return 'OFFLINE_CASH';
      case PaymentGateway.bankTransfer:
        return 'OFFLINE_BANK';
    }
  }
}

/// Status of a payment transaction
enum PaymentStatus {
  unpaid,
  pending,
  authorized,
  paid,
  failed,
  refunded;

  String get label {
    switch (this) {
      case PaymentStatus.unpaid:
        return 'Unpaid';
      case PaymentStatus.pending:
        return 'Processing';
      case PaymentStatus.authorized:
        return 'Authorized';
      case PaymentStatus.paid:
        return 'Paid in Full';
      case PaymentStatus.failed:
        return 'Payment Failed';
      case PaymentStatus.refunded:
        return 'Refunded';
    }
  }
}

/// Architecture specification for future gateway integration
class PaymentTransactionModel extends Equatable {
  final String id;
  final String bookingId;
  final double amount;
  final String currency;
  final PaymentGateway gateway;
  final PaymentStatus status;
  final String? gatewayReference;
  final String? transactionHash;
  final DateTime? createdAt;
  final Map<String, dynamic>? metadata;

  const PaymentTransactionModel({
    required this.id,
    required this.bookingId,
    required this.amount,
    this.currency = 'USD',
    required this.gateway,
    this.status = PaymentStatus.pending,
    this.gatewayReference,
    this.transactionHash,
    this.createdAt,
    this.metadata,
  });

  factory PaymentTransactionModel.fromJson(Map<String, dynamic> json) {
    return PaymentTransactionModel(
      id: json['id'] as String? ?? '',
      bookingId: json['booking_id'] as String? ?? '',
      amount: (json['amount'] as num?)?.toDouble() ?? 0.0,
      currency: json['currency'] as String? ?? 'USD',
      gateway: PaymentGateway.values.firstWhere(
        (g) => g.name == json['gateway'],
        orElse: () => PaymentGateway.cashOnArrival,
      ),
      status: PaymentStatus.values.firstWhere(
        (s) => s.name == json['status'],
        orElse: () => PaymentStatus.pending,
      ),
      gatewayReference: json['gateway_reference'] as String?,
      transactionHash: json['transaction_hash'] as String?,
      createdAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at'].toString())
          : null,
      metadata: json['metadata'] as Map<String, dynamic>?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'booking_id': bookingId,
      'amount': amount,
      'currency': currency,
      'gateway': gateway.name,
      'status': status.name,
      'gateway_reference': gatewayReference,
      'transaction_hash': transactionHash,
      if (createdAt != null) 'created_at': createdAt!.toIso8601String(),
      if (metadata != null) 'metadata': metadata,
    };
  }

  @override
  List<Object?> get props => [
        id,
        bookingId,
        amount,
        currency,
        gateway,
        status,
        gatewayReference,
        transactionHash,
        createdAt,
      ];
}

/// Abstract contract for payment processing gateways
/// Prepared for upcoming Stripe, Paymob, and Fawry integrations
abstract class PaymentGatewayService {
  Future<PaymentTransactionModel> createPaymentIntent({
    required String bookingId,
    required double amount,
    required String currency,
    required PaymentGateway gateway,
    required Map<String, dynamic> customerInfo,
  });

  Future<PaymentStatus> verifyPayment({
    required String transactionId,
    required PaymentGateway gateway,
  });

  Future<bool> refundPayment({
    required String transactionId,
    required double amount,
  });
}
