
# NoSQL Distilled by Martin Fowler

https://www.youtube.com/watch?v=ASiU89Gl0F0

# Introduction to NoSQL by Martin Fowler

https://www.youtube.com/watch?v=qI_g07C_Q5I&feature=youtu.be

* name nosql comes from a twitter hash tag of a first conferecnce on non
  relational databases
* nosql movement - *21 sentury* (as similar
  concepts was before too and they are not considered nosql), *nonrelational* databases 

* relational DB has explicit scheme
* noSql DB has implicit scheme (how is data used is the schema)

types:

* agregat
  * hard to restructur data (order -> line item, now you decide you want
    to have order -> product -> lineitem, you need to restructurize, in
    relational DB you just add a join)
  * types:
    * key value nosql database
      * foo:bar
    * document store databases
      * json document
    * column family nosql databases
      * agregate is made from a family comuns (so easier searching)
    
* graph databases
  * using nodes and arcs
  * really good at storing relations and jumping from relation to
    relation without defining foreign keys or jonins 
    (as SQL relation databases do. If you have too much jonis in
    relational database the relation may collaps, not in graph nosql DB)

    START barbara = node:nodeIndex(name = "Barbara")
    MATCH (barbara)-[:FRIEND] -> (friend_node)
    RETURN friend_node.name,friend_node.location


* Relational DB and Graph NoSQLDB are ACID  ==  atomic(noone mess the data before is
  saved) consistant isoleted durable

* Agregate noSQL db are BASE    ==  
  * *Basically Available* (does guarantee the availability of the data as regards CAP Theorem)
  * *Soft state* -  (The state of the system could change over time, so even
    during times without input there may be changes going on due to
‘eventual consistency,’)
  * *Eventual consistency*: The system will eventually become consistent
    once it stops receiving input. The data will propagate to
    everywhere it should sooner or later.

in agregate NoSQL model transactions are part of same agregate => they are
basically implicit ACID, The problem is when you updating multiple agregates non-ACID, but that problem is reare. 
But Relation DB has an ACID problem when transaction to if you hold transaction open for long time => performance killer


consistency
* resiliancy - data SHA on several servers

## cap theorum
* *Consistency* refers to whether a system operates fully or not. Does the
  system reliably follow the established rules within its programming
  according to those defined rules?  Do all nodes within a cluster see all
  the data they are supposed to? This is the same idea presented in ACID.
* *Availability*: means just as it sounds. Is the given service or system
  available when requested? Does each request get a response outside of
  failure or success?
* *Partition Tolerance* represents the fact that a given system continues to
  operate even under circumstances of data loss or system failure. A
  single node failure should not cause the entire system to collapse.

so cap therom is about when you have a partitioned system, you have a
chaoce  a Consistancy of data accross partitions or Availibility of
partitions.

This is not true/false flag, you have a levels 

as more as you want your servers to be consistant to each other the
slower it gets (if you have 20 servers and you want to be sure all 20
has the same data well you're screwed, but if you are building shopping
card and 3 out of 20 servers is good enough then yes that's a good
solution)

http://www.dataversity.net/acid-vs-base-the-shifting-ph-of-database-transaction-processing/

