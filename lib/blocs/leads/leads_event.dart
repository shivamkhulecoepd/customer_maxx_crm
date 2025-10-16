import 'package:equatable/equatable.dart';
import 'package:customer_maxx_crm/models/lead.dart';

abstract class LeadsEvent extends Equatable {
  const LeadsEvent();

  @override
  List<Object?> get props => [];
}

class LoadAllLeads extends LeadsEvent {}

class LoadLeadsByStatus extends LeadsEvent {
  final String status;

  const LoadLeadsByStatus(this.status);

  @override
  List<Object?> get props => [status];
}

class AddLead extends LeadsEvent {
  final Lead lead;

  const AddLead(this.lead);

  @override
  List<Object?> get props => [lead];
}

class UpdateLead extends LeadsEvent {
  final Lead lead;

  const UpdateLead(this.lead);

  @override
  List<Object?> get props => [lead];
}

class DeleteLead extends LeadsEvent {
  final String id;

  const DeleteLead(this.id);

  @override
  List<Object?> get props => [id];
}

class FilterLeads extends LeadsEvent {
  final String? name;
  final String? phone;
  final String? email;
  final String? education;
  final String? experience;
  final String? location;
  final String? status;
  final String? feedback;
  final String? orderBy;
  final String? assignedBy;

  const FilterLeads({
    this.name,
    this.phone,
    this.email,
    this.education,
    this.experience,
    this.location,
    this.status,
    this.feedback,
    this.orderBy,
    this.assignedBy,
  });

  @override
  List<Object?> get props => [
        name,
        phone,
        email,
        education,
        experience,
        location,
        status,
        feedback,
        orderBy,
        assignedBy,
      ];
}

class SearchLeads extends LeadsEvent {
  final String query;

  const SearchLeads(this.query);

  @override
  List<Object?> get props => [query];
}

class FilterLeadsByDate extends LeadsEvent {
  final DateTime date;

  const FilterLeadsByDate(this.date);

  @override
  List<Object?> get props => [date];
}

class ExportCSV extends LeadsEvent {}

class ImportCSV extends LeadsEvent {}

class DeleteSelectedLeads extends LeadsEvent {
  final List<String> selectedLeadIds;

  const DeleteSelectedLeads(this.selectedLeadIds);

  @override
  List<Object?> get props => [selectedLeadIds];
}