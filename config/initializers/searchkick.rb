Searchkick.timeout = 2
Searchkick.search_timeout = 2

# If Elasticsearch is not reachable at boot time, disable automatic indexing so
# that saves/creates/destroys work normally without ES running.
# The SearchController already degrades gracefully when a query fails.
begin
  require "socket"
  TCPSocket.new("localhost", 9200).close
rescue Errno::ECONNREFUSED, SocketError
  Searchkick.callbacks = false
  Rails.logger.warn "[Searchkick] Elasticsearch is not running – auto-indexing disabled. Search will return empty results."
end
