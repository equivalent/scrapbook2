
Remove all failed pods:

```
kubectl get po --all-namespaces --field-selector 'status.phase==Failed' -o json | kubectl delete -f -
```
