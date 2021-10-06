 #!/bin/bash
url=https://www.mscbs.gob.es/profesionales/saludPublica/ccayes/alertasActual/nCov/documentos/Informe_Comunicacion_20210119.ods
date=$(date +%m-%d-%Y)
dirName="$date.ods"
curl $url > $dirName