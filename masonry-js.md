

_a/views/entries/index.html.slim_

```slim

.container
  .row data-masonry=("{\"percentPosition\": true }")
    = render partial: "search/es_entry_card", collection: @es.es_entries, as: :es_entry

```


_a/views/search/_es_entry_card.html.slim_

```slim
.col-sm-6.col-lg-3.mb-4
  .card
    - if es_entry.main_picture
      = image_tag es_entry.main_picture.variant(resize_to_fill: [400, 300],  quality: 80), class: "card-img-top", alt: es_entry.title
    - else
      = image_tag 'https://via.placeholder.com/400x300', class: "card-img-top", alt: es_entry.title
    .card-body
      = entry_category_badge(es_entry.categories.last, title: es_entry.categories.map(&:title).join('>'))
      = entry_region_badge(es_entry)
      = entry_price_badge(es_entry)
      .clearfix.mb-2
      h5.card-title= em_only(es_entry.suggestable_title)
      = link_to 'Zobraz', entry_path(es_entry.public_uid), class: 'btn btn-primary'
```


_a/javascript/packs/application.js_

```js
import Masonry from 'masonry-layout' // https://getbootstrap.com/docs/5.0/examples/masonry/
```

_package.json_

```json
 //...
    "masonry-layout": "^4.2.2",
 //...
```
