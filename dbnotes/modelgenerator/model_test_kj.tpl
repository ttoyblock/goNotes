{{$exportModelName := .ModelName | FirstCharUpperPerUnderline}}

package {{.PackageName}}

const {{StringUpper .TableName}}_TABLE = "{{.TableName}}"

type {{$exportModelName}} struct {
{{range .TableSchema}} {{.COLUMN_NAME | ExportColumn}} {{.DATA_TYPE | TypeConvert}} {{.COLUMN_NAME | Tags}} // {{.COLUMN_COMMENT}}
{{end}}}

type {{$exportModelName}} struct {
	usql.KJTable
}

func New{{$exportModelName}}(tb *sql.DB) *{{$exportModelName}} {
	return &{{$exportModelName}}{KJTable: *usql.New(tb, {{StringUpper .TableName}}_TABLE)}
}

func (m *{{$exportModelName}}) tableName() string {
	return "{{.TableName}}"
}

func (m *{{$exportModelName}}) columns() string {
	return " {{Join .ColumnNames ","}} "
}