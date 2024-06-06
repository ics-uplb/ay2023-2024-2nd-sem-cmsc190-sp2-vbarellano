class Report {
  // Key
  String? report_id;
  // Details
  String sender_id; // User ID of sender
  String sender_name;
  String status;
  String datetime_sent;
  String description;
  String? datetime_evaluated;
  String? evaluated_by;
  String? evaluator_id; // User ID of sender
  String? datetime_resolved;
  String? resolved_by;
  String? resolver_id;

  // Constructor
  Report(
    this.report_id,
    this.sender_id,
    this.sender_name,
    this.status,
    this.datetime_sent,
    this.description,
    this.datetime_evaluated,
    this.evaluated_by,
    this.evaluator_id,
    this.datetime_resolved,
    this.resolved_by,
    this.resolver_id,
  );
}
