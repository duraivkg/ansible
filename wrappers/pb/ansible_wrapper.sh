#!/usr/bin/env bash
# -----------------------------------------------------------------------------------
#  ansible_wrapper.sh
# ====================
# normal shell routine to trigger ansible-palybook execution
#
# Performs the following:
# 	1)  triggers ansible-palybook execution
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
# 06//02/2016    Durai G     1.0            Initial version
# ------------------------------------------------------------------------------------
# Global vars/inits
JOB_NAME="`basename $0`"
workspace="`pwd`"
logs_dir="${workspace}/logs"
ansible_playbook="playbook.yml"
ansible_inventory="dev_hosts"
ansible_limit="all"
ansible_forks="20"
ansible_user="ansible"
ansible_extra_params="NA"
ansible_cfg="/etc/ansible/ansible.cfg"
ansible_vars_file="NA"
extra_args="NA"

usage() {
           echo
           echo "Usage list for $JOB_NAME"
           echo
           echo "Options:"
           echo
           echo "    --help                                                 - <help>"
           echo "    --workspace                                            - workspace directory. Default=${workspace}"
           echo "    --logs_dir                                             - logs_dir directory. Default=${logs_dir}"
           echo "    --ansible_cfg                                          - ansible config file path. Default=${ansible_cfg}"
           echo "    --playbook                                             - ansible playbook containing list of tasks to execute . Default=${ansible_playbook}"
           echo "    --inventory                                            - ansible host list file or list of hosts (csv). Default=${ansible_inventory}"
           echo "    --limit                                                - further limit the target host with a tag. Default=${ansible_limit}"
           echo "    --forks                                                - parallel processing threads. Default=${ansible_forks}"
           echo "    --user                                                 - ansible user name. Default=${ansible_user}"
           echo "    --extra_params                                         - ansible extra parameters to be passed to playbook. Default=${ansible_extra_params}"
           echo "    --vars_file                                            - ansible extra vars file containing list of vars to be passed to playbook. Default=${ansible_vars_file}"
           echo "    --extra_args                                           - extra arguments to the script which will be suffixed to ansible caller. Default=${extra_args}"
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
            --ansible_cfg) iansible_cfg="$2"; shift 2;;
            --playbook) iansible_playbook="$2"; shift 2;;
            --inventory) iansible_inventory="$2"; shift 2;;
            --limit) iansible_limit="$2"; shift 2;;
            --forks) iansible_forks="$2"; shift 2;;
            --user) iansible_user="$2"; shift 2;;
            --extra_params) iansible_extra_params="$2"; shift 2;;
            --vars_file) iansible_vars_file="$2"; shift 2;;
            --extra_args) iextra_args="$2"; shift 2;;
            *) echo -e "\n msg: ERROR - In sufficient parameters passed. Please validate the usage list.\n script_arguments: ${l_script_caller}\n"; usage; exit 1;;
        esac
    done
}

val_params()
{
        if [[ ! "${l_workspace}" || ! "${l_ansible_playbook}"  || ! "${l_ansible_inventory}" || ! "${l_ansible_limit}"  || ! "${l_ansible_cfg}" || ! "${l_ansible_forks}" || ! "${l_ansible_user}" || ! "${l_ansible_extra_params}" || ! "${l_ansible_vars_file}" || ! "${l_extra_args}" || ! "${l_logs_dir}" ]]; then
            write_log "0" "val_params - parameters passed are insufficient." "ERROR"
            write_log "0" "val_params - script_arguments: ${l_script_caller}"
            usage
            exit 1
        fi

        write_log "0" "script_arguments: ${l_script_caller}"
}


init_vars()
{
    lPwd=`pwd`
    l_workspace=${iworkspace-${workspace}}
    l_logs_dir=${ilogs_dir-${logs_dir}}

    l_ansible_cfg=${iansible_cfg-${ansible_cfg}}
    l_ansible_playbook=${iansible_playbook-${ansible_playbook}}
    l_ansible_inventory=${iansible_inventory-${ansible_inventory}}
    l_ansible_inventory=${iansible_inventory-${ansible_inventory}}
    l_ansible_limit=${iansible_limit-${ansible_limit}}
    l_ansible_forks=${iansible_forks-${ansible_forks}}
    l_ansible_user=${iansible_user-${ansible_user}}
    l_ansible_extra_params=${iansible_extra_params-${ansible_extra_params}}
    l_ansible_vars_file=${iansible_vars_file-${ansible_vars_file}}
    l_extra_args=${iextra_args-${extra_args}}

    l_caller_sc="ansible_runner.sh"

    mkdir -p ${l_workspace} ${l_logs_dir}
    l_log_file=${l_logs_dir}/${JOB_NAME%.*}.log
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

call_ansible()
{
    time_stamp=`date +%Y%m%d%H%M`
    host_file_count=`ls ${l_ansible_inventory} 2>/dev/null | wc -l`

    export ANSIBLE_CONFIG="${l_ansible_cfg}"
    write_log 0 "ANSIBLE_CONFIG: ${ANSIBLE_CONFIG}"

    export ANSIBLE_FORCE_COLOR=true
    export PYTHONUNBUFFERED=1
    #write_log 0 "ANSIBLE_FORCE_COLOR: true"

    l_cmd_string="ansible-playbook ${l_ansible_playbook}  -u ${l_ansible_user}  -f ${l_ansible_forks}"

    if [ ${host_file_count} -ne 0 ]; then
        l_cmd_string="${l_cmd_string} -i ${l_ansible_inventory} --limit \"${l_ansible_limit}\""
    else
        l_cmd_string="${l_cmd_string} -i \"${l_ansible_inventory},\""

        if [ "${l_ansible_inventory}" == "localhost" ]; then
             l_cmd_string="${l_cmd_string} --connection=local"
        fi
    fi

    if [ "${l_ansible_extra_params}" != "${ansible_extra_params}" ]; then
        l_cmd_string="${l_cmd_string}  -e  "\"${l_ansible_extra_params}\"""
    fi

    if [ "${l_ansible_vars_file}" != "${ansible_vars_file}" ]; then
        l_cmd_string="${l_cmd_string} --extra-vars "\"@${l_ansible_vars_file}\"""
    fi

    if [ "${l_extra_args}" != "${extra_args}" ]; then
        l_cmd_string="${l_cmd_string} ${l_extra_args}"
    fi

    write_log 0 "l_cmd_string - ${l_cmd_string}"
    echo ${l_cmd_string} > ${l_caller_sc}

    chmod 0755 ${l_caller_sc}
    ./${l_caller_sc}
    l_rc="$?"
    val_return_code "${l_rc}" "execute ${l_caller_sc}"
}

clean_files()
{
    for file in `ls ${1}`; do
        if [ -f ${file} ]; then
            rm -rf "${file}"
        fi
    done
}

sub_process() {
    call_ansible
    l_rc="$?"
    val_return_code "${l_rc}" "call_ansible"
}

domain()
{
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
domain "$@"