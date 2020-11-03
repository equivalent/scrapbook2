## pure Java Script notes


### .map() alternative


how to map children elements data

```
let chipFiltersTargetDiv = document.getElementById('my-div-id');

let filterChips = chipFiltersTargetDiv.children

let filtersData = []
for (let chip of filterChips) {
  filtersData.push(Object.assign({}, chip.dataset))
}

conssole.log(filtersData); // [{}, {}, {}]
```
