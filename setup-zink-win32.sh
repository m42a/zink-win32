#!/bin/bash

set -e

dll_dir=/usr/share/zink-win32

if [[ -z "$1" ]] || [[ "$1" == "install" ]]; then
	mode="install"
elif [[ "$1" == "uninstall" ]]; then
	mode="uninstall"
else
	if [[ "$1" != "--help" ]]; then
		printf 'Unknown argument "%s"; bailing\n' "$1" 1>&2
	fi
	echo "Usage: setup-zink-win32.sh [install|uninstall]" 1>&2
	exit 1
fi

# Allow overriding the wine executable via the WINE environment variable, and fail if it's not present
hash "${WINE:=wine}"

windir=$("$WINE" cmd /c 'winepath -u %WINDIR%' | tr -d '\r')
syswow64="$windir/syswow64"
if ! [[ -d "$syswow64" ]]; then
	printf 'Invalid windows 32-bit dll directory "%s"; bailing\n' "$syswow64" 1>&2
	exit 1
fi

rm -f "$syswow64/opengl32.dll" "$syswow64/libgallium_wgl.dll"
if [[ "$mode" == "install" ]]; then
	ln -s "$dll_dir/opengl32.dll" "$syswow64/opengl32.dll"
	ln -s "$dll_dir/libgallium_wgl.dll" "$syswow64/libgallium_wgl.dll"
	"$WINE" reg add 'HKCU\Software\Wine\DllOverrides' /v "opengl32" /d "native" /f
	# wine doesn't ship libgallium_wgl, so we don't need to override it
else
	# The override might not exist, so don't fail if we can't delete it
	"$WINE" reg delete 'HKCU\Software\Wine\DllOverrides' /v "opengl32" /f || true
	# Restore opengl32 to its builtin version
	"$WINE" wineboot -u
fi
