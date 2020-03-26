#!/bin/bash
echo 'generate db model'


cur=`pwd`/dbnotes/modelgenerator

go run $cur/modelgenerator.go \
-tplFile=$cur'/model_test.tpl' \
-modelFolder='./model_test/' \
-packageName='model' \
-dbIP='alpha'  \
-dbPort=3306 \
-dbConnection='dbhelper.DB' \
-dbName='ultrax' \
-userName='root' \
-pwd='' \
-genTable='pre_system_time_task' \

echo 'done'

# sh dbnotes/modelgenerator/dbmodelgen.sh