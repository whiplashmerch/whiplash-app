ENV["WHIPLASH_CLIENT_ID"] = "2ef544a861f544e3db2712fe190e41827e6ad2b2179a7b437e965fc34560e91c"
ENV["WHIPLASH_CLIENT_SECRET"] = "f0682fde92a1f5b3a9424007d249bcc4c2df148132f5e00fa149d5f5a4aafb34"
ENV["WHIPLASH_CLIENT_SCOPE"] = "app_manage"
ENV["WHIPLASH_API_URL"] = "http://localhost:3001"

$LOAD_PATH.unshift File.expand_path('../../lib', __FILE__)
require 'whiplash/app'
