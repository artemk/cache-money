require 'memcached'

    # A cache store implementation which stores data in Memcached:
    # http://www.danga.com/memcached/
    #
    # This is currently the most popular cache store for production websites.
    #
    # Special features:
    # - Clustering and load balancing. One can specify multiple memcached servers,
    #   and MemCacheStore will load balance between all available servers. If a
    #   server goes down, then MemCacheStore will ignore it until it goes back
    #   online.
    # - Time-based expiry support. See #write and the +:expires_in+ option.
    # - Per-request in memory cache for all communication with the MemCache server(s).
    class MemCachedSupportStore < ActiveSupport::Cache::Store

      attr_reader :addresses

      # Creates a new MemCacheStore object, with the given memcached server
      # addresses. Each address is either a host name, or a host-with-port string
      # in the form of "host_name:port". For example:
      #
      #   ActiveSupport::Cache::MemCacheStore.new("localhost", "server-downstairs.localnetwork:8229")
      #
      # If no addresses are specified, then MemCacheStore will connect to
      # localhost port 11211 (the default memcached port).
      def initialize(*addresses)
        addresses = addresses.flatten
        options = addresses.extract_options!
        options[:prefix_key] ||= options[:namespace]
        addresses = ["localhost"] if addresses.empty?
        @addresses = addresses
        @data = Memcached.new(addresses, options)

        extend ActiveSupport::Cache::Strategy::LocalCache
      end

      def read(key, options = nil) # :nodoc:
        super
        @data.get(key, marshal?(options))
      rescue Memcached::NotFound
        nil
      rescue Memcached::Error => e
        logger.error("MemcachedError (#{e}): #{e.message}")
        nil
      end

      # Writes a value to the cache.
      #
      # Possible options:
      # - +:unless_exist+ - set to true if you don't want to update the cache
      #   if the key is already set.
      # - +:expires_in+ - the number of seconds that this value may stay in
      #   the cache. See ActiveSupport::Cache::Store#write for an example.
      def write(key, value, options = nil)
        super
        method = options && options[:unless_exist] ? :add : :set
        # memcache-client will break the connection if you send it an integer
        # in raw mode, so we convert it to a string to be sure it continues working.
        @data.send(method, key, value, expires_in(options), marshal?(options))
        true
      rescue Memcached::NotStored
        false
      rescue Memcached::NotFound
        false
      rescue Memcached::Error => e
        logger.error("MemcachedError (#{e}): #{e.message}")
        false
      end

      def delete(key, options = nil) # :nodoc:
        super
        @data.delete(key)
        true
      rescue Memcached::NotFound
        false
      rescue Memcached::Error => e
        logger.error("MemcachedError (#{e}): #{e.message}")
        false
      end

      def exist?(key, options = nil) # :nodoc:
        # Doesn't call super, cause exist? in memcache is in fact a read
        # But who cares? Reading is very fast anyway
        # Local cache is checked first, if it doesn't know then memcache itself is read from
        !read(key, options).nil?
      end

      def increment(key, amount = 1) # :nodoc:
        log("incrementing", key, amount)

        @data.incr(key, amount)
        response
      rescue Memcached::NotFound
        nil
      rescue Memcached::Error
        nil
      end

      def decrement(key, amount = 1) # :nodoc:
        log("decrement", key, amount)
        @data.decr(key, amount)
        response
      rescue Memcached::NotFound
        nil
      rescue Memcached::Error
        nil
      end

      def delete_matched(matcher, options = nil) # :nodoc:
        # don't do any local caching at present, just pass
        # through and let the error happen
        super
        raise "Not supported by Memcache"
      end

      def clear
        @data.flush
      rescue Memcached::NotFound
      end

      def stats
        @data.stats
      rescue Memcached::NotFound
      end

      private
        def expires_in(options)
          (options && options[:expires_in]) || 0
        end

        def marshal?(options)
          !(options && options[:raw])
        end
    end
