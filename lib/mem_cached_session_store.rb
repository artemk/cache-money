begin
  require 'memcached'

      class MemCachedSessionStore < ActionController::Session::AbstractStore
        def initialize(app, options = {})
          # Support old :expires option
          options[:expire_after] ||= options[:expires]

          super

          @default_options = {
            :namespace => 'rack:session',
            :servers => 'localhost:11211'
          }.merge(@default_options)

          @default_options[:prefix_key] ||= @default_options[:namespace]

          @pool = options[:cache] || Memcached.new(@default_options[:servers], @default_options)
          # unless @pool.servers.any? { |s| s.alive? }
          #   raise "#{self} unable to find server during initialization."
          # end
          @mutex = Mutex.new

          super
        end

        private
          def get_session(env, sid)
            sid ||= generate_sid
            begin
              session = @pool.get(sid) || {}
            rescue Memcached::NotFound, MemCache::MemCacheError, Errno::ECONNREFUSED
              session = {}
            end
            [sid, session]
          end

          def set_session(env, sid, session_data)
            options = env['rack.session.options']
            expiry  = options[:expire_after] || 0
            @pool.set(sid, session_data, expiry)
            return true
          rescue Memcached::NotStored, MemCache::MemCacheError, Errno::ECONNREFUSED
            return false
          end
      end
rescue Exception => e
   # Memcached wasn't available so neither can the store be.  Reraise any other error.
   raise unless e.is_a?(LoadError) && e.message =~ /memcached/
end
