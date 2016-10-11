#@IgnoreInspection BashAddShebang

# provisioner specific
export OPS_FS_HOME="/opt/local/"
export ANSIBLE_HOME=${OPS_FS_HOME}/apps/ansible

# ansible core
export ANSIBLE_LIBRARY=${ANSIBLE_HOME}/library
export ANSIBLE_PLAYBOOKS=${ANSIBLE_HOME}/playbooks
export ANSIBLE_PLUGINS=${ANSIBLE_HOME}/plugins
export ANSIBLE_ROLES=${ANSIBLE_HOME}/roles
export ANSIBLE_WRAPPERS=${ANSIBLE_HOME}/wrappers
export ANSIBLE_INVENTORY=${ANSIBLE_HOME}/inventory
export ANSIBLE_CONFIGS=${ANSIBLE_HOME}/configs
export ANSIBLE_CONFIG=${ANSIBLE_CONFIGS}/common/ansible.cfg
export ANSIBLE_WRAPPER_PB_SCRIPT=${ANSIBLE_WRAPPERS}/ansible_wrapper.sh
export ANSIBLE_WRAPPER_ADHOC_SCRIPT=${ANSIBLE_WRAPPERS}/ansible_adhoc_wrapper.sh
export ANSIBLE_VAULT_PASSWORD_FILE=${ANSIBLE_CONFIGS}/common/.ansible_secret
export ANSIBLE_VARS=${ANSIBLE_HOME}/vars
export ANSIBLE_LOG_DIR=${OPS_FS_HOME}/logs/ansible
export ANSIBLE_LOG=${ANSIBLE_LOG_DIR}/ansible.log
export ANSIBLE_PKI=${ANSIBLE_CONFIGS}/common/.ansible_pki