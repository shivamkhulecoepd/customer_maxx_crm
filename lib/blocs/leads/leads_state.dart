import 'package:equatable/equatable.dart';
import 'package:customer_maxx_crm/models/lead.dart';

class LeadsState extends Equatable {
  final List<Lead> leads;
  final bool isLoading;
  final String? error;

  const LeadsState({
    required this.leads,
    required this.isLoading,
    this.error,
  });

  factory LeadsState.initial() {
    return const LeadsState(
      leads: [],
      isLoading: false,
    );
  }

  LeadsState copyWith({
    List<Lead>? leads,
    bool? isLoading,
    String? error,
  }) {
    return LeadsState(
      leads: leads ?? this.leads,
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
    );
  }

  @override
  List<Object?> get props => [leads, isLoading, error];
}