
`--validate` for dry-run 

## export DNS zonefiles from Azure with az cli

```
az network dns zone export --resource-group <name-of-resource-group> --name whatever.com --output table
```

> name-of-resource-group - can be found in azure portal once you click
> on hosted zone overview



## webapp (Appservices)


```
az webapp list -o table


# add ENV variable

az webapp config appsettings list -g myResourceGroup -n <app_name>  -o table
az webapp config appsettings set --resource-group myResourceGroup --name <app_name> --settings WEBSITES_PORT=8000

# deploy image

az webapp config container set --name <app_name> --resource-group myResourceGroup --docker-registry-server-user <docker-id> --docker-registry-server-password <password>

az webapp config container set --name <app_name> --resource-group myResourceGroup --docker-custom-image-name <azure-container-registry-name>.azurecr.io/mydockerimage --docker-registry-server-url https://<azure-container-registry-name>.azurecr.io --docker-registry-server-user <registry-username> --docker-registry-server-password <password>

```

## ACS 

```
az group create  --name support --location uksouth
az acs create --orchestrator-type kubernetes --resource-group support --name support --agent-count 1 --generate-ssh-keys

```


## AKS

```
az group create -n support -l westeurope
az aks create -g support -n support-app -c 1 # -l westeurope
az aks list -o table
az aks get-credentials -n support-app -g support

az aks browse -n support-app -g support  # kubernetes UI

az aks scale -n support-app -g support -c 3  # scale to 3 nodes
az aks get-versions -n support-app -g support  -o table  # agent version


kubectl get pods --all-namespaces
```



https://channel9.msdn.com/blogs/OfficeDevPnP/PnP-Web-Cast-oAuth-and-OpenID-Connect-for-Office-365-developer
