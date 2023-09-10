# Signals

Observable ruby objects which fire change notifications whilst automatically tracking their own dependencies.

## Example

Imagine an app that shows a name badge.  People have a first and last name and, where I live, the last name is normally their family name.  In some circumstances you refer to a person by their first name alone, in other circumstances you want both their first and last name to be displayed.  For the purposes of the example, we also want our name badge to automatically update whenever someone's name changes, or if we switch between "full-name" and "first-name-only" mode.  

Firstly, we define our first name and last name attributes, plus an additional attribute, show_full_name, for our "mode".

Then we define a computed attribute, display_name, which formats the name according to the current mode.  

Finallly, we define an observer (our "name badge") that simply writes the display_name to the console.  

When we update the values stored in those various attributes, our "name badge" redraws itself when it has to but does nothing if it does not need to change.  

```ruby
# Define the basic attributes
first_name = Signal::Attribute.text "Alice"
last_name = Signal::Attribute.text "Aardvark"
show_full_name = Signal::Attribute.boolean true

# Define the composite attribute 
display_name = Signal.compute do
  show_full_name.get ?  "#{first_name.get} #{last_name.get}" : first_name.get
end

# Define the output that the end-user will see 
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

Signal.update do
  first_name.set "Anthony"
  # no output
  show_full_name.set false
  # no output
end
# => My name is Anthony
show_full_name.set true
# => My name is Anthony Anteater
```

## Why should I care?

Many years ago, the Smalltalk environment had a user-interface based on the Model-View-Controller paradigm.  Although similar to the MVC frameworks, such as Ruby on Rails, that rubyists are familiar with, Smalltalk MVC, being structured for desktop applications worked slightly differently.  

The Models represented the "things" that the user would recognise.  The Views would display those models on-screen.  And the Controllers would take input (whether keystrokes, mouse-movements or clicks) and use those to update the Models.  

In Ruby on Rails, the Controller receives input from the user in the form of HTTP requests, finds the relevant models, loads data into instance variables and then renders the view.  The view is, technically, part of the controller.  But in Smalltalk, the three categories were completely separate.  Instead, the view would register itself as a "dependent" of the model, so everytime the model changed (whether in response to user input, or in response to something else), the view would be notified and could redraw itself.  

While the view is aware of the model, the model is _not_ aware of the views.  Instead, it just pushes out notifications to anyone who happens to be listening.  This is similar to HTML Elements and Event Listeners in your browser's DOM.  Your HTML Input field isn't aware of any javascript code, it just publishes Events and any Javascript event listeners will receive the notification.  

This is a fundamental piece of Object-Oriented programming as it allows us to decouple our objects, limiting the scope of what each object knows.  This makes our code more flexible and easier to understand.  

## How are Signals different? 

