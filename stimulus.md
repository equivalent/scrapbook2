
### companies controloler


```js
# a/j/c/company_controller.js

import { Controller } from 'stimulus'
export default class extends Controller {
  static targets = [ "phoneSubmitBtn", "phoneInput" ]

  initialize() {
    this.hidePhoneSubmitBtnIfValueSame();
  }

  phoneSubmit(event) {
    event.preventDefault();
    var res = $.ajax({
      url: this.data.get('update-company-path'),
      data: { company: {phone: this.phoneInputTarget.value } },
      type: 'PUT',
    })
  }

  phoneBlured(event) {
    this.phoneInputTarget.value = $.trim(this.phoneInputTarget.value);
  }

  phoneInputed(event) {
    this.hidePhoneSubmitBtnIfValueSame();
  }

  //..........


  hidePhoneSubmitBtnIfValueSame(){
    console.log(this.data.get('original-phone'));
    if(this.phoneInputTarget.value == this.data.get('original-phone')) {
      //$(this.phoneSubmitBtnTarget).hide();
      $(this.phoneSubmitBtnTarget).css("visibility", "hidden");
    } else {
      //$(this.phoneSubmitBtnTarget).show();
      $(this.phoneSubmitBtnTarget).css("visibility", "visible");
    }
  }
}
```

### helloz example

https://www.youtube.com/watch?v=GEJWvMYU5_8


```slim
    <%= javascript_pack_tag 'application', 'data-turbolinks-track': 'reload' %>



div data-controller="helloz" data-helloz-name="Tomas"
  input data-target="helloz.name" type="text" data-action="paste->helloz#log"
  button data-action="click->helloz#log" hello

```


```js
# app/javascript/packs/application.js
import { Application } from "stimulus"
import { definitionsFromContext } from "stimulus/webpack-helpers"
const application = Application.start()
const context = require.context("controllers", true, /.js$/)
application.load(definitionsFromContext(context))

# app/javascript/controllers/helloz_controller.js
import { Controller } from 'stimulus'
export default class extends Controller {
  initialize() {
    this.nameElement.value = this.name
  }

  log(event) {
    //console.log(this.targets.find("name").value)
    console.log(this.nameElement.value)
  }

  get name() {
    if(this.data.has("name")) {
      return this.data.get("name")
    } else {
      return "Default value"
    }
  }

  get nameElement() {
    return this.targets.find("name")
  }
}
```
