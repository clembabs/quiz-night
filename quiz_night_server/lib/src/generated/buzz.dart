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

abstract class Buzz implements _is.TableRow<int?>, _is.ProtocolSerialization {
  Buzz._({
    this.id,
    required this.playerId,
    required this.questionId,
    required this.buzzedAt,
    this.wasCorrect,
    bool? lockedOut,
  }) : lockedOut = lockedOut ?? false;

  factory Buzz({
    int? id,
    required int playerId,
    required int questionId,
    required DateTime buzzedAt,
    bool? wasCorrect,
    bool? lockedOut,
  }) = _BuzzImpl;

  factory Buzz.fromJson(Map<String, dynamic> jsonSerialization) {
    return Buzz(
      id: jsonSerialization['id'] as int?,
      playerId: jsonSerialization['playerId'] as int,
      questionId: jsonSerialization['questionId'] as int,
      buzzedAt: _is.DateTimeJsonExtension.fromJson(
        jsonSerialization['buzzedAt'],
      ),
      wasCorrect: jsonSerialization['wasCorrect'] == null
          ? null
          : _is.BoolJsonExtension.fromJson(jsonSerialization['wasCorrect']),
      lockedOut: jsonSerialization['lockedOut'] == null
          ? null
          : _is.BoolJsonExtension.fromJson(jsonSerialization['lockedOut']),
    );
  }

  static final t = BuzzTable();

  static const db = BuzzRepository._();

  @override
  int? id;

  int playerId;

  int questionId;

  DateTime buzzedAt;

  bool? wasCorrect;

  bool lockedOut;

  @override
  _is.Table<int?> get table => t;

  /// Returns a shallow copy of this [Buzz]
  /// with some or all fields replaced by the given arguments.
  @_is.useResult
  Buzz copyWith({
    int? id,
    int? playerId,
    int? questionId,
    DateTime? buzzedAt,
    bool? wasCorrect,
    bool? lockedOut,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'Buzz',
      if (id != null) 'id': id,
      'playerId': playerId,
      'questionId': questionId,
      'buzzedAt': buzzedAt.toJson(),
      if (wasCorrect != null) 'wasCorrect': wasCorrect,
      'lockedOut': lockedOut,
    };
  }

  @override
  Map<String, dynamic> toJsonForProtocol() {
    return {
      '__className__': 'Buzz',
      if (id != null) 'id': id,
      'playerId': playerId,
      'questionId': questionId,
      'buzzedAt': buzzedAt.toJson(),
      if (wasCorrect != null) 'wasCorrect': wasCorrect,
      'lockedOut': lockedOut,
    };
  }

  static BuzzInclude include() {
    return BuzzInclude._();
  }

  static BuzzIncludeList includeList({
    _is.WhereExpressionBuilder<BuzzTable>? where,
    int? limit,
    int? offset,
    _is.OrderByBuilder<BuzzTable>? orderBy,
    _is.OrderByListBuilder<BuzzTable>? orderByList,
    BuzzInclude? include,
  }) {
    return BuzzIncludeList._(
      where: where,
      limit: limit,
      offset: offset,
      orderBy: orderBy?.call(Buzz.t),
      orderByList: orderByList?.call(Buzz.t),
      include: include,
    );
  }

  @override
  String toString() {
    return _is.SerializationManager.encode(this);
  }
}

class _Undefined {}

class _BuzzImpl extends Buzz {
  _BuzzImpl({
    int? id,
    required int playerId,
    required int questionId,
    required DateTime buzzedAt,
    bool? wasCorrect,
    bool? lockedOut,
  }) : super._(
         id: id,
         playerId: playerId,
         questionId: questionId,
         buzzedAt: buzzedAt,
         wasCorrect: wasCorrect,
         lockedOut: lockedOut,
       );

  /// Returns a shallow copy of this [Buzz]
  /// with some or all fields replaced by the given arguments.
  @_is.useResult
  @override
  Buzz copyWith({
    Object? id = _Undefined,
    int? playerId,
    int? questionId,
    DateTime? buzzedAt,
    Object? wasCorrect = _Undefined,
    bool? lockedOut,
  }) {
    return Buzz(
      id: id is int? ? id : this.id,
      playerId: playerId ?? this.playerId,
      questionId: questionId ?? this.questionId,
      buzzedAt: buzzedAt ?? this.buzzedAt,
      wasCorrect: wasCorrect is bool? ? wasCorrect : this.wasCorrect,
      lockedOut: lockedOut ?? this.lockedOut,
    );
  }
}

