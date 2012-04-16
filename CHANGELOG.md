## 1.2.6

* CHANGELOG added
* required\_key logic moved to given\_key and triggered with a :required => true option
  * required\_key now calls given_key with :required => true

## 1.2.5

* required\_key fixed so that block behaves like given\_key block, by diving into the context of the key value

## 1.2.4

* required\_key added to HashMethods
* Additional Tests

## 1.2.2

* is\_a? method added to HashMethods
* Additional Tests

## 1.2.0

* Added Ratatouille::Ratifier name attribute for use with dynamically changing scoped errors.
* The current Ratifier name (in scope of the validation block) will be appended to errors created
  in the direct context of that block.
* The name attribute is automatically set when using a given_key block. However, you may pass a :name
  option to the given\_key method to manually set it.

## 1.1.1

* choice\_of validation errors show semantically correct key names (Symbols, Strings, etc.)
* choice\_of tweaked/fixed to perform proper validation on list of keys

## 1.0.0

* Not to be mistaken by 0.1.0
* Plethora of tests added
* Refactoring Code
* Organization and Documentation

## 0.9.2

* Initial Release
  * Strange, I know, but this library was being production tested prior to becoming a gem.
