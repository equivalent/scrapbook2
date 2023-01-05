
**to disable turbo on a form sumbit:**
```
= form_with model: post, data: { turbo: false } do |f|
```


` 'data-turbo-frame' => '_top'`

```
= link_to 'Pokračovať',  root_path, class: "btn", 'data-turbo-frame' => '_top'

```

## tag

```erb
<%= turbo_frame_tag "tray", src: tray_path(tray) %>
# => <turbo-frame id="tray" src="http://example.com/trays/1"></turbo-frame>

<%= turbo_frame_tag tray, src: tray_path(tray) %>
# => <turbo-frame id="tray_1" src="http://example.com/trays/1"></turbo-frame>

<%= turbo_frame_tag "tray", src: tray_path(tray), target: "_top" %>
# => <turbo-frame id="tray" target="_top" src="http://example.com/trays/1"></turbo-frame>

<%= turbo_frame_tag "tray", target: "other_tray" %>
# => <turbo-frame id="tray" target="other_tray"></turbo-frame>

<%= turbo_frame_tag "tray", src: tray_path(tray), loading: "lazy" %>
# => <turbo-frame id="tray" src="http://example.com/trays/1" loading="lazy"></turbo-frame>

<%= turbo_frame_tag "tray" do %>
  <div>My tray frame!</div>
<% end %>
# => <turbo-frame id="tray"><div>My tray frame!</div></turbo-fram
```

* https://turbo.hotwired.dev/handbook/frames
* https://github.com/hotwired/turbo-rails/blob/main/app/helpers/turbo/frames_helper.rb
* https://developer.mozilla.org/en-US/docs/Web/Performance/Lazy_loading

## disabel turbo in form submision

```ruby
= form_with(model: @login_code, url: whatever_path, method: :post, data: { 'turbo': false }) do |f|
  = f.submit "Ok", class: "btn btn-primary float-end"
```

* [source](https://github.com/hotwired/turbo-rails/issues/31)


## Form Submitions

```ruby
class EntryController < ApplicationController
  # ...

  def create
    @entry = Post.new
    @entry.attributes = params.require(:entry).permit(:title)

    if @entry.save
      # always do redirect on success, not a 200 render
      redirect_to entry_path(@entry)
    else
      # for erros it's ok to reder partial, but you munt return 4xx or 5xx erros
      render :new, status: :unprocessable_entity
    end
  end

  # ...
end
```

source

* <https://twitter.com/dhh/status/1346448749170749449>
* <https://turbo.hotwire.dev/handbook/drive#redirecting-after-a-form-submission>

## Form submit from JS

```erb
<%= form_with model: todo, url: toggle_todo_path(todo), method: :post do |form| %>
  <%= form.check_box :completed, data: { controller: "checkbox", action: "checkbox#submit" } %>
<% end %>
```


```js
// app/javascript/controllers/checkbox_controller.js
import { Controller } from "stimulus"

export default class extends Controller {
  submit() {
    this.element.closest("form").requestSubmit();
  }
}
```

> note:  `submit()` submits the form, but that’s all it does. `requestSubmit()`, on the other hand, acts as if a submit button were clicked. The form’s content is validated, and the form is submitted only if validation succeeds. Once the form has been submitted, the submit event is sent back to the form object.


source:
<https://discuss.hotwire.dev/t/triggering-turbo-frame-with-js/1622/24?u=equivalent>

<https://discuss.hotwire.dev/t/triggering-turbo-frame-with-js/1622/23>


## Change browser url history

```
Turbo.navigator.history.replace({ absoluteURL: '/posts/1/edit' })
```

<https://discuss.hotwire.dev/t/how-to-change-current-url/1846>



## turbo rame pointing to another frame

https://www.hotrails.dev/turbo-rails/turbo-frames-and-turbo-streams

```
<%# app/views/quotes/index.html.erb %>

<main class="container">
  <%= turbo_frame_tag "first_turbo_frame" do %>
    <div class="header">
      <h1>Quotes</h1>
      <%= link_to "New quote",
                  new_quote_path,
                  data: { turbo_frame: "second_frame" },
                  class: "btn btn--primary" %>
    </div>
  <% end %>

  <%= turbo_frame_tag "second_frame" do %>
    <%= render @quotes %>
  <% end %>
</main>

<%# app/views/quotes/new.html.erb %>

<main class="container">
  <%= link_to sanitize("&larr; Back to quotes"), quotes_path %>

  <div class="header">
    <h1>New quote</h1>
  </div>

  <%= turbo_frame_tag "second_frame" do %>
    <%= render "form", quote: @quote %>
  <% end %>
</main>
```

A link can target a Turbo Frame it is not directly nested in, thanks to the data-turbo-frame data attribute. In that case, the Turbo Frame with the same id as the data-turbo-frame data attribute on the source page will be replaced by the Turbo Frame of the same id as the data-turbo-frame data attribute on the target page.



### different ways to render partail in stream

```
<%# app/views/quotes/create.turbo_stream.erb %>

<%= turbo_stream.prepend "quotes", partial: "quotes/quote", locals: { quote: @quote } %>
<%= turbo_stream.update Quote.new, "" %>

```

and this does the same

```
<%# app/views/quotes/create.turbo_stream.erb %>

<%= turbo_stream.prepend "quotes" do %>
  <%= render partial: "quotes/quote", locals: { quote: @quote } %>
<% end %>

<%= turbo_stream.update Quote.new, "" %>

```


### stream broadcast callbacks

```
  after_create_commit -> { broadcast_prepend_to "quotes", partial: "quotes/quote", locals: { quote: self }, target: "quotes" }
  
  after_create_commit -> { broadcast_prepend_later_to "quotes" }
  after_update_commit -> { broadcast_replace_later_to "quotes" }
  after_destroy_commit -> { broadcast_remove_to "quotes" }
  # Those three callbacks are equivalent to the following single line
  broadcasts_to ->(quote) { "quotes" }, inserts_by: :prepend

  # to secure this the frame msut be nested. https://www.hotrails.dev/turbo-rails/turbo-streams-security
  broadcasts_to ->(quote) { [quote.company, "quotes"] }, inserts_by: :prepend

```

```
class Discount < ApplicationRecord
  after_update_commit -> { broadcast_replace_to "discounts" }

  def to_partial_path
    "dashboard/discounts/discount"
  end
end
```

### broadcast security 

https://www.hotrails.dev/turbo-rails/turbo-streams-security

```
<%= turbo_stream_from current_company, "quotes" %>

  broadcasts_to ->(quote) { [quote.company, "quotes"] }, inserts_by: :prepend

```
