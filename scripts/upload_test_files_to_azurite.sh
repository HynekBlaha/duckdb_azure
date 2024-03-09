#!/bin/bash

# Default Azurite connection string (see: https://github.com/Azure/Azurite)
conn_string="DefaultEndpointsProtocol=http;AccountName=devstoreaccount1;AccountKey=Eby8vdM02xNOcqFlqUwJPLlmEtlCDXJ1OUzFT50uSRZ6IFsuFq2UVErCz4I6tq/K1SZFPTOtr/KBHBeksoGMGw==;BlobEndpoint=http://127.0.0.1:10000/devstoreaccount1;QueueEndpoint=http://127.0.0.1:10001/devstoreaccount1;TableEndpoint=http://127.0.0.1:10002/devstoreaccount1;"

# Create container
az storage container create -n testing-private --connection-string "${conn_string}"
az storage container create -n testing-public  --connection-string "${conn_string}" --public-access blob

copy_file() {
  local from="${1}"
  local to="${2}"
  az storage blob upload --file "${from}" --name "${to}" --container-name "testing-private" --connection-string "${conn_string}"
  az storage blob upload --file "${from}" --name "${to}" --container-name "testing-public"  --connection-string "${conn_string}"
}

while read filepath; do
    remote_filepath="$(echo "${filepath}" | cut -c 8-)"
    copy_file "${filepath}" "${remote_filepath}"
done < <(find ./data -type f)
