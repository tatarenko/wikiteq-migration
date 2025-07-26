#!/bin/bash

while [ $# -gt 0 ]; do
    case "$1" in
        --docker-path)
            docker_path="$2"
            shift 2 || exit 1
            ;;
        --result-path)
            result_path="$2"
            shift 2 || exit 1
            ;;
        *)  
            echo "Unknown option: $1" >&2
            exit 1
            ;;
    esac
done

if [ -z "$docker_path" ]; then
    echo 'Error: `--docker-path PATH` is required' >&2
    exit 1
fi

if [ -z "$result_path" ]; then
    echo 'Error: `--result-path PATH` is required' >&2
    exit 1
fi

result_filename=`basename "$result_path"` 
result_dirname=`dirname "$result_path"`

if [ -d "$result_dirname" ]; then
    mkdir -p "${result_dirname}" || { echo "can't create non-existent dir ${result_dirname}! aborting..."; exit 1; }
fi

if [ -f "${result_dirname}/${result_filename}.2" ]; then
    mv "${result_dirname}/${result_filename}.2" "${result_dirname}/${result_filename}.3"
fi

if [ -f "${result_dirname}/${result_filename}.1" ]; then
    mv "${result_dirname}/${result_filename}.1" "${result_dirname}/${result_filename}.2"
fi

if [ -f "${result_dirname}/${result_filename}" ]; then
    mv "${result_dirname}/${result_filename}" "${result_dirname}/${result_filename}.1"
fi

docker-compose --project-directory="${docker_path}" exec -T db /bin/bash -c 'mysqldump --all-databases --triggers --routines --events --single-transaction --skip-lock-tables --column-statistics -uroot -p"$MYSQL_ROOT_PASSWORD"' | gzip  > "${result_path}"


