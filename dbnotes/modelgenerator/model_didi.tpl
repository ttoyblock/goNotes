{{$exportModelName := .ModelName | FirstCharUpperPerUnderline}}

package {{.PackageName}}

const(
	// CacheKey{{$exportModelName}} cache key format based on {{$exportModelName}} id
	CacheKey{{$exportModelName}} = "cache:{{.TableName}}:v1:id:%v"
)

type {{$exportModelName}} struct {
{{range .TableSchema}} {{.COLUMN_NAME | ExportColumn}} {{.DATA_TYPE | TypeConvertV2}} {{.COLUMN_NAME | Tags}} // {{.COLUMN_COMMENT}}
{{end}}Props     {{$exportModelName}}Props `db:"-"`
}

type {{$exportModelName}}Props struct {
}

func (m *{{$exportModelName}}) TableName() string {
	return "{{.TableName}}"
}

func (m *{{$exportModelName}}) PkName() string {
	return "{{.PkColumn}}"
}

func (m *{{$exportModelName}}) PkValue() int64 {
	return m.{{.PkColumn | ExportColumn}}
}

func (m *{{$exportModelName}}) CacheKey() string {
	return fmt.Sprintf(CacheKey{{$exportModelName}}, m.{{.PkColumn | ExportColumn}})
}


func (m *{{$exportModelName}}) columns() string {
	return " {{Join .ColumnNames ","}} "
}

func (m *{{$exportModelName}}) CacheExpireTime() time.Duration {
	return redis_db.ONE_MONTH
}

func (m *{{$exportModelName}}) EncodingProps() ([]byte, error) {
	propsValue, err := json.Marshal(m.Props)
	if err != nil {
		return nil, err
	}
	return propsValue, nil
}

func (m *{{$exportModelName}}) DecodingProps(propsValue []byte) error {
	if len(propsValue) == 0 {
		m.Props = {{$exportModelName}}Props{}
		return nil
	}
	return json.Unmarshal(propsValue, &m.Props)
}

// ModelHelper{{$exportModelName}} - function to transfer {{$exportModelName}} instances to Model interfaces
func ModelHelper{{$exportModelName}}(ids []int64) []models.Model {
	instanceSlice := make([]models.Model, len(ids))
	for i, id := range ids {
		instanceSlice[i] = &{{$exportModelName}}{ {{.PkColumn | ExportColumn}}: id}
	}
	return instanceSlice
}

// Flush - instance method to flush caches
func (m *{{$exportModelName}}) Flush() error {
	instanceCacheKey := m.CacheKey()
	return master_db.DelKey(instanceCacheKey)
}