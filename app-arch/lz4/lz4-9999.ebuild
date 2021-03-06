# Copyright 1999-2016 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: app-arch/lz4/lz4-9999.ebuild,v 1.14 2015/08/14 12:58:22 Exp $

EAPI=5

case "${PV}" in
	(9999*)
	KEYWORDS=""
	VCS_ECLASS=git-2
	EGIT_REPO_URI="git://github.com/Cyan4973/${PN}.git"
	EGIT_PROJECT="${PN}.git"
	;;
	(*)
	KEYWORDS="~amd64 ~arm ~hppa ~ia64 ~mips ~s390 ~x86 ~amd64-linux ~x86-linux"
	VCS_ECLASS=vcs-snapshot
	SRC_URI="https://github.com/Cyan4973/${PN}/archive/r${PV}.tar.gz -> ${P}.tar.gz"
	;;
esac
inherit multilib-minimal toolchain-funcs ${VCS_ECLASS}

DESCRIPTION="Extremely Fast Compression algorithm"
HOMEPAGE="http://lz4.org/"

LICENSE="BSD-2 GPL-2"
SLOT="0"
IUSE="debug test"

DEPEND="test? ( debug? ( dev-util/valgrind ) )"

DOCS=( NEWS lz4_Block_format.md lz4_Frame_format.md )

src_prepare()
{
	if ! use debug; then
		sed -i -e '/^test:/s|test-mem||g' programs/Makefile || die
	fi
	multilib_copy_sources
}

multilib_src_compile()
{
	tc-export CC AR
	# we must not use the 'all' target since it builds test programs
	# & extra -m32 executables
	emake
	emake -C programs
}

multilib_src_install()
{
	emake install DESTDIR="${D}" \
		PREFIX="${EPREFIX}/usr" \
		LIBDIR="${EPREFIX}"/usr/$(get_libdir)
}
