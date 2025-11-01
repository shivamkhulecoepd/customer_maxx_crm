import 'package:bloc/bloc.dart';
import 'package:customer_maxx_crm/models/lead.dart';
import 'package:customer_maxx_crm/services/lead_service.dart';
import 'package:customer_maxx_crm/utils/api_service_locator.dart';
import 'package:file_picker/file_picker.dart';
import 'package:csv/csv.dart';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'leads_event.dart';
import 'leads_state.dart';

class LeadsBloc extends Bloc<LeadsEvent, LeadsState> {
  final LeadService _leadService = ServiceLocator.leadService;

  LeadsBloc() : super(LeadsState.initial()) {
    on<LoadAllLeads>(_onLoadAllLeads);
    on<LoadLeadsByStatus>(_onLoadLeadsByStatus);
    on<AddLead>(_onAddLead);
    on<UpdateLead>(_onUpdateLead);
    on<DeleteLead>(_onDeleteLead);
    on<FilterLeads>(_onFilterLeads);
    on<SearchLeads>(_onSearchLeads);
    on<FilterLeadsByDate>(_onFilterLeadsByDate);
    on<ExportCSV>(_onExportCSV);
    on<ImportCSV>(_onImportCSV);
    on<DeleteSelectedLeads>(_onDeleteSelectedLeads);
  }

  Future<void> _onLoadAllLeads(
    LoadAllLeads event,
    Emitter<LeadsState> emit,
  ) async {
    emit(state.copyWith(isLoading: true, error: null));
    try {
      final leads = await _leadService.getAllLeadsNoPagination();
      emit(state.copyWith(isLoading: false, leads: leads));
    } catch (e) {
      emit(state.copyWith(
        isLoading: false,
        error: 'Error fetching leads: $e',
      ));
    }
  }

  Future<void> _onLoadLeadsByStatus(
    LoadLeadsByStatus event,
    Emitter<LeadsState> emit,
  ) async {
    emit(state.copyWith(isLoading: true, error: null));
    try {
      final leads = await _leadService.getAllLeadsNoPagination(status: event.status);
      emit(state.copyWith(isLoading: false, leads: leads));
    } catch (e) {
      emit(state.copyWith(
        isLoading: false,
        error: 'Error fetching leads by status: $e',
      ));
    }
  }

  Future<void> _onAddLead(AddLead event, Emitter<LeadsState> emit) async {
    emit(state.copyWith(isLoading: true, error: null));
    try {
      final response = await _leadService.createLead(event.lead);
      final success = response['status'] == 'success';
      if (success) {
        final updatedLeads = List<Lead>.from(state.leads)..add(event.lead);
        emit(state.copyWith(isLoading: false, leads: updatedLeads));
      } else {
        emit(state.copyWith(
          isLoading: false,
          error: 'Failed to add lead',
        ));
      }
    } catch (e) {
      emit(state.copyWith(
        isLoading: false,
        error: 'Error adding lead: $e',
      ));
    }
  }

  Future<void> _onUpdateLead(
    UpdateLead event,
    Emitter<LeadsState> emit,
  ) async {
    emit(state.copyWith(isLoading: true, error: null));
    try {
      final response = await _leadService.updateLead(event.lead);
      final success = response['status'] == 'success';
      if (success) {
        final updatedLeads = List<Lead>.from(state.leads);
        final index = updatedLeads.indexWhere((l) => l.id == event.lead.id);
        if (index != -1) {
          updatedLeads[index] = event.lead;
        }
        emit(state.copyWith(isLoading: false, leads: updatedLeads));
      } else {
        emit(state.copyWith(
          isLoading: false,
          error: 'Failed to update lead',
        ));
      }
    } catch (e) {
      emit(state.copyWith(
        isLoading: false,
        error: 'Error updating lead: $e',
      ));
    }
  }

  Future<void> _onDeleteLead(
    DeleteLead event,
    Emitter<LeadsState> emit,
  ) async {
    emit(state.copyWith(isLoading: true, error: null));
    try {
      // final response = await _leadService.deleteLead(int.parse(event.id));
      final response = await _leadService.deleteLead(event.id);
      final success = response['status'] == 'success';
      if (success) {
        final updatedLeads =
            state.leads.where((lead) => lead.id != event.id).toList();
        emit(state.copyWith(isLoading: false, leads: updatedLeads));
      } else {
        emit(state.copyWith(
          isLoading: false,
          error: 'Failed to delete lead',
        ));
      }
    } catch (e) {
      emit(state.copyWith(
        isLoading: false,
        error: 'Error deleting lead: $e',
      ));
    }
  }

  Future<void> _onFilterLeads(
    FilterLeads event,
    Emitter<LeadsState> emit,
  ) async {
    emit(state.copyWith(isLoading: true, error: null));
    try {
      // Use getAllLeads with filtering on client side for now
      final leads = await _leadService.getAllLeadsNoPagination();
      emit(state.copyWith(isLoading: false, leads: leads));
    } catch (e) {
      emit(state.copyWith(
        isLoading: false,
        error: 'Error filtering leads: $e',
      ));
    }
  }

