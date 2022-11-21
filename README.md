# Container registry lab
Lab for testing Azure container registry tasks.

## GitHub - Personal Access Token (PAT)
Create your PAT here: [github.com/settings/tokens](https://github.com/settings/tokens)

## Manual
To run a manual build with container registry task:

`az acr build --resource-group <RESOURCE GROUP NAME> --registry <CONTAINER REGISTRY NAME> --image <IMAGE:TAG> --file Dockerfile .`