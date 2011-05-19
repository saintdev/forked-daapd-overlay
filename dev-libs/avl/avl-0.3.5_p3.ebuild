# Copyright 1999-2010 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI=2

inherit flag-o-matic

MY_PV="${PV/_p/-}"

SRC_BASE="http://libavl.sourcearchive.com/downloads/${MY_PV}"
PATCH_NAME="libavl_${MY_PV}.diff"

DESCRIPTION="Implementation of AVL trees for C"
HOMEPAGE="http://libavl.sourcearchive.com"
SRC_URI="${SRC_BASE}/libavl_${PV%_p*}.orig.tar.gz"

if [ x$PV != x$MY_PV ]; then
	SRC_URI="${SRC_URI}
		${SRC_BASE}/${PATCH_NAME}.gz"
fi

LICENSE="LGPL"
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE=""

RESTRICT="primaryuri"

S="${WORKDIR}/${P%_p*}"

src_prepare() {
	if [ x$PV != x$MY_PV ]; then
		epatch "${WORKDIR}/${PATCH_NAME}"
	fi
}

src_compile() {
	emake || die "emake failed"
}

src_install() {
	dolib libavl.so.1.5 || die
	dosym libavl.so.1.5 /usr/lib/libavl.so || die
	dodoc README || die
	insinto /usr/include
	doins avl.h || die
}