  Future<void> _onSearchLeads(
    SearchLeads event,
    Emitter<LeadsState> emit,
  ) async {
    emit(state.copyWith(isLoading: true, error: null));
    try {
      List<Lead> filteredLeads;
      if (event.query.isEmpty) {
        filteredLeads = await _leadService.getAllLeadsNoPagination();
      } else {
        // For now, we'll filter by name, phone, or email
        // In a real implementation, this would call a search API
        List<Lead> allLeads = await _leadService.getAllLeadsNoPagination();
        filteredLeads = allLeads.where((lead) {
          return lead.name.toLowerCase().contains(event.query.toLowerCase()) ||
              lead.phone.contains(event.query) ||
              lead.email.toLowerCase().contains(event.query.toLowerCase());
        }).toList();
      }
      emit(state.copyWith(isLoading: false, leads: filteredLeads));
    } catch (e) {
      emit(state.copyWith(
        isLoading: false,
        error: 'Error searching leads: $e',
      ));
    }
  }

  Future<void> _onFilterLeadsByDate(
    FilterLeadsByDate event,
    Emitter<LeadsState> emit,
  ) async {
    emit(state.copyWith(isLoading: true, error: null));
    try {
      List<Lead> allLeads = await _leadService.getAllLeadsNoPagination();
      final filteredLeads = allLeads.where((lead) {
        if (lead.date == null) return false;
        return lead.date!.year == event.date.year &&
            lead.date!.month == event.date.month &&
            lead.date!.day == event.date.day;
      }).toList();
      emit(state.copyWith(isLoading: false, leads: filteredLeads));
    } catch (e) {
      emit(state.copyWith(
        isLoading: false,
        error: 'Error filtering leads by date: $e',
      ));
    }
  }

  Future<void> _onExportCSV(ExportCSV event, Emitter<LeadsState> emit) async {
    emit(state.copyWith(isLoading: true, error: null));
    try {
      // Create CSV headers
      List<List<dynamic>> rows = [];

      // Add header row
      rows.add([
        'ID',
        'Date',
        'Name',
        'Phone',
        'Email',
        'Owner Name',
        'Status',
        'Feedback',
        'Education',
        'Experience',
        'Location',
        'Assigned Name',
        'Discount'
      ]);

      // Add data rows
      for (var lead in state.leads) {
        rows.add([
          lead.id,
          lead.date?.toIso8601String() ?? '',
          lead.name,
          lead.phone,
          lead.email,
          lead.ownerName,
          lead.status,
          lead.feedback,
          lead.education,
          lead.experience,
          lead.location,
          lead.assignedName,
          lead.discount,
        ]);
      }

      // Convert to CSV string
      String csv = const ListToCsvConverter().convert(rows);

      // Get the directory for saving files
      Directory? directory;
      try {
        directory = await getApplicationDocumentsDirectory();
      } catch (e) {
        // Fallback to temporary directory
        directory = await getTemporaryDirectory();
      }

      // Save to file
      final file = File('${directory.path}/leads_export.csv');
      await file.writeAsString(csv);

      emit(state.copyWith(isLoading: false));
    } catch (e) {
      emit(state.copyWith(
        isLoading: false,
        error: 'Error exporting CSV: $e',
      ));
    }
  }

  Future<void> _onImportCSV(ImportCSV event, Emitter<LeadsState> emit) async {
    emit(state.copyWith(isLoading: true, error: null));
    try {
      // Pick a CSV file
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['csv'],
      );

      if (result != null && result.files.single.path != null) {
        File file = File(result.files.single.path!);
        final input = await file.readAsString();

        // Parse CSV
        List<List<dynamic>> rows = const CsvToListConverter().convert(input);

        // Skip header row and process data
        final List<Lead> newLeads = [];
        for (int i = 1; i < rows.length; i++) {
          try {
            var row = rows[i];
            if (row.length >= 15) {
              final lead = Lead(
                id: int.tryParse(row[0].toString()) ?? 0,
                name: row[2].toString(),
                phone: row[3].toString(),
                email: row[4].toString(),
                education: row[8].toString(),
                experience: row[9].toString(),
                location: row[10].toString(),
                status: row[6].toString(),
                feedback: row[7].toString(),
                createdAt: row[1].toString(),
                ownerName: row[5].toString(),
                assignedName: row[12].toString(),
                latestHistory: '',
              );

              // Add lead to the list
              await _leadService.createLead(lead);
              newLeads.add(lead);
            }
          } catch (e) {
            // Handle error silently
          }
        }

        // Update state with new leads
        final updatedLeads = List<Lead>.from(state.leads)..addAll(newLeads);
        emit(state.copyWith(
          isLoading: false,
          leads: updatedLeads,
        ));
      } else {
        emit(state.copyWith(
          isLoading: false,
          error: 'No file selected',
        ));
      }
    } catch (e) {
      emit(state.copyWith(
        isLoading: false,
        error: 'Error importing CSV: $e',
      ));
    }
  }

  Future<void> _onDeleteSelectedLeads(
    DeleteSelectedLeads event,
    Emitter<LeadsState> emit,
  ) async {
    emit(state.copyWith(isLoading: true, error: null));
    try {
      bool allSuccess = true;
      final List<Lead> remainingLeads = List<Lead>.from(state.leads);

      for (String id in event.selectedLeadIds) {
        final response = await _leadService.deleteLead(int.parse(id));
        bool success = response['status'] == 'success';
        if (success) {
          remainingLeads.removeWhere((lead) => lead.id == int.parse(id));
        } else {
          allSuccess = false;
        }
      }

      if (allSuccess) {
        emit(state.copyWith(isLoading: false, leads: remainingLeads));
      } else {
        emit(state.copyWith(
          isLoading: false,
          leads: remainingLeads,
          error: 'Some leads could not be deleted',
        ));
      }
    } catch (e) {
      emit(state.copyWith(
        isLoading: false,
        error: 'Error deleting selected leads: $e',
      ));
    }
  }
}