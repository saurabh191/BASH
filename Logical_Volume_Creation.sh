#!/bin/bash

#-----------------------------------------------------------------------------
#-----------------------------------------------------------------------------

#Logical Volume Manager Script

#Step by step procedure

#Create PV --> pvcreate $pv_name
#Create VG --> vgcreate LocalVG2 $vg_name
#Create LV --> lvcreate -L 10G -n /dev/$vg_name/$lv_name
#Format filesystem --> mkfs.ext4 /dev/$vg_name/$lv_name
#Make directories (mount points) --> mkdir -p /m_value
#Make Entries in  the /etc/fstab
#Mount partitions --> mount -a
#Final output --> df -h

#-----------------------------------------------------------------------------
#-----------------------------------------------------------------------------

#Variables to be used:-

#pv_value ---> for creating pv
#vg_value ---> for creating vg
#a ,b lv_value ---> for size and name & number of the lv
#m_value ---> for mounting filesystem

#-----------------------------------------------------------------------------
#-----------------------------------------------------------------------------

echo "Enter the Physical Volumes names to be added in a single line"
read pv_value
pvcreate $pv_value
echo "The Physical Volumes is created"
pvs

echo "Enter the Volume Group name to be created"
read vg_value
vgcreate $vg_value $pv_value
echo "The Volume Group is created"
vgs
vgdisplay $vg_value

echo "Enter the number of Logical Volumes to be created"
read lv_value

for ((i=0;i<$lv_value;i++))
do
		echo -e "Enter the Logical Volume size (M,G,T) followed by the LV name (example: 2G lvdata), for LV#:$i"
		read a b
        lvcreate -L $a -n /dev/$vg_value/$b
		echo "The Logical Volumes are created"
		lvs
        echo "Enter FileSystem Type (ex.ext3,ext4,xfs,swap)"
        read lv_type
        case $lv_type in
            "ext3") mkfs.ext3 /dev/$vg_value/$b 
						echo 'Enter the mount points'
						read m_value
						mkdir -p $m_value
						echo "Enter Ownership (ex. oracle:oinstall)"
						read owner_name
						chown $owner_name $m_value -R
						echo -e "/dev/$vg_value/$b\t$m_value\text3\tdefaults\t1 2" | cat >> /etc/fstab
						mount -a
					    df -h
					;;
            "ext4") mkfs.ext4 /dev/$vg_value/$b 
						echo 'Enter the mount points'
						read m_value
						mkdir -p $m_value
						echo "Enter Ownership (ex.oracle:oinstall)"
						read owner_name
						chown $owner_name $m_value -R
						echo -e "/dev/$vg_value/$b\t$m_value\text4\tdefaults\t1 2" | cat >> /etc/fstab
						mount -a
						df -h
					;;					
            "xfs") mkfs.xfs /dev/$vg_value/$b 
						echo 'Enter the mount points'
						read m_value
						mkdir -p $m_value
						echo "Enter Ownership (ex.oracle:oinstall)"
						read owner_name
						chown $owner_name $m_value -R
						echo -e "/dev/$vg_value/$b\t$m_value\txfs\tdefaults\t1 2" | cat >> /etc/fstab
						mount -a
						df -h
					;;					
            "swap") mkswap /dev/$vg_value/$b 
					echo -e "/dev/$vg_value/$b\t$m_value\tswap\tswap\tdefaults\t0 0" | cat >> /etc/fstab
					swapon -v /dev/$vg_value/$b
					cat /proc/swaps
					df -h
					;;				
			*)echo " Invalid options"						
				;;
			
        esac
done
