# frozen_string_literal: true

require "json"
require "asin"

client = Asin::Client.new # reads ASIN_API_KEY
response = client.search_amazon(query: "wireless earbuds")
puts JSON.pretty_generate(response.data)
