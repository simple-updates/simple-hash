# Simple::Hash

typically make JSON into object with accessors

## installation

    $ gem install simple-hash

**or**

```ruby
gem 'simple-hash'
```

    $ bundle

## usage

```ruby
user = SimpleHash.new(name: "localhostdotdev", writing?: true)
user.name # => "localhostdotdev"
user.writing? # => true
user[:name] # => "localhostdotdev"
user["name"] # => "localhostdotdev"
user.namme # => NoMethodError, did you mean? name
user.try(:nammmes) # => nil
user.keys # => [:name, :writing?]
user.values # => ["localhostdotdev", true]

# what about that?
user = SimpleHash[emails: [{ domain: "localhost.dev" }]]
user.emails.first.domain # "localhost.dev"
```