class BuzzUpdateTable extends _is.UpdateTable<BuzzTable> {
  BuzzUpdateTable(super.table);

  _is.ColumnValue<int, int> playerId(int value) => _is.ColumnValue(
    table.playerId,
    value,
  );

  _is.ColumnValue<int, int> questionId(int value) => _is.ColumnValue(
    table.questionId,
    value,
  );

  _is.ColumnValue<DateTime, DateTime> buzzedAt(DateTime value) =>
      _is.ColumnValue(
        table.buzzedAt,
        value,
      );

  _is.ColumnValue<bool, bool> wasCorrect(bool? value) => _is.ColumnValue(
    table.wasCorrect,
    value,
  );

  _is.ColumnValue<bool, bool> lockedOut(bool value) => _is.ColumnValue(
    table.lockedOut,
    value,
  );
}

class BuzzTable extends _is.Table<int?> {
  BuzzTable({super.tableRelation}) : super(tableName: 'buzz') {
    updateTable = BuzzUpdateTable(this);
    playerId = _is.ColumnInt(
      'playerId',
      this,
    );
    questionId = _is.ColumnInt(
      'questionId',
      this,
    );
    buzzedAt = _is.ColumnDateTime(
      'buzzedAt',
      this,
    );
    wasCorrect = _is.ColumnBool(
      'wasCorrect',
      this,
    );
    lockedOut = _is.ColumnBool(
      'lockedOut',
      this,
      hasDefault: true,
    );
  }

  late final BuzzUpdateTable updateTable;

  late final _is.ColumnInt playerId;

  late final _is.ColumnInt questionId;

  late final _is.ColumnDateTime buzzedAt;

  late final _is.ColumnBool wasCorrect;

  late final _is.ColumnBool lockedOut;

  @override
  List<_is.Column> get columns => [
    id,
    playerId,
    questionId,
    buzzedAt,
    wasCorrect,
    lockedOut,
  ];
}

class BuzzInclude extends _is.IncludeObject {
  BuzzInclude._();

  @override
  Map<String, _is.Include?> get includes => {};

  @override
  _is.Table<int?> get table => Buzz.t;
}

class BuzzIncludeList extends _is.IncludeList {
  BuzzIncludeList._({
    _is.WhereExpressionBuilder<BuzzTable>? where,
    super.limit,
    super.offset,
    super.orderBy,
    super.orderByList,
    super.include,
  }) {
    super.where = where?.call(Buzz.t);
  }

  @override
  Map<String, _is.Include?> get includes => include?.includes ?? {};

  @override
  _is.Table<int?> get table => Buzz.t;
}

class BuzzRepository {
  const BuzzRepository._();

