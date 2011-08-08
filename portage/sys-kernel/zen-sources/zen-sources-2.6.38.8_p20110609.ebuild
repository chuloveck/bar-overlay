# Copyright 1999-2011 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: sys-kernel/zen-sources/zen-sources-2.6.38.8_p20110609.ebuild,v1.0 2011/06/10 Exp $

EAPI="2"

COMPRESSTYPE=".gz"
K_USEPV="yes"
UNIPATCH_STRICTORDER="yes"
K_SECURITY_UNSUPPORTED="1"

CKV=${PV/.8_p[0-9]*}
ETYPE="sources"
inherit kernel-2
detect_version
K_NOSETEXTRAVERSION="don't_set_it"

DESCRIPTION="The Zen Kernel Sources v2.6"
HOMEPAGE="http://zen-kernel.org"

ZEN_FILE="zenpatch-${PV}.diff.gz"
TUXONICE_FILE="tuxonice-3.2-for-$(get_version_component_range 1-3).patch.bz2"
TUXONICE_URI="tuxonice? ( http://tuxonice.net/files/${TUXONICE_FILE} )"
SRC_URI="${DISTDIR}/${ZEN_FILE} ${KERNEL_URI} ${TUXONICE_URI}"

KEYWORDS="-* ~amd64 ~ppc ~ppc64 ~x86"
IUSE="tuxonice" 

DEPEND="|| ( app-arch/xz-utils app-arch/lzma-utils )"
RDEPEND=""

KV_FULL=${PVR/_p[0-9]*/-zen}
S="${WORKDIR}"/linux-${KV_FULL}

pkg_setup(){
	ewarn
	ewarn "${PN} is *not* supported by the Gentoo Kernel Project in any way."
	ewarn "If you need support, please contact the Zen developers directly."
	ewarn "Do *not* open bugs in Gentoo's bugzilla unless you have issues with"
	ewarn "the ebuilds. Thank you."
	ewarn
	ebeep 8
	kernel-2_pkg_setup
}

src_prepare(){
	epatch "${DISTDIR}"/${ZEN_FILE}
	epatch "${FILESDIR}"/cleancache-8.0_p20110414.patch
	use tuxonice && epatch "${DISTDIR}"/${TUXONICE_FILE}
}

K_EXTRAEINFO="For more info on zen-sources and details on how to report problems, see: \
${HOMEPAGE}. You may also visit #zen-sources on irc.rizon.net"
