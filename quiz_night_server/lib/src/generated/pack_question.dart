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
import 'package:quiz_night_server/src/generated/protocol.dart' as _izn0xfae;
import 'package:serverpod/serverpod.dart' as _is;

/// One question in a [QuestionPack].
abstract class PackQuestion
    implements _is.TableRow<int?>, _is.ProtocolSerialization {
  PackQuestion._({
    this.id,
    required this.packId,
    required this.orderIndex,
    required this.isFinal,
    required this.text,
    required this.options,
    required this.correctIndex,
  });

  factory PackQuestion({
    int? id,
    required int packId,
    required int orderIndex,
    required bool isFinal,
    required String text,
    required List<String> options,
    required int correctIndex,
  }) = _PackQuestionImpl;

  factory PackQuestion.fromJson(Map<String, dynamic> jsonSerialization) {
    return PackQuestion(
      id: jsonSerialization['id'] as int?,
      packId: jsonSerialization['packId'] as int,
      orderIndex: jsonSerialization['orderIndex'] as int,
      isFinal: _is.BoolJsonExtension.fromJson(jsonSerialization['isFinal']),
      text: jsonSerialization['text'] as String,
      options: _izn0xfae.Protocol().deserialize<List<String>>(
        jsonSerialization['options'],
      ),
      correctIndex: jsonSerialization['correctIndex'] as int,
    );
  }

  static final t = PackQuestionTable();

  static const db = PackQuestionRepository._();

  @override
  int? id;

  int packId;

  /// Play order within its kind (rounds or final).
  int orderIndex;

  bool isFinal;

  String text;

  List<String> options;

  int correctIndex;

  @override
  _is.Table<int?> get table => t;

  /// Returns a shallow copy of this [PackQuestion]
  /// with some or all fields replaced by the given arguments.
  @_is.useResult
  PackQuestion copyWith({
    int? id,
    int? packId,
    int? orderIndex,
    bool? isFinal,
    String? text,
    List<String>? options,
    int? correctIndex,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'PackQuestion',
      if (id != null) 'id': id,
      'packId': packId,
      'orderIndex': orderIndex,
      'isFinal': isFinal,
      'text': text,
      'options': options.toJson(),
      'correctIndex': correctIndex,
    };
  }

  @override
  Map<String, dynamic> toJsonForProtocol() {
    return {
      '__className__': 'PackQuestion',
      if (id != null) 'id': id,
      'packId': packId,
      'orderIndex': orderIndex,
      'isFinal': isFinal,
      'text': text,
      'options': options.toJson(),
      'correctIndex': correctIndex,
    };
  }

  static PackQuestionInclude include() {
    return PackQuestionInclude._();
  }

  static PackQuestionIncludeList includeList({
    _is.WhereExpressionBuilder<PackQuestionTable>? where,
    int? limit,
    int? offset,
    _is.OrderByBuilder<PackQuestionTable>? orderBy,
    _is.OrderByListBuilder<PackQuestionTable>? orderByList,
    PackQuestionInclude? include,
  }) {
    return PackQuestionIncludeList._(
      where: where,
      limit: limit,
      offset: offset,
      orderBy: orderBy?.call(PackQuestion.t),
      orderByList: orderByList?.call(PackQuestion.t),
      include: include,
    );
  }

  @override
  String toString() {
    return _is.SerializationManager.encode(this);
  }
}

class _Undefined {}

class _PackQuestionImpl extends PackQuestion {
  _PackQuestionImpl({
    int? id,
    required int packId,
    required int orderIndex,
    required bool isFinal,
    required String text,
    required List<String> options,
    required int correctIndex,
  }) : super._(
         id: id,
         packId: packId,
         orderIndex: orderIndex,
         isFinal: isFinal,
         text: text,
         options: options,
         correctIndex: correctIndex,
       );

  /// Returns a shallow copy of this [PackQuestion]
  /// with some or all fields replaced by the given arguments.
  @_is.useResult
  @override
  PackQuestion copyWith({
    Object? id = _Undefined,
    int? packId,
    int? orderIndex,
    bool? isFinal,
    String? text,
    List<String>? options,
    int? correctIndex,
  }) {
    return PackQuestion(
      id: id is int? ? id : this.id,
      packId: packId ?? this.packId,
      orderIndex: orderIndex ?? this.orderIndex,
      isFinal: isFinal ?? this.isFinal,
      text: text ?? this.text,
      options: options ?? this.options.map((e0) => e0).toList(),
      correctIndex: correctIndex ?? this.correctIndex,
    );
  }
}

