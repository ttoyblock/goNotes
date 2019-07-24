{{$exportModelName := .ModelName | FirstCharUpperPerUnderline}}

package {{.PackageName}}

type {{$exportModelName}} struct {
{{range .TableSchema}} {{.COLUMN_NAME | ExportColumn}} {{.DATA_TYPE | TypeConvert}} {{.COLUMN_NAME | Tags}} // {{.COLUMN_COMMENT}}
{{end}}}

var Default{{$exportModelName}} = &{{$exportModelName}}{}

func (m *{{$exportModelName}}) errWrite(err error, sql string, addParams ...interface{}) {
	type ErrorType struct {
		{{$exportModelName}}
		AddParams []interface{} `json:"add_params"`
	}

	errType := ErrorType{
		{{$exportModelName}}: *m,
		AddParams:    addParams,
	}

	paramsJSON, _ := json.Marshal(errType)
	dlog.ERROR("msg", "dbError", "tableName", "{{.TableName}}", "error", err.Error(), "sql", sql, "params", string(paramsJSON))
}

func (m *{{$exportModelName}}) tableName() string {
	return "{{.TableName}}"
}

func (m *{{$exportModelName}}) columns() string {
	return " {{Join .ColumnNames ","}} "
}

func (m *{{$exportModelName}}) _selectBody(db *sql.DB, sqlText string, params []interface{}, errMap map[string]interface{}) (_bodyArr []{{$exportModelName}}, err error) {
	rows, err := db.Query(sqlText, params...)
	if nil != err {
		m.errWrite(err, sqlText, errMap)
		return
	}
	defer rows.Close()

	for rows.Next() {
		_one := {{$exportModelName}}{}
		err = rows.Scan(
			{{range .TableSchema}}&_one.{{.COLUMN_NAME | ExportColumn}},
			{{end}}
		)
		if nil != err {
			m.errWrite(err, sqlText, errMap)
			continue
		}
		_bodyArr = append(_bodyArr, _one)
	}
	return
}

func (m *{{$exportModelName}}) _updateBody(db *sql.DB, sqlText string, params []interface{}, errMap map[string]interface{}) (b bool, err error) {
	stmt, err := db.Prepare(sqlText)
	if nil != err {
		m.errWrite(err, sqlText, errMap)
		return
	}
	defer stmt.Close()

	res, err := stmt.Exec(params...)
	if nil != err {
		m.errWrite(err, sqlText, errMap)
		return
	}

	_count, err := res.RowsAffected()
	if nil != err {
		m.errWrite(err, sqlText, errMap)
		return
	}
	return _count > 0, nil
}

func (m *{{$exportModelName}}) Insert(db *sql.DB, valInfo *{{$exportModelName}}) (b bool, err error) {
	const sqlText = "INSERT INTO {{.TableName}}({{Join .ColumnNames ","}}) VALUES({{.ColumnCount | MakeQuestionMarkList}})"
	stmt, err := db.Prepare(sqlText)
	if nil != err {
		dlog.ERROR("error", err, "sql", sqlText)
		return
	}
	defer stmt.Close()

	res, err := stmt.Exec(
		{{range .TableSchema}}valInfo.{{.COLUMN_NAME | ExportColumn}},
		{{end}}
	)
	if nil != err {
		dlog.ERROR("error", err, "sql", sqlText)
		return
	}

	n, err := res.RowsAffected()
	if nil != err {
		dlog.ERROR("error", err, "sql", sqlText)
		return
	}
	return n > 0, nil
}