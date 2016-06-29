require "resugan/worker/version"
require "resugan/worker/parallel_queue_dispatcher"
require "resugan"
require "parallel_queue"
require "redis"
require "json"

module Resugan
  module Worker
    class Config
      attr_accessor :error_handler
    end

    class Monitor
      def initialize(namespace = '')
        @namespace = namespace
        @config = Config.new
        @queue = ParallelQueue.new(redis, 'resugan_queue-' + namespace)
      end

      def configure(&block)
        block.call(@config)
        self
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

          begin
            Resugan::Kernel.invoke(@namespace, event, args)
          rescue StandardError => exception
            if @config.error_handler
              @config.error_handler.call(@namespace, event, args, exception)
            end
          end
        end
      end
    end
  end
end

# alter the default dispatcher
Resugan::Kernel.set_default_dispatcher(Resugan::Worker::ParallelQueueDispatcher)
