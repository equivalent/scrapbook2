
`--validate` for dry-run 

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
```



https://channel9.msdn.com/blogs/OfficeDevPnP/PnP-Web-Cast-oAuth-and-OpenID-Connect-for-Office-365-developer
