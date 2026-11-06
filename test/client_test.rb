# frozen_string_literal: true

require "test_helper"

class ClientTest < Minitest::Test
  def setup
    @transport = FakeTransport.new
    @client = Asin::Client.new(api_key: "test-key", transport: @transport)
  end

  def test_requires_api_key
    with_env("ASIN_API_KEY", nil) do
      assert_raises(Asin::ConfigurationError) { Asin::Client.new }
    end
    assert_raises(Asin::ConfigurationError) { Asin::Client.new(api_key: "   ") }
    assert_raises(Asin::ConfigurationError) { Asin::Client.new(api_key: "k", base_url: "ftp://x") }
  end

  def test_reads_api_key_from_environment
    with_env("ASIN_API_KEY", "env-key") do
      client = Asin::Client.new(transport: @transport)
      client.request("GET", "/account")
    end
    assert_equal "Bearer env-key", @transport.calls.first[:headers]["Authorization"]
  end

  def test_featured_operation
    @transport.respond { json_response({ "hello" => "world" }) }
    response = @client.search_amazon(query: "wireless earbuds")
    assert_instance_of Asin::JsonResponse, response
    assert_equal({ "hello" => "world" }, response.data)
    call = @transport.calls.first
    assert_equal "GET", call[:method]
    assert_equal "https://www.asin.dev/api/v1/search", call[:url].split("?").first
    assert_equal "Bearer test-key", call[:headers]["Authorization"]
    assert_match(/\Aasin-ruby\//, call[:headers]["User-Agent"])
  end

  def test_query_serialization
    client = Asin::Client.new(api_key: "k", base_url: "https://example.test/", transport: @transport)
    client.request("GET", "/anything",
                   { text: "a b&c", flag: false, count: 0, ratio: 1.5, whole: 2.0, list: %w[x y], nothing: nil })
    assert_equal "https://example.test/anything?text=a%20b%26c&flag=false&count=0&ratio=1.5&whole=2&list=x&list=y",
                 @transport.calls.first[:url]
  end

  def test_post_sends_json_body
    @client.request("POST", "/anything", { query: "x", page: 2, gone: nil })
    call = @transport.calls.first
    assert_equal "POST", call[:method]
    assert_equal "application/json", call[:headers]["Content-Type"]
    assert_equal({ "query" => "x", "page" => 2 }, JSON.parse(call[:body]))
    refute_includes call[:url], "?"
  end

  def test_wait_location_depends_on_the_endpoint
    @client.request("POST", "/products/{id}/check", { id: "p1", wait: true })
    assert_equal "https://www.asin.dev/api/v1/products/p1/check?wait=true", @transport.calls[0][:url]
    assert_empty JSON.parse(@transport.calls[0][:body])
    @client.request("POST", "/products", { product: "B09DFCB66S", wait: true })
    assert_equal "https://www.asin.dev/api/v1/products", @transport.calls[1][:url]
    assert_equal({ "product" => "B09DFCB66S", "wait" => true }, JSON.parse(@transport.calls[1][:body]))
  end

  def test_patch_and_delete
    @client.request("PATCH", "/products/{id}", { id: "p1", paused: true })
    assert_equal "PATCH", @transport.calls[0][:method]
    assert_equal({ "paused" => true }, JSON.parse(@transport.calls[0][:body]))
    @client.request("DELETE", "/products/{id}", { id: "p1" })
    assert_equal "DELETE", @transport.calls[1][:method]
    assert_nil @transport.calls[1][:body]
  end

  def test_path_parameters
    @client.request("GET", "/items/{id}", { id: "a/b c", other: 1 })
    assert_equal "https://www.asin.dev/api/v1/items/a%2Fb%20c?other=1", @transport.calls.first[:url]
    assert_raises(Asin::SerializationError) { @client.request("GET", "/items/{id}", {}) }
  end

  def test_required_and_unknown_parameters
    assert_raises(Asin::SerializationError) { @client.search_amazon }
    assert_raises(Asin::SerializationError) { @client.search_amazon(query: "wireless earbuds", not_a_parameter: 1) }
    assert_empty @transport.calls
  end

  def test_unsupported_method
    assert_raises(Asin::ConfigurationError) do
      @client.get_account(request_options: { method: "POST" })
    end
  end

  def test_every_endpoint
    Asin::ENDPOINTS.each do |name, endpoint|
      method = @client.respond_to?(name) ? name : "#{name}_endpoint"
      @client.public_send(method, **REQUIRED.fetch(name, {}))
      call = @transport.calls.last
      assert_equal "https://www.asin.dev/api/v1#{endpoint[:path].sub("{id}", "test")}", call[:url].split("?").first, name
      assert_equal endpoint[:methods].first, call[:method], name
    end
    assert_equal Asin::ENDPOINTS.size, @transport.calls.size
  end

  def test_binary_response
    @transport.respond { [200, { "content-type" => ["image/png"] }, "\x89PNG".b] }
    response = @client.request("GET", "/anything")
    assert_instance_of Asin::BinaryResponse, response
    assert_equal "\x89PNG".b, response.bytes
    assert_equal "image/png", response.content_type
  end

  def test_non_json_success_for_json_operation
    @transport.respond { [200, { "content-type" => ["text/html"] }, "<html>"] }
    assert_raises(Asin::ResponseDecodingError) { @client.search_amazon(query: "wireless earbuds") }
  end

  def test_api_error
    @transport.respond { json_response({ "error" => "Invalid API Key" }, 401) }
    error = assert_raises(Asin::APIError) { @client.request("GET", "/account") }
    assert_equal 401, error.status
    assert_equal "Invalid API Key", error.message
    assert_equal({ "error" => "Invalid API Key" }, error.response_body)
  end

  def test_non_json_error_body
    @transport.respond { [502, {}, "Bad gateway"] }
    error = assert_raises(Asin::APIError) { @client.request("GET", "/account", max_retries: 0) }
    assert_equal 502, error.status
    assert_equal "Bad gateway", error.raw_response.body
  end

  def test_transport_error
    @transport.respond { raise IOError, "network down" }
    assert_raises(Asin::TransportError) { @client.request("GET", "/account", max_retries: 0) }
  end

  def test_retries_then_succeeds
    client = Asin::Client.new(api_key: "k", transport: @transport, retry_delay: 0.001)
    calls = 0
    @transport.respond do
      calls += 1
      raise IOError, "reset" if calls == 1
      next [429, { "retry-after" => ["0"] }, "{}"] if calls == 2
      next json_response({}, 503) if calls == 3

      json_response({ "ok" => true })
    end
    assert client.request("GET", "/account").json?
    assert_equal 4, @transport.calls.size
  end

  def test_retry_limits_and_client_errors
    client = Asin::Client.new(api_key: "k", transport: @transport, retry_delay: 0.001, max_retries: 2)
    @transport.respond { json_response({ "error" => "busy" }, 503) }
    assert_raises(Asin::APIError) { client.request("GET", "/account") }
    assert_equal 3, @transport.calls.size
    @transport.respond { json_response({ "error" => "Payment required" }, 402) }
    assert_raises(Asin::APIError) { client.request("GET", "/account") }
    assert_equal 4, @transport.calls.size
  end

  def test_401_is_never_retried
    client = Asin::Client.new(api_key: "k", transport: @transport, retry_delay: 0.001)
    {
      "Rate limit exceeded: You've exceeded the rate limit on your subscription" => 1,
      "Rate limit exceeded for the API key: quota daily" => 1,
      "Invalid API Key" => 1
    }.each do |message, expected|
      calls = 0
      @transport.respond do
        calls += 1
        calls == 1 ? json_response({ "error" => message }, 401) : json_response({})
      end
      begin
        client.request("GET", "/account")
      rescue Asin::APIError
        nil
      end
      assert_equal expected, calls, message
    end
  end

  def test_nested_error_message
    @transport.respond { json_response({ "error" => { "code" => "insufficient_credits", "message" => "No credits left" } }, 402) }
    error = assert_raises(Asin::APIError) { @client.request("GET", "/account") }
    assert_equal "No credits left", error.error_message
  end

  def test_batch
    running = 0
    peak = 0
    lock = Mutex.new
    results = @client.batch(1..6, concurrency: 2) do |n|
      lock.synchronize { running += 1; peak = [peak, running].max }
      sleep 0.005
      lock.synchronize { running -= 1 }
      raise "boom" if n == 4

      n * 10
    end
    assert_equal 2, peak
    assert_equal [10, 20, 30, nil, 50, 60], results.map(&:value)
    refute results[3].ok?
    assert_equal (0..5).to_a, results.map(&:index)
  end

  REQUIRED = {
    "check_product" => { id: "test" },
    "delete_product" => { id: "test" },
    "fetch_offers" => { asin: "test" },
    "get_asin_history" => { asin: "test" },
    "get_offers" => { asin: "test" },
    "get_product" => { id: "test" },
    "search_amazon" => { query: "test" },
    "track_product" => { product: "test" },
    "update_product" => { id: "test" }
  }.freeze
end
