# Early compatibility shim for ancient mysql2 (0.2.x) with modern libmysqlclient headers.
# Rails loads this before picking the boot strategy, which is early enough to affect
# ActiveRecord's adapter require.

begin
  # Predefine the constant so mysql2's Ruby code can reference it even if the
  # native extension didn't define it (e.g., headers without CLIENT_SECURE_CONNECTION).
  module Mysql2
    class Client
      SECURE_CONNECTION = 0 unless const_defined?(:SECURE_CONNECTION)
    end
  end
rescue Exception
  # Ignore – mysql2 may not even be present yet; this file is executed for all environments.
end

# Monkey-patch Mysql2::Client.new to accept an options hash even when the native
# extension exposes a 0-arity initializer. We avoid requiring the gem here to not
# interfere with Rails' boot sequence.
begin
  module Mysql2
    class Client
      class << self
        def new(opts = nil, *rest)
          if opts.is_a?(Hash)
            client = allocate
            client.send(:initialize)
            # Provide default query_options expected by the adapter
            begin
              flags = 0
              [:REMEMBER_OPTIONS, :LONG_PASSWORD, :LONG_FLAG, :TRANSACTIONS, :PROTOCOL_41, :SECURE_CONNECTION].each do |sym|
                flags |= Mysql2::Client.const_get(sym) if Mysql2::Client.const_defined?(sym)
              end
              default_query_options = {
                :as => :hash,
                :async => false,
                :cast_booleans => false,
                :symbolize_keys => false,
                :database_timezone => :local,
                :application_timezone => nil,
                :cache_rows => true,
                :connect_flags => flags
              }
              client.instance_variable_set(:@query_options, default_query_options)
              # Ensure reader exists even if the gem didn't define it
              (class << client; self; end).class_eval { attr_reader :query_options } unless client.respond_to?(:query_options)
            rescue Exception
            end

            # Optional setters if available
            [:reconnect, :connect_timeout].each do |key|
              next unless opts.key?(key)
              setter = "#{key}="
              client.send(setter, opts[key]) if client.respond_to?(setter)
            end
            # Force encoding to utf8 if supported
            client.charset_name = (opts[:encoding] || 'utf8') if client.respond_to?(:charset_name=)
            # SSL setup if method exists
            if client.respond_to?(:ssl_set)
              ssl_args = opts.values_at(:sslkey, :sslcert, :sslca, :sslcapath, :sslciper)
              client.ssl_set(*ssl_args)
            end
            user     = opts[:username]
            pass     = opts[:password]
            host     = opts[:host] || 'localhost'
            port     = opts[:port] || 3306
            database = opts[:database]
            socket   = opts[:socket]
            flags    = opts[:flags] || 0
            client.connect(user, pass, host, port, database, socket, flags) if client.respond_to?(:connect)
            client
          else
            obj = allocate
            obj.send(:initialize)
            obj
          end
        end
      end
    end
  end
rescue Exception
  # Ignore; we'll rely on the gem's defaults in environments where this patch isn't applicable.
end
