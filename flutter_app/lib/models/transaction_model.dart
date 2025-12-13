class Transaction {
  final int id;
  final String transactionRef;
  final String fromCurrency;
  final String toCurrency;
  final double fromAmount;
  final double toAmount;
  final double exchangeRate;
  final String status;
  final String? paymentMethod;
  final String? paymentProofUrl;
  final DateTime createdAt;

  Transaction({
    required this.id,
    required this.transactionRef,
    required this.fromCurrency,
    required this.toCurrency,
    required this.fromAmount,
    required this.toAmount,
    required this.exchangeRate,
    required this.status,
    this.paymentMethod,
    this.paymentProofUrl,
    required this.createdAt,
  });

  factory Transaction.fromJson(Map<String, dynamic> json) {
    return Transaction(
      id: json['id'],
      transactionRef: json['transaction_ref'],
      fromCurrency: json['from_currency'],
      toCurrency: json['to_currency'],
      fromAmount: double.parse(json['from_amount'].toString()),
      toAmount: double.parse(json['to_amount'].toString()),
      exchangeRate: double.parse(json['exchange_rate'].toString()),
      status: json['status'],
      paymentMethod: json['payment_method'],
      paymentProofUrl: json['payment_proof_url'],
      createdAt: DateTime.parse(json['created_at']),
    );
  }
}
