# Mongoid::PublishingLogic

A set of methods and scopes for publishing logic in mongoid models

Basically a rewrite of [codegourmet/mm-publishing-logic](https://github.com/codegourmet/mm-publishing-logic) for mongoid.

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'mongoid-publishing_logic'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install mongoid-publishing_logic

## Usage

``` ruby
class Page
  include Mongoid::Document
  include Mongoid::PublishingLogic

  field :title, type: String
end

page = Page.create(title: 'My Awesome Page')
page.published? # => false

published_page = Page.create(published_flag: true, title: 'My Awesome Published Page')
published_page.published? # => true

Page.published.map(&:title) # => ["My Awesome Published Page"]
Page.unpublished.map(&:title) # => ["My Awesome Page"]

Mongoid::PublishingLogic.deactivate
Page.published.map(&:title) # => ["My Awesome Published Page", "My Awesome Page"]

Mongoid::PublishingLogic.activate

Page.deactivated do
  Page.published.map(&:title) # => ["My Awesome Published Page", "My Awesome Page"]
end

Page.published.map(&:title) # => ["My Awesome Published Page"]

Mongoid::PublishingLogic.deactivate

Page.activated do
  Page.published.map(&:title) # => ["My Awesome Published Page"]
end

Page.published.map(&:title) # => ["My Awesome Published Page", "My Awesome Page"]

soon_to_be_unpublished_page = Page.create(
  title: 'My Deprecated Page',
  published_flag: true,
  publishing_end_date: Date.today.next_day
)

sleep(1.day)

soon_to_be_unpublished_page.published? # => false

soon_to_be_published_page = Page.create(
  title: 'My Brand-New Page',
  published_flag: true,
  publishing_date: Date.today.next_day
)

sleep(1.day)

soon_to_be_published_page.published? # => true
```

## Caveats

Avoid directly calling `Mongoid::PublishingLogic.deactivate` or `activate`. Due
to class caching in Rails you will be facing nondeterministic behavior so that
the value can survive requests in a production environment. Instead use the
`activated` and `deactivated` methods to temporarily change the active
attribute.

## Contributing

1. Fork it ( https://github.com/jreinert/mongoid-publishing_logic/fork )
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Write and run tests, make sure everything passes
5. Push to the branch (`git push origin my-new-feature`)
6. Create a new Pull Request
