source /etc/environment
source /opt/webadmin/extra/path_comum_sinc/path_comum_sinc.conf
source /Zanthus/Zeus/pdvJava/ATULIB_0.TXT

#if [ "$CONF_UPDATE_MODE" == 'Manager' ]; then
if [ -n "$VERSAO" ] || [ -n "$PURO_ZTAR" ] || [ -n "$ZTAR" ]; then
        cd /Zanthus/Zeus/pdvJava/
        ./libpdv_separa.xz64 /Zanthus/Zeus/lib_inter |grep "Ja esta com versao atualizada"
        if [ "$?" != "0" ];then
                # Descompactando so_u64 e copiando para pasta Zanthus/Zeus/so_u64
                if [ -n "$(ls -A /Zanthus/Zeus/lib_inter)" ]; then
                        # Compactar Pasta so_u64 para backup
                        echo -e "[Backup das Bibliotecas (lib_u64) realizada com sucesso!]\n"
                        find /Zanthus/Zeus/lib_u64_* -type f -mtime +15 -exec rm -rf {} \;
                        cd /Zanthus/Zeus/
                        tar -czf lib_u64_$(date +%Y-%m-%d_%H-%M-%S).tar.gz lib_u22
                        cd lib_u22
                        #rm -rf *.*
                        cd /Zanthus/Zeus/lib_inter/
                        tar -xvf ExecLibs.tar.gz
                        cp -f * /Zanthus/Zeus/lib_u22/
                        cd /Zanthus/Zeus/
                        rm -rf /lib_inter/*
                fi
        echo -e "[Atualizacao das Bibliotecas via Manager (lib_u64) realizada com sucesso!]\n"
        else
                echo -e "[Nao existem atualizacoes de (lib_u64) a serem realizadas.!]\n"
        fi
fi

#fi
