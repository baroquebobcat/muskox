# Muskox

A JSON Parser-Generator that takes a json-schema and converts it into a parser.

It supports a subset of json-schema, and changes some of the default assumptions of the spec to be stricter--eg it effectively sets the `additionalProperties` field to false by not allowing unspecified fields. It also doesn't allow `patternProperties`, or `enum`. It definitely doesn't follow the Hyper-Schema stuff. If you want to use a portion of someone elses' schema, you'll need to drop it into yours directly.

## Why?

Using a parser to handle inputs makes your app safe from attacks that rely on passing disallowed params, because disallowed params will either be ignored or rejected.

> Be definite about what you accept.(*) 
>
> Treat inputs as a language, accept it with a matching computational
> power, generate its recognizer from its grammar.
>
> Treat input-handling computational power as privilege, and reduce it
> whenever possible.

http://www.cs.dartmouth.edu/~sergey/langsec/postel-principle-patch.txt

## Installation

Add this line to your application's Gemfile:

    gem 'muskox'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install muskox

## Usage

```ruby
    # to generate a parser, call generate w/ a JSON-Schema
    parser = Muskox.generate({
        "title" => "Schema",
        "type" => "object",
        "properties" => {
          "number" => {
            "type" => "integer"
          }
        },
        "required" => ["number"]
      })

    # then call parse with the string you want to have parsed
    n = parser.parse "{\"number\": 1}"
    # => {"number" => 1}
    
    # invalid types are disallowed
    parser.parse "{\"number\": true}" rescue puts $!
```

## TODOs

* performance improvements/testing
  * Ruby is slow & the lexer uses Regex. We should do something better
  * for JRuby: Jackson has a streaming interface that looks interesting
* fuzz testing
  * needs more tests that try to break it
* better JSON-schema support
  * maybe instead of reassuming the default for `additionalProperties`, we should validate schemas and say `"Muskox requires additionalProperties: false"`

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
