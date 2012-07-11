## 1.4.1

### Corrections

* BUG FIX: Exception when trying to call #collect on an error string instead of an error array.

## 1.4.0

### Updates

* New global :skip option allows you to programmatically skip validation by passing in a value of true.
* min\_length and max\_length now call length\_between to perform validation
* is\_boolean now accepts :unwrap\_block option in addition to new :skip option
* 12 new tests

### Corrections

* Fixed some false negatives with Array length validation
* :unwrap\_block not applicable for given\_key if :required is set to true

## 1.3.8

### Updates

* New is\_boolean method to test if ratifiable\_object value is of a TrueClass or FalseClass. 
* All other classes fail validation.

## 1.3.6

### Updates

* New Array Method: **ratify\_each** iterates over each item in an array to perform validation logic.
* Tweaks to Ratatouille::Ratifier.errors\_array to provide additional functionality required for **ratify\_each**.
  * Refactored logic in Ratatouille::Ratifier into new method (**namespace\_errors\_array**).

## 1.3.4

### Updates

* :is\_a now available as an option in **ratify** to reduce unnecessary nesting

### Corrections

* Fixed logic error while processing missing methods. It will correctly call super on missing\_method if 
  we do not catch expected methods

## 1.3.2

### Updates

* is\_empty and is\_not\_empty have been moved to generic ghost methods in the Ratifier object that also support other boolean methods.
  * Say you have Object#foo?, you can use **is\_foo** and **is\_not\_foo** for validation against that boolean method
* **:is\_a** added as option to perform class validation prior to the core method logic for the following methods:
  * HashMethod#given_key
  * HashMethod#required_key

## 1.3.0 (API Change!)

### Updates

* All Methods have been modified to accept optional hashes as arguments
  * This is to provide better flexibility with future versions of the API.
  * NOTE: As such, some methods have been updated to conform to this new call format. See README for details.
* Optional key, **:unwrap_block** supported by all methods. 
  * See README for details.

## 1.2.6

### Updates

* CHANGELOG added
* required\_key logic moved to given\_key and triggered with a :required => true option
  * required\_key now calls given_key with :required => true

## 1.2.5

### Corrections

* required\_key fixed so that block behaves like given\_key block, by diving into the 
  context of the key value

## 1.2.4

### Updates

* **required\_key** added to HashMethods
* Additional Tests

## 1.2.2

### Updates

* **is\_a?** method added to HashMethods
* Additional Tests

## 1.2.0

### Updates

* Added Ratatouille::Ratifier name attribute for use with dynamically changing scoped errors.
* The current Ratifier name (in scope of the validation block) will be appended to errors created
  in the direct context of that block.
* The name attribute is automatically set when using a given_key block. However, you may pass a :name
  option to the given\_key method to manually set it.

## 1.1.1

### Corrections

* choice\_of validation errors show semantically correct key names (Symbols, Strings, etc.)
* choice\_of tweaked/fixed to perform proper validation on list of keys

## 1.0.0

* Not to be mistaken by 0.1.0

### Updates

* Plethora of tests added
* Refactoring Code
* Organization and Documentation

## 0.9.2

* Initial Release
  * Strange, I know, but this library was being production tested prior to becoming a gem.
