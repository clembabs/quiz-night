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
import 'question_difficulty.dart' as _i5mrkeak;

/// AI-written questions for one host's game, made before the room exists.
abstract class QuestionPack
    implements _is.TableRow<int?>, _is.ProtocolSerialization {
  QuestionPack._({
    this.id,
    required this.topic,
    required this.difficulty,
    this.token,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  factory QuestionPack({
    int? id,
    required String topic,
    required _i5mrkeak.QuestionDifficulty difficulty,
    String? token,
    DateTime? createdAt,
  }) = _QuestionPackImpl;

  factory QuestionPack.fromJson(Map<String, dynamic> jsonSerialization) {
    return QuestionPack(
      id: jsonSerialization['id'] as int?,
      topic: jsonSerialization['topic'] as String,
      difficulty: _i5mrkeak.QuestionDifficulty.fromJson(
        (jsonSerialization['difficulty'] as String),
      ),
      token: jsonSerialization['token'] as String?,
      createdAt: jsonSerialization['createdAt'] == null
          ? null
          : _is.DateTimeJsonExtension.fromJson(jsonSerialization['createdAt']),
    );
  }

  static final t = QuestionPackTable();

  static const db = QuestionPackRepository._();

  @override
  int? id;

  String topic;

  _i5mrkeak.QuestionDifficulty difficulty;

  /// Proves the caller made this pack; required to use or edit it.
  String? token;

  DateTime createdAt;

  @override
  _is.Table<int?> get table => t;

  /// Returns a shallow copy of this [QuestionPack]
  /// with some or all fields replaced by the given arguments.
  @_is.useResult
  QuestionPack copyWith({
    int? id,
    String? topic,
    _i5mrkeak.QuestionDifficulty? difficulty,
    String? token,
    DateTime? createdAt,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'QuestionPack',
      if (id != null) 'id': id,
      'topic': topic,
      'difficulty': difficulty.toJson(),
      if (token != null) 'token': token,
      'createdAt': createdAt.toJson(),
    };
  }

  @override
  Map<String, dynamic> toJsonForProtocol() {
    return {
      '__className__': 'QuestionPack',
      if (id != null) 'id': id,
      'topic': topic,
      'difficulty': difficulty.toJson(),
      'createdAt': createdAt.toJson(),
    };
  }

  static QuestionPackInclude include() {
    return QuestionPackInclude._();
  }

  static QuestionPackIncludeList includeList({
    _is.WhereExpressionBuilder<QuestionPackTable>? where,
    int? limit,
    int? offset,
    _is.OrderByBuilder<QuestionPackTable>? orderBy,
    _is.OrderByListBuilder<QuestionPackTable>? orderByList,
    QuestionPackInclude? include,
  }) {
    return QuestionPackIncludeList._(
      where: where,
      limit: limit,
      offset: offset,
      orderBy: orderBy?.call(QuestionPack.t),
      orderByList: orderByList?.call(QuestionPack.t),
      include: include,
    );
  }

  @override
  String toString() {
    return _is.SerializationManager.encode(this);
  }
}

class _Undefined {}

class _QuestionPackImpl extends QuestionPack {
  _QuestionPackImpl({
    int? id,
    required String topic,
    required _i5mrkeak.QuestionDifficulty difficulty,
    String? token,
    DateTime? createdAt,
  }) : super._(
         id: id,
         topic: topic,
         difficulty: difficulty,
         token: token,
         createdAt: createdAt,
       );

  /// Returns a shallow copy of this [QuestionPack]
  /// with some or all fields replaced by the given arguments.
  @_is.useResult
  @override
  QuestionPack copyWith({
    Object? id = _Undefined,
    String? topic,
    _i5mrkeak.QuestionDifficulty? difficulty,
    Object? token = _Undefined,
    DateTime? createdAt,
  }) {
    return QuestionPack(
      id: id is int? ? id : this.id,
      topic: topic ?? this.topic,
      difficulty: difficulty ?? this.difficulty,
      token: token is String? ? token : this.token,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}

class QuestionPackUpdateTable extends _is.UpdateTable<QuestionPackTable> {
  QuestionPackUpdateTable(super.table);

  _is.ColumnValue<String, String> topic(String value) => _is.ColumnValue(
    table.topic,
    value,
  );

  _is.ColumnValue<_i5mrkeak.QuestionDifficulty, _i5mrkeak.QuestionDifficulty>
  difficulty(_i5mrkeak.QuestionDifficulty value) => _is.ColumnValue(
    table.difficulty,
    value,
  );

  _is.ColumnValue<String, String> token(String? value) => _is.ColumnValue(
    table.token,
    value,
  );

  _is.ColumnValue<DateTime, DateTime> createdAt(DateTime value) =>
      _is.ColumnValue(
        table.createdAt,
        value,
      );
}

class QuestionPackTable extends _is.Table<int?> {
  QuestionPackTable({super.tableRelation}) : super(tableName: 'question_pack') {
    updateTable = QuestionPackUpdateTable(this);
    topic = _is.ColumnString(
      'topic',
      this,
    );
    difficulty = _is.ColumnEnum(
      'difficulty',
      this,
      _is.EnumSerialization.byName,
    );
    token = _is.ColumnString(
      'token',
      this,
    );
    createdAt = _is.ColumnDateTime(
      'createdAt',
      this,
      hasDefault: true,
    );
  }

  late final QuestionPackUpdateTable updateTable;

  late final _is.ColumnString topic;

  late final _is.ColumnEnum<_i5mrkeak.QuestionDifficulty> difficulty;

  /// Proves the caller made this pack; required to use or edit it.
  late final _is.ColumnString token;

  late final _is.ColumnDateTime createdAt;

  @override
  List<_is.Column> get columns => [
    id,
    topic,
    difficulty,
    token,
    createdAt,
  ];
}

class QuestionPackInclude extends _is.IncludeObject {
  QuestionPackInclude._();

  @override
  Map<String, _is.Include?> get includes => {};

  @override
  _is.Table<int?> get table => QuestionPack.t;
}

class QuestionPackIncludeList extends _is.IncludeList {
  QuestionPackIncludeList._({
    _is.WhereExpressionBuilder<QuestionPackTable>? where,
    super.limit,
    super.offset,
    super.orderBy,
    super.orderByList,
    super.include,
  }) {
    super.where = where?.call(QuestionPack.t);
  }

  @override
  Map<String, _is.Include?> get includes => include?.includes ?? {};

  @override
  _is.Table<int?> get table => QuestionPack.t;
}

class QuestionPackRepository {
  const QuestionPackRepository._();

  /// Returns a list of [QuestionPack]s matching the given query parameters.
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
  Future<List<QuestionPack>> find(
    _is.DatabaseSession session, {
    _is.WhereExpressionBuilder<QuestionPackTable>? where,
    int? limit,
    int? offset,
    _is.OrderByBuilder<QuestionPackTable>? orderBy,
    _is.OrderByListBuilder<QuestionPackTable>? orderByList,
    _is.Transaction? transaction,
    _is.LockMode? lockMode,
    _is.LockBehavior? lockBehavior,
  }) async {
    return session.db.find<QuestionPack>(
      where: where?.call(QuestionPack.t),
      orderBy: orderBy?.call(QuestionPack.t),
      orderByList: orderByList?.call(QuestionPack.t),
      limit: limit,
      offset: offset,
      transaction: transaction,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Returns the first matching [QuestionPack] matching the given query parameters.
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
  Future<QuestionPack?> findFirstRow(
    _is.DatabaseSession session, {
    _is.WhereExpressionBuilder<QuestionPackTable>? where,
    int? offset,
    _is.OrderByBuilder<QuestionPackTable>? orderBy,
    _is.OrderByListBuilder<QuestionPackTable>? orderByList,
    _is.Transaction? transaction,
    _is.LockMode? lockMode,
    _is.LockBehavior? lockBehavior,
  }) async {
    return session.db.findFirstRow<QuestionPack>(
      where: where?.call(QuestionPack.t),
      orderBy: orderBy?.call(QuestionPack.t),
      orderByList: orderByList?.call(QuestionPack.t),
      offset: offset,
      transaction: transaction,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Finds a single [QuestionPack] by its [id] or null if no such row exists.
  Future<QuestionPack?> findById(
    _is.DatabaseSession session,
    int id, {
    _is.Transaction? transaction,
    _is.LockMode? lockMode,
    _is.LockBehavior? lockBehavior,
  }) async {
    return session.db.findById<QuestionPack>(
      id,
      transaction: transaction,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Inserts all [QuestionPack]s in the list and returns the inserted rows.
  ///
  /// The returned [QuestionPack]s will have their `id` fields set.
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
  Future<List<QuestionPack>> insert(
    _is.DatabaseSession session,
    List<QuestionPack> rows, {
    _is.Transaction? transaction,
    bool ignoreConflicts = false,
    bool noReturn = false,
  }) async {
    return session.db.insert<QuestionPack>(
      rows,
      transaction: transaction,
      ignoreConflicts: ignoreConflicts,
      noReturn: noReturn,
    );
  }

  /// Inserts a single [QuestionPack] and returns the inserted row.
  ///
  /// The returned [QuestionPack] will have its `id` field set.
  Future<QuestionPack> insertRow(
    _is.DatabaseSession session,
    QuestionPack row, {
    _is.Transaction? transaction,
  }) async {
    return session.db.insertRow<QuestionPack>(
      row,
      transaction: transaction,
    );
  }

  /// Upserts all [QuestionPack]s in the list and returns the resulting rows.
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
  /// The returned [QuestionPack]s will have their `id` fields set.
  ///
  /// This is an atomic operation, meaning that if one of the rows fails,
  /// none of the rows will be affected.
  ///
  /// If [noReturn] is set to `true`, the resulting rows are not read back from
  /// the database and an empty list is returned. This avoids the overhead of
  /// transferring and deserializing the rows when the result is not needed.
  Future<List<QuestionPack>> upsert(
    _is.DatabaseSession session,
    List<QuestionPack> rows, {
    required _is.ColumnSelections<QuestionPackTable> conflictColumns,
    _is.ColumnSelections<QuestionPackTable>? updateColumns,
    _is.WhereExpressionBuilder<QuestionPackTable>? updateWhere,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.upsert<QuestionPack>(
      rows,
      conflictColumns: conflictColumns(QuestionPack.t),
      updateColumns: updateColumns?.call(QuestionPack.t),
      updateWhere: updateWhere?.call(QuestionPack.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Upserts a single [QuestionPack] and returns the resulting row.
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
  /// The returned [QuestionPack] will have its `id` field set.
  Future<QuestionPack?> upsertRow(
    _is.DatabaseSession session,
    QuestionPack row, {
    required _is.ColumnSelections<QuestionPackTable> conflictColumns,
    _is.ColumnSelections<QuestionPackTable>? updateColumns,
    _is.WhereExpressionBuilder<QuestionPackTable>? updateWhere,
    _is.Transaction? transaction,
  }) async {
    return session.db.upsertRow<QuestionPack>(
      row,
      conflictColumns: conflictColumns(QuestionPack.t),
      updateColumns: updateColumns?.call(QuestionPack.t),
      updateWhere: updateWhere?.call(QuestionPack.t),
      transaction: transaction,
    );
  }

  /// Updates all [QuestionPack]s in the list and returns the updated rows. If
  /// [columns] is provided, only those columns will be updated. Defaults to
  /// all columns.
  /// This is an atomic operation, meaning that if one of the rows fails to
  /// update, none of the rows will be updated.
  ///
  /// If [noReturn] is set to `true`, the updated rows are not read back from
  /// the database and an empty list is returned. This avoids the overhead of
  /// transferring and deserializing the rows when the result is not needed.
  Future<List<QuestionPack>> update(
    _is.DatabaseSession session,
    List<QuestionPack> rows, {
    _is.ColumnSelections<QuestionPackTable>? columns,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.update<QuestionPack>(
      rows,
      columns: columns?.call(QuestionPack.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Updates a single [QuestionPack]. The row needs to have its id set.
  /// Optionally, a list of [columns] can be provided to only update those
  /// columns. Defaults to all columns.
  Future<QuestionPack> updateRow(
    _is.DatabaseSession session,
    QuestionPack row, {
    _is.ColumnSelections<QuestionPackTable>? columns,
    _is.Transaction? transaction,
  }) async {
    return session.db.updateRow<QuestionPack>(
      row,
      columns: columns?.call(QuestionPack.t),
      transaction: transaction,
    );
  }

  /// Updates a single [QuestionPack] by its [id] with the specified [columnValues].
  /// Returns the updated row or null if no row with the given id exists.
  Future<QuestionPack?> updateById(
    _is.DatabaseSession session,
    int id, {
    required _is.ColumnValueListBuilder<QuestionPackUpdateTable> columnValues,
    _is.Transaction? transaction,
  }) async {
    return session.db.updateById<QuestionPack>(
      id,
      columnValues: columnValues(QuestionPack.t.updateTable),
      transaction: transaction,
    );
  }

  /// Updates all [QuestionPack]s matching the [where] expression with the specified [columnValues].
  /// Returns the list of updated rows.
  ///
  /// If [noReturn] is set to `true`, the updated rows are not read back from
  /// the database and an empty list is returned. This avoids the overhead of
  /// transferring and deserializing the rows when the result is not needed.
  Future<List<QuestionPack>> updateWhere(
    _is.DatabaseSession session, {
    required _is.ColumnValueListBuilder<QuestionPackUpdateTable> columnValues,
    required _is.WhereExpressionBuilder<QuestionPackTable> where,
    int? limit,
    int? offset,
    _is.OrderByBuilder<QuestionPackTable>? orderBy,
    _is.OrderByListBuilder<QuestionPackTable>? orderByList,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.updateWhere<QuestionPack>(
      columnValues: columnValues(QuestionPack.t.updateTable),
      where: where(QuestionPack.t),
      limit: limit,
      offset: offset,
      orderBy: orderBy?.call(QuestionPack.t),
      orderByList: orderByList?.call(QuestionPack.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Deletes all [QuestionPack]s in the list and returns the deleted rows.
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
  Future<List<QuestionPack>> delete(
    _is.DatabaseSession session,
    List<QuestionPack> rows, {
    _is.OrderByBuilder<QuestionPackTable>? orderBy,
    _is.OrderByListBuilder<QuestionPackTable>? orderByList,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.delete<QuestionPack>(
      rows,
      orderBy: orderBy?.call(QuestionPack.t),
      orderByList: orderByList?.call(QuestionPack.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Deletes a single [QuestionPack].
  Future<QuestionPack> deleteRow(
    _is.DatabaseSession session,
    QuestionPack row, {
    _is.Transaction? transaction,
  }) async {
    return session.db.deleteRow<QuestionPack>(
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
  Future<List<QuestionPack>> deleteWhere(
    _is.DatabaseSession session, {
    required _is.WhereExpressionBuilder<QuestionPackTable> where,
    _is.OrderByBuilder<QuestionPackTable>? orderBy,
    _is.OrderByListBuilder<QuestionPackTable>? orderByList,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.deleteWhere<QuestionPack>(
      where: where(QuestionPack.t),
      orderBy: orderBy?.call(QuestionPack.t),
      orderByList: orderByList?.call(QuestionPack.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Counts the number of rows matching the [where] expression. If omitted,
  /// will return the count of all rows in the table.
  Future<int> count(
    _is.DatabaseSession session, {
    _is.WhereExpressionBuilder<QuestionPackTable>? where,
    int? limit,
    _is.Transaction? transaction,
  }) async {
    return session.db.count<QuestionPack>(
      where: where?.call(QuestionPack.t),
      limit: limit,
      transaction: transaction,
    );
  }

  /// Acquires row-level locks on [QuestionPack] rows matching the [where] expression.
  Future<void> lockRows(
    _is.DatabaseSession session, {
    required _is.WhereExpressionBuilder<QuestionPackTable> where,
    required _is.LockMode lockMode,
    required _is.Transaction transaction,
    _is.LockBehavior lockBehavior = _is.LockBehavior.wait,
  }) async {
    return session.db.lockRows<QuestionPack>(
      where: where(QuestionPack.t),
      lockMode: lockMode,
      lockBehavior: lockBehavior,
      transaction: transaction,
    );
  }
}
