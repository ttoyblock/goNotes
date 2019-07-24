#!/bin/bash
echo 'generate db model'


cur=`pwd`/dbnotes/modelgenerator

go run $cur/modelgenerator.go \
-tplFile=$cur'/model_test.tpl' \
-modelFolder='./model_test/' \    # 输出目录
-packageName='model' \
-dbIP='127.0.0.1'  \
-dbPort=3306 \
-dbConnection='dbhelper.DB' \
-dbName='dbnote' \
-userName='root' \
-pwd='123456' \
-genTable='mail#msg#notice' \

echo 'done'

