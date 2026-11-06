# frozen_string_literal: true

# Generated from the Asin OpenAPI document. Do not edit by hand.

module Asin
  # One method per documented endpoint. Mixed into {Client}.
  module Operations
    # Check the price now. Asks for a check right away (1 credit), at most once per 5 minutes; earlier calls return the product unchanged. A paused product has to be resumed first. The check runs in the background; with wait=true the answer waits for it. Read last_e…
    #
    # +POST /products/{id}/check+
    #
    # @param id [String] (required) product_id returned when the product was added
    # @param wait [Boolean] Answer once the check is done (up to 45 seconds)
    # @param request_options [Hash, nil] +:method+ ("GET"/"POST"), +:timeout+ (seconds), +:headers+
    # @return [JsonResponse]
    def check_product(request_options: nil, **params)
      call_operation("check_product", params, request_options)
    end

    # Stop tracking a product. Removes the product and its price history.
    #
    # +DELETE /products/{id}+
    #
    # @param id [String] (required) product_id returned when the product was added
    # @param request_options [Hash, nil] +:method+ ("GET"/"POST"), +:timeout+ (seconds), +:headers+
    # @return [JsonResponse]
    def delete_product(request_options: nil, **params)
      call_operation("delete_product", params, request_options)
    end

    # Read every offer from Amazon. Reads the offers on Amazon for 1 credit, refunded if it doesn't answer. A read made in the last 3 hours, by anyone, is returned instead, for free (charged: false). The answer is the same as GET /offers.
    #
    # +POST /offers+
    #
    # @param asin [String] (required) 10-character ASIN
    # @param marketplace [String] Amazon store, e.g. com for amazon.com
    # @param refresh [Boolean] Read Amazon again unless the last read is under 5 minutes old (1 credit)
    # @param request_options [Hash, nil] +:method+ ("GET"/"POST"), +:timeout+ (seconds), +:headers+
    # @return [JsonResponse]
    def fetch_offers(request_options: nil, **params)
      call_operation("fetch_offers", params, request_options)
    end

    # Plan and remaining credits. Your plan, the credits left (monthly allowance and packs), how many products you track and the credits they use per month.
    #
    # +GET /account+
    #
    # @param request_options [Hash, nil] +:method+ ("GET"/"POST"), +:timeout+ (seconds), +:headers+
    # @return [JsonResponse]
    def get_account(request_options: nil, **params)
      call_operation("get_account", params, request_options)
    end

    # Price history of any ASIN. Every price Asin read for an ASIN on a marketplace over the period, whoever tracks it, oldest first, with the lowest, highest and average of those prices. A history of more than 5000 points is thinned evenly, keeping its first and last poi…
    #
    # +GET /history+
    #
    # @param asin [String] (required) 10-character ASIN
    # @param marketplace [String] Amazon store, e.g. com for amazon.com
    # @param days [Integer] History period in days
    # @param request_options [Hash, nil] +:method+ ("GET"/"POST"), +:timeout+ (seconds), +:headers+
    # @return [JsonResponse]
    def get_asin_history(request_options: nil, **params)
      call_operation("get_asin_history", params, request_options)
    end

    # Offers already known. Who sells the product and at what price, as last read, cheapest first, with Amazon's own price and the cheapest new and used offers (used is only known for Amazon's own outlet). Free: this never reads Amazon or spends a credit. When nobody…
    #
    # +GET /offers+
    #
    # @param asin [String] (required) 10-character ASIN
    # @param marketplace [String] Amazon store, e.g. com for amazon.com
    # @param request_options [Hash, nil] +:method+ ("GET"/"POST"), +:timeout+ (seconds), +:headers+
    # @return [JsonResponse]
    def get_offers(request_options: nil, **params)
      call_operation("get_offers", params, request_options)
    end

    # Get a product and its price history. The product's latest state and every price read of the period, oldest first. The history covers every read of this ASIN on this marketplace, including those made before you added it, so a product added today can come with months of prices;…
    #
    # +GET /products/{id}+
    #
    # @param id [String] (required) product_id returned when the product was added
    # @param days [Integer] History period in days
    # @param request_options [Hash, nil] +:method+ ("GET"/"POST"), +:timeout+ (seconds), +:headers+
    # @return [JsonResponse]
    def get_product(request_options: nil, **params)
      call_operation("get_product", params, request_options)
    end

    # List tracked products. Your watchlist, newest first, with each product's latest state and its recent prices (trend). Filter with asin (and marketplace) to know if a product is tracked, or with filter to get the same lists as the app's tabs.
    #
    # +GET /products+
    #
    # @param asin [String] Only this ASIN
    # @param marketplace [String] Only this Amazon store
    # @param filter [String] Only the products of one of the app's watchlist filters. all: Every tracked product (default). drops: Cheaper now than when the product was added. target: At or below its target price. out_of_stock:…
    # @param page [Integer] Page number
    # @param limit [Integer] Products per page
    # @param request_options [Hash, nil] +:method+ ("GET"/"POST"), +:timeout+ (seconds), +:headers+
    # @return [JsonResponse]
    def list_products(request_options: nil, **params)
      call_operation("list_products", params, request_options)
    end

    # Search Amazon. Amazon search results (up to 60, sponsored included), to find the ASIN of a product. Free, limited to 30 searches per hour.
    #
    # +GET /search+
    #
    # @param query [String] (required) Keywords
    # @param marketplace [String] Amazon store, e.g. com for amazon.com
    # @param request_options [Hash, nil] +:method+ ("GET"/"POST"), +:timeout+ (seconds), +:headers+
    # @return [JsonResponse]
    def search_amazon(request_options: nil, **params)
      call_operation("search_amazon", params, request_options)
    end

    # Track a product. Adds an ASIN, an Amazon link or a short link (amzn.to, a.co…) to your watchlist. The first check runs in the background within seconds (checking is true until then): poll GET /products/{id}, or send wait: true to get the answer once it's d…
    #
    # +POST /products+
    #
    # @param product [String] (required) ASIN (B09DFCB66S) or Amazon product link
    # @param marketplace [String] Amazon store, e.g. com for amazon.com. A product link sets it on its own.
    # @param target_price [Numeric] Email the owner when the price goes at or below this amount. null removes it.
    # @param interval_minutes [Integer] Minutes between two checks (1440 = daily). Checks faster than daily need a plan or a credit pack: every 60 minutes with a pack or Starter, 30 with Pro, 5 with Business.
    # @param wait [Boolean] Answer once the first check is done (up to 45 seconds)
    # @param request_options [Hash, nil] +:method+ ("GET"/"POST"), +:timeout+ (seconds), +:headers+
    # @return [JsonResponse]
    def track_product(request_options: nil, **params)
      call_operation("track_product", params, request_options)
    end

    # Change alerts and checks. Target price, drop alerts, check interval, or pause. Send only what changes.
    #
    # +PATCH /products/{id}+
    #
    # @param id [String] (required) product_id returned when the product was added
    # @param target_price [Numeric] Email the owner when the price goes at or below this amount. null removes it.
    # @param interval_minutes [Integer] Minutes between two checks (1440 = daily). Checks faster than daily need a plan or a credit pack: every 60 minutes with a pack or Starter, 30 with Pro, 5 with Business.
    # @param alert_on_drop [Boolean] Email when the price drops or the product is back in stock
    # @param paused [Boolean] Stop checking (and charging) for now; false resumes
    # @param request_options [Hash, nil] +:method+ ("GET"/"POST"), +:timeout+ (seconds), +:headers+
    # @return [JsonResponse]
    def update_product(request_options: nil, **params)
      call_operation("update_product", params, request_options)
    end
  end
end