class PackQuestionUpdateTable extends _is.UpdateTable<PackQuestionTable> {
  PackQuestionUpdateTable(super.table);

  _is.ColumnValue<int, int> packId(int value) => _is.ColumnValue(
    table.packId,
    value,
  );

  _is.ColumnValue<int, int> orderIndex(int value) => _is.ColumnValue(
    table.orderIndex,
    value,
  );

  _is.ColumnValue<bool, bool> isFinal(bool value) => _is.ColumnValue(
    table.isFinal,
    value,
  );

  _is.ColumnValue<String, String> text(String value) => _is.ColumnValue(
    table.text,
    value,
  );

  _is.ColumnValue<List<String>, List<String>> options(List<String> value) =>
      _is.ColumnValue(
        table.options,
        value,
      );

  _is.ColumnValue<int, int> correctIndex(int value) => _is.ColumnValue(
    table.correctIndex,
    value,
  );
}

class PackQuestionTable extends _is.Table<int?> {
  PackQuestionTable({super.tableRelation}) : super(tableName: 'pack_question') {
    updateTable = PackQuestionUpdateTable(this);
    packId = _is.ColumnInt(
      'packId',
      this,
    );
    orderIndex = _is.ColumnInt(
      'orderIndex',
      this,
    );
    isFinal = _is.ColumnBool(
      'isFinal',
      this,
    );
    text = _is.ColumnString(
      'text',
      this,
    );
    options = _is.ColumnSerializable<List<String>>(
      'options',
      this,
    );
    correctIndex = _is.ColumnInt(
      'correctIndex',
      this,
    );
  }

  late final PackQuestionUpdateTable updateTable;

  late final _is.ColumnInt packId;

  /// Play order within its kind (rounds or final).
  late final _is.ColumnInt orderIndex;

  late final _is.ColumnBool isFinal;

  late final _is.ColumnString text;

  late final _is.ColumnSerializable<List<String>> options;

  late final _is.ColumnInt correctIndex;

  @override
  List<_is.Column> get columns => [
    id,
    packId,
    orderIndex,
    isFinal,
    text,
    options,
    correctIndex,
  ];
}

class PackQuestionInclude extends _is.IncludeObject {
  PackQuestionInclude._();

  @override
  Map<String, _is.Include?> get includes => {};

  @override
  _is.Table<int?> get table => PackQuestion.t;
}

class PackQuestionIncludeList extends _is.IncludeList {
  PackQuestionIncludeList._({
    _is.WhereExpressionBuilder<PackQuestionTable>? where,
    super.limit,
    super.offset,
    super.orderBy,
    super.orderByList,
    super.include,
  }) {
    super.where = where?.call(PackQuestion.t);
  }

  @override
  Map<String, _is.Include?> get includes => include?.includes ?? {};

  @override
  _is.Table<int?> get table => PackQuestion.t;
}

class PackQuestionRepository {
  const PackQuestionRepository._();

