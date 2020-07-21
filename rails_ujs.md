

```js
import Rails from '@rails/ujs';
import { Controller } from "stimulus"

export default class extends Controller {
  static targets = [ "recaptchaToken" ]

  greet() {
    let recaptcha_token  = this.recaptchaTokenTarget.value

    Rails.ajax({
      type: 'post',
      url: 'http://localhost:3001/v3/email_authentication',
      data: `recaptcha_token=${recaptcha_token}`,
      dataType: 'json',
      success: function(data) {
        console.log(data);
      },
      error: function(data) {
        alert(data);
      }
    })
  }
}
```

* https://medium.com/actualize-network/sending-post-requests-in-rails-5-1-without-jquery-ff89f6f80487
* https://dev.to/morinoko/adding-recaptcha-v3-to-a-rails-app-without-a-gem-46jj
