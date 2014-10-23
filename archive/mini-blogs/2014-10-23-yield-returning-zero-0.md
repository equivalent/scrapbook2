# Yield Haml block will return 0  (zero)

I had a presenter-view code like this one:

```ruby
class MyPresenter
  def render_content
    view_header = true
    yield(self, view_header)
  end

  def tlt(name)
    "fetching translation for #{name}"
  end
end
```

```haml
- language_presenter = MyPresenter.new
- language_presenter.render_content do |presenter, view_header|
  = content_tag :h2, presenter.tlt('top_header') if view_header
  = presenter.tlt('main_body')
  bla bla bla 
```

but for some reason the value of `yield(self, view_header)` was `0`.
Not nil, not empty string but a zero.

It turns out it was caused by the way how Haml outputs to template.
Long story short, using `capture_haml` will capture haml to sting, and 
if you then render that string with `=` that will make it work properly:

```haml
- language_presenter = MyPresenter.new
= language_presenter.render_content do |presenter, view_header|
  - capture_haml do
    = content_tag :h2, presenter.tlt('top_header') if view_header
    = presenter.tlt('main_body')
    bla bla bla
```

source: 

* http://stackoverflow.com/questions/3619699/haml-block-returning-0-on-yield
* http://haml.info/docs/yardoc/Haml/Helpers.html#capture_haml-instance_method
