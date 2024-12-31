class Expense {
  final String? id; // Optional ID for Firestore
  final String title;
  final double amount;

  Expense({this.id, required this.title, required this.amount});

  Map<String, dynamic> toMap() {
    return {
      'title': title.toLowerCase(),
      'amount': amount,
    };
  }

  factory Expense.fromMap(Map<String, dynamic> map, {String? id}) {
    return Expense(
      id: id, // Assign Firestore document ID
      title: map['title'] ?? '',
      amount: map['amount']?.toDouble() ?? 0.0,
    );
  }
}
