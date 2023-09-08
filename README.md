# Attribute

Signal-style observable attributes in Ruby

## What is this about?

In traditional object-oriented programming, we deal with `Observables` (which, in the original Smalltalk, we called `dependents`). In fact, ruby even defines an `Observable` module for you to use.

An observable object allows other objects - listeners, watchers, dependents (whatever you want to call them) - to observe this object and get notified when it changes.

This is great, as it allows us to decouple our objects. If X and Y both need to know when Z changes, the observable pattern allows X and Y to know about Z without Z having to know about X or Y. This reduces the coupling between our different objects which makes it more flexible (as well as easier to understand and write tests for).

Things get more complex when we depend on multiple things though.

Imagine an application where we are displaying someone's name.

Where I live, most people have a first name and a last name (where the last name is their family name). In some circumstances, you will refer to them by just their first name, in others, by their first name and last name combined.

So our dependent (maybe it's the user-interface showing a name badge on-screen) needs to know which format to use - either combined names or just first. And, because this is a live system, it needs to update itself if something changes.

If we're showing the combined name, we depend on first_name and last_name. But if we're showing the shorter version, we only depend on the first_name - we don't want the dependency on last_name, because, should the last_name change, it will trigger a UI update even though nothing needs to be redrawn. At best, this is unnecessary CPU usage, at worst, it could result in slow responses and lots of flicker.

(Of course, this is a trivial example, but you can imagine how if you've got a whole load of complex inter-dependencies which are frequently updated, the cost of redraws quickly becomes an issue)

The simple observable pattern doesn't deal with variation in dependencies in a simple way. Our dependent would have to listen for changes to the `show_full_name` setting and then add or remove itself from the `last_name` as required. Manual overhead that, while not complex, is the sort of thing we'll either forget to do or will add a load of boiler-plate to our code, making it harder to understand.

But there's a pattern being popularised in "reactive" javascript, known as "[signals](https://dev.to/ryansolid/a-hands-on-introduction-to-fine-grained-reactivity-3ndf)" that we can use to handle this exact scenario.

Instead of just having an observable object that "pushes" updates out to its dependents, we have an hybrid "push-pull" interaction between the observer and its dependents.

When an observable changes, it pushes updates out to its dependents. So far, so traditional observable. But during the update phase, the observers push themselves back into the observable, so the dependency links are renewed. This means any unused dependencies are dropped and any new dependencies added in - which in turn also means that "dead" objects that are only being kept alive by virtue of having a hanging event-listener, are also swept from memory.

Which is all very abstract, so let's see it in action.

### Example

In the example below, the observer (which is the bit that prints "My name is X") depends on the `display_name` attribute.

`display_name` itself has varying dependencies - if `show_full_name` is false, it depends on `first_name`, but if it is true it depends on both `first_name` and `last_name`.

Even though we are only observing the `display_name` attribute, the system keeps track of those dependencies and our log message is printed when the relevant attributes are updated. That is, whenever `show_full_name` or `first_name` are updated, we get a redraw. And if `last_name` is updated, we only get a redraw if `show_full_name` is true.

Finally note that, even though we are only observing `display_name`, we get updates for everything it depends upon, for free. No more writing masses of listeners for each and every object in your system, or relying on events "bubbling" up from deeply nested components up to where you need to respond.

```ruby
first_name = Attribute.text "Alice"
last_name = Attribute.text "Aardvark"
show_full_name = Attribute.boolean true

display_name = Attribute.compute do
  show_full_name.get ?  "#{first_name.get} #{last_name.get}" : first_name.get
end

display_name.observe do
  puts "My name is #{display_name.get}"
end
# => My name is Alice Aardvark

show_full_name.set false
# => My name is Alice
last_name.set "Anteater"
# no output
show_full_name.set true
# => My name is Alice Anteater

Attribute.update do
  first_name.set "Anthony"
  # no output
  show_full_name.set false
  # no output
end
# => My name is Anthony
show_full_name.set true
# => My name is Anthony Anteater
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
