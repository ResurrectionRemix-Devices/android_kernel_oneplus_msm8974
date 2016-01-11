#!/bin/bash

# Bash Color
green='\033[01;32m'
red='\033[01;31m'
blink_red='\033[05;31m'
restore='\033[0m'
clear

# Resources
THREAD="-j10"
KERNEL="zImage"
DTBIMAGE="dtb"
DEFCONFIG="cyanogenmod_bacon_defconfig"
device="bacon"

# Kernel Details
BASE_RR_VER="RR"
VER="V3.2"
RR_VER="$BASE_RR_VER$VER"

# Vars
export LOCALVERSION="-$RR_VER-$(date +%Y%m%d)"
export CROSS_COMPILE="/home/varun/rr2/prebuilts/gcc/linux-x86/arm/arm-eabi-5.3/bin/arm-eabi-"
export ARCH=arm
export SUBARCH=arm
export KBUILD_BUILD_HOST=`hostname`
# Paths
KERNEL_DIR=`pwd`
REPACK_DIR="$KERNEL_DIR/anykernel"
PATCH_DIR="$KERNEL_DIR/anykernel/patch"
ZIMAGE_DIR="$KERNEL_DIR/arch/arm/boot"
FINAL_ZIP="/home/varun/RR/$RR_VER-$(date +%Y%m%d).zip"
# Functions

function make_dtb {
		$REPACK_DIR/tools/dtbToolCM -2 -o $REPACK_DIR/$DTBIMAGE -s 2048 -p scripts/dtc/ arch/arm/boot/

}
function clean_all {
		make clean && make mrproper
}

function make_kernel {
		echo
		make $DEFCONFIG
		make $THREAD
		cp -vr $ZIMAGE_DIR/$KERNEL $REPACK_DIR/zImage
}

function make_zip {
		cd $REPACK_DIR
		zip -r9 ~/oneplus/$RR_VER-$(date +%Y%m%d).zip *
		cd $KERNEL_DIR
		while read -p "Do you want to upload zip (y/n)? " uchoice
		do
		case "$uchoice" in
		        y|Y )
		                upload-sf $FINAL_ZIP RR/device/bacon/RRkernel
		                break
		                ;;
		        n|N )
		                break
		                ;;
		        * )
		                echo
		                echo "Invalid try again!"
		                echo
		                ;;
		esac
		done
}


DATE_START=$(date +"%s")

echo -e "${red}"; echo -e "${blink_red}"; echo "$AK_VER"; echo -e "${restore}";

echo -e "${green}"
echo "-----------------"
echo "Making RR Kernel:"
echo "-----------------"
echo -e "${restore}"

case "$1" in
clean|cleanbuild)
clean_all
make_kernel
make_dtb
if [ -e "arch/arm/boot/zImage" ]; then
make_zip
else
echo -e "Error Occurred"
echo -e "zImage not found"
fi
;;
dirty)
make_kernel
make_dtb
if [ -e "arch/arm/boot/zImage" ]; then
make_zip
else
echo -e "Error Occurred"
echo -e "zImage not found"
fi
;;
*)
while read -p "Do you want to clean stuff (y/n)? " cchoice
do
case "$cchoice" in
	y|Y )
		clean_all
		echo
		echo "All Cleaned now."
		break
		;;
	n|N )
		break
		;;
	* )
		echo
		echo "Invalid try again!"
		echo
		;;
esac
done

echo

while read -p "Do you want to build kernel (y/n)? " dchoice
do
case "$dchoice" in
	y|Y)
		make_kernel
		make_dtb
		if [ -e "arch/arm/boot/zImage" ]; then
		make_zip
		fi
		break
		;;
	n|N )
		break
		;;
	* )
		echo
		echo "Invalid try again!"
		echo
		;;
esac
done
;;
esac
echo -e "${green}"
echo "-------------------"
echo "Build Completed in:"
echo "-------------------"
echo -e "${restore}"

DATE_END=$(date +"%s")
DIFF=$(($DATE_END - $DATE_START))
echo "Time: $(($DIFF / 60)) minute(s) and $(($DIFF % 60)) seconds."
echo

