ENV["WHIPLASH_CLIENT_ID"] = "f5aff8eb291c5e0cf5646dda976bf2a28788f00900e4e9c3e8933cc2a24c64ef"
ENV["WHIPLASH_CLIENT_SECRET"] = "de93407ddb52f2812a387f401eb5c3f8233e1b40b4d018762e113bf6334d61ea"
ENV["WHIPLASH_CLIENT_SCOPE"] = "app_manage"
ENV["WHIPLASH_API_URL"] = "https://testing.whiplashmerch.com"

$LOAD_PATH.unshift File.expand_path('../../lib', __FILE__)
require 'whiplash/app'
