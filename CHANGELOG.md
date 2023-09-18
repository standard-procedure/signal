## [0.3.2] - 2023-09-18

- Bugfix: Specs were not picking up that Array and Hash did not trigger updates correctly

## [0.3.1] - 2023-09-16

- Array and Hash no longer wrap their contents in attributes.  

## [0.3.0] - 2023-09-14

- Added opal-rspec to ensure that everything works OK when running in a browser context

## [0.2.0] - 2023-09-14

- Improved the API by extending the ruby Signal module

## [0.1.2] - 2023-09-13

- Added the StandardProcedure namespace, as ::Signal is used by Ruby itself

## [0.1.1] - 2023-09-13

- Added in [Signal::Attribute::Array](/lib/signal/attribute/array.rb) and [Signal::Attribute::Hash](/lib/signal/attribute/hash.rb)

## [0.1.0] - 2023-09-08

- Initial release

Things to do:

- Add compound types
