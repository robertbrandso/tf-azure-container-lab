# Container registry lab
Lab for testing av container registry run tasks.

## Azure DevOps - Personal Access Token (PAT)
* Opprett PAT her: [Azure DevOps - Personal Access Tokens](https://dev.azure.com/NorskHelsenettUtvikling/_usersSettings/tokens)
* Scopes på PAT: `Code.Read`, `Code.Status`
* Legg inn PAT i `locals.git_access_token` som ligger i `main.tf`.

## Manuell
For å kjøre en manuell build på container registry:

`az acr build --resource-group <NAVN PÅ RESSURSGRUPPE> --registry <NAVN PÅ CONTAINER REGISTRY> --image <NAVN PÅ IMAGE:TAG> --file Dockerfile .`