require 'active_support/lazy_load_hooks'

ActiveSupport.on_load(:active_record) do
  require 'fresh_connection/extend/ar_base'
  require 'fresh_connection/extend/ar_relation'
  require 'fresh_connection/extend/connection_handler'
  require 'fresh_connection/extend/mysql2_adapter'
  require 'active_record/connection_adapters/mysql2_adapter'

  ActiveRecord::Base.extend FreshConnection::Extend::ArBase

  ActiveRecord::Relation.__send__(:include, FreshConnection::Extend::ArRelation)

  ActiveRecord::ConnectionAdapters::ConnectionHandler.__send__(
    :include, FreshConnection::Extend::ConnectionHandler
  )

  ActiveRecord::ConnectionAdapters::Mysql2Adapter.__send__(
    :include, FreshConnection::Extend::Mysql2Adapter
  )

  if defined?(ActiveRecord::StatementCache)
    require 'fresh_connection/extend/ar_statement_cache'
    ActiveRecord::StatementCache.__send__(:include, FreshConnection::Extend::ArStatementCache)
  end

  ActiveRecord::Base.establish_fresh_connection
end