### Brightwheel coding challenge

#### About

This is a Sinatra application.

#### Dependencies

I am not sure what the minimum Ruby version is that can run this code, but
the best bet is to use version 2.3 or newer.

#### Running Server

**step 1**

```sh
git clone http://github.com/maxpleaner/brightwheel_challenge
cd brightwheel_challenge
bundle install
cp .env.example .env
```

**step 2**

_get api keys from mailgun and sendgrid, then add them to .env_

_also, if running tests, create a new email account on Gmail and add
the credentials here_

**step 3**

```sh
bundle exec rackup
```

`rackup`uses port 9292 by default, but the `-p <port>` option can be
appended to change this.

#### Usage

The server has one route, POST /email, and accepts the params listed in the
challenge prompt ("to", "to_name", "from", "from_name", "subject", "body").
These must be given in the form body of the request as a JSON string

The response returns a JSON-formatted hash.
For succesfull responses, the status code will be either 200 or 202 and the
response body will be an empty JSON-formatted hash.
For validation errors, the status code is 422 and the response body
will be a JSON-formatted hash mapping key to array(of error message strings).
Other response codes may be returned, depending on the response from the
underlying service (SendGrid, Mailgun), but to avoid leaking application details,
the response body is hidden.

By default, SendGrid is used by the server to send email.
However, this can easily be changed to MailGun by launching the server with an
environment variable:

```rb
env EMAIL_PROVIDER=MailGunAPI rackreadup
```

The other option, besides MailGunAPI, is SendGridAPI.


#### running tests

simply `rspec`, run from the root of the repo

The integration tests actually send the email using the email service,
and check whether it was delivered to a gmail address. There is some required
`sleep` when doing this which is fundamentally finnicky (it has to wait for
the email to arrive), which could possibly be removed if a post hook were
added to the email client.

The unit tests do no network calls (all of that is stubbed), making them
run quicker.

It's easy to run only the unit or integration tests
with `rspec spec/unit/` or `rspec spec/integration/`. Most of the methods
have unit tests, including the private ones.


#### Design decisions

**minimal framework**

Rails apps might sometimes be quicker to put together than Sinatra ones.
However, I enjoy writing Sinatra apps more because I feel it gives my code
a chance to shine.

This may be a bit cheesy, but I like the fact that my code
is not obscured behind predefined folders. The top level of my application
has only two folders (lib/ and spec/), vs. the 10 in rails' boiler. 

Since there's so little boilerplate, I'm confident that if someone else
were to look at my code, they would be able to find the important bits.
It can be difficult to even find where the custom code is inside a rails
application unless the original programmer documented them all.

I don't really need a view layer since I'm only doing minimal manipulation of
my functions' output before sending it as JSON. I don't need a model layer
because I'm not doing any data persistence. In Sinatra, the controllers are
inlined in the router, which can be inlined in the main server file.

Very little of the code here is bound to Sinatra in any way;
rather they deal in POROs (plain old ruby objects).

**functional programming**

I've gradually come to prefer a more static application.

Specifically, what I mean by this is that I use a lot of constants and
class methods, and don't do a lot of internal state tracking via instances.

This approach is more in line with the Functional Programming paradigm,
which I gained more exposure to as I practiced Elixir and Javascript.

I mainly choose to use instances when semantically, there is a two-step process
involed in some behavior. For example `EmailProvider#initialize` functions
as a factory, and delegates instance method calls to some other class.

Thus `EmailProvider.new(<Type>).send_email` makes sense as a constructor
pattern.

I also use class methods for factories, but this is missing the point of
instances, which is that they have their own state. I think there surely
tons of use-cases for this, but from experience, I've seen when there is a lot
of inferred method calls (i.e. patched attr_reader style methods) and internal
state references things can get somewhat hard to understand. Also, it becomes
easier to move methods from one namespace to another (and also to test)
when they can function without internal state tracking.

_by the way_

I use this approach to make private class methods:

```rb
class Foo
  def self.bar
    a_private_class_method
  end
  class << self
    private
    def a_private_class_method
      "hello world"
    end
  end
end
Foo.bar => "hello world"
Foo.a_private_class_method # NoMethodError: private method called ...
```

**metaprogramming and tricks**

I try not to do too much metaprogramming (e.g. I avoid `method_missing`)
but these are some possibly tricky things I've done.

Here's a couple examples of things found in this project:

1. Using refinements instead of patching Ruby core classes.
See [spec/test_helpers.rb](./spec/test_helpers.rb) for a refinement's
definition, and the top of [spec/api_spec.rb](./spec/api_spec.rb) for it's usage.
The benefit of this is that the patches are lexically scoped, and there is no
risk of them disrupting external libraries such as gems.

2. the `.register` method in [lib/email_provider.rb](./lib/email_provider.rb)
allows other classes to add themselves as options for the EmailProvider
factory.

4. Making the test suite fire up dynamic, one-off servers in background threads.
   This has pros and cons.
   - pros: no need to run a separate server in another terminal
   - cons: debugger calls don't work in background threads
   - Note: this inability to set breakpoints turned out to be so annoying that
     I added an override. Now `env SERVER_URL=http://localhost:9292 rspec` can be
    used to test against the running local server.

5. Using a backport definition of Kernel#yield_self, which was added in Ruby 2.5

#### issues encountered

There is [this](https://github.com/sendgrid/docs/issues/1417) issue with
SendGrid. They don't support the OPTION http request, which is automatically
fired by browsers (and, it turns out, the Mechanize HTTP client I'm using).

As a workaround, I switched to RestClient for the POST request