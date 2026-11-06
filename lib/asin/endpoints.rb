# frozen_string_literal: true

# Generated from the Asin OpenAPI document. Do not edit by hand.

module Asin
  # Path, methods, response kind and parameter names of every documented operation.
  ENDPOINTS = {
    "check_product" => {
      path: "/products/{id}/check",
      methods: ["POST"].freeze,
      response: :json,
      required: ["id"].freeze,
      params: ["id", "wait"].freeze
    }.freeze,
    "delete_product" => {
      path: "/products/{id}",
      methods: ["DELETE"].freeze,
      response: :json,
      required: ["id"].freeze,
      params: ["id"].freeze
    }.freeze,
    "fetch_offers" => {
      path: "/offers",
      methods: ["POST"].freeze,
      response: :json,
      required: ["asin"].freeze,
      params: ["asin", "marketplace", "refresh"].freeze
    }.freeze,
    "get_account" => {
      path: "/account",
      methods: ["GET"].freeze,
      response: :json,
      required: [].freeze,
      params: [].freeze
    }.freeze,
    "get_asin_history" => {
      path: "/history",
      methods: ["GET"].freeze,
      response: :json,
      required: ["asin"].freeze,
      params: ["asin", "marketplace", "days"].freeze
    }.freeze,
    "get_offers" => {
      path: "/offers",
      methods: ["GET"].freeze,
      response: :json,
      required: ["asin"].freeze,
      params: ["asin", "marketplace"].freeze
    }.freeze,
    "get_product" => {
      path: "/products/{id}",
      methods: ["GET"].freeze,
      response: :json,
      required: ["id"].freeze,
      params: ["id", "days"].freeze
    }.freeze,
    "list_products" => {
      path: "/products",
      methods: ["GET"].freeze,
      response: :json,
      required: [].freeze,
      params: ["asin", "marketplace", "filter", "page", "limit"].freeze
    }.freeze,
    "search_amazon" => {
      path: "/search",
      methods: ["GET"].freeze,
      response: :json,
      required: ["query"].freeze,
      params: ["query", "marketplace"].freeze
    }.freeze,
    "track_product" => {
      path: "/products",
      methods: ["POST"].freeze,
      response: :json,
      required: ["product"].freeze,
      params: ["product", "marketplace", "target_price", "interval_minutes", "wait"].freeze
    }.freeze,
    "update_product" => {
      path: "/products/{id}",
      methods: ["PATCH"].freeze,
      response: :json,
      required: ["id"].freeze,
      params: ["id", "target_price", "interval_minutes", "alert_on_drop", "paused"].freeze
    }.freeze
  }.freeze
end
