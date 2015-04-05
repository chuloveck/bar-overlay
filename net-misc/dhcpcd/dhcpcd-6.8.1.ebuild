# Copyright 1999-2015 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: net-misc/dhcpcd/dhcpcd-6.7.1.ebuild,v 1.3 2015/03/18 18:53:34 -tclover Exp $

EAPI=5

if [[ ${PV} == "9999" ]]; then
	FOSSIL_URI="http://roy.marples.name/projects/dhcpcd"
else
	SRC_URI="ftp://roy.marples.name/pub/${PN}/${P/_/-}.tar.bz2"
	KEYWORDS="~alpha ~amd64 ~arm arm64 ~hppa ~ia64 ~mips ~ppc ~ppc64 ~s390 ~sh ~sparc ~x86 ~amd64-fbsd ~sparc-fbsd ~x86-fbsd ~amd64-linux ~arm-linux ~x86-linux"
	S="${WORKDIR}/${P/_/-}"
fi

inherit eutils systemd toolchain-funcs

DESCRIPTION="A fully featured, yet light weight RFC2131 compliant DHCP client"
HOMEPAGE="http://roy.marples.name/projects/dhcpcd/"
LICENSE="BSD-2"
SLOT="0"
IUSE="elibc_glibc +embedded ipv6 kernel_linux +udev"

COMMON_DEPEND="udev? ( virtual/udev )"
DEPEND="${COMMON_DEPEND}"
RDEPEND="${COMMON_DEPEND}"

src_unpack()
{
	if [[ "${PV}" == 9999* ]]; then
		local distdir="${PORTAGE_ACTUAL_DISTDIR:-${DISTDIR}}"/fossil-src
		local repo="${distdir}"/${PN}.fossil

		addwrite "${distdir}"

		if [[ -e "${repo}" ]]; then
			fossil pull "${FOSSIL_URI}" -R "${repo}" || die
		else
			mkdir -p "${distdir}/fossil" || die
			fossil clone "${FOSSIL_URI}" "${repo}" || die
		fi

		mkdir -p "${S}" || die
		cd "${S}" || die
		fossil open "${repo}" || die
	else
		default
	fi
}

src_prepare()
{
	epatch_user
}

src_configure()
{
	local myeconfargs=(
		"CC=$(tc-getCC)"
		"--prefix=${EPREFIX}"
		"--libexecdir=${EPREFIX}/lib/dhcpcd"
		"--dbdir=${EPREFIX}/var/lib/dhcpcd"
		"--localstatedir=${EPREFIX}/var"
		"--with-hook=ntp.conf"
		$(usex elibc_glibc '--with-hook=yp.conf' '')
		$(use_enable embedded)
		$(use_enable ipv6)
		$(usex kernel_linux '--rundir=${EPREFIX}/run' '')
		$(usex udev '' '--without-dev --without-udev')
	)
	econf "${myeconfargs[@]}"
}

src_install()
{
	default
	newinitd "${FILESDIR}"/${PN}.initd ${PN}
	systemd_dounit "${FILESDIR}"/${PN}.service
}

pkg_postinst()
{
	# Upgrade the duid file to the new format if needed
	local old_duid="${ROOT}"/var/lib/dhcpcd/dhcpcd.duid
	local new_duid="${ROOT}"/etc/dhcpcd.duid
	if [ -e "${old_duid}" ] && ! grep -q '..:..:..:..:..:..' "${old_duid}"; then
		sed -i -e 's/\(..\)/\1:/g; s/:$//g' "${old_duid}"
	fi

	# Move the duid to /etc, a more sensible location
	if [ -e "${old_duid}" -a ! -e "${new_duid}" ]; then
		cp -p "${old_duid}" "${new_duid}"
	fi

	if [ -z "$REPLACING_VERSIONS" ]; then
		elog
	 elog "dhcpcd has zeroconf support active by default."
		elog "This means it will always obtain an IP address even if no"
		elog "DHCP server can be contacted, which will break any existing"
		elog "failover support you may have configured in your net configuration."
		elog "This behaviour can be controlled with the noipv4ll configuration"
		elog "file option or the -L command line switch."
		elog "See the dhcpcd and dhcpcd.conf man pages for more details."

		elog
		elog "Dhcpcd has duid enabled by default, and this may cause issues"
		elog "with some dhcp servers. For more information, see"
		elog "https://bugs.gentoo.org/show_bug.cgi?id=477356"
	fi

	if ! has_version net-dns/bind-tools; then
		elog
		elog "If you activate the lookup-hostname hook to look up your hostname"
		elog "using the dns, you need to install net-dns/bind-tools."
	fi
}