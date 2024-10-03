# Almost all ruby HTTP libs are net-http under the hood
# this will give us default outbound timeouts accross every app which includes this gem

OUTBOUND_TIMEOUT = ENV["OUTBOUND_TIMEOUT"] || 15

# Faraday uses Net::HTTP adapter by default
# HTTParty uses Net::HTTP adapter by deafult
# so we only need to patch Net::HTTP
Net::HTTP.class_eval do
  alias original_initialize initialize

  def initialize(*args, &block)
    original_initialize(*args, &block)
    @read_timeout = OUTBOUND_TIMEOUT
  end
end

