#!/system/bin/sh

rm -rf /data/adb/service.d/detachyt.sh
rm -rf grep /data/app/*/com.google.android.youtube*

[[ -e "/data/system/package_cache" ]] && rm -rf /data/system/package_cache/*
