#!/bin/bash

input="/home/andriy29k/.ssh/config"
output="../inventory.ini"

declare -A group_map=(
  ["bastion"]="bastion_group"
  ["backend"]="backend_group"
  ["frontend"]="frontend_group"
  ["monitoring"]="monitoring_group"
  ["control-plane"]="control_plane_group"  # Зміна тут: control-plane замість control_plane
  ["reverse_proxy"]="reverse_proxy_group"
  ["database"]="database_group"
)

declare -A hosts_by_group

host=""
hostname=""
user=""
keyfile=""
proxyjump=""

function write_host {
  local h=$1
  local hn=$2
  local u=$3
  local kf=$4
  local pj=$5

  local group=${group_map[$h]:-"ungrouped"}

  hosts_by_group[$group]+="$h ansible_host=$hn ansible_user=$u ansible_ssh_private_key_file=$kf"
  if [[ -n "$pj" ]]; then
    hosts_by_group[$group]+=" ansible_ssh_common_args='-o ProxyJump=$pj'"
  fi
  hosts_by_group[$group]+=$'\n'
}

while IFS= read -r line; do
  line="$(echo "$line" | sed 's/^[ \t]*//')"
  [[ -z "$line" || "$line" == \#* ]] && continue

  if [[ "$line" =~ ^Host[[:space:]]+(.+) ]]; then
    if [[ -n "$host" ]]; then
      write_host "$host" "$hostname" "$user" "$keyfile" "$proxyjump"
    fi
    host="${BASH_REMATCH[1]}"
    hostname=""
    user=""
    keyfile=""
    proxyjump=""
  elif [[ "$line" =~ ^HostName[[:space:]]+(.+) ]]; then
    hostname="${BASH_REMATCH[1]}"
  elif [[ "$line" =~ ^User[[:space:]]+(.+) ]]; then
    user="${BASH_REMATCH[1]}"
  elif [[ "$line" =~ ^IdentityFile[[:space:]]+(.+) ]]; then
    keyfile="${BASH_REMATCH[1]}"
  elif [[ "$line" =~ ^ProxyJump[[:space:]]+(.+) ]]; then
    proxyjump="${BASH_REMATCH[1]}"
  fi
done < "$input"

if [[ -n "$host" ]]; then
  write_host "$host" "$hostname" "$user" "$keyfile" "$proxyjump"
fi

> "$output"

for group in "${!hosts_by_group[@]}"; do
  echo "[$group]" >> "$output"
  echo -e "${hosts_by_group[$group]}" | sed '/^[[:space:]]*$/d' >> "$output"
  echo "" >> "$output"
done

workers_groups=(backend_group frontend_group monitoring_group reverse_proxy_group database_group)
echo "[workers_group]" >> "$output"
for wg in "${workers_groups[@]}"; do
  echo "${hosts_by_group[$wg]}" | grep -o '^[a-zA-Z0-9_-]\+' | sort -u >> "$output"
done
echo "" >> "$output"