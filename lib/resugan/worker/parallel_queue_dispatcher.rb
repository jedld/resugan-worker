module Resugan
  module Worker
    class ParallelQueueDispatcher
      def redis
        @redis ||= Redis.new
      end

      def redis=(redis)
        @redis = redis
      end

      def dispatch(namespace, events)
        @queues ||= {}
        @queues[namespace] ||= ParallelQueue.new(redis, 'resugan_queue-' + namespace)
        events.each do |k, v|
          @queues[namespace].enqueue('default', { event: k, args: v }.to_json)
        end
      end
    end
  end
end
