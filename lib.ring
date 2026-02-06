if isWindows()
	loadlib("ring_slint.dll")
but isLinux() or isFreeBSD()
	loadlib("libring_slint.so")
but isMacOSX()
	loadlib("libring_slint.dylib")
else
	raise("Unsupported OS! You need to build the library for your OS.")
ok

load "src/slint.ring"
