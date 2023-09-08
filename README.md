# Standard::Procedure::Attribute

## Signal-style observable attributes in Ruby

Each attribute is observable, similar to a traditional Ruby Observable.

But computed values (that are constructed from multiple attributes) switch their dependencies on and off as needed, so unnecessary updates are avoided.

This is based upon [Signals](https://dev.to/ryansolid/a-hands-on-introduction-to-fine-grained-reactivity-3ndf) from reactive Javascript.

### Example

In the example below, the change handler (that prints "My name is X") depends on the `display_name` attribute.

Display name depends on `first_name` and `last_name` or just `first_name`, depending on the value of `show_full_name` (which itself is another dependency).

This means that if `show_full_name` is true, then `display_name` will update if `first_name`, `last_name` or `show_full_name` change. But if `show_full_name` is false, then `display_name` will only update when `first_name` or `show_full_name` changes. So `last_name` does not trigger unecessary updates.

```ruby
first_name = Attribute.string "John"
last_name = Attribute.string "Smith"
show_full_name = Attribute.boolean true

display_name = Attribute.compute do
  show_full_name.() ?  "#{first_name.()} #{last_name.()}" : first_name.()
end

Attribute.changed do
  puts "My name is #{display_name.()}"
end

show_full_name.set false
# => My name is John
last_name.set "Brown"
# no output as `show_full_name` does not depend on `last_name` at the moment
show_full_name.set true
# => My name is John Brown

Attribute.update do
  first_name.set "Dave"
  # no output when we set `first_name`, only when the batch is completed
  show_full_name.set false
end
# => My name is Dave
```

## Installation

Install the gem and add to the application's Gemfile by executing:

    $ bundle add standard-procedure-attribute

If bundler is not being used to manage dependencies, install the gem by executing:

    $ gem install standard-procedure-attribute

Then

    `require "attribute"`

## Usage

See example above for now. More examples to come.

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/standard-procedure/standard-procedure-attribute. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [code of conduct](https://github.com/standard-procedure/standard-procedure-attribute/blob/main/CODE_OF_CONDUCT.md).

## Code of Conduct

Everyone interacting in the Standard::Procedure::Attribute project's codebases, issue trackers, chat rooms and mailing lists is expected to follow the [code of conduct](https://github.com/standard-procedure/standard-procedure-attribute/blob/main/CODE_OF_CONDUCT.md).
