import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import '../../../../core/utils/debounce.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../shared/database/database_providers.dart';
import '../../../../shared/database/app_database.dart';
import '../../../../shared/models/extracted_data.dart';
import '../../../parser/domain/nlp_engine.dart';
import '../../../parser/presentation/providers/parser_providers.dart';

class ArchiveResult {
  final String entryId;
  final List<ExtractedBillModel> bills;
  const ArchiveResult({required this.entryId, required this.bills});
}

final inputTextProvider =
    AutoDisposeNotifierProvider<InputTextNotifier, String>(
  InputTextNotifier.new,
);

class InputTextNotifier extends AutoDisposeNotifier<String> {
  @override
  String build() => '';

  void set(String text) {
    state = text;
    ref.read(draftManagerProvider.notifier).onTextChanged(text);
  }

  void clear() {
    state = '';
  }

  void appendText(String text) {
    state = state + text;
    ref.read(draftManagerProvider.notifier).onTextChanged(state);
  }
}

final draftManagerProvider =
    NotifierProvider<DraftManagerNotifier, DraftState>(
  DraftManagerNotifier.new,
);

class DraftState {
  final String text;
  final DateTime? lastSavedAt;
  final bool isSaving;

  const DraftState({
    this.text = '',
    this.lastSavedAt,
    this.isSaving = false,
  });
}

class DraftManagerNotifier extends Notifier<DraftState> {
  final _uuid = const Uuid();
  final _debouncer = Debouncer(milliseconds: AppConstants.debounceMs);

  @override
  DraftState build() {
    _loadDraft();
    return const DraftState();
  }

  Future<void> _loadDraft() async {
    final db = ref.read(appDatabaseProvider);
    final draft = await db.getCurrentDraft();
    if (draft != null) {
      state = DraftState(text: draft.rawText, lastSavedAt: draft.updatedAt);
      ref.read(inputTextProvider.notifier).set(draft.rawText);
    }
  }

  void onTextChanged(String text) {
    state = DraftState(text: text, lastSavedAt: state.lastSavedAt);
    _debouncer.run(() => _saveDraft(text));
  }

  Future<void> _saveDraft(String text) async {
    final db = ref.read(appDatabaseProvider);
    state = DraftState(text: text, lastSavedAt: state.lastSavedAt, isSaving: true);

    if (text.trim().isEmpty) {
      await db.deleteDraft();
    } else {
      await db.upsertDraft(DraftsCompanion.insert(
        id: 'current',
        rawText: text,
        updatedAt: DateTime.now(),
      ));
    }

    state = DraftState(text: text, lastSavedAt: DateTime.now());
  }

  Future<ArchiveResult> archiveEntry() async {
    final db = ref.read(appDatabaseProvider);
    final text = state.text.trim();
    if (text.isEmpty) return const ArchiveResult(entryId: '', bills: []);

    final entryId = _uuid.v4();
    final now = DateTime.now();
    final dateStr =
        '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';

    await db.insertEntry(EntriesCompanion.insert(
      id: entryId,
      date: dateStr,
      createdAt: now,
      updatedAt: now,
      rawText: text,
    ));

    await db.deleteDraft();
    state = const DraftState();

    final engine = ref.read(nlpEngineProvider);
    final bills = engine.parse(text);

    if (bills.isNotEmpty) {
      ref.read(pendingBillsProvider.notifier).setBills(bills);
    }

    return ArchiveResult(entryId: entryId, bills: bills);
  }

  @override
  void dispose() {
    _debouncer.cancel();
    super.dispose();
  }
}
