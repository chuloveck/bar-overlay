# Copyright 1999-2015 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: sys-apps/hprofile/hprofile-3.0.ebuild,v 1.4 2015/01/01 08:41:42 -tclover Exp $

EAPI=5

inherit eutils

DESCRIPTION="Utility to manage hardware, network, power or other profiles"
HOMEPAGE="https://github.com/tokiclover/hprofile"
SRC_URI="https://github.com/tokiclover/${PN}/archive/${PV}.tar.gz -> ${P}.tar.gz"

LICENSE="GPL-2"
SLOT="0/${PV:0:1}"
KEYWORDS="~x86 ~amd64"

DEPEND="sys-apps/findutils"
RDEPEND="${DEPEND}
	sys-apps/diffutils
	sys-apps/sed
	app-shells/bash"

src_install()
{
	sed -e '/.*COPYING.*$/d' -i Makefile
	emake DESTDIR="${ED}" prefix=/usr exec_prefix=/ install{,-doc}
}