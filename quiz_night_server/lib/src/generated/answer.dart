/* AUTOMATICALLY GENERATED CODE DO NOT MODIFY */
/*   To generate run: "serverpod generate"    */

// ignore_for_file: implementation_imports
// ignore_for_file: library_private_types_in_public_api
// ignore_for_file: non_constant_identifier_names
// ignore_for_file: public_member_api_docs
// ignore_for_file: type_literal_in_constant_pattern
// ignore_for_file: use_super_parameters
// ignore_for_file: invalid_use_of_internal_member

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'package:serverpod/serverpod.dart' as _is;

abstract class Answer implements _is.TableRow<int?>, _is.ProtocolSerialization {
  Answer._({
    this.id,
    required this.playerId,
    required this.questionId,
    required this.choiceIndex,
    required this.answeredAt,
    required this.elapsedMs,
    required this.isCorrect,
    required this.pointsAwarded,
    required this.isShadow,
  });

  factory Answer({
    int? id,
    required int playerId,
    required int questionId,
    required int choiceIndex,
    required DateTime answeredAt,
    required int elapsedMs,
    required bool isCorrect,
    required int pointsAwarded,
    required bool isShadow,
  }) = _AnswerImpl;

  factory Answer.fromJson(Map<String, dynamic> jsonSerialization) {
    return Answer(
      id: jsonSerialization['id'] as int?,
      playerId: jsonSerialization['playerId'] as int,
      questionId: jsonSerialization['questionId'] as int,
      choiceIndex: jsonSerialization['choiceIndex'] as int,
      answeredAt: _is.DateTimeJsonExtension.fromJson(
        jsonSerialization['answeredAt'],
      ),
      elapsedMs: jsonSerialization['elapsedMs'] as int,
      isCorrect: _is.BoolJsonExtension.fromJson(jsonSerialization['isCorrect']),
      pointsAwarded: jsonSerialization['pointsAwarded'] as int,
      isShadow: _is.BoolJsonExtension.fromJson(jsonSerialization['isShadow']),
    );
  }

  static final t = AnswerTable();

  static const db = AnswerRepository._();

  @override
  int? id;

  int playerId;

  int questionId;

  int choiceIndex;

  DateTime answeredAt;

  int elapsedMs;

  bool isCorrect;

  int pointsAwarded;

  bool isShadow;

  @override
  _is.Table<int?> get table => t;

  /// Returns a shallow copy of this [Answer]
  /// with some or all fields replaced by the given arguments.
  @_is.useResult
  Answer copyWith({
    int? id,
    int? playerId,
    int? questionId,
    int? choiceIndex,
    DateTime? answeredAt,
    int? elapsedMs,
    bool? isCorrect,
    int? pointsAwarded,
    bool? isShadow,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'Answer',
      if (id != null) 'id': id,
      'playerId': playerId,
      'questionId': questionId,
      'choiceIndex': choiceIndex,
      'answeredAt': answeredAt.toJson(),
      'elapsedMs': elapsedMs,
      'isCorrect': isCorrect,
      'pointsAwarded': pointsAwarded,
      'isShadow': isShadow,
    };
  }

  @override
  Map<String, dynamic> toJsonForProtocol() {
    return {
      '__className__': 'Answer',
      if (id != null) 'id': id,
      'playerId': playerId,
      'questionId': questionId,
      'choiceIndex': choiceIndex,
      'answeredAt': answeredAt.toJson(),
      'elapsedMs': elapsedMs,
      'isCorrect': isCorrect,
      'pointsAwarded': pointsAwarded,
      'isShadow': isShadow,
    };
  }

  static AnswerInclude include() {
    return AnswerInclude._();
  }

  static AnswerIncludeList includeList({
    _is.WhereExpressionBuilder<AnswerTable>? where,
    int? limit,
    int? offset,
    _is.OrderByBuilder<AnswerTable>? orderBy,
    _is.OrderByListBuilder<AnswerTable>? orderByList,
    AnswerInclude? include,
  }) {
    return AnswerIncludeList._(
      where: where,
      limit: limit,
      offset: offset,
      orderBy: orderBy?.call(Answer.t),
      orderByList: orderByList?.call(Answer.t),
      include: include,
    );
  }

  @override
  String toString() {
    return _is.SerializationManager.encode(this);
  }
}

class _Undefined {}

