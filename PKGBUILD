pkgname=zink-win32
pkgver=26.2.5
_pkgver=${pkgver/[a-z]/-&}
pkgrel=1
pkgdesc="32-bit OpenGL implementation using vulkan"
arch=(x86_64)
license=("MIT AND BSD-3-Clause AND SGI-B-2.0")
makedepends=(
	meson
	mingw-w64-binutils
	mingw-w64-gcc
	python
)
validpgpkeys=(
	946D09B5E4C9845E63075FF1D961C596A7203456 # Andres Gomez <tanty@igalia.com>
	71C4B75620BC75708B4BDB254C95FAAB3EB073EC # Dylan Baker <dylan@pnwbakers.com>
	8703B6700E7EE06D7A39B8D6EDAE37B02CEB490D # Emil Velikov <emil.l.velikov@gmail.com>
	57551DE15B968F6341C248F68D8E31AFC32428A6 # Eric Engestrom <eric@engestrom.ch>
	A5CC9FEC93F2F837CB044912336909B6B25FADFA # Juan A. Suarez Romero <jasuarez@igalia.com>
	E3E8F480C52ADD73B278EE78E1ECBE07D7D70895 # Juan Antonio Suárez Romero (Igalia, S.L.) <jasuarez@igalia.com>
)
source=(
	"https://archive.mesa3d.org/mesa-$_pkgver.tar.xz"{,.sig}
	"cross32.ini"
	"setup-zink-win32.sh"
)
b2sums=(
	'cfcc4d72c5e6f54904c77b98c65df8159c41ebe9c4b8f82a18a38983bfe06e25c02ea20ba613753838f2455edb156a2d79938f28328313a8eb79fe67d2ea9624'
	'SKIP'
	'de26af3e6ac15a7f122f3e84df308ebfabfcda3049174e0a11b638dfd618499528134e6ef1ce13a32f0b1fdd7d22f4dc878fbfe5b37c159d8ffec8df7630fea8'
	'ea50b25f18013f51f3215517d53e27d88bc9ae3b8542227854cd8451bde8b037ad63f9f84eff19980fce0c616de738a5d15e62d716848bc7776ea70a84937151'
)
sha256sums=(
	'794b3d1729075dae7ebd47c7283b7ca0cdb5dec668f7f11cc0a5d82f6138a0a5'
	'SKIP'
	'7673e6d44f753172cf3c99498736c0b9f3130e7794a3da14eb8f4cdd22229334'
	'f0476fba0f3da06993de6c7744d435b68ac0cae822021ad5ad521168bda6fddc'
)
options=(
	# meson.build says "LTO causes random issues that are nearly impossible to debug", so disable it
	!lto
	# This only generates usable debug packages for ELF binaries. Invert it and remove the --strip below if you want to debug the dlls.
	!debug
)

build() {
	local options=(
		--auto-features disabled
		--wrap-mode nodownload
		--cross-file cross32.ini
		--prefix "/usr/share/zink-win32"
		--bindir ""
		--libdir ""
		--buildtype plain
		# Ideally this would only apply if strip is set in the user's options, but I don't see a documented way to check if an option is enabled, and it shrinks the dll by over 20%.
		--strip

		-Dplatforms=windows
		-Dgallium-drivers=zink
		-Dvulkan-drivers=
		-Dtools=
		-Dvideo-codecs=
		# zlib is only used for the shader cache, which doesn't work on Windows anyway
		-Dzlib=disabled
	)
	if [[ -n "$LDFLAGS" ]]; then
		# HACK: Mingw's ld doesn't recognize -z, so strip those linker arguments
		export LDFLAGS=$(sed -e 's/-Wl,-z,[^ ]\+//g' <<< "$LDFLAGS")
	fi
	meson setup build mesa-$_pkgver "${options[@]}"
	meson compile -C build
}

package() {
	meson install -C build --destdir "$pkgdir"
	install -D -t "$pkgdir/usr/bin" setup-zink-win32.sh
}
