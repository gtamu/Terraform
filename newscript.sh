#!/bin/bash

sudo mkfs -t xfs /dev/nvme1n1
sudo mkdir /data
sudo mount /dev/nvme1n1 /data
sudo mkfs -t xfs /dev/nvme2n1
sudo mkdir /backup
sudo mount /dev/nvme2n1 /backup
grep -q /dev/nvme1n1  /etc/fstab || echo "/dev/nvme1n1       /data          xfs     defaults,noatime   1  1" | sudo tee --append /etc/fstab
sudo findmnt --verify 
grep -q /dev/nvme2n1  /etc/fstab || echo "/dev/nvme2n1      /backup          xfs     defaults,noatime   1  1" | sudo tee --append /etc/fstab

#sudo findmnt --verify 
## verifier 1
grep -q 'vm.zone_reclaim_mode' /etc/sysctl.conf || echo "vm.zone_reclaim_mode=0" | sudo tee --append /etc/sysctl.conf
## verifier 2
grep   "vm.zone_reclaim_mode=0" /etc/sysctl.conf || echo "Incorrect value for Zone Reclaim Mode"
## change NUMA setting if not already configured correctly
sudo sysctl -w  vm.zone_reclaim_mode=0
## verifier 2
grep -q 'vm.swappiness' /etc/sysctl.conf || echo "vm.swappiness=1" | sudo tee --append /etc/sysctl.conf
## change Swap setting if not already configured correctly
sudo sysctl -w  vm.swappiness=1
systemctl list-unit-files | grep ntp | grep -q enabled
grep /data /etc/fstab | grep -q noatime || echo "Access Time on data drive not disabled"
for limit in fsize cpu as memlock
do
  grep "mongodb" /etc/security/limits.conf | grep -q $limit || echo -e "mongod     hard   $limit    unlimited\nmongod     soft    $limit   unlimited" | sudo tee --append /etc/security/limits.conf
done
## Set ulimits for open files & processes/threads to 64000
for limit in nofile noproc
do
  grep "mongodb" /etc/security/limits.conf | grep -q $limit || echo -e "mongod     hard   $limit    64000\nmongod     soft    $limit   64000" | sudo tee --append /etc/security/limits.conf
done
## https://docs.mongodb.com/manual/tutorial/transparent-huge-pages/
SCRIPT=$(cat << 'ENDSCRIPT'
#!/bin/bash
### BEGIN INIT INFO
# Provides:          disable-transparent-hugepages
# Required-Start:    $local_fs
# Required-Stop:
# X-Start-Before:    mongod mongodb-mms-automation-agent
# Default-Start:     2 3 4 5
# Default-Stop:      0 1 6
# Short-Description: Disable Linux transparent huge pages
# Description:       Disable Linux transparent huge pages, to improve
#                    database performance.
### END INIT INFO
case $1 in
  start)
    if [ -d /sys/kernel/mm/transparent_hugepage ]; then
      thp_path=/sys/kernel/mm/transparent_hugepage
    elif [ -d /sys/kernel/mm/redhat_transparent_hugepage ]; then
      thp_path=/sys/kernel/mm/redhat_transparent_hugepage
    else
      return 0
    fi
    echo 'never' > ${thp_path}/enabled
    echo 'never' > ${thp_path}/defrag
    re='^[0-1]+$'
    if [[ $(cat ${thp_path}/khugepaged/defrag) =~ $re ]]
    then
      # RHEL 7
      echo 0  > ${thp_path}/khugepaged/defrag
    else
      # RHEL 6
      echo 'no' > ${thp_path}/khugepaged/defrag
    fi
    #Set Readahead for Data Disk
    blockdev --setra 8 /dev/xvdb
    blockdev --setra 8 /dev/xvdc
    unset re
    unset thp_path
    ;;
esac
ENDSCRIPT
)
echo "$SCRIPT" | sudo tee /etc/init.d/disable-transparent-hugepages
sudo chmod 755 /etc/init.d/disable-transparent-hugepages
sudo chkconfig --add disable-transparent-hugepages
## Create an /etc/yum.repos.d/mongodb-enterprise-4.4.repo file so that you can install MongoDB enterprise directly using yum:
cat << 'ENDOFDOC' | sudo tee /etc/yum.repos.d/mongodb-enterprise.repo
[mongodb-enterprise-4.4]
name=MongoDB Enterprise Repository
baseurl=https://repo.mongodb.com/yum/redhat/$releasever/mongodb-enterprise/4.4/$basearch/
gpgcheck=1
enabled=1
gpgkey=https://www.mongodb.org/static/pgp/server-4.4.asc
ENDOFDOC
## Install the MongoDB Enterprise packages.
sudo yum install -y mongodb-enterprise
sudo mkdir /data/appdb
sudo chown mongod:mongod /data/appdb
sudo mkdir /data/logs
sudo chown mongod:mongod /data/logs
sudo mkdir /data/config
sudo chown mongod:mongod /data/config
## Ensure your system has the checkpolicy package installed:
sudo yum install checkpolicy
cat > mongodb_cgroup_memory.te <<EOF
module mongodb_cgroup_memory 1.0;
require {
    type cgroup_t;
    type mongod_t;
    class dir search;
    class file { getattr open read };
}
#============= mongod_t ==============
allow mongod_t cgroup_t:dir search;
allow mongod_t cgroup_t:file { getattr open read };
EOF
sudo systemctl start mongod