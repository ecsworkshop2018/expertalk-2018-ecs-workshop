echo "Creating mount point from efs"
yum install -y amazon-efs-utils
mkdir -p ${efs_directory}
cp -p /etc/fstab /etc/fstab.back-$(date +%F)
echo "${file_system_id}:/ ${efs_directory} efs tls,_netdev" >> /etc/fstab
mount -a -t efs defaults