  /// Returns a list of [Buzz]s matching the given query parameters.
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
  Future<List<Buzz>> find(
    _is.DatabaseSession session, {
    _is.WhereExpressionBuilder<BuzzTable>? where,
    int? limit,
    int? offset,
    _is.OrderByBuilder<BuzzTable>? orderBy,
    _is.OrderByListBuilder<BuzzTable>? orderByList,
    _is.Transaction? transaction,
    _is.LockMode? lockMode,
    _is.LockBehavior? lockBehavior,
  }) async {
    return session.db.find<Buzz>(
      where: where?.call(Buzz.t),
      orderBy: orderBy?.call(Buzz.t),
      orderByList: orderByList?.call(Buzz.t),
      limit: limit,
      offset: offset,
      transaction: transaction,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Returns the first matching [Buzz] matching the given query parameters.
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
  Future<Buzz?> findFirstRow(
    _is.DatabaseSession session, {
    _is.WhereExpressionBuilder<BuzzTable>? where,
    int? offset,
    _is.OrderByBuilder<BuzzTable>? orderBy,
    _is.OrderByListBuilder<BuzzTable>? orderByList,
    _is.Transaction? transaction,
    _is.LockMode? lockMode,
    _is.LockBehavior? lockBehavior,
  }) async {
    return session.db.findFirstRow<Buzz>(
      where: where?.call(Buzz.t),
      orderBy: orderBy?.call(Buzz.t),
      orderByList: orderByList?.call(Buzz.t),
      offset: offset,
      transaction: transaction,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Finds a single [Buzz] by its [id] or null if no such row exists.
  Future<Buzz?> findById(
    _is.DatabaseSession session,
    int id, {
    _is.Transaction? transaction,
    _is.LockMode? lockMode,
    _is.LockBehavior? lockBehavior,
  }) async {
    return session.db.findById<Buzz>(
      id,
      transaction: transaction,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Inserts all [Buzz]s in the list and returns the inserted rows.
  ///
  /// The returned [Buzz]s will have their `id` fields set.
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
  Future<List<Buzz>> insert(
    _is.DatabaseSession session,
    List<Buzz> rows, {
    _is.Transaction? transaction,
    bool ignoreConflicts = false,
    bool noReturn = false,
  }) async {
    return session.db.insert<Buzz>(
      rows,
      transaction: transaction,
      ignoreConflicts: ignoreConflicts,
      noReturn: noReturn,
    );
  }

  /// Inserts a single [Buzz] and returns the inserted row.
  ///
  /// The returned [Buzz] will have its `id` field set.
  Future<Buzz> insertRow(
    _is.DatabaseSession session,
    Buzz row, {
    _is.Transaction? transaction,
  }) async {
    return session.db.insertRow<Buzz>(
      row,
      transaction: transaction,
    );
  }

  /// Upserts all [Buzz]s in the list and returns the resulting rows.
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
  /// The returned [Buzz]s will have their `id` fields set.
  ///
  /// This is an atomic operation, meaning that if one of the rows fails,
  /// none of the rows will be affected.
  ///
  /// If [noReturn] is set to `true`, the resulting rows are not read back from
  /// the database and an empty list is returned. This avoids the overhead of
  /// transferring and deserializing the rows when the result is not needed.
  Future<List<Buzz>> upsert(
    _is.DatabaseSession session,
    List<Buzz> rows, {
    required _is.ColumnSelections<BuzzTable> conflictColumns,
    _is.ColumnSelections<BuzzTable>? updateColumns,
    _is.WhereExpressionBuilder<BuzzTable>? updateWhere,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.upsert<Buzz>(
      rows,
      conflictColumns: conflictColumns(Buzz.t),
      updateColumns: updateColumns?.call(Buzz.t),
      updateWhere: updateWhere?.call(Buzz.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Upserts a single [Buzz] and returns the resulting row.
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
  /// The returned [Buzz] will have its `id` field set.
  Future<Buzz?> upsertRow(
    _is.DatabaseSession session,
    Buzz row, {
    required _is.ColumnSelections<BuzzTable> conflictColumns,
    _is.ColumnSelections<BuzzTable>? updateColumns,
    _is.WhereExpressionBuilder<BuzzTable>? updateWhere,
    _is.Transaction? transaction,
  }) async {
    return session.db.upsertRow<Buzz>(
      row,
      conflictColumns: conflictColumns(Buzz.t),
      updateColumns: updateColumns?.call(Buzz.t),
      updateWhere: updateWhere?.call(Buzz.t),
      transaction: transaction,
    );
  }

  /// Updates all [Buzz]s in the list and returns the updated rows. If
  /// [columns] is provided, only those columns will be updated. Defaults to
  /// all columns.
  /// This is an atomic operation, meaning that if one of the rows fails to
  /// update, none of the rows will be updated.
  ///
  /// If [noReturn] is set to `true`, the updated rows are not read back from
  /// the database and an empty list is returned. This avoids the overhead of
  /// transferring and deserializing the rows when the result is not needed.
  Future<List<Buzz>> update(
    _is.DatabaseSession session,
    List<Buzz> rows, {
    _is.ColumnSelections<BuzzTable>? columns,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.update<Buzz>(
      rows,
      columns: columns?.call(Buzz.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Updates a single [Buzz]. The row needs to have its id set.
  /// Optionally, a list of [columns] can be provided to only update those
  /// columns. Defaults to all columns.
  Future<Buzz> updateRow(
    _is.DatabaseSession session,
    Buzz row, {
    _is.ColumnSelections<BuzzTable>? columns,
    _is.Transaction? transaction,
  }) async {
    return session.db.updateRow<Buzz>(
      row,
      columns: columns?.call(Buzz.t),
      transaction: transaction,
    );
  }

  /// Updates a single [Buzz] by its [id] with the specified [columnValues].
  /// Returns the updated row or null if no row with the given id exists.
  Future<Buzz?> updateById(
    _is.DatabaseSession session,
    int id, {
    required _is.ColumnValueListBuilder<BuzzUpdateTable> columnValues,
    _is.Transaction? transaction,
  }) async {
    return session.db.updateById<Buzz>(
      id,
      columnValues: columnValues(Buzz.t.updateTable),
      transaction: transaction,
    );
  }

  /// Updates all [Buzz]s matching the [where] expression with the specified [columnValues].
  /// Returns the list of updated rows.
  ///
  /// If [noReturn] is set to `true`, the updated rows are not read back from
  /// the database and an empty list is returned. This avoids the overhead of
  /// transferring and deserializing the rows when the result is not needed.
  Future<List<Buzz>> updateWhere(
    _is.DatabaseSession session, {
    required _is.ColumnValueListBuilder<BuzzUpdateTable> columnValues,
    required _is.WhereExpressionBuilder<BuzzTable> where,
    int? limit,
    int? offset,
    _is.OrderByBuilder<BuzzTable>? orderBy,
    _is.OrderByListBuilder<BuzzTable>? orderByList,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.updateWhere<Buzz>(
      columnValues: columnValues(Buzz.t.updateTable),
      where: where(Buzz.t),
      limit: limit,
      offset: offset,
      orderBy: orderBy?.call(Buzz.t),
      orderByList: orderByList?.call(Buzz.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Deletes all [Buzz]s in the list and returns the deleted rows.
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
  Future<List<Buzz>> delete(
    _is.DatabaseSession session,
    List<Buzz> rows, {
    _is.OrderByBuilder<BuzzTable>? orderBy,
    _is.OrderByListBuilder<BuzzTable>? orderByList,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.delete<Buzz>(
      rows,
      orderBy: orderBy?.call(Buzz.t),
      orderByList: orderByList?.call(Buzz.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Deletes a single [Buzz].
  Future<Buzz> deleteRow(
    _is.DatabaseSession session,
    Buzz row, {
    _is.Transaction? transaction,
  }) async {
    return session.db.deleteRow<Buzz>(
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
  Future<List<Buzz>> deleteWhere(
    _is.DatabaseSession session, {
    required _is.WhereExpressionBuilder<BuzzTable> where,
    _is.OrderByBuilder<BuzzTable>? orderBy,
    _is.OrderByListBuilder<BuzzTable>? orderByList,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.deleteWhere<Buzz>(
      where: where(Buzz.t),
      orderBy: orderBy?.call(Buzz.t),
      orderByList: orderByList?.call(Buzz.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Counts the number of rows matching the [where] expression. If omitted,
  /// will return the count of all rows in the table.
  Future<int> count(
    _is.DatabaseSession session, {
    _is.WhereExpressionBuilder<BuzzTable>? where,
    int? limit,
    _is.Transaction? transaction,
  }) async {
    return session.db.count<Buzz>(
      where: where?.call(Buzz.t),
      limit: limit,
      transaction: transaction,
    );
  }

  /// Acquires row-level locks on [Buzz] rows matching the [where] expression.
  Future<void> lockRows(
    _is.DatabaseSession session, {
    required _is.WhereExpressionBuilder<BuzzTable> where,
    required _is.LockMode lockMode,
    required _is.Transaction transaction,
    _is.LockBehavior lockBehavior = _is.LockBehavior.wait,
  }) async {
    return session.db.lockRows<Buzz>(
      where: where(Buzz.t),
      lockMode: lockMode,
      lockBehavior: lockBehavior,
      transaction: transaction,
    );
  }
}
