
#


Generate model SNSNotification (optional, this can be anything you want really)

```bash
mix phoenix.gen.model SNSNotification sns_notifications message:text
mix ecto.migrate
```






# mix task

```ex
# lib/mix/tasks/eq8.sns_subscribe.ex 


```

```bash
mix compile              # comiple your mix file

mix help | grep sns
# mix myapp.sns_subscribe    # subscribes your app to SNS topic
```


# phoenix sns subscription

* https://github.com/CargoSense/ex_aws
* https://hexdocs.pm/ex_aws/ExAws.SNS.html#functions
* http://docs.aws.amazon.com/sns/latest/dg/SendMessageToHttp.html#SendMessageToHttp.confirm
* http://docs.aws.amazon.com/sns/latest/dg/SendMessageToHttp.html#SendMessageToHttp.prepare
* https://aws.amazon.com/blogs/developer/testing-webhooks-locally-for-amazon-sns/
* http://docs.aws.amazon.com/AmazonS3/latest/dev/NotificationHowTo.html
* http://docs.aws.amazon.com/AmazonS3/latest/dev/ways-to-add-notification-config-to-bucket.html
* http://docs.aws.amazon.com/sns/latest/api/API_ConfirmSubscription.html
* https://forums.aws.amazon.com/thread.jspa?threadID=170317
* https://forums.aws.amazon.com/thread.jspa?threadID=238335
* https://forums.aws.amazon.com/thread.jspa?threadID=88125
* https://github.com/CargoSense/ex_aws/blob/master/test/lib/ex_aws/sns/parser_test.exs
