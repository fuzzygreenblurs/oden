## Systems and Testing

#### 1. Remount /boot to be Read-Write 

You need to edit a file on /boot but the partition is read only. On a Unix/Linux system
how would you remount a filesystem in read write mode without rebooting the machine?

A general template of the command we can use is `mount -o remount, rw boot_partition_identifier mounted_fs_access_path`
where:
- `-o`                        : accesses the `mount` utility command options
- `remount`                   : allows us to remount the already mounted filesystem
- `rw`                        : sets the permissions to read-write
- `boot_partition_identifier` : this is the identifier that we use to target the `boot` filesystem
- `mounted_fs_access_path`    : the file path to access the newly remounted /boot specific filesystem. generally this would be at `/boot`

To determine the `boot_partition_identifier`, we can run something like: 
`mount -v | grep "^/" | awk '{print "\nPartition identifier: " $1  "\n Mountpoint: "  $3}'`

This will give us a list of all the mounted filesystems, and we can clearly determine the exact partition identifier with a mountpoint of `/boot`

* But since the boot partition is generally mounted at /boot, a more concise version of the command would look something like: *
`mount -o remount, rw /boot`

#### 2. Vetting Embedded Linux Device Updates 

Write a general test plan for vetting embedded linux devices when software
updates/features are applied to them, then apply the test plan to the following features:

a. Version 1.0.2 of the embedded device supports a Real Time Clock(RTC)

b. Version 1.0.3 has a feature that uses the RTC module to keep time when NTP services
are not available

#### Kernel and Driver Test Plan

1. Linux kernel/driver Test Plan
    The TP-Link T2UH AC600 Wifi adapter does not have driver support mainlined in the 4.4. Kernel of Raspbian
    Jessie. However, there is a community driver available.
    
    Write a new test plan or reuse the previous one you made to ensure proper function and operation of the WiFi
    adapter.