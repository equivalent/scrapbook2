
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

az aks browse -n support-app -g support  # kubernetes UI

az aks scale -n support-app -g support -c 3  # scale to 3 nodes
az aks get-versions -n support-app -g support  -o table  # agent version


kubectl get pods --all-namespaces
```



https://channel9.msdn.com/blogs/OfficeDevPnP/PnP-Web-Cast-oAuth-and-OpenID-Connect-for-Office-365-developer
