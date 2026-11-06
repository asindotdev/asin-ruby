# Asin Ruby SDK

The official Ruby SDK for the [Asin](https://www.asin.dev) Amazon price tracking API.

Track Amazon prices and products with a scheduled watchlist, price history, offers and alerts.

The SDK exposes **11 methods**, one per documented endpoint, plus a generic `request`. It only uses the Ruby standard library.

## Requirements

- Ruby 3.1 or newer

## Installation

```sh
gem install asindotdev
```

Or in your `Gemfile`:

```ruby
gem "asindotdev"
```

## Get your API key

[Sign up for Asin](https://www.asin.dev/signup) or sign in, then copy your API key from the [dashboard](https://www.asin.dev/app). The client reads `ENV["ASIN_API_KEY"]` when no key is passed.

## Quick start

```ruby
require "asin"

client = Asin::Client.new(api_key: ENV.fetch("ASIN_API_KEY"))
response = client.search_amazon(query: "wireless earbuds")
puts response.data
```

Keyword arguments use the parameter names of the [API reference](https://www.asin.dev/docs). Unknown names raise `Asin::SerializationError`; use `request` for undocumented parameters.

## HTTP methods

Each method uses the HTTP verb of its endpoint. `GET` and `DELETE` send parameters in the query string; `POST` and `PATCH` send them as a JSON body, except `wait` on `/products/{id}/check`, which stays in the query string. Null values are never sent, so `target_price` cannot be removed through the SDK yet.

`nil` values are omitted, `false` and `0` are sent, and arrays repeat the parameter name.

## Any endpoint

```ruby
response = client.request("GET", "/account")
```

## Errors

```ruby
begin
  client.search_amazon(query: "wireless earbuds")
rescue Asin::APIError => e
  warn "HTTP #{e.status}: #{e.message}"
end
```

| Error | When |
| --- | --- |
| `Asin::ConfigurationError` | Missing API key, invalid options or unsupported method. |
| `Asin::SerializationError` | A required parameter is missing, unknown or can't be sent. |
| `Asin::TransportError` | Network failure or timeout. |
| `Asin::APIError` | Non-2xx status (`status`, `error_message`, `response_body`, `raw_response`). |
| `Asin::ResponseDecodingError` | A success response could not be decoded. |

All of them inherit from `Asin::Error`.

## Retries

Requests are retried up to 3 times after a network error, a `408`, `429`, `500`, `502`, `503` or `504`. Other statuses, such as `400`, `401`, `402` or `404`, and client-side timeouts are not retried. The delay starts at 1 second and grows 1.5× per retry (capped at 30 seconds); a `Retry-After` header wins.

```ruby
client = Asin::Client.new(max_retries: 5, retry_delay: 0.5)
client.search_amazon(query: "wireless earbuds", request_options: { max_retries: 0 }) # one request without retries
```

## Batch requests

`batch` runs the block for every item on 10 threads (`concurrency:`) and returns one `BatchResult` per item, in input order. A failing item never stops the others.

```ruby
inputs = ["wireless earbuds", "mechanical keyboard", "usb-c hub"]
results = client.batch(inputs, concurrency: 5) { |value| client.search_amazon(query: value) }
results.each do |result|
  if result.ok?
    puts result.value.data
  else
    warn "#{inputs[result.index]}: #{result.error.message}"
  end
end
```

| Constant | Default | Description |
| --- | --- | --- |
| `Asin::Client::DEFAULT_CONCURRENCY` | `10` | Tasks run at the same time by batch |
| `Asin::Client::DEFAULT_TIMEOUT` | `120` | Request timeout (seconds) |
| `Asin::Client::MAX_RETRIES` | `3` | Retry attempts after a network error, a 408/429/5xx |
| `Asin::Client::RETRY_BACKOFF_FACTOR` | `1.5` | Exponential backoff multiplier |
| `Asin::Client::DEFAULT_RETRY_DELAY` | `1.0` | Delay before the first retry (seconds) |

## Timeouts and custom transports

```ruby
client = Asin::Client.new(timeout: 60) # seconds, default 120
client.search_amazon(query: "wireless earbuds", request_options: { timeout: 30 })
```

A transport is any object with `call(method:, url:, headers:, body:, timeout:)` returning `[status, headers, body]`; the default is `Asin::NetHTTPTransport`.

## Endpoints

11 methods, generated from the [OpenAPI document](https://www.asin.dev/openapi.json).

| Method | HTTP | Description |
| --- | --- | --- |
| `check_product` | POST `/products/{id}/check` | Asks for a check right away (1 credit), at most once per 5 minutes; earlier calls return the product unchanged. A paused product has to be… |
| `delete_product` | DELETE `/products/{id}` | Removes the product and its price history. |
| `fetch_offers` | POST `/offers` | Reads the offers on Amazon for 1 credit, refunded if it doesn't answer. A read made in the last 3 hours, by anyone, is returned instead, fo… |
| `get_account` | GET `/account` | Your plan, the credits left (monthly allowance and packs), how many products you track and the credits they use per month. |
| `get_asin_history` | GET `/history` | Every price Asin read for an ASIN on a marketplace over the period, whoever tracks it, oldest first, with the lowest, highest and average o… |
| `get_offers` | GET `/offers` | Who sells the product and at what price, as last read, cheapest first, with Amazon's own price and the cheapest new and used offers (used i… |
| `get_product` | GET `/products/{id}` | The product's latest state and every price read of the period, oldest first. The history covers every read of this ASIN on this marketplace… |
| `list_products` | GET `/products` | Your watchlist, newest first, with each product's latest state and its recent prices (trend). Filter with asin (and marketplace) to know if… |
| `search_amazon` | GET `/search` | Amazon search results (up to 60, sponsored included), to find the ASIN of a product. Free, limited to 30 searches per hour. |
| `track_product` | POST `/products` | Adds an ASIN, an Amazon link or a short link (amzn.to, a.co…) to your watchlist. The first check runs in the background within seconds (che… |
| `update_product` | PATCH `/products/{id}` | Target price, drop alerts, check interval, or pause. Send only what changes. |

## All Asin SDKs

| SDK | Package | Install |
| --- | --- | --- |
| Node.js | [`@asindev/sdk`](https://www.npmjs.com/package/@asindev/sdk) | `npm install @asindev/sdk` |
| Python | [`asindotdev`](https://pypi.org/project/asindotdev/) | `pip install asindotdev` |
| Go | [`asin-go`](https://pkg.go.dev/github.com/asindotdev/asin-go) | `go get github.com/asindotdev/asin-go` |
| .NET | [`Asin`](https://www.nuget.org/packages/Asin) | `dotnet add package Asin` |
| Ruby | [`asindotdev`](https://rubygems.org/gems/asindotdev) | `gem install asindotdev` |
| PHP | [`asindotdev/sdk`](https://packagist.org/packages/asindotdev/sdk) | `composer require asindotdev/sdk` |
| Java | [`asin-java`](https://github.com/asindotdev/asin-java) | build from source, see its README |
| CLI | [`@asindev/cli`](https://www.npmjs.com/package/@asindev/cli) | `npm install -g @asindev/cli` |
| MCP server | [`@asindev/mcp`](https://www.npmjs.com/package/@asindev/mcp) | `npx -y @asindev/mcp` |

## License

MIT — see [LICENSE](LICENSE).
