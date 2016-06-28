require "resugan/worker/version"
require "resugan/worker/parallel_queue_dispatcher"
require "resugan"
require "parallel_queue"
require "redis"
require "json"

module Resugan
  module Worker
    class Monitor
      def initialize(namespace = '')
        @namespace = namespace
        @queue = ParallelQueue.new(redis, 'resugan_queue-' + namespace)
      end

      def start
        puts "monitoring resugan queue: #{@namespace}"

        ::Kernel.loop do
          eval_queue
          sleep 1
        end
      end

      def redis=(redis)
        @redis = redis
      end

      protected

      def redis
        @redis ||= Redis.new
      end

      private

      def eval_queue
        @queue.dequeue_each do |item|
          unmarshalled_event = JSON.parse(item)
          event = unmarshalled_event["event"]
          args = unmarshalled_event["args"]

          Resugan::Kernel.invoke(@namespace, event, args)
        end
      end
    end
  end
end

# alter the default dispatcher
Resugan::Kernel.set_default_dispatcher(Resugan::Worker::ParallelQueueDispatcher)
