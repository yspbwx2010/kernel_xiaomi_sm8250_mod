### AnyKernel3 Ramdisk Mod Script
## osm0sis @ xda-developers

### AnyKernel setup
# global properties
properties() { '
kernel.string=yourself
do.devicecheck=1
do.modules=0
do.systemless=1
do.cleanup=1
do.cleanuponabort=0
device.name1=<DEVICE>
supported.versions=
supported.patchlevels=
supported.vendorpatchlevels=
'; } # end properties


### AnyKernel install
## boot files attributes
boot_attributes() {
set_perm_recursive 0 0 755 644 $RAMDISK/*;
set_perm_recursive 0 0 750 750 $RAMDISK/init* $RAMDISK/sbin;
} # end attributes

# boot shell variables
# Check if the device uses A/B partitions
if [ -e /dev/block/bootdevice/by-name/boot_a ]; then
  # Get the current active slot
  SLOT=$(getprop ro.boot.slot_suffix)
  if [ -z "$SLOT" ]; then
    SLOT=_$(getprop ro.boot.slot)
  fi
  # Set the BLOCK variable to the correct boot partition
  BLOCK=/dev/block/bootdevice/by-name/boot$SLOT
else
  # For non-A/B devices, use the standard boot partition
  BLOCK=/dev/block/bootdevice/by-name/boot
fi

IS_SLOT_DEVICE=0;
RAMDISK_COMPRESSION=auto;
PATCH_VBMETA_FLAG=auto;

# import functions/variables and setup patching - see for reference (DO NOT REMOVE)
. tools/ak3-core.sh;

# boot install
echo "Unpacking ramdisk..."
dump_boot; # use split_boot to skip ramdisk unpack, e.g. for devices with init_boot ramdisk
echo "Ramdisk unpacked!"

# init.rc
echo "Modifying init.rc..."
backup_file init.rc;
replace_string init.rc "cpuctl cpu,timer_slack" "mount cgroup none /dev/cpuctl cpu" "mount cgroup none /dev/cpuctl cpu,timer_slack";
echo "init.rc modified!"

# init.tuna.rc
echo "Modifying init.tuna.rc..."
backup_file init.tuna.rc;
insert_line init.tuna.rc "nodiratime barrier=0" after "mount_all /fstab.tuna" "\tmount ext4 /dev/block/platform/omap/omap_hsmmc.0/by-name/userdata /data remount nosuid nodev noatime nodiratime barrier=0";
append_file init.tuna.rc "bootscript" init.tuna;
echo "init.tuna.rc modified!"

# fstab.tuna
echo "Modifying fstab.tuna..."
backup_file fstab.tuna;
patch_fstab fstab.tuna /system ext4 options "noatime,barrier=1" "noatime,nodiratime,barrier=0";
patch_fstab fstab.tuna /cache ext4 options "barrier=1" "barrier=0,nomblk_io_submit";
patch_fstab fstab.tuna /data ext4 options "data=ordered" "nomblk_io_submit,data=writeback";
append_file fstab.tuna "usbdisk" fstab;
echo "fstab.tuna modified!"

echo "Writing to boot partition..."
write_boot; # use flash_boot to skip ramdisk repack, e.g. for devices with init_boot ramdisk
echo "Boot partition written!"

echo "Flashing complete!"
exit 0
## end boot install
