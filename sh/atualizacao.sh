#/bin/bash

pkill -9 PdvJava2
pkill -9 lnx
pkill -9 java
pkill -9 chr

if [ -d /Zanthus/Zeus/lib ]; then
echo "copiando diretorio lib..."
sleep 3
cp -rf so/* /Zanthus/Zeus/lib/
fi

if [ -d /Zanthus/Zeus/lib_co5 ]; then
echo "copiando diretorio lib_co5..."
sleep 3
cp -rf so_co5/* /Zanthus/Zeus/lib_co5/
fi

if [ -d /Zanthus/Zeus/lib_ubu ]; then
echo "copiando diretorio lib_ubu..."
sleep 3
cp -rf so_ubu/* /Zanthus/Zeus/lib_ubu/
fi

if [ -d /Zanthus/Zeus/lib_u64 ]; then
echo "copiando diretorio lib_u64..."
sleep 3
cp -rf so_u64/* /Zanthus/Zeus/lib_u64/
fi

ldconfig

cp -rf ZMAN_1_X_X_700_CZ.EXL /Zanthus/Zeus/pdvJava/
cp -rf moduloPHPPDV_2_14_165_143b_24176_php_5_6.zip /Zanthus/Zeus/pdvJava/GERAL/SINCRO/WEB/moduloPHPPDV

cd /Zanthus/Zeus/pdvJava/GERAL/SINCRO/WEB/moduloPHPPDV
unzip -o moduloPHPPDV_2_14_165_143b_24176_php_5_6.zip

cd /Zanthus/Zeus/pdvJava/
tar -zxvf ZMAN_1_X_X_700_CZ.EXL

# ls -1 ctsat* moduloPHPPDV* pdvGUI* ZMAN* >> atualizacao.sh
if [ -d /Zanthus/Zeus/lib ]; then
echo "copiando ctsat..."
sleep 3
ctsat:
lnx_ctsat_2_1_0.xz
lnx_ctsat_2_1_0.xz64

moduloPHPPDV:
moduloPHPPDV_2_14_165_143c_24180_php_5_6.zip
moduloPHPPDV_2_14_165_143c_24180_php_8_1.zip

pdvGUI:
jpdvgui6_v7_7_15_14.jar

ZMAN:
ZMAN_1_X_X_700_CZ.EXL