class _AnswerImpl extends Answer {
  _AnswerImpl({
    int? id,
    required int playerId,
    required int questionId,
    required int choiceIndex,
    required DateTime answeredAt,
    required int elapsedMs,
    required bool isCorrect,
    required int pointsAwarded,
    required bool isShadow,
  }) : super._(
         id: id,
         playerId: playerId,
         questionId: questionId,
         choiceIndex: choiceIndex,
         answeredAt: answeredAt,
         elapsedMs: elapsedMs,
         isCorrect: isCorrect,
         pointsAwarded: pointsAwarded,
         isShadow: isShadow,
       );

  /// Returns a shallow copy of this [Answer]
  /// with some or all fields replaced by the given arguments.
  @_is.useResult
  @override
  Answer copyWith({
    Object? id = _Undefined,
    int? playerId,
    int? questionId,
    int? choiceIndex,
    DateTime? answeredAt,
    int? elapsedMs,
    bool? isCorrect,
    int? pointsAwarded,
    bool? isShadow,
  }) {
    return Answer(
      id: id is int? ? id : this.id,
      playerId: playerId ?? this.playerId,
      questionId: questionId ?? this.questionId,
      choiceIndex: choiceIndex ?? this.choiceIndex,
      answeredAt: answeredAt ?? this.answeredAt,
      elapsedMs: elapsedMs ?? this.elapsedMs,
      isCorrect: isCorrect ?? this.isCorrect,
      pointsAwarded: pointsAwarded ?? this.pointsAwarded,
      isShadow: isShadow ?? this.isShadow,
    );
  }
}

class AnswerUpdateTable extends _is.UpdateTable<AnswerTable> {
  AnswerUpdateTable(super.table);

  _is.ColumnValue<int, int> playerId(int value) => _is.ColumnValue(
    table.playerId,
    value,
  );

  _is.ColumnValue<int, int> questionId(int value) => _is.ColumnValue(
    table.questionId,
    value,
  );

  _is.ColumnValue<int, int> choiceIndex(int value) => _is.ColumnValue(
    table.choiceIndex,
    value,
  );

  _is.ColumnValue<DateTime, DateTime> answeredAt(DateTime value) =>
      _is.ColumnValue(
        table.answeredAt,
        value,
      );

  _is.ColumnValue<int, int> elapsedMs(int value) => _is.ColumnValue(
    table.elapsedMs,
    value,
  );

  _is.ColumnValue<bool, bool> isCorrect(bool value) => _is.ColumnValue(
    table.isCorrect,
    value,
  );

  _is.ColumnValue<int, int> pointsAwarded(int value) => _is.ColumnValue(
    table.pointsAwarded,
    value,
  );

  _is.ColumnValue<bool, bool> isShadow(bool value) => _is.ColumnValue(
    table.isShadow,
    value,
  );
}

class AnswerTable extends _is.Table<int?> {
  AnswerTable({super.tableRelation}) : super(tableName: 'answer') {
    updateTable = AnswerUpdateTable(this);
    playerId = _is.ColumnInt(
      'playerId',
      this,
    );
    questionId = _is.ColumnInt(
      'questionId',
      this,
    );
    choiceIndex = _is.ColumnInt(
      'choiceIndex',
      this,
    );
    answeredAt = _is.ColumnDateTime(
      'answeredAt',
      this,
    );
    elapsedMs = _is.ColumnInt(
      'elapsedMs',
      this,
    );
    isCorrect = _is.ColumnBool(
      'isCorrect',
      this,
    );
    pointsAwarded = _is.ColumnInt(
      'pointsAwarded',
      this,
    );
    isShadow = _is.ColumnBool(
      'isShadow',
      this,
    );
  }

  late final AnswerUpdateTable updateTable;

  late final _is.ColumnInt playerId;

  late final _is.ColumnInt questionId;

  late final _is.ColumnInt choiceIndex;

  late final _is.ColumnDateTime answeredAt;

  late final _is.ColumnInt elapsedMs;

  late final _is.ColumnBool isCorrect;

  late final _is.ColumnInt pointsAwarded;

  late final _is.ColumnBool isShadow;

  @override
  List<_is.Column> get columns => [
    id,
    playerId,
    questionId,
    choiceIndex,
    answeredAt,
    elapsedMs,
    isCorrect,
    pointsAwarded,
    isShadow,
  ];
}

class AnswerInclude extends _is.IncludeObject {
  AnswerInclude._();

  @override
  Map<String, _is.Include?> get includes => {};

  @override
  _is.Table<int?> get table => Answer.t;
}

