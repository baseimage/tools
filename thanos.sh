###############################################################
#                                                             #
#                                                             #
#                                                             #
#                                                             #
###############################################################

#!/usr/bin/env bash -e

# source database define
export STRIDE=99999


function check_env_vars () {
  for name; do
    : ${!name:?$name must not be empty}
  done
}

function check_command(){
    cmd=$1
    if hash "$cmd" 2>/dev/null; then
        return 0
    else
        exit 1
    fi
}

function verify_export_data(){
    minid=$1
    maxid=$2
    count=$3
    cnt=0

    while true; do 
        end_id=$((minid+STRIDE))
        
        if [ ${end_id} -ge ${maxid} ]; then
            end_id=${maxid}
            flag=true
        fi

        result=$( echo $(${excmd} --execute="SELECT count(id) FROM ${TABLE_NAME} WHERE id BETWEEN ${minid} AND ${end_id};") | awk '{print $NF}')

        cnt=$((cnt+result))

        if [ "${flag}" == "true" ]; then
            break
        fi

    done

    if [ ${cnt} -eq ${count} ];then
        echo "ok"
    else
        echo "error"
    fi
}

function main(){
    if ! check_env_vars "EX_DB_PASSWD" "IM_DB_PASSWD" "TABLE_NAME"; then
      exit 1
    fi
    
    if check_command "mysql";then
        excmd="$(which mysql) --host=${EX_DB_HOST} --port=${EX_DB_PORT} --user=${EX_DB_USER} --password=${EX_DB_PASSWD} --database=${EX_DB_NAME}"
        imcmd="$(which mysql) --host=${IM_DB_HOST} --port=${IM_DB_PORT} --user=${IM_DB_USER} --password=${IM_DB_PASSWD} --database=${IM_DB_NAME}"
    fi

    case ${IM_TABLE_NAME} in 
        "orders"|"account_histories")
            #IM_TABLE_NAME=${TABLE_NAME}_$(date +%Y%m%d --date="-1 day")
            IM_TABLE_NAME=${TABLE_NAME}_20200220
            ;;
        "trades")
            # if [ $(date +%Y%m%d --date="-1 day") == $(date -d "-$(date +%d) days  month" +%Y%m%d) ];then
            #     IM_TABLE_NAME=${TABLE_NAME}_$(date +%Y%m --date="-1 month")
            # else
            #    IM_TABLE_NAME=${TABLE_NAME}_$(date +%Y%m)
            # fi
            IM_TABLE_NAME=${TABLE_NAME}_202002
            ;;
        *)
            echo "error"
            exit 1
    esac

    import_data=$(${imcmd} --execute="SELECT min(id),max(id),count(id) FROM ${TABLE_NAME}")

    minid=$(echo ${import_data} | awk '{print $4}')
    maxid=$(echo ${import_data} | awk '{print $5}')
    count=$(echo ${import_data} | awk '{print $6}')

    verify_export_data "${minid}" "${maxid}" "${count}"

}

main $@