Ruby has an in-built [Observable](https://ruby-doc.org/stdlib-2.7.0/libdoc/observer/rdoc/Observable.html) module that works exactly as described above.  Using our earlier example, you could define an `Observable` first name, last name and mode, then have your user-interface listen for changes on those Observables and react accordingly.  

However, there are two issues with this simple way of doing things.  

Firstly, when it comes to "composite" attributes, built out of multiple other attributes (like `display_name`), we need to add the notification handling in for _all_ the attributes that we depend on.  This means writing a load of boilerplate which makes things harder to understand - there is simply more code to read and digest.  

_Aside: the browser DOM handles this difficulty by "bubbling" events up through the page.  The original update may happen to an input element nested deep within a form element, but you could attach an event listener to the top-level document in order to respond to that change.  While this works, it means your event handlers are not located near the source of those events which can make it harder to understand what's going on.  The event handlers now have to examine their `event.target` properties in order to figure out what they are actually responding to._

Secondly, each these observers is a potential memory leak.  The observables have to maintain lists of observers, which are kept alive even if the user-interface component (or whatever) that is doing the observing goes out of scope.  

### Introducing Signals

There is a pattern, being popularised in "reactive" javascript, known as "[signals](https://dev.to/ryansolid/a-hands-on-introduction-to-fine-grained-reactivity-3ndf)", that we can use to deal with this.  

A simple observable "pushes" notifications out to observers.  But a signalling observable has a "push-pull" interaction with its observers.   

The observer itself is not attached to a single observable, as you would do with a traditional event listener or ruby observable.  Instead, while the observer is being built, it pushes itself into every observable it comes across.  Later, when any of those observables are updated, the observables push notifications back out to the observers.  And during those updates, the observables pull themselves out of their existing observers, then push themselves back into their current observers as and when they meet them.  

This method (which, admittedly, is much harder to describe and to understand when reading the library code) has some distinct advantages: 

- When looking at composite attributes which depend upon multiple observables, a single observer can handle them all without manually having to add multiple event handlers in to our code
- As the dependencies are discovered at the time that the observer is being built or at the time the observer is being updated, if those dependencies change, they are automatically removed or added as required
- As dependencies get removed automatically, we no longer maintain those hanging references, meaning memory will be cleaned up and garbage collected

Looking back at the example code above, you can see that our display_name attribute has either two or three dependencies.  It depends on `show_full_name` and `first_name` and it may also depend on `last_name` (if `show_full_name` is true).  We then add in our "name badge", using the `Signal.observe` call.  This depends on `display_name` and prints to the console every time `display_name` changes.  

So, when the observer is built, it prints "My name is Alice Aadvark".  

We then set `show_full_name` to `false`.  `display_name` depends on `show_full_name`, so is updated.  And when `display_name` is updated, our "name badge" observer is also updated, printing "My name is Alice".  

The real magic happens now, when we update `last_name` to "Anteater".  

`display_name` no longer depends on `last_name`, so even though `last_name` has changed from "Aardvark" to "Anteater", `display_name` is not updated.  That in turn means the name-badge is not updated and nothing is output to the console.  

In the next step, we set `show_full_name` back to `true`.  This updates `display_name` which rebuilds its own dependencies and starts observing `last_name` again.  That in turn notifiies our observer which prints "My name is Alice Anteater" to the console.  

Of course, this is a trivial example, but you can see that, when you have a complex set of dependencies, any one of which could be updated at any time, the signal pattern means everything can be kept in sync, with a minimum number of screen redraws (or network messages or however else changes are managed within the application).  

Finally, note that all this effectively comes for free, with no additional complexity in your client code.  No more writing masses of listeners for each and every object in your system, or relying on events "bubbling" up from deeply nested components up to where you need to respond.

## How to use 

All this is handled for you by the interaction between the `Signal` and `Signal::Observable` modules and the `Signal::Observer` class.  You never deal with `Signal::Observers` directly, as the `Signal` module will build one when you call `Signal.observe`.  

In addition, there is a concrete implementation of the `Signal::Observable` module that you can use directly.  A `Signal::Attribute` is an observable that stores any arbitrary object and notifies its observers when it is updated.  There are also subclasses of `Signal::Attribute` that automatically perform type-conversions for you (`text, integer, float, date, time, boolean, array and hash`).  

And `Signal.compute` allows you to build composite observables which depend on multiple other observables.  

```ruby
@my_object = Signal::Attribute.new MyObject.new 
@my_text = Signal::Attribute.text "The total is: "
@a = Signal::Attribute.integer 1 
@b = Signal::Attribute.integer 2 
@sum = Signal.compute { @a.get + @b.get }
Signal.observe do 
  puts "#{@my_text.get} #{@sum.get}"
end
```

To access the values stored in a `Signal::Attribute`, you can call `Signal::Attribute#get`, which is aliased as `Signal::Attribute#read` and `Signal::Attribute#call` (which means you can use the short-hand `@my_attribute.()` as well).  

To place a value into an attribute you call `Signal::Attribute#set`, which is aliased as `Signal::Attribute#write`.  

## Installation

Install the gem and add to the application's Gemfile by executing:

    $ bundle add standard-procedure-signal

If bundler is not being used to manage dependencies, install the gem by executing:

    $ gem install standard-procedure-signal

Then

    `require "signal"`

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/standard-procedure/standard-procedure-signal. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [code of conduct](https://github.com/standard-procedure/standard-procedure-signal/blob/main/CODE_OF_CONDUCT.md).

## Code of Conduct

Everyone interacting in the Signal project's codebases, issue trackers, chat rooms and mailing lists is expected to follow the [code of conduct](https://github.com/standard-procedure/standard-procedure-signal/blob/main/CODE_OF_CONDUCT.md).
