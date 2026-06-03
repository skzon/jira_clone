Searchkick.timeout = 2
Searchkick.search_timeout = 2

# In test, Elasticsearch is never available — disable indexing immediately.
# In development/production, ping ES; if unreachable, disable indexing so
# saves/creates/destroys work normally without ES running.
if Rails.env.test?
  Searchkick.disable_callbacks
else
  begin
    require "socket"
    TCPSocket.new("localhost", 9200).close
  rescue Errno::ECONNREFUSED, SocketError
    Searchkick.disable_callbacks
    Rails.logger.warn "[Searchkick] Elasticsearch is not running – auto-indexing disabled."
  end
end
