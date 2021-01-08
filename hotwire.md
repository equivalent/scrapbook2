


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

