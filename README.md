# Standard::Procedure::Attribute

Signal-style observable attributes in Ruby

## What is this about?

In traditional object-oriented programming, we deal with `Observables` (which, in the original Smalltalk, we called `dependents`). In fact, ruby even defines an `Observable` module for you to use.

An observable object allows other objects - listeners, watchers, dependents (whatever you want to call them) - to observe this object and get notified when it changes.

This is great, as it allows us to decouple our objects. If X and Y both need to know when Z changes, the observable pattern allows X and Y to know about Z without Z having to know about X or Y, which reduces interdependence of our code and makes it more flexible.

Things get more complex when we depend on multiple things though.

Imagine (or if you prefer, look at the example below), an application where we are displaying someone's name. Where I live, most people commonly have a first name and a last name (where the last name tends to be their family name). In some circumstances, you will refer to them by just their first name, in others, by their first name and last name combined.

So our dependent (which, for the sake of the example, may be the user-interface we are displaying to the user) needs to depend on the person's first name and last name - because if either is updated, the UI needs to update too.

What about if we're only displaying their first name though?

If their last name is updated, we don't want to redraw the UI, because, for display purposes, nothing has changed. We're only interested in changes to the first name.

So our dependencies have changed, depending upon whether we're interested in their full (combined) name, or just their first name.

The simple observable pattern doesn't deal with this.

But a new pattern, that has been around for years, but is being popularised in "reactive" javascript, known as "[signals](https://dev.to/ryansolid/a-hands-on-introduction-to-fine-grained-reactivity-3ndf)" can deal with it.

Instead of just having an observable object that "pushes" updates out to its dependents, we have an hybrid "push-pull" interaction.

When an observable changes, it pushes updates out to its dependents. But its dependents then update their dependencies while they are updating themselves, so any unused dependencies are dropped and any new dependencies added in.

Which is all very abstract. Let's see it in action.

### Example

In the example below, the observer (which is the bit that prints "My name is X") depends on the `display_name` attribute.

`display_name` itself depends on either a combination of first_name`and`last_name`or just`first_name`- depending on the value of`show_full_name` (which itself is another dependency).

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
