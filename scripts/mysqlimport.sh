#!/bin/sh
# import test_table.sql into test_database.test_table
# content in test_table.sql like "123,abc,334; N,ddd,999"

function import_from_file()
{
   echo "开始导入<${MYSQL_TABLE:-jeesite}.sql>到<${MYSQL_HOST:-127.0.0.1}/${MYSQL_DATABASE:-jeesite}> ..."
   echo -n -e "\t"
   mysqlimport -h ${MYSQL_HOST:-127.0.0.1} -u${MYSQL_USER:-admin} -p${MYSQL_PASS} --fields-terminated-by=',' \
   --lines-terminated-by=';' -L ${MYSQL_DATABASE:-jeesite} /data/${MYSQL_TABLE:-jeesite}.sql
   if [ 0 -eq $? ]; then
      echo "导入完成！"
   else
      echo "导入过程中出现错误，错误码为：$?"
      exit
   fi
   echo
}

# call function
import_from_file