# Copyright 1999-2018 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2

EAPI=6
# Keep cmake-utils at the end
inherit gnome2 vala cmake-utils

DESCRIPTION="A lightweight, easy-to-use, feature-rich email client"
HOMEPAGE="https://wiki.gnome.org/Apps/Geary"

LICENSE="LGPL-2.1"
SLOT="0"
KEYWORDS="amd64 ~x86"
IUSE="nls"

DEPEND="
	>=app-crypt/gcr-3.10.1:0=[gtk,introspection,vala]
	app-crypt/libsecret
	app-text/iso-codes
	dev-db/sqlite:3
	>=dev-libs/glib-2.42:2[dbus]
	>=dev-libs/libgee-0.8.5:0.8=
	dev-libs/libxml2:2
	dev-libs/gmime:2.6
	media-libs/libcanberra
	>=net-libs/webkit-gtk-2.10.0:4=[introspection]
	>=x11-libs/gtk+-3.14.0:3[introspection]
	x11-libs/libnotify
"
RDEPEND="${DEPEND}
	gnome-base/gsettings-desktop-schemas
	nls? ( virtual/libintl )
"
DEPEND="${DEPEND}
	app-text/gnome-doc-utils
	dev-util/desktop-file-utils
	nls? ( sys-devel/gettext )
	$(vala_depend)
	virtual/pkgconfig
"

src_prepare() {
	# https://bugzilla.gnome.org/show_bug.cgi?id=751557
	sed -i -e 's/vapigen --library/${VAPIGEN} --library/' src/CMakeLists.txt || die

	local i
	if use nls ; then
		if [[ -n "${LINGUAS+x}" ]] ; then
			for i in $(cd po ; echo *.po) ; do
				if ! has ${i%.po} ${LINGUAS} ; then
					sed -i -e "/^${i%.po}$/d" po/LINGUAS || die
				fi
			done
		fi
	else
		sed -i -e 's#add_subdirectory(po)##' CMakeLists.txt || die
	fi

	cmake-utils_src_prepare
	gnome2_src_prepare
	vala_src_prepare
}

src_configure() {
	local mycmakeargs=(
		-DDESKTOP_UPDATE=OFF
		-DNO_FATAL_WARNINGS=ON
		-DGSETTINGS_COMPILE=OFF
		-DICON_UPDATE=OFF
		-DVALA_EXECUTABLE="${VALAC}"
		-DVAPIGEN="${VAPIGEN}"
		-DWITH_UNITY=OFF
		-DDESKTOP_VALIDATE=OFF
	)

	cmake-utils_src_configure
}