class AnswerIncludeList extends _is.IncludeList {
  AnswerIncludeList._({
    _is.WhereExpressionBuilder<AnswerTable>? where,
    super.limit,
    super.offset,
    super.orderBy,
    super.orderByList,
    super.include,
  }) {
    super.where = where?.call(Answer.t);
  }

  @override
  Map<String, _is.Include?> get includes => include?.includes ?? {};

  @override
  _is.Table<int?> get table => Answer.t;
}

class AnswerRepository {
  const AnswerRepository._();

  /// Returns a list of [Answer]s matching the given query parameters.
  ///
  /// Use [where] to specify which items to include in the return value.
  /// If none is specified, all items will be returned.
  ///
  /// To specify the order of the items use [orderBy] or [orderByList]
  /// when sorting by multiple columns.
  ///
  /// The maximum number of items can be set by [limit]. If no limit is set,
  /// all items matching the query will be returned.
  ///
  /// [offset] defines how many items to skip, after which [limit] (or all)
  /// items are read from the database.
  ///
  /// ```dart
  /// var persons = await Persons.db.find(
  ///   session,
  ///   where: (t) => t.lastName.equals('Jones'),
  ///   orderBy: (t) => t.firstName,
  ///   limit: 100,
  /// );
  /// ```
  Future<List<Answer>> find(
    _is.DatabaseSession session, {
    _is.WhereExpressionBuilder<AnswerTable>? where,
    int? limit,
    int? offset,
    _is.OrderByBuilder<AnswerTable>? orderBy,
    _is.OrderByListBuilder<AnswerTable>? orderByList,
    _is.Transaction? transaction,
    _is.LockMode? lockMode,
    _is.LockBehavior? lockBehavior,
  }) async {
    return session.db.find<Answer>(
      where: where?.call(Answer.t),
      orderBy: orderBy?.call(Answer.t),
      orderByList: orderByList?.call(Answer.t),
      limit: limit,
      offset: offset,
      transaction: transaction,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Returns the first matching [Answer] matching the given query parameters.
  ///
  /// Use [where] to specify which items to include in the return value.
  /// If none is specified, all items will be returned.
  ///
  /// To specify the order use [orderBy] or [orderByList]
  /// when sorting by multiple columns.
  ///
  /// [offset] defines how many items to skip, after which the next one will be picked.
  ///
  /// ```dart
  /// var youngestPerson = await Persons.db.findFirstRow(
  ///   session,
  ///   where: (t) => t.lastName.equals('Jones'),
  ///   orderBy: (t) => t.age,
  /// );
  /// ```
  Future<Answer?> findFirstRow(
    _is.DatabaseSession session, {
    _is.WhereExpressionBuilder<AnswerTable>? where,
    int? offset,
    _is.OrderByBuilder<AnswerTable>? orderBy,
    _is.OrderByListBuilder<AnswerTable>? orderByList,
    _is.Transaction? transaction,
    _is.LockMode? lockMode,
    _is.LockBehavior? lockBehavior,
  }) async {
    return session.db.findFirstRow<Answer>(
      where: where?.call(Answer.t),
      orderBy: orderBy?.call(Answer.t),
      orderByList: orderByList?.call(Answer.t),
      offset: offset,
      transaction: transaction,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Finds a single [Answer] by its [id] or null if no such row exists.
  Future<Answer?> findById(
    _is.DatabaseSession session,
    int id, {
    _is.Transaction? transaction,
    _is.LockMode? lockMode,
    _is.LockBehavior? lockBehavior,
  }) async {
    return session.db.findById<Answer>(
      id,
      transaction: transaction,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Inserts all [Answer]s in the list and returns the inserted rows.
  ///
  /// The returned [Answer]s will have their `id` fields set.
  ///
  /// This is an atomic operation, meaning that if one of the rows fails to
  /// insert, none of the rows will be inserted.
  ///
  /// If [ignoreConflicts] is set to `true`, rows that conflict with existing
  /// rows are silently skipped, and only the successfully inserted rows are
  /// returned.
  ///
  /// If [noReturn] is set to `true`, the inserted rows are not read back from
  /// the database and an empty list is returned. This avoids the overhead of
  /// transferring and deserializing the rows when the result is not needed.
  Future<List<Answer>> insert(
    _is.DatabaseSession session,
    List<Answer> rows, {
    _is.Transaction? transaction,
    bool ignoreConflicts = false,
    bool noReturn = false,
  }) async {
    return session.db.insert<Answer>(
      rows,
      transaction: transaction,
      ignoreConflicts: ignoreConflicts,
      noReturn: noReturn,
    );
  }

  /// Inserts a single [Answer] and returns the inserted row.
  ///
  /// The returned [Answer] will have its `id` field set.
  Future<Answer> insertRow(
    _is.DatabaseSession session,
    Answer row, {
    _is.Transaction? transaction,
  }) async {
    return session.db.insertRow<Answer>(
      row,
      transaction: transaction,
    );
  }

  /// Upserts all [Answer]s in the list and returns the resulting rows.
  ///
  /// If a row conflicts on the given [conflictColumns], the existing row is
  /// updated with the new values. Otherwise, a new row is inserted.
  ///
  /// If [updateColumns] is provided, only those columns will be updated on
  /// conflict. If null, all non-conflict, non-id columns are updated.
  ///
  /// If [updateWhere] is provided, the update only applies to rows matching the
  /// given expression. Conflicting rows that don't match are skipped and not
  /// returned, so the resulting list may be shorter than [rows].
  ///
  /// The returned [Answer]s will have their `id` fields set.
  ///
  /// This is an atomic operation, meaning that if one of the rows fails,
  /// none of the rows will be affected.
  ///
  /// If [noReturn] is set to `true`, the resulting rows are not read back from
  /// the database and an empty list is returned. This avoids the overhead of
  /// transferring and deserializing the rows when the result is not needed.
  Future<List<Answer>> upsert(
    _is.DatabaseSession session,
    List<Answer> rows, {
    required _is.ColumnSelections<AnswerTable> conflictColumns,
    _is.ColumnSelections<AnswerTable>? updateColumns,
    _is.WhereExpressionBuilder<AnswerTable>? updateWhere,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.upsert<Answer>(
      rows,
      conflictColumns: conflictColumns(Answer.t),
      updateColumns: updateColumns?.call(Answer.t),
      updateWhere: updateWhere?.call(Answer.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Upserts a single [Answer] and returns the resulting row.
  ///
  /// If the row conflicts on the given [conflictColumns], the existing row is
  /// updated. Otherwise, a new row is inserted.
  ///
  /// If [updateColumns] is provided, only those columns will be updated on
  /// conflict. If null, all non-conflict, non-id columns are updated.
  ///
  /// If [updateWhere] is provided, the update only applies when the existing
  /// row matches the expression. Returns `null` if no row was affected — for
  /// example when [updateWhere] does not match the conflicting row.
  ///
  /// The returned [Answer] will have its `id` field set.
  Future<Answer?> upsertRow(
    _is.DatabaseSession session,
    Answer row, {
    required _is.ColumnSelections<AnswerTable> conflictColumns,
    _is.ColumnSelections<AnswerTable>? updateColumns,
    _is.WhereExpressionBuilder<AnswerTable>? updateWhere,
    _is.Transaction? transaction,
  }) async {
    return session.db.upsertRow<Answer>(
      row,
      conflictColumns: conflictColumns(Answer.t),
      updateColumns: updateColumns?.call(Answer.t),
      updateWhere: updateWhere?.call(Answer.t),
      transaction: transaction,
    );
  }

  /// Updates all [Answer]s in the list and returns the updated rows. If
  /// [columns] is provided, only those columns will be updated. Defaults to
  /// all columns.
  /// This is an atomic operation, meaning that if one of the rows fails to
  /// update, none of the rows will be updated.
  ///
  /// If [noReturn] is set to `true`, the updated rows are not read back from
  /// the database and an empty list is returned. This avoids the overhead of
  /// transferring and deserializing the rows when the result is not needed.
  Future<List<Answer>> update(
    _is.DatabaseSession session,
    List<Answer> rows, {
    _is.ColumnSelections<AnswerTable>? columns,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.update<Answer>(
      rows,
      columns: columns?.call(Answer.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Updates a single [Answer]. The row needs to have its id set.
  /// Optionally, a list of [columns] can be provided to only update those
  /// columns. Defaults to all columns.
  Future<Answer> updateRow(
    _is.DatabaseSession session,
    Answer row, {
    _is.ColumnSelections<AnswerTable>? columns,
    _is.Transaction? transaction,
  }) async {
    return session.db.updateRow<Answer>(
      row,
      columns: columns?.call(Answer.t),
      transaction: transaction,
    );
  }

  /// Updates a single [Answer] by its [id] with the specified [columnValues].
  /// Returns the updated row or null if no row with the given id exists.
  Future<Answer?> updateById(
    _is.DatabaseSession session,
    int id, {
    required _is.ColumnValueListBuilder<AnswerUpdateTable> columnValues,
    _is.Transaction? transaction,
  }) async {
    return session.db.updateById<Answer>(
      id,
      columnValues: columnValues(Answer.t.updateTable),
      transaction: transaction,
    );
  }

  /// Updates all [Answer]s matching the [where] expression with the specified [columnValues].
  /// Returns the list of updated rows.
  ///
  /// If [noReturn] is set to `true`, the updated rows are not read back from
  /// the database and an empty list is returned. This avoids the overhead of
  /// transferring and deserializing the rows when the result is not needed.
  Future<List<Answer>> updateWhere(
    _is.DatabaseSession session, {
    required _is.ColumnValueListBuilder<AnswerUpdateTable> columnValues,
    required _is.WhereExpressionBuilder<AnswerTable> where,
    int? limit,
    int? offset,
    _is.OrderByBuilder<AnswerTable>? orderBy,
    _is.OrderByListBuilder<AnswerTable>? orderByList,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.updateWhere<Answer>(
      columnValues: columnValues(Answer.t.updateTable),
      where: where(Answer.t),
      limit: limit,
      offset: offset,
      orderBy: orderBy?.call(Answer.t),
      orderByList: orderByList?.call(Answer.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Deletes all [Answer]s in the list and returns the deleted rows.
  ///
  /// To specify the order of the returned rows use [orderBy] or [orderByList]
  /// when sorting by multiple columns.
  ///
  /// This is an atomic operation, meaning that if one of the rows fail to
  /// be deleted, none of the rows will be deleted.
  ///
  /// If [noReturn] is set to `true`, the deleted rows are not read back from
  /// the database and an empty list is returned. This avoids the overhead of
  /// transferring and deserializing the rows when the result is not needed.
  Future<List<Answer>> delete(
    _is.DatabaseSession session,
    List<Answer> rows, {
    _is.OrderByBuilder<AnswerTable>? orderBy,
    _is.OrderByListBuilder<AnswerTable>? orderByList,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.delete<Answer>(
      rows,
      orderBy: orderBy?.call(Answer.t),
      orderByList: orderByList?.call(Answer.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Deletes a single [Answer].
  Future<Answer> deleteRow(
    _is.DatabaseSession session,
    Answer row, {
    _is.Transaction? transaction,
  }) async {
    return session.db.deleteRow<Answer>(
      row,
      transaction: transaction,
    );
  }

  /// Deletes all rows matching the [where] expression.
  ///
  /// To specify the order of the returned rows use [orderBy] or [orderByList]
  /// when sorting by multiple columns.
  ///
  /// If [noReturn] is set to `true`, the deleted rows are not read back from
  /// the database and an empty list is returned. This avoids the overhead of
  /// transferring and deserializing the rows when the result is not needed.
  Future<List<Answer>> deleteWhere(
    _is.DatabaseSession session, {
    required _is.WhereExpressionBuilder<AnswerTable> where,
    _is.OrderByBuilder<AnswerTable>? orderBy,
    _is.OrderByListBuilder<AnswerTable>? orderByList,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.deleteWhere<Answer>(
      where: where(Answer.t),
      orderBy: orderBy?.call(Answer.t),
      orderByList: orderByList?.call(Answer.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Counts the number of rows matching the [where] expression. If omitted,
  /// will return the count of all rows in the table.
  Future<int> count(
    _is.DatabaseSession session, {
    _is.WhereExpressionBuilder<AnswerTable>? where,
    int? limit,
    _is.Transaction? transaction,
  }) async {
    return session.db.count<Answer>(
      where: where?.call(Answer.t),
      limit: limit,
      transaction: transaction,
    );
  }

  /// Acquires row-level locks on [Answer] rows matching the [where] expression.
  Future<void> lockRows(
    _is.DatabaseSession session, {
    required _is.WhereExpressionBuilder<AnswerTable> where,
    required _is.LockMode lockMode,
    required _is.Transaction transaction,
    _is.LockBehavior lockBehavior = _is.LockBehavior.wait,
  }) async {
    return session.db.lockRows<Answer>(
      where: where(Answer.t),
      lockMode: lockMode,
      lockBehavior: lockBehavior,
      transaction: transaction,
    );
  }
}
