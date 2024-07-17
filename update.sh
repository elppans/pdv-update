#!/bin/bash

# Arquivos
ctsat32l=lnx_ctsat.xz
ctsat64l=lnx_ctsat.xz64
ctsat32=lnx_ctsat_2_1_0.xz
ctsat64=lnx_ctsat_2_1_0.xz64
moduloPHPPDV56=moduloPHPPDV_2_14_165_143c_24180_php_5_6.zip
moduloPHPPDV58=moduloPHPPDV_2_14_165_143c_24180_php_8_1.zip
pdvGUIj=jpdvgui6.jar
pdvGUI=jpdvgui6_v7_7_15_14.jar
ZMAN=ZMAN_1_X_X_700_CZ.EXL

# Diretorios
pdvJava_dir='/Zanthus/Zeus/pdvJava'
pdvGUI_dir='/Zanthus/Zeus/pdvJava/pdvGUI'
modulo_dir='/Zanthus/Zeus/pdvJava/GERAL/SINCRO/WEB/moduloPHPPDV'

# Verifica a arquitetura do sistema
ARCH=$(uname -m)

# Função para copiar diretórios
copiar_diretorio() {
    local origem="$1"
    local destino="/Zanthus/Zeus/$2"

    if [ -d "$destino" ]; then
        echo "Copiando diretório $origem para $destino..."
        sleep 3
        rsync -ahz --info=progress2 "$origem" "$destino"
    else
        echo "Diretório $destino não existe."
    fi
}

# Copia os diretórios fixos (?):
# copiar_diretorio parametro_origem parametro_destino

# Função para executar comandos em sistemas de 32 bits
run_on_32_bits() {
    echo "Executando comandos para 32 bits..."
    copiar_diretorio so/ lib
    copiar_diretorio so_co5/ lib_co5
    copiar_diretorio so_ubu/ lib_ubu
    copiar_diretorio ctsat/"$ctsat32" ctsat
    # Caminho para o arquivo ctsat 32
    ctsat=/Zanthus/Zeus/ctsat/$ctsat32l

    # Verifica se o arquivo é um link simbólico
    if [ -L "$ctsat" ]; then
        #echo "O arquivo é um link simbólico."
        unlink "$ctsat"
        ln -sf "/Zanthus/Zeus/ctsat/$ctsat32" "$ctsat"
        chmod +x "/Zanthus/Zeus/ctsat/$ctsat32"
    else
        #echo "O arquivo não é um link simbólico."
        mv "$ctsat" "$ctsat".old
        ln -sf "/Zanthus/Zeus/ctsat/$ctsat32" "$ctsat"
    fi
}

# Função para executar comandos em sistemas de 64 bits
run_on_64_bits() {
    echo "Executando comandos para 64 bits..."
    copiar_diretorio so_u64/ lib_u64
    copiar_diretorio ctsat/"$ctsat64" ctsat
    # Caminho para o arquivo ctsat 64
    ctsat=/Zanthus/Zeus/ctsat/$ctsat64l

    # Verifica se o arquivo é um link simbólico
    if [ -L "$ctsat" ]; then
        #echo "O arquivo é um link simbólico."
        unlink "$ctsat"
        ln -sf "/Zanthus/Zeus/ctsat/$ctsat64" "$ctsat"
        chmod +x "/Zanthus/Zeus/ctsat/$ctsat64"
    else
        #echo "O arquivo não é um link simbólico."
        mv "$ctsat" "$ctsat".old
        ln -sf "/Zanthus/Zeus/ctsat/$ctsat64" "$ctsat"
    fi
}

# Função para verificar a versão do Ubuntu
modulo_check() {
    local versao
    versao=$(lsb_release -rs)
    #echo "Versão do Ubuntu: $versao"

    if [[ "$versao" == "12."* ]]; then
        # Comandos específicos para o Ubuntu 12
        echo "Executando comandos para o Ubuntu 12..."
        # Verifica a versão do PHP
        pacphp="php/php_5.6.28-1_i386.deb"
        php_version=$(php -v | grep -oP 'PHP \K[0-9]+\.[0-9]+')

        # Compara a versão e executa os comandos correspondentes
        # shellcheck disable=SC2164
        if [[ "$php_version" == "5.4" ]]; then
            echo "Versão do PHP: 5.4"
            dpkg -i "$pacphp"
            sed -i '/Z_MOUNT/i service zanthus start' /Zanthus/Zeus/pdvJava/pdvJava2
            copiar_diretorio moduloPHPPDV/"$moduloPHPPDV56" pdvJava/GERAL/SINCRO/WEB/moduloPHPPDV
            cd "$modulo_dir"
            unzip -q -o "$moduloPHPPDV56"
        elif [[ "$php_version" == "5.6" ]]; then
            echo "Versão do PHP: 5.6"
            copiar_diretorio moduloPHPPDV/"$moduloPHPPDV56" pdvJava/GERAL/SINCRO/WEB/moduloPHPPDV
            cd "$modulo_dir"
            unzip -q -o "$moduloPHPPDV56"
        else
            echo "Versão do PHP não é 5.4 nem 5.6."
            exit 1
        fi
    elif [[ "$versao" == "16."* ]]; then
        # Comandos específicos para o Ubuntu 16
        echo "Executando comandos para o Ubuntu 16..."
        copiar_diretorio moduloPHPPDV/"$moduloPHPPDV56" pdvJava/GERAL/SINCRO/WEB/moduloPHPPDV
        # shellcheck disable=SC2164
        cd "$modulo_dir"
        unzip -q -o "$moduloPHPPDV56"
    elif [[ "$versao" == "22."* ]]; then
        # Comandos específicos para o Ubuntu 22
        echo "Executando comandos para o Ubuntu 22..."
        copiar_diretorio moduloPHPPDV/"$moduloPHPPDV58" pdvJava/GERAL/SINCRO/WEB/moduloPHPPDV
        # shellcheck disable=SC2164
        cd "$modulo_dir"
        unzip -q -o "$moduloPHPPDV58"
    else
        echo "Versão não suportada."
    fi
}

# Chama as funções

# Verifica se é 32 bits ou 64 bits e chama a função correspondente
if [ "$ARCH" == "x86_64" ]; then
    run_on_64_bits
else
    run_on_32_bits
fi

copiar_diretorio pdvGUI/"$pdvGUI" pdvJava/pdvGUI
copiar_diretorio ZMAN/"$ZMAN" pdvJava
modulo_check

# shellcheck disable=SC2164
if [ -e "$pdvJava_dir"/"$ZMAN" ]; then
    cd "$pdvJava_dir"
    tar -zxf "$ZMAN"
else
    echo "Arquivo $ZMAN não encontrado!"
    exit 1

fi

if [ -e "$pdvGUI_dir/$pdvGUI" ]; then
    if [ -L "$pdvGUI_dir/$pdvGUIj" ]; then
        #echo "O arquivo é um link simbólico."
        unlink "$pdvGUI_dir/$pdvGUIj"
        ln -sf "$pdvGUI_dir/$pdvGUI" "$pdvGUI_dir/$pdvGUIj"
        chmod +x "$pdvGUI_dir/$pdvGUI"
    else
        #echo "O arquivo não é um link simbólico."
        mv "$pdvGUI_dir/$pdvGUIj" "$pdvGUI_dir/$pdvGUIj.old"
        ln -sf "$pdvGUI_dir/$pdvGUI" "$pdvGUI_dir/$pdvGUIj"
        chmod +x "$pdvGUI_dir/$pdvGUI"
    fi
else
    echo "$pdvGUIj não encontrado!"
    exit 1
fi
