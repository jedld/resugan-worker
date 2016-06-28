# Resugan::Worker

Background worker extension to the resugan gem. Uses redis and parallel_queue
as a backend.

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'resugan-worker'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install resugan-worker

## Usage

Transparently works with the resugan gem to turn your event listeners into background workers. When this gem is included it will
use Resugan::Worker::ParallelQueueDispatcher as the default dispatcher. What this dispatcher does is it queues all
fired events into a redis queue to be consumed by an event worker.

You can start a monitor for namespace group1 using (note that this blocks):

```ruby
  Resugan::Worker::Monitor.new('group1').start
```

Ideally you can create a rake task with something like this:

```ruby
# monitor.rake

namespace :monitor do
  desc "Starts the environment monitor"
  task :start =>[:namespace] do |t, args|

    # sample listeners, can be placed somewhere else
    _listener :hello do
      #do stuff that happens when hello is fired
    end

    Resugan::Worker::Monitor.new(args[:namespace] || '').start
  end
end
```

```
  rake monitor:start[group1]
```

This will create a blocking process that listens for events on the default namespace and sends them to the listeners

Firing events is the same, but the event generators can be in another process or machine

```ruby
resugan {
  _fire :hello
}
```

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/[USERNAME]/resugan-worker. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [Contributor Covenant](http://contributor-covenant.org) code of conduct.


## License

The gem is available as open source under the terms of the [MIT License](http://opensource.org/licenses/MIT).
