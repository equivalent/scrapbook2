# Active Storage - photoswipe in content


```erb
# app/views/entries/show.html.erb
<div data-controller="gallery">
  <%= @entry.content %>
</div>

<%= render 'photoswipe'%>
```

```erb
# app/views/active_storage/blobs/_blob.html.erb
<figure class="attachment attachment--<%= blob.representable? ? "preview" : "file" %> attachment--<%= blob.filename.extension %>">
  <% if blob.representable? %>

    <%= image_tag blob.variant(resize_to_fill: [300, 200],  quality: 80 ),
      'class':"img-thumbnail handjob",
      'data-large': polymorphic_url(blob.variant(resize_to_limit: [1600, 1200])),
      'data-action': 'click->gallery#onImageClick',
      'data-gallery-target': 'picture' %>

    <%#= image_tag blob.representation(resize_to_limit: local_assigns[:in_gallery] ? [ 800, 600 ] : [ 1024, 768 ]) %>

  <% end %>

  <figcaption class="attachment__caption">
    <% if caption = blob.try(:caption) %>
      <%= caption %>
    <% else %>
      <span class="attachment__name"><%= blob.filename %></span>
      <span class="attachment__size"><%= number_to_human_size blob.byte_size %></span>
    <% end %>
  </figcaption>
</figure>
```

```slim
# app/views/application/_photoswipe.html.slim
.pswp aria-hidden="true" role="dialog" tabindex="-1" 
  .pswp__bg
  .pswp__scroll-wrap
    .pswp__container
      .pswp__item
      .pswp__item
      .pswp__item
    .pswp__ui.pswp__ui--hidden
      .pswp__top-bar
        .pswp__counter
        button.pswp__button.pswp__button--close title="#{t('gallery.close')}" 
        button.pswp__button.pswp__button--share title="#{t('gallery.share')}" 
        button.pswp__button.pswp__button--fs title="#{t('gallery.fullscreen')}" 
        button.pswp__button.pswp__button--zoom title="#{t('gallery.zoom')}" 
        .pswp__preloader
          .pswp__preloader__icn
            .pswp__preloader__cut
              .pswp__preloader__donut
      .pswp__share-modal.pswp__share-modal--hidden.pswp__single-tap
        .pswp__share-tooltip
      button.pswp__button.pswp__button--arrow--left title="#{t('gallery.previous')}" 
      button.pswp__button.pswp__button--arrow--right title="#{t('gallery.next')}" 
      .pswp__caption
        .pswp__caption__center

```

```
# config/locales/en.yml
en:
  gallery:
    close: 'Close'
    share: 'Share'
    fullscreen: 'Fullscreen'
    zoom: 'Zoom'
    previous: 'Previous'
    next: 'Next'
```


```
# app/javascript/controllers/gallery_controller.js
// https://awesomeprogrammer.com/blog/2019/02/16/photoswipe-gallery-with-stimulusjs-on-rails/
import {Controller} from 'stimulus'
import * as PhotoSwipe from 'photoswipe'
import * as PhotoSwipeUI_Default from 'photoswipe/dist/photoswipe-ui-default'

export default class extends Controller {
  static targets = ['picture']


  onImageClick(event) {
    event.preventDefault()
    // as our gallery markup lives outside of our controller
    // unfortunately we need to query for it, for the simplicity of example
    // let's assume we have single gallery controller in the app and we can call
    // query selector directly by it's class and we don't need to extract it into
    // configurable data-attribute
    const galleryWrapper = document.querySelector('.pswp')

    var options = {
      // we don't want browser history for or example for the sake of simplicity
      history: false,
      // and I'm assuming we have unique links in each gallery
      index: this.items.findIndex(item => item.src === event.currentTarget.getAttribute('data-large'))
    }

    var gallery = new PhotoSwipe(galleryWrapper, PhotoSwipeUI_Default, this.items, options)

    // PhotoSwipe requires width and height do be declared up-front
    // let's work around that limitation, references:
    // https://github.com/dimsemenov/PhotoSwipe/issues/741#issuecomment-430725838
    gallery.listen('beforeChange', function() {
      const src = gallery.currItem.src

      const image = new Image()
      image.src = src

      image.onload = () => {
        gallery.currItem.w = image.width
        gallery.currItem.h = image.height

        gallery.updateSize()
      }
    })

    gallery.init()
  }

  get items() {
    return this.pictureTargets.map(function(item) {
      //src: item.getAttribute('href'),
      return {
        src: item.getAttribute('data-large'),
        title: item.getAttribute('alt'),
        w: 0,
        h: 0
      }
    })
  }
}

```
