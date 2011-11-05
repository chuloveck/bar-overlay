# Copyright 1999-2011 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $BAR-overlay/x11-themes/faenza-variants-icon-theme-0.20,v 1.1 2011/08/18 -tclover Exp $

inherit gnome2-utils

DESCRIPTION="Variants from he original Faenza{,-Cupertino} icon themes."
HOMEPAGE="http://spg76.deviantart.com/"

SRC_URI="http://www.deviantart.com/download/184551528/faenza_variants_by_spg76-d31vkvc.zip -> ${P}.zip"

LICENSE="GPL-3"
SLOT="0"
KEYWORDS="amd64 x86"
IUSE="minimal"
EAPI=2

RDEPEND="minimal? ( !x11-themes/gnome-icon-theme )
		!x11-themes/faenza-cupertino-icon-theme
		x11-themes/faenza-icon-theme
"
DEPEND="app-arch/unzip"

RESTRICT="binchecks strip"

S=${WORKDIR}

src_unpack() {
	unpack ${A}
}

src_install() {
	for pkg in Faenza-Variants{,-Dark,-Cupertino}
	do unpack ./${pkg}.tar.gz; done
	insinto /usr/share/icons
	doins -r Faenza-Variants{,-Dark,-Cupertino} || die "eek!"
}

pkg_preinst() { gnome2_icon_savelist; }
pkg_postinst() { gnome2_icon_cache_update; }
pkg_postrm() { gnome2_icon_cache_update; }
