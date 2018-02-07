# Connect Ruby on Rails app to Azure Cosmos DB with Mongoid gem

Your Rails application can comunicate with CosmosDB via Mongo DB API.
Therefore you can use [Mongoid gem](https://github.com/mongodb/mongoid)
(Or Mongo Mapper) to comunicate with your CosmosDB database


the problem however is that unlike localhost mongo conection, you cannot
just provide `host`, `user`, `password`  and everything magicly works.
You need to use the  `uri` option and specify presigned "connection
string" url that Azure generated for you

Now to obtain  this "connection string" you need to use `az` cli.



1. create cosmos table from Azure portal (web interface)
2. install `az` cli, [how to here](https://docs.microsoft.com/en-us/cli/azure/install-azure-cli?view=azure-cli-latest)
   and login `az login`


```
Given that your "resource group" is named `my-project`
And  your cosmos db account has name `my-awesome-cosmos`
Then run this:
```


```bash
az cosmosdb list-connection-strings --resource-group my-project --name my-awesome-cosmos
```

> if you have no idea what those values are run `az cosmosdb list` and search for `name` (name of cosmos DB) and  `resourceGroup`

Now you will have string like this: 

```json
{
  "connectionStrings": [
    {
      "connectionString": "mongodb://my-awesome-cosmos:FxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxA==@my-awesome-cosmos.documents.azure.com:10255/?ssl=true",
      "description": "Default MongoDB Connection String"
    }
  ]
}
```

copy the `connectinoString` value to mongoid.yml:

```yaml
# config/mongoid.yml

development:
  sessions:
    default:
      options:
        ssl: true
  clients:
    default:
      uri: mongodb://my-awesome-cosmos:FxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxA==@my-awesome-cosmos.documents.azure.com:10255/?ssl=true
      options:
        connect_timeout: 15
  options:

# ...

```


And now you should be connected


If you are looking for automated solution check this file https://github.com/devigned/level1/blob/master/api-ruby/config/mongoid.yml 


### Ruby solution?

Unfortunatelly during the time of writing this article [Azure Ruby SDK](https://github.com/Azure/azure-sdk-for-ruby)
is not mentioning anything about Cosmos DB => sdk cannot do operation on
Cosmos.

Be sure to check this as this article may be out of date. As soon as I
have ruby solution I'll include it in this note



### source of information:

* https://medium.com/azure-developers/level-1-azure-rails-ember-cosmosdb-c3951c61bda3
* https://github.com/devigned/level1/blob/master/api-ruby/config/mongoid.yml
* https://github.com/devigned/level1/issues/1

Discussion on this Article/Note:

* [Ruby Flow Discussion](http://www.rubyflow.com/p/pvwg5q-til-connect-ruby-on-rails-app-to-azure-cosmos-db-with-mongoid-gem)
* [Reddit Discussion](https://www.reddit.com/r/ruby/comments/7sowe2/til_how_to_connect_rails_app_to_azure_cosmosdb/)
