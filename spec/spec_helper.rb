ENV["WHIPLASH_CLIENT_ID"] = "4ab59d8a08930053ad31e9ecf04380269c2f16ab0e8f25274b7288f95da5614d"
ENV["WHIPLASH_CLIENT_SECRET"] = "195aee38cfd9b3db28238d684092a0fff76318b14774c8f9a21cbea26c3f8a6b"
ENV["WHIPLASH_CLIENT_SCOPE"] = "user_manage"
ENV["WHIPLASH_API_URL"] = "https://qa.getwhiplash.com/"

$LOAD_PATH.unshift File.expand_path('../../lib', __FILE__)
require 'whiplash/app'
require "pry"
