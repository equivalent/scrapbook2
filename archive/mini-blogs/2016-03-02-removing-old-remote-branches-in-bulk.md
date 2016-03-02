# Removing old release branches

After some time release branches piles up and we may want to clean up
our Github from old `live-*` branches

Given we name our release branches `live-20150821` (`live-yearmmdd`) here is an example how to remove all live branches from previous year (Given it's 2016)

* cd to the repo of your project you want to cleanup
* create the `cleanup.rb` with content bellow
* lunch `ruby cleanup.rb`

```ruby
# cleanup.rb
old_live_branches = `git fetch origin && git branch -r | grep live-2015`  # all branches `live-2015*`
old_live_branches
  .split("\n")
  .map(&:strip)
  .map { |i| i.gsub("/", ' :') }
  .each do |destroy|
    # e.g.: git push origin :live-20151129
    puts `git push #{destroy}`
  end
```
