TARGET?=riscv-none-elf

PROJECT?=${TARGET}

BUILD_ROOT:=build

BUILD_DIR:=build/${TARGET}

RELP:=../..

JOBS?=20

TAR_DIR:=tar

SRC_DIR:=src

COMMON_FLAGS:=--prefix=/opt/${PROJECT} --program-prefix=${TARGET}- --target=${TARGET} -disable-nls

riscv-none-elf_FLAGS:=--with-arch=rv32imafdc --with-abi=ilp32

BINUTILS_VER:=2.45
BINUTILS_TAR:=${TAR_DIR}/binutils-${BINUTILS_VER}.tar.xz
BINUTILS_SRC:=${SRC_DIR}/binutils
BINUTILS_BIN:=${BUILD_DIR}/binutils
BINUTILS_CFG:=${BINUTILS_SRC}/configure
BINUTILS_MAK:=${BINUTILS_BIN}/Makefile
BINUTILS_FLAGS:=${COMMON_FLAGS} ${${TARGET}_FLAGS}

GCC_VER:=15.2.0
GCC_TAR:=${TAR_DIR}/gcc-${GCC_VER}.tar.xz
GCC_SRC:=${SRC_DIR}/gcc
GCC_BIN:=${BUILD_DIR}/gcc
GCC_MAK:=${GCC_BIN}/Makefile
GCC_FLAGS:=${COMMON_FLAGS} ${${TARGET}_FLAGS} --enable-languages=c,c++ --without-headers --with-newlib --disable-multilib --disable-libstdcxx --disable-libssp

.PHONY: default binutils gcc clean

default: binutils gcc

binutils: ${BINUTILS_MAK}
	make -C ${BINUTILS_BIN} -j ${JOBS}
	make install

gcc: ${GCC_MAK}
	make -C ${GCC_BIN} -j ${JOBS}
	make install

clean:
	rm -r -I ${BUILD_DIR}

${BUILD_DIR}:
	mkdir -p $@

${TAR_DIR} ${SRC_DIR}: %: ${BUILD_DIR}
	mkdir -p $@

${BINUTILS_SRC} ${GCC_SRC}: %: ${SRC_DIR}
	mkdir -p $@

${BINUTILS_TAR}:
	wget https://mirrors.tuna.tsinghua.edu.cn/gnu/binutils/binutils-${BINUTILS_VER}.tar.xz -O $@

${BINUTILS_CFG}: ${BINUTILS_TAR} | ${BINUTILS_SRC}
	tar -xaf $< -C $@

${BINUTILS_MAK}: ${BINUTILS_SRC} | ${BINUTILS_BIN}
	cd ${BINUTILS_BIN} && ${RELP}/${BINUTILS_CFG} ${BINUTILS_FLAGS}

${GCC_TAR}:
	wget https://mirrors.tuna.tsinghua.edu.cn/gnu/gcc/gcc-${GCC_VER}/gcc-${GCC_VER}.tar.xz -O $@

${GCC_CFG}: ${GCC_TAR}
	tar -xaf $< -C $@

${GCC_MAK}: ${GCC_SRC} | ${GCC_BIN}
	cd ${GCC_BIN} && ${RELP}/${GCC_CFG} ${GCC_FLAGS}
