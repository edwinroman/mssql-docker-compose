set -e

init_db(){
    INPUT_SQL_FILE="db-init.sql"
    until /opt/mssql-tools/bin/sqlcmd -S localhost,1433 -U sa -P "${SA_PASSWORD}" -d master -i $INPUT_SQL_FILE > /dev/null 2>&1
    do
        echo -e "\033[31mSQL server is unavaileble - sleeping"
        sleep 10
    done
    echo -e "\033[31mDone initialize a database" 
}

init_db & /opt/mssql/bin/sqlservr

eval $1