  /// Returns a list of [PackQuestion]s matching the given query parameters.
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
  Future<List<PackQuestion>> find(
    _is.DatabaseSession session, {
    _is.WhereExpressionBuilder<PackQuestionTable>? where,
    int? limit,
    int? offset,
    _is.OrderByBuilder<PackQuestionTable>? orderBy,
    _is.OrderByListBuilder<PackQuestionTable>? orderByList,
    _is.Transaction? transaction,
    _is.LockMode? lockMode,
    _is.LockBehavior? lockBehavior,
  }) async {
    return session.db.find<PackQuestion>(
      where: where?.call(PackQuestion.t),
      orderBy: orderBy?.call(PackQuestion.t),
      orderByList: orderByList?.call(PackQuestion.t),
      limit: limit,
      offset: offset,
      transaction: transaction,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Returns the first matching [PackQuestion] matching the given query parameters.
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
  Future<PackQuestion?> findFirstRow(
    _is.DatabaseSession session, {
    _is.WhereExpressionBuilder<PackQuestionTable>? where,
    int? offset,
    _is.OrderByBuilder<PackQuestionTable>? orderBy,
    _is.OrderByListBuilder<PackQuestionTable>? orderByList,
    _is.Transaction? transaction,
    _is.LockMode? lockMode,
    _is.LockBehavior? lockBehavior,
  }) async {
    return session.db.findFirstRow<PackQuestion>(
      where: where?.call(PackQuestion.t),
      orderBy: orderBy?.call(PackQuestion.t),
      orderByList: orderByList?.call(PackQuestion.t),
      offset: offset,
      transaction: transaction,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Finds a single [PackQuestion] by its [id] or null if no such row exists.
  Future<PackQuestion?> findById(
    _is.DatabaseSession session,
    int id, {
    _is.Transaction? transaction,
    _is.LockMode? lockMode,
    _is.LockBehavior? lockBehavior,
  }) async {
    return session.db.findById<PackQuestion>(
      id,
      transaction: transaction,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Inserts all [PackQuestion]s in the list and returns the inserted rows.
  ///
  /// The returned [PackQuestion]s will have their `id` fields set.
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
  Future<List<PackQuestion>> insert(
    _is.DatabaseSession session,
    List<PackQuestion> rows, {
    _is.Transaction? transaction,
    bool ignoreConflicts = false,
    bool noReturn = false,
  }) async {
    return session.db.insert<PackQuestion>(
      rows,
      transaction: transaction,
      ignoreConflicts: ignoreConflicts,
      noReturn: noReturn,
    );
  }

  /// Inserts a single [PackQuestion] and returns the inserted row.
  ///
  /// The returned [PackQuestion] will have its `id` field set.
  Future<PackQuestion> insertRow(
    _is.DatabaseSession session,
    PackQuestion row, {
    _is.Transaction? transaction,
  }) async {
    return session.db.insertRow<PackQuestion>(
      row,
      transaction: transaction,
    );
  }

  /// Upserts all [PackQuestion]s in the list and returns the resulting rows.
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
  /// The returned [PackQuestion]s will have their `id` fields set.
  ///
  /// This is an atomic operation, meaning that if one of the rows fails,
  /// none of the rows will be affected.
  ///
  /// If [noReturn] is set to `true`, the resulting rows are not read back from
  /// the database and an empty list is returned. This avoids the overhead of
  /// transferring and deserializing the rows when the result is not needed.
  Future<List<PackQuestion>> upsert(
    _is.DatabaseSession session,
    List<PackQuestion> rows, {
    required _is.ColumnSelections<PackQuestionTable> conflictColumns,
    _is.ColumnSelections<PackQuestionTable>? updateColumns,
    _is.WhereExpressionBuilder<PackQuestionTable>? updateWhere,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.upsert<PackQuestion>(
      rows,
      conflictColumns: conflictColumns(PackQuestion.t),
      updateColumns: updateColumns?.call(PackQuestion.t),
      updateWhere: updateWhere?.call(PackQuestion.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Upserts a single [PackQuestion] and returns the resulting row.
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
  /// The returned [PackQuestion] will have its `id` field set.
  Future<PackQuestion?> upsertRow(
    _is.DatabaseSession session,
    PackQuestion row, {
    required _is.ColumnSelections<PackQuestionTable> conflictColumns,
    _is.ColumnSelections<PackQuestionTable>? updateColumns,
    _is.WhereExpressionBuilder<PackQuestionTable>? updateWhere,
    _is.Transaction? transaction,
  }) async {
    return session.db.upsertRow<PackQuestion>(
      row,
      conflictColumns: conflictColumns(PackQuestion.t),
      updateColumns: updateColumns?.call(PackQuestion.t),
      updateWhere: updateWhere?.call(PackQuestion.t),
      transaction: transaction,
    );
  }

  /// Updates all [PackQuestion]s in the list and returns the updated rows. If
  /// [columns] is provided, only those columns will be updated. Defaults to
  /// all columns.
  /// This is an atomic operation, meaning that if one of the rows fails to
  /// update, none of the rows will be updated.
  ///
  /// If [noReturn] is set to `true`, the updated rows are not read back from
  /// the database and an empty list is returned. This avoids the overhead of
  /// transferring and deserializing the rows when the result is not needed.
  Future<List<PackQuestion>> update(
    _is.DatabaseSession session,
    List<PackQuestion> rows, {
    _is.ColumnSelections<PackQuestionTable>? columns,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.update<PackQuestion>(
      rows,
      columns: columns?.call(PackQuestion.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Updates a single [PackQuestion]. The row needs to have its id set.
  /// Optionally, a list of [columns] can be provided to only update those
  /// columns. Defaults to all columns.
  Future<PackQuestion> updateRow(
    _is.DatabaseSession session,
    PackQuestion row, {
    _is.ColumnSelections<PackQuestionTable>? columns,
    _is.Transaction? transaction,
  }) async {
    return session.db.updateRow<PackQuestion>(
      row,
      columns: columns?.call(PackQuestion.t),
      transaction: transaction,
    );
  }

  /// Updates a single [PackQuestion] by its [id] with the specified [columnValues].
  /// Returns the updated row or null if no row with the given id exists.
  Future<PackQuestion?> updateById(
    _is.DatabaseSession session,
    int id, {
    required _is.ColumnValueListBuilder<PackQuestionUpdateTable> columnValues,
    _is.Transaction? transaction,
  }) async {
    return session.db.updateById<PackQuestion>(
      id,
      columnValues: columnValues(PackQuestion.t.updateTable),
      transaction: transaction,
    );
  }

  /// Updates all [PackQuestion]s matching the [where] expression with the specified [columnValues].
  /// Returns the list of updated rows.
  ///
  /// If [noReturn] is set to `true`, the updated rows are not read back from
  /// the database and an empty list is returned. This avoids the overhead of
  /// transferring and deserializing the rows when the result is not needed.
  Future<List<PackQuestion>> updateWhere(
    _is.DatabaseSession session, {
    required _is.ColumnValueListBuilder<PackQuestionUpdateTable> columnValues,
    required _is.WhereExpressionBuilder<PackQuestionTable> where,
    int? limit,
    int? offset,
    _is.OrderByBuilder<PackQuestionTable>? orderBy,
    _is.OrderByListBuilder<PackQuestionTable>? orderByList,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.updateWhere<PackQuestion>(
      columnValues: columnValues(PackQuestion.t.updateTable),
      where: where(PackQuestion.t),
      limit: limit,
      offset: offset,
      orderBy: orderBy?.call(PackQuestion.t),
      orderByList: orderByList?.call(PackQuestion.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Deletes all [PackQuestion]s in the list and returns the deleted rows.
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
  Future<List<PackQuestion>> delete(
    _is.DatabaseSession session,
    List<PackQuestion> rows, {
    _is.OrderByBuilder<PackQuestionTable>? orderBy,
    _is.OrderByListBuilder<PackQuestionTable>? orderByList,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.delete<PackQuestion>(
      rows,
      orderBy: orderBy?.call(PackQuestion.t),
      orderByList: orderByList?.call(PackQuestion.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Deletes a single [PackQuestion].
  Future<PackQuestion> deleteRow(
    _is.DatabaseSession session,
    PackQuestion row, {
    _is.Transaction? transaction,
  }) async {
    return session.db.deleteRow<PackQuestion>(
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
  Future<List<PackQuestion>> deleteWhere(
    _is.DatabaseSession session, {
    required _is.WhereExpressionBuilder<PackQuestionTable> where,
    _is.OrderByBuilder<PackQuestionTable>? orderBy,
    _is.OrderByListBuilder<PackQuestionTable>? orderByList,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.deleteWhere<PackQuestion>(
      where: where(PackQuestion.t),
      orderBy: orderBy?.call(PackQuestion.t),
      orderByList: orderByList?.call(PackQuestion.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Counts the number of rows matching the [where] expression. If omitted,
  /// will return the count of all rows in the table.
  Future<int> count(
    _is.DatabaseSession session, {
    _is.WhereExpressionBuilder<PackQuestionTable>? where,
    int? limit,
    _is.Transaction? transaction,
  }) async {
    return session.db.count<PackQuestion>(
      where: where?.call(PackQuestion.t),
      limit: limit,
      transaction: transaction,
    );
  }

  /// Acquires row-level locks on [PackQuestion] rows matching the [where] expression.
  Future<void> lockRows(
    _is.DatabaseSession session, {
    required _is.WhereExpressionBuilder<PackQuestionTable> where,
    required _is.LockMode lockMode,
    required _is.Transaction transaction,
    _is.LockBehavior lockBehavior = _is.LockBehavior.wait,
  }) async {
    return session.db.lockRows<PackQuestion>(
      where: where(PackQuestion.t),
      lockMode: lockMode,
      lockBehavior: lockBehavior,
      transaction: transaction,
    );
  }
}
