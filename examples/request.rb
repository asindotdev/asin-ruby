# frozen_string_literal: true

require "asin"

client = Asin::Client.new # reads ASIN_API_KEY
begin
  response = client.request("GET", "/account")
  puts response.data if response.json?
rescue Asin::APIError => e
  warn "HTTP #{e.status}: #{e.message}"
end
