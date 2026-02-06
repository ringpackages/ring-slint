aPackageInfo = [
	:name = "Ring Slint",
	:description = "Ring bindings for the Slint UI toolkit. Build beautiful, native applications with Ring and Slint UI.",
	:folder = "slint",
	:developer = "ysdragon",
	:email = "youssefelkholey@gmail.com",
	:license = "MIT",
	:version = "1.0.0",
	:ringversion = "1.25",
	:versions = 	[
		[
			:version = "1.0.0",
			:branch = "1.0.0"
		]
	],
	:libs = 	[
		[
			:name = "",
			:version = "",
			:providerusername = ""
		]
	],
	:files = 	[
		// Add files here
	],
	:ringfolderfiles = 	[

	],
	:windowsfiles = 	[
		// Add Windows files here
	],
	:linuxfiles = 	[
		// Add Linux files here
	],
	:ubuntufiles = 	[

	],
	:fedorafiles = 	[

	],
	:macosfiles = 	[
		"lib/macos/amd64/libring_slint.dylib",
		"lib/macos/arm64/libring_slint.dylib"
	],
	:freebsdfiles = 	[
		"lib/freebsd/amd64/libring_slint.so"
	],
	:windowsringfolderfiles = 	[

	],
	:linuxringfolderfiles = 	[

	],
	:ubunturingfolderfiles = 	[

	],
	:fedoraringfolderfiles = 	[

	],
	:freebsdringfolderfiles = 	[

	],
	:macosringfolderfiles = 	[

	],
	:run = "ring main.ring",
	:windowsrun = "",
	:linuxrun = "",
	:macosrun = "",
	:ubunturun = "",
	:fedorarun = "",
	:setup = "ring src/utils/install.ring",
	:windowssetup = "",
	:linuxsetup = "",
	:macossetup = "",
	:ubuntusetup = "",
	:fedorasetup = "",
	:remove = "ring src/utils/uninstall.ring",
	:windowsremove = "",
	:linuxremove = "",
	:macosremove = "",
	:ubunturemove = "",
	:fedoraremove = "",
    :remotefolder = "ring-slint",
    :branch = "master",
    :providerusername = "ysdragon",
    :providerwebsite = "github.com"
]