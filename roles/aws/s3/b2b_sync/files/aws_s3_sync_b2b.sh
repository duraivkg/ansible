#!/usr/bin/env bash
# -----------------------------------------------------------------------------------
#  aws_s3_sync_b2b.sh
# =============
# normal shell routine to perform aws s3 bucket to bucket sync
#
# Performs the following:
# 	1) aws s3 sync script, supports parallel processing
#
# Parameters :
#
# Durai Govindasamy | duraivkg@gmail.com | https://www.linkedin.com/pub/durai-govindasamy/68/81a/239
#
# -----------------------------------------------------------------------------------
# Modification History
# ====================
#
# Date          Name       Version          Description
# ----          ----       --------         -----------
# 07/13/2016   Durai G     1.0
# ------------------------------------------------------------------------------------
#
# ./aws_s3_sync_b2b.sh --src_bucket sync-test-src --target_bucket sync-test-tgt --target_info_mode dynamic --sync_forks 2 --target_bucket_dir new_3 --sleep_timer 1
#
# Global vars/inits
JOB_NAME="`basename $0`"
base_script_name=${JOB_NAME%.*}
workspace="`pwd`/${base_script_name}"
logs_dir="${workspace}/logs"
target_info_mode="static"
target_bucket_dir="NA"
extra_vars="NA"
aws_caller="NA"
sync_forks=10
sleep_timer=5
wait="yes"
tag_archive="archive_target"

usage() {
        echo
        echo "Usage list for $JOB_NAME"
        echo
        echo "Options:"
        echo
        echo "    --help                         - <help>"
        echo "    --workspace                    - workspace directory. Default=${workspace}"
        echo "    --logs_dir                     - logs_dir directory. Default=${logs_dir}"
        echo "    --target_info_mode             - choice[ static/dynamic ]. Default=${target_info_mode}"
        echo "    --src_bucket                   - s3 source bucket name."
        echo "    --target_bucket                - s3 target bucket name."
        echo "    --target_bucket_dir            - s3 target bucket dir. if specified the src objects will be synced to this directory in target. Default=${target_bucket_dir}"
        echo "    --tag_archive                  - s3 tag name in src bucket which defines the target bucket Default=${tag_archive}"
        echo "    --extra_vars                   - extra vars to aws cli if any. Default=${extra_vars}"
        echo "    --sync_forks                   - no of parallel threads. Default=${sync_forks}"
        echo "    --sleep_timer                  - sleep timer in seconds to monitor the parallel threads. Default=${sleep_timer}"
        echo "    --wait                         - launch the sub process and monitor them until all of them finishes. choice[ yes/no ] Default=${wait}"
        echo
        echo
}

get_params() {
    # validate the command line arguments
    while [[ $# -gt 0 ]]; do
        case $1 in
            --help) usage; exit 1;;
            --workspace) iworkspace="$2"; shift 2;;
            --logs_dir) ilogs_dir="$2"; shift 2;;
            --target_info_mode) itarget_info_mode="$2"; shift 2;;
            --src_bucket) isrc_bucket="$2"; shift 2;;
            --target_bucket) itarget_bucket="$2"; shift 2;;
            --target_bucket_dir) itarget_bucket_dir="$2"; shift 2;;
            --tag_archive) itag_archive="$2"; shift 2;;
            --extra_vars) iextra_vars="$2"; shift 2;;
            --sync_forks) isync_forks="$2"; shift 2;;
            --sleep_timer) isleep_timer="$2"; shift 2;;
            --wait) iwait="$2"; shift 2;;
            --aws_caller) iaws_caller="$2"; shift 2;;
            *) echo -e "\n msg: ERROR - get_params - In sufficient parameters passed. Please validate the usage list.\n script_arguments: ${l_script_caller}\n"; usage; exit 1;;
        esac
    done
}

