TARGET?=riscv-none-elf

PROJECT?=${TARGET}

BUILD_ROOT:=build

BUILD_DIR:=build/${TARGET}

RELP:=../../..

JOBS?=20

TAR_DIR:=tar

SRC_DIR:=src

COMMON_FLAGS:=--prefix=/opt/${PROJECT} --program-prefix=${TARGET}- --target=${TARGET} -disable-nls

riscv-none-elf_FLAGS:=--enable-multilib --with-multilib-generator="rv32i-ilp32--;rv32im-ilp32--;rv32imfdv-ilp32d--" 
riscv-none-elf_PROCESSOR:=riscv

arm-none-eabi_FLAGS:=--with-multilib-list=rmprofile
arm-none-eabi_PROCESSOR:=arm

BINUTILS_VER:=2.45
BINUTILS_TAR:=${TAR_DIR}/binutils-${BINUTILS_VER}.tar.xz
BINUTILS_SRC:=${SRC_DIR}/binutils-${BINUTILS_VER}
BINUTILS_BIN:=${BUILD_DIR}/binutils
BINUTILS_CFG:=${BINUTILS_SRC}/configure
BINUTILS_MAK:=${BINUTILS_BIN}/Makefile
BINUTILS_FLAGS:=${COMMON_FLAGS} ${${TARGET}_FLAGS}

GCC_VER:=15.2.0
GCC_TAR:=${TAR_DIR}/gcc-${GCC_VER}.tar.xz
GCC_SRC:=${SRC_DIR}/gcc-${GCC_VER}
GCC_BIN:=${BUILD_DIR}/gcc
GCC_CFG:=${GCC_SRC}/configure
GCC_MAK:=${GCC_BIN}/Makefile
GCC_FLAGS:=${COMMON_FLAGS} ${${TARGET}_FLAGS} --enable-languages=c,c++ --without-headers --with-newlib --disable-libstdcxx --disable-libssp

GXX_BIN:=${BUILD_DIR}/gxx
GXX_MAK:=${GXX_BIN}/Makefile
GXX_FLAGS:=${COMMON_FLAGS} ${${TARGET}_FLAGS} --enable-languages=c,c++ --with-newlib

PICOLIBC_VER:=1.8.10
PICOLIBC_TAR:=${TAR_DIR}/picolibc-${PICOLIBC_VER}
PICOLIBC_SRC:=${SRC_DIR}/picolibc-${PICOLIBC_VER}
PICOLIBC_BIN:=${BUILD_DIR}/picolibc
PICOLIBC_CFG:=${PICOLIBC_SRC}/meson.build
PICOLIBC_MAK:=${PICOLIBC_BIN}/Makefile
PICOLIBC_FLAGS:=--prefix=/ -Dmultilib=true

.PHONY: default binutils gcc picolibc gxx clean

default: binutils gcc picolibc

binutils: ${BINUTILS_MAK}
	make -C ${BINUTILS_BIN} -j ${JOBS}
	make -C ${BINUTILS_BIN} install

gcc: ${GCC_MAK}
	make -C ${GCC_BIN} -j ${JOBS}
	make -C ${GCC_BIN} install

gxx: ${GXX_MAK}
	make -C ${GXX_BIN} -j ${JOBS}
	make -C ${GXX_BIN} install

picolibc: ${PICOLIBC_MAK}
	ninja -C ${PICOLIBC_BIN}
	DESTDIR=/opt/${PROJECT}/${TARGET} ninja -C ${PICOLIBC_BIN} install  
	touch /opt/${PROJECT}/${TARGET}/lib/libgloss.a

clean:
	rm -r -I ${BUILD_DIR}

${BUILD_ROOT} ${TAR_DIR} ${SRC_DIR}: %:
	mkdir -p $@

${BUILD_DIR}: | ${BUILD_ROOT}
	mkdir -p $@

${BINUTILS_BIN} ${GCC_BIN} ${PICOLIBC_BIN} ${GXX_BIN}: %: | ${BUILD_DIR}
	mkdir -p $@

${BINUTILS_SRC} ${GCC_SRC} ${PICOLIBC_SRC}: %: | ${SRC_DIR}
	mkdir -p $@

${BINUTILS_TAR}: | ${TAR_DIR}
	wget https://mirrors.tuna.tsinghua.edu.cn/gnu/binutils/binutils-${BINUTILS_VER}.tar.xz -O $@

${BINUTILS_CFG}: ${BINUTILS_TAR} | ${SRC_DIR}
	tar -xaf $< -C ${SRC_DIR}
	touch $@

${BINUTILS_MAK}: ${BINUTILS_CFG} | ${BINUTILS_BIN}
	cd ${BINUTILS_BIN} && ${RELP}/${BINUTILS_CFG} ${BINUTILS_FLAGS}

${GCC_TAR}: | ${TAR_DIR}
	wget https://mirrors.tuna.tsinghua.edu.cn/gnu/gcc/gcc-${GCC_VER}/gcc-${GCC_VER}.tar.xz -O $@

${GCC_CFG}: ${GCC_TAR} | ${SRC_DIR}
	tar -xaf $< -C ${SRC_DIR}
	touch $@

${GCC_MAK}: ${GCC_CFG} | ${GCC_BIN}
	cd ${GCC_BIN} && ${RELP}/${GCC_CFG} ${GCC_FLAGS}

${GXX_MAK}: ${GCC_CFG} | ${GXX_BIN}
	cd ${GXX_BIN} && ${RELP}/${GCC_CFG} ${GXX_FLAGS}

${PICOLIBC_TAR}: | ${TAR_DIR}
	wget https://github.com/picolibc/picolibc/releases/download/${PICOLIBC_VER}/picolibc-${PICOLIBC_VER}.tar.xz -O $@

${PICOLIBC_CFG} : ${PICOLIBC_TAR} | ${SRC_DIR}
	tar -xaf $< -C ${SRC_DIR}
	touch $@

${PICOLIBC_MAK} : ${PICOLIBC_CFG} | ${PICOLIBC_BIN}
	cd ${PICOLIBC_BIN} && meson setup --cross-file=${RELP}/cross-file.cfg ${PICOLIBC_FLAGS} ${RELP}/${PICOLIBC_SRC} 
