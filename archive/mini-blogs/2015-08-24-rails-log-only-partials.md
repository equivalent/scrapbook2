# Rails log - partials log only

Let say your Rails log is doing to much and you just want to see which
partials or layouts are beeing rendered.

```bash
cd ~/my-rails-application
tail -f log/development.log                     # entire log as it is

tail -f log/development.log | grep -e 'Render'  # just what is rendered
                                                # partials / layouts
```

This can be anything you want

```bash
tail -f log/development.log | grep -e 'anything'
```