val_params()
{
    if [[ ! "${l_workspace}" || ! "${l_target_info_mode}"  || ! "${l_src_bucket}"  || ! "${l_target_bucket}"  ]]; then
        write_log "0" "parameters passed are insufficient." "ERROR"
        write_log "0" "script_arguments: ${l_script_caller}"
        usage
        exit 1
    fi

    case ${l_target_info_mode} in
        static) echo ""; ;;
        dynamic)  echo ""; ;;
        *) write_log "0" "Invalid target_info_mode: ${l_target_info_mode}"; echo -e "\n msg: ERROR - In sufficient parameters passed. Please validate the usage list.\n script_arguments: ${l_script_caller}\n"; usage; exit 1;;
    esac

    if [ ${l_extra_vars} == "NA" ]; then
        l_extra_vars=" --output text"
    else
        l_extra_vars= "${l_extra_vars} --output text"
    fi

    if [ ${l_target_bucket_dir} == "NA" ]; then
        l_target_bucket_dir=""
    else
        l_target_bucket_dir="/${l_target_bucket_dir}"
    fi

    if [ ${l_aws_caller} == "NA" ]; then
        aws_caller="/usr/local/bin/aws"
    fi


    write_log "0" "script_arguments: ${l_script_caller}"
}


init_vars()
{
    lPwd=`pwd`
    l_workspace=${iworkspace-${workspace}}
    l_logs_dir=${ilogs_dir-${logs_dir}}
    l_target_info_mode=${itarget_info_mode-${target_info_mode}}
    l_src_bucket=${isrc_bucket-${src_bucket}}
    l_target_bucket=${itarget_bucket-${target_bucket}}
    l_target_bucket_dir=${itarget_bucket_dir-${target_bucket_dir}}
    l_extra_vars=${iextra_vars-${extra_vars}}
    l_sync_forks=${isync_forks-${sync_forks}}
    l_sleep_timer=${isleep_timer-${sleep_timer}}
    l_wait=${iwait-${wait}}
    l_tag_archive=${itag_archive-${tag_archive}}
    l_aws_caller=${iaws_caller-${aws_caller}}
    l_sub_process_dir=${l_workspace}/subprocess
    l_sub_process_log_dir="${l_sub_process_dir}/logs"

    if [ -d ${l_workspace} ]; then
        rm -rf ${l_workspace}/*
    fi

    mkdir -p ${l_workspace} ${l_logs_dir}
    s3_sync_log_file=${l_logs_dir}/s3_sync_${base_script_name}_`date +%Y%m%d`.log
    l_log_file=${l_logs_dir}/${JOB_NAME%.*}.log
    echo "l_log_file - ${l_log_file}"
}

print_vars()
{
    write_log 0 "$1: $2" "DEBUG"
}

val_return_code()
{
    if [ ${1} -ne 0 ]; then
        write_log "1" "$2 failed with exit code $1" "ERROR"
        print_footer
        exit 1
    else
        write_log "0" "$2 passed with exit code $1"
    fi
}

write_log()
{
    exit_code="${1}"
    message="${2}"
    context="${3}"
    l_exit_code=${exit_code:-"0"}
    l_context=${context:-"INFO"}
    l_caller=${FUNCNAME[1]}

    printf "%-5s %-5s %s %-5s %-20s %s %s\n" `date "+%D %T"`  "${l_exit_code}" "${l_context}" "${l_caller}" "${message}"
    printf "%-5s %-5s %s %-5s %-20s %s %s\n" `date "+%D %T"`  "${l_exit_code}" "${l_context}" "${l_caller}" "${message}" >> ${l_log_file}
}

print_footer()
{
    echo
    echo
    write_log 0 "Please refer the log file ${l_log_file} for details."
    echo
    echo
}

validate_env()
{
    # validate aws cli
    ${l_aws_caller} --version >/dev/null 2>&1
    l_rc="$?"

    if [ ${l_rc} -ne 0 ]; then
        write_log "0" "validate_env - failed to detect aws cli." "ERROR"
        exit 100
    fi
}

b2b_sync() {
    sync_s3_src_bucket=${1}
    sync_s3_target_bucket=${2}
    sync_s3_target_bucket_dir=${3}
    sync_s3_extra_vars=${4}
    sync_seq=${5}
    sync_forks=${6}

    mkdir -p ${l_sub_process_dir} ${l_sub_process_log_dir}

    sync_s3_sub_script_name="${sync_seq}_sync_script"
    sync_s3_sub_process_script=${l_sub_process_dir}/${sync_s3_sub_script_name}.sh
    sync_s3_sub_process_script_in_progress_log=${l_sub_process_log_dir}/${sync_s3_sub_script_name}_inprogress.log
    sync_s3_sub_process_script_success_log=${l_sub_process_log_dir}/${sync_s3_sub_script_name}_success.log
    sync_s3_sub_process_script_failed_log=${l_sub_process_log_dir}/${sync_s3_sub_script_name}_failed.log

    write_log 0 "sync_s3 - about to execute ${l_aws_caller} s3 sync s3://${sync_s3_src_bucket} s3://${sync_s3_target_bucket}${sync_s3_target_bucket_dir} ${sync_s3_extra_vars}  >> ${sync_s3_sub_process_script_in_progress_log}"
    l_cmd_string_01="${l_aws_caller} s3 sync s3://${sync_s3_src_bucket} s3://${sync_s3_target_bucket}${sync_s3_target_bucket_dir} ${sync_s3_extra_vars} --quiet > ${sync_s3_sub_process_script_in_progress_log}"
    l_cmd_string_02="l_rc=\$?; if [ \${l_rc} -ne 0 ]; then mv ${sync_s3_sub_process_script_in_progress_log} ${sync_s3_sub_process_script_failed_log}; else mv ${sync_s3_sub_process_script_in_progress_log} ${sync_s3_sub_process_script_success_log}; fi"

    mkdir -p ${l_workspace}
    echo "${l_cmd_string_01}" > ${sync_s3_sub_process_script}
    echo "${l_cmd_string_02}" >> ${sync_s3_sub_process_script}

    l_in_progress_process_count=`ls ${l_sub_process_log_dir}/*inprogress* 2>/dev/null | wc -l`

    if [[ ${l_sync_forks} -ne 0 ]]; then
        if [[ ${l_in_progress_process_count} -le ${l_sync_forks} ]]; then
            #write_log "0" "b2b_sync - launching in parallel mode as l_in_progress_process_count is ${l_in_progress_process_count} -le ${l_sync_forks}"
            write_log "0" "b2b_sync - launching in parallel mode"
            nohup sh ${sync_s3_sub_process_script} >/dev/null 2>&1 &
        else
            write_log "0" "b2b_sync - launching in serial mode as np of active(${l_in_progress_process_count}) parallel threads is ge to the limit (${l_sync_forks})"
            sh ${sync_s3_sub_process_script}
        fi
    else
        write_log "0" "b2b_sync - launching in serial mode"
        sh ${sync_s3_sub_process_script}
    fi

}

monitor_sub_process() {
    monitor_dir="${1}"
    monitor_in_progress_string="${2}"
    monitor_in_failed_string="${3}"
    monitor_in_success_string="${4}"

    l_in_progress_process_count=`ls ${monitor_dir}/${monitor_in_progress_string} 2>/dev/null | wc -l`

    while [ ${l_in_progress_process_count} -ne 0 ]
    do
            l_in_progress_process_count=`ls ${monitor_dir}/${monitor_in_progress_string} 2>/dev/null | wc -l`
            l_failed_process_count=`ls ${monitor_dir}/${monitor_in_failed_string} 2>/dev/null | wc -l`
            l_success_process_count=`ls ${monitor_dir}/${monitor_in_success_string} 2>/dev/null | wc -l`

            if [ ${l_in_progress_process_count} -ne 0 ]; then
                write_log "0" "monitor_sub_process - status: finished=${l_success_process_count} in_progress=${l_in_progress_process_count} failed=${l_failed_process_count}. about to sleep for ${l_sleep_timer} secs"
                sleep ${l_sleep_timer}
            fi
    done

    l_failed_process_count=`ls ${monitor_dir}/${monitor_in_failed_string} 2>/dev/null | wc -l`
    l_success_process_count=`ls ${monitor_dir}/${monitor_in_success_string} 2>/dev/null | wc -l`

    write_log "0" "monitor_sub_process - s3_sync_final_status: FINISHED=${l_success_process_count} IN_PROGRESS=${l_in_progress_process_count} FAILED=${l_failed_process_count}."
}

validate_s3_bucket() {
    l_s3_bucket="${1}"

    write_log "0" "validate_s3_bucket- (/usr/local/bin/aws s3 ls ${l_extra_vars} | grep -i \"${l_s3_bucket}\" | awk '{print \$3}')"
    l_a_src_buckets=($(${l_aws_caller} s3 ls ${l_extra_vars} | grep -i ${l_s3_bucket} | awk '{print $3}'))

    if [ ${#l_a_src_buckets[@]} -eq 0 ]; then
        write_log "0" "validate_s3_bucket - s3_bucket - ${l_s3_bucket} src_bucket_list - ${l_a_src_bucket} empty s3 bucket list." "ERROR"
        exit 100
    else
        write_log "0" "validate_s3_bucket - found bucket ${l_s3_bucket}"
    fi
}

sync_s3() {

   if [ ${l_target_info_mode} == "static" ]; then
        validate_s3_bucket "${l_src_bucket}"
        b2b_sync "${l_src_bucket}" "${l_target_bucket}" "${l_target_bucket_dir}" "${l_extra_vars}" "1" "${l_sync_forks}"

        if [ ${l_wait} == "yes" ]; then
            monitor_sub_process "${l_sub_process_log_dir}" "*progress*" "*failed*" "*success*"
        else
            write_log "0" "sync_s3 - static - launched the process in background mode. exiting the script as requested - wait: ${l_wait}"
        fi
   elif [ ${l_target_info_mode} == "dynamic" ]; then
        validate_s3_bucket "${l_src_bucket}"
        sync_s3_dynamic

        if [ ${l_wait} == "yes" ]; then
            monitor_sub_process "${l_sub_process_log_dir}" "*progress*" "*failed*" "*success*"
        else
            write_log "0" "sync_s3 - dynamic - launched the process in background mode. exiting the script as requested - wait: ${l_wait}"
        fi
   fi
}

sync_s3_dynamic() {
    write_log "0" "sync_s3_dynamic"
    array_length=${#l_a_src_buckets[@]}

    for (( i=0; i<${array_length}; i++ )); do
        write_log "0" "dynamic_s3_target - about to start sync process"
        sync_s3_dynamic_src_bucket=("${l_a_src_buckets[$i]}")

        write_log "0" "dynamic_s3_target - processing sync_s3_dynamic_src_bucket: ${sync_s3_dynamic_src_bucket}"

        # Get Target Bucket
        write_log "0" "${l_aws_caller} s3api get-bucket-tagging --bucket ${sync_s3_dynamic_src_bucket} ${l_extra_vars}| grep -i ${l_tag_archive} | awk '{print \$3}'"
        sync_s3_dynamic_target_bucket=`${l_aws_caller} s3api get-bucket-tagging --bucket ${sync_s3_dynamic_src_bucket} ${l_extra_vars}| grep -i ${l_tag_archive} | awk '{print \$3}'`
        write_log "0" "dynamic_s3_target - sync_s3_dynamic_target_bucket: ${sync_s3_dynamic_target_bucket}"

        if [[ ${sync_s3_dynamic_target_bucket} != "" ]]; then
        {
            write_log "0" "sync_s3_dynamic_target_bucket: ${sync_s3_dynamic_target_bucket}"
            b2b_sync "${sync_s3_dynamic_src_bucket}" "${sync_s3_dynamic_target_bucket}" "${l_target_bucket_dir}" "${l_extra_vars}" "${i}" "${l_sync_forks}"
            l_rc=$?

            if [ ${l_rc} -eq 0 ]; then
                write_log "0" "dynamic_s3_target - sync from ${sync_s3_dynamic_src_bucket} to ${sync_s3_dynamic_target_bucket}/${l_target_bucket_dir}"
            else
                write_log "0" "dynamic_s3_target - failed sync from ${sync_s3_dynamic_src_bucket} to ${sync_s3_dynamic_target_bucket}/${l_target_bucket_dir}" "ERROR"
            fi
        }
        else
        {
            write_log "0" "dynamic_s3_target - No target_bucket_info found for the src_bucket: ${l_a_src_buckets[$i]}. please check the existence of the tag ${l_tag_archive} in src_bucket" "ERROR"
            exit 100
        }
        fi
    done

    write_log "0" "sync_s3_dynamic - finished"
}

clean_files()
{
    write_log "0" "clean_files"

    for file in `ls ${1}`; do
        if [ -f ${file} ]; then
            rm -rf "${file}"
        fi
    done
}

sub_process() {
    validate_env
    l_rc="$?"
    val_return_code "${l_rc}" "validate_env"

    sync_s3
    l_rc="$?"
    val_return_code "${l_rc}" "sync_s3"
}

main()
{
    clear
    l_script_caller="\"$@\""
    get_params "$@"
    init_vars

    printf '%200s\n' | tr ' ' - >> ${l_log_file}
    write_log "0" "BEGIN - execution of ${JOB_NAME}"
    print_footer
    val_params

    sub_process
    l_rc="$?"
    val_return_code "${l_rc}" "sub_process"

    print_footer

    write_log "0" "END - execution of ${JOB_NAME}"
}

# execution starts here
main "$@"