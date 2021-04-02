

` 'data-turbo-frame' => '_top'`



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
