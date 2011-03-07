# ActiveConductor

This plugin uses the conductor pattern to wrap multiple models as one object.
It's basically like the Presenter pattern, but for saving and creating multiple models.
For more information, please read the blog post
[Presenters & Conductors on Rails](http://blog.new-bamboo.co.uk/2007/8/31/presenters-conductors-on-rails).

## Installation

This plugin is built on top of Rails 3 ActiveModel. For a Rails 2 compatible version, see the
[Conductor](https://github.com/smtlaissezfaire/conductor) plugin.

### Gem

Install the gem:

    gem install active_conductor

Add it to your Gemfile:

     gem "active_conductor"

### Plugin

Install as a Rails plugin:

    rails plugin install git://github.com/smtlaissezfaire/active_conductor.git

## Documentation

You can browse the API documentation directly on [rdoc.info](http://rdoc.info/github/netzpirat/active_conductor/master/frames).

## Example

    class SignupConductor < ActiveConductor
      def models
        [user, profile]
      end

      def user
        @user ||= User.new
      end

      def profile
        @profile ||= Profile.new
      end

      conduct :user, :first_name, :last_name
      conduct :profile, :image
    end

    conductor = SignupConductor.new
    conductor.first_name = "Scott"
    conductor.last_name = "Taylor"

    conductor.first_name #=> "Scott"
    conductor.user.first_name #=> "Scott"

    conductor.save
    conductor.valid? #=> false

    conductor.errors #=> [["photo", "is not valid"]]

## Contributors

* Michael Kessler ([netzpirat](https://github.com/netzpirat))

## License

(The MIT License)

Copyright (c) 2011 Scott Taylor

Permission is hereby granted, free of charge, to any person obtaining
a copy of this software and associated documentation files (the
'Software'), to deal in the Software without restriction, including
without limitation the rights to use, copy, modify, merge, publish,
distribute, sublicense, and/or sell copies of the Software, and to
permit persons to whom the Software is furnished to do so, subject to
the following conditions:

The above copyright notice and this permission notice shall be
included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED 'AS IS', WITHOUT WARRANTY OF ANY KIND,
EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.
IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY
CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT,
TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE
SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
