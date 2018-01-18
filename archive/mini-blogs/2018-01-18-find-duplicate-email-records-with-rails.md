# Find duplicate email records with Rails


Rails + SQL do the heavy lifting

```ruby
User.find_by_sql("SELECT email FROM users GROUP BY email HAVING COUNT(email) > 1;")
```


Ruby/Rails doing all the heavy lifting solution:


```ruby

# occurences of emails
email_counts = User.pluck(:email).each_with_object(Hash.new(0)) { |word,counts| counts[word] += 1 }.select { |k,v| v >1 }
puts email_counts

# uniq emails
puts email_counts.map{|k,v| k}.uniq


# all together
User.pluck(:email).each_with_object(Hash.new(0)) { |word,counts| counts[word] += 1 }.select { |k,v| v >1 }.map{|k,v| k}.uniq
```

