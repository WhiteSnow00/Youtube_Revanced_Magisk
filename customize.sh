#!/system/bin/sh

# Checking for installation environment
# Abort TWRP installation with error message when user tries to install this module in TWRP

if [ $BOOTMODE = false ]; then
	ui_print "- Installing through TWRP Not supported"
	ui_print "- Intsall this module via Magisk Manager"
	abort "- Aborting installation !!"
fi


PKGNAME=com.google.android.youtube
APPNAME="YouTube"


if ! dumpsys package $PKGNAME | grep path > /dev/null 2>&1
then
	ui_print "- $APPNAME app is not installed"
	ui_print "- Install $APPNAME from PlayStore"
	abort "- Aborting installation !!"
fi


STOCKAPPVER=$(dumpsys package $PKGNAME | grep versionName | cut -d= -f 2 | sed -n '1p')
RVAPPVER=$(grep version= module.prop | sed 's/version=v//')

if [ "$STOCKAPPVER" != "$RVAPPVER" ]
then
	ui_print "- Installed $APPNAME version = $STOCKAPPVER"
	ui_print "- $APPNAME Revanced version = $RVAPPVER"
	ui_print "- App Version Mismatch !!"
	ui_print "- Get the module matching the version number."
	abort "- Aborting installation !!"
fi

ui_print "- Unmounting Previous Mounts"

grep $PKGNAME /proc/mounts | while read -r LINE
do 
	echo "$LINE" | grep "$PKGNAME" | cut -d " " -f 2 | sed "s/apk.*/apk/" | xargs -r umount -l
done

ui_print "- Moving Files and setting permissions"
mkdir -p "$MODPATH/app"
rm $MODPATH/app/"$APPNAME"*
mv $MODPATH/*.apk $MODPATH/app/"$APPNAME"Revanced-"$RVAPPVER".apk
STOCKAPK=$(pm path $PKGNAME | grep base | cut -d ":" -f2)
RVAPK=$MODPATH/app/"$APPNAME"Revanced-"$RVAPPVER".apk
chmod 644 "$RVAPK"
chown system:system "$RVAPK"
chcon u:object_r:apk_data_file:s0 "$RVAPK"
mount -o bind "$RVAPK" "$STOCKAPK"
am force-stop "$PKGNAME"

set_perm_recursive $MODPATH/system/bin 0 0 0755 0755

mv $MODPATH/detachyt /data/adb/service.d/detachyt.sh
chmod +x /data/adb/service.d/detachyt.sh

PS=com.android.vending
LDB=/data/data/$PS/databases/library.db
LADB=/data/data/$PS/databases/localappstate.db
cmd appops set --uid $PS GET_USAGE_STATS ignore
pm disable $PS > /dev/null 2>&1
$MODPATH/system/bin/sqlite3 $LDB "UPDATE ownership SET doc_type = '25' WHERE doc_id = '$PKGNAME'";
$MODPATH/system/bin/sqlite3 $LADB "UPDATE appstate SET auto_update = '2' WHERE package_name = '$PKGNAME'";
rm -rf /data/data/$PS/cache/*
pm enable $PS > /dev/null 2>&1

# Disable battery optimization for YouTube ReVanced
sleep 1
ui_print "- Disable Battery Optimization for YouTube ReVanced"
dumpsys deviceidle whitelist +$PKGNAME > /dev/null 2>&1


ui_print "- Install Successful !!"

ui_print "- You can use Revanced Extended without reboot as well."