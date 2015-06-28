# Copyright 1999-2015 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: www-misc/dactyl/dactyl-1.0.ebuild,v 1.2 2015/06/28 Exp $

EAPI=5

case "${PV}" in
	(9999*)
		KEYWORDS=""
		VCS_ECLASS=git-2
		EGIT_REPO_URI="git://github.com/5digits/${PN}.git"
		EGIT_PROJECT="${PN}.git"
		;;
	(*)
		KEYWORDS="~amd64 ~arm ~x86"
		SRC_URI="https://github.com/5digits/${PN}/archive/penta${P}.tar.gz"
		S="${WORKDIR}/${PN}-penta${P}"
		;;
esac
inherit eutils multilib ${VCS_ECLASS}

DESCRIPTION="Efficient and keyboard friendly vim UI interface add-on"
HOMEPAGE="https://5digits/org https://github.com/5digits/dactyl"

LICENSE="MIT"
SLOT="0"
IUSE="+firefox songbird thunderbird"
REQUIRED_USE="|| ( firefox songbird thunderbird )"

DEPEND="app-arch/zip
	net-misc/curl
	sys-apps/sed"
RDEPEND="${DEPEND}
	virtual/awk"
DOCS=( BREAKING_CHANGES HACKING )

src_configure()
{
	BROWSER_SRC=(
		$(usex firefox  'pentadactyl:firefox' '')
		$(usex songbird 'melodactyl:songbird' '')
		$(usex thunderbird 'teledactyl:thunderbird' '')
	)
}

src_compile()
{
	local dir
	for dir in "${BROWSER_SRC[@]}"; do
		pushd "${dir%:*}"
		emake xpi
		popd
	done
}

src_install()
{
	local dir doc{,s}
	for dir in "${BROWSER_SRC[@]}"; do
		insinto /usr/"$(get_libdir)/${dir#*:}"/browser/extensions
		mv downloads/${dir%:*}*.xpi "${dir%:*}@5digits.org.xpi"
		doins "${dir%:*}@5digits.org.xpi"
		for doc in {AUTHORS,NEWS,TODO}; do
			cp ${dir%:*}/${doc} ${doc}.${dir%:*} && docs+=( ${doc}.${dir%:*} )
		done
		dodoc "${docs[@]}"
	done
	dodoc "${DOCS[@]}"
}
