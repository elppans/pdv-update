#!/bin/bash

# Diretório base
bdir="$(pwd)"

# Arquivos PDV
ctsat32l=lnx_ctsat.xz
ctsat64l=lnx_ctsat.xz64
pdvGUIj=jpdvgui6.jar

# Arquivos locais
ctsat32="$(find "$bdir"/*/lnx_ctsat*.xz | sort -V | tail -n 1 | xargs basename)"
ctsat64="$(find "$bdir"/*/lnx_ctsat*.xz64 | sort -V | tail -n 1 | xargs basename)"
moduloPHPPDV56="$(find "$bdir"/*/moduloPHPPDV*php_5_6.zip | sort -V | tail -n 1 | xargs basename)"
moduloPHPPDV81="$(find "$bdir"/*/moduloPHPPDV*php_8_1.zip | sort -V | tail -n 1 | xargs basename)"
pdvGUI="$(find "$bdir"/*/jpdvgui6*.jar | sort -V | tail -n 1 | xargs basename)"
ZMAN="$(find "$bdir"/*/ZMAN*.EXL | sort -V | tail -n 1 | xargs basename)"

# Diretorio base PDV
zz='/Zanthus/Zeus'

# Diretórios de aplicação
pdvJava_dir="$zz/pdvJava"
pdvGUI_dir="$zz/pdvJava/pdvGUI"
modulo_dir="$zz/pdvJava/GERAL/SINCRO/WEB/moduloPHPPDV"
ctsat_dir="$zz/ctsat"

# Criando/Mesclando diretórios para trabalho
for dir in $pdvJava_dir $pdvGUI_dir $modulo_dir $ctsat_dir; do
    if [ ! -d "$dir" ]; then
        mkdir -p "$dir"
        chmod 777 "$dir"
    fi
done

# Verifica a arquitetura do sistema
ARCH=$(uname -m)

# Função para copiar diretórios
copiar_diretorio() {
    local origem="$1"
    local destino="$zz/$2"

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
    ctsat=$ctsat_dir/$ctsat32l

    # Verifica se o arquivo é um link simbólico
    if [ -L "$ctsat" ]; then
        #echo "O arquivo é um link simbólico."
        unlink "$ctsat"
        ln -sf "$ctsat_dir/$ctsat32" "$ctsat"
        chmod +x "$ctsat_dir/$ctsat32"
    else
        #echo "O arquivo não é um link simbólico."
        mv "$ctsat" "$ctsat".old
        ln -sf "$ctsat_dir/$ctsat32" "$ctsat"
    fi
}

# Função para executar comandos em sistemas de 64 bits
run_on_64_bits() {
    echo "Executando comandos para 64 bits..."
    copiar_diretorio so_u64/ lib_u64
    copiar_diretorio ctsat/"$ctsat64" ctsat

    # Caminho para o arquivo ctsat 64
    ctsat=$ctsat_dir/$ctsat64l

    # Verifica se o arquivo é um link simbólico
    if [ -L "$ctsat" ]; then
        #echo "O arquivo é um link simbólico."
        unlink "$ctsat"
        ln -sf "$ctsat_dir/$ctsat64" "$ctsat"
        chmod +x "$ctsat_dir/$ctsat64"
    else
        #echo "O arquivo não é um link simbólico."
        mv "$ctsat" "$ctsat".old
        ln -sf "$ctsat_dir/$ctsat64" "$ctsat"
    fi
}

# Verifica se é 32 bits ou 64 bits e chama a função correspondente
pdv_check() {
if [ "$ARCH" == "x86_64" ]; then
    run_on_64_bits
else
    run_on_32_bits
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
            sed -i '/Z_MOUNT/i service zanthus start' $pdvJava_dir/pdvJava2
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
        copiar_diretorio moduloPHPPDV/"$moduloPHPPDV81" pdvJava/GERAL/SINCRO/WEB/moduloPHPPDV
        # shellcheck disable=SC2164
        cd "$modulo_dir"
        unzip -q -o "$moduloPHPPDV81"
    else
        echo "Versão não suportada."
    fi
}

# Função para atualização do CODFON
zman_check() {
    copiar_diretorio ZMAN/"$ZMAN" pdvJava
    # shellcheck disable=SC2164
    if [ -e "$pdvJava_dir"/"$ZMAN" ]; then
        cd "$pdvJava_dir"
        tar -zxf "$ZMAN"
    else
        echo "Arquivo $ZMAN não encontrado!"
        exit 1

    fi
}

# Função para atualizaçao do Java do PDV
pdvgui_check() {
    copiar_diretorio pdvGUI/"$pdvGUI" pdvJava/pdvGUI

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
}

# Chama as funções para PDV
pdv_check
modulo_check
zman_check
pdvgui_check
