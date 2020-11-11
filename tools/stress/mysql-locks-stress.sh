#!/bin/bash

# https://ops.tips/blog/limits-aws-efs-nfs-locks/
# Example
  #  sh mysql-locks-stress.sh 300 mysql-6c88956cb5-n2g7b testdb password

# exit on any failed execution
set -o errexit

number_of_tables="$1"
pod="$2"
db="$3"
mysqlpass="$4"

create_table () {
        local name=$1
        echo "Creating table: $name"
        kubectl -n mysql exec $pod -- mysql --password=$mysqlpass --database=$db -e "CREATE TABLE $name (  id INT,  data VARCHAR(100) );"
}

main () {
    if [[ -z "$number_of_tables" ]]; then
        echo "ERROR:
        An argument (number of tables) must be supplied.
        "
        exit 1
    fi

    for i in $(seq 1 $number_of_tables); do
        create_table mytable$i
    done
}

main
