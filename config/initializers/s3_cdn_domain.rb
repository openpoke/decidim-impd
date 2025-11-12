# frozen_string_literal: true

Rails.application.config.to_prepare do
  Aws::S3::Object.class_eval do
    def public_url(options = {})
      bucket_url = if ENV["AWS_CDN_HOST"].present? && ENV["AWS_CDN_HOST"].starts_with?("https://")
                     ENV.fetch("AWS_CDN_HOST", nil)
                   else
                     bucket.url(options)
                   end
      url = URI.parse(bucket_url)
      url.path += "/" unless url.path[-1] == "/"
      url.path += key.gsub(%r{[^/]+}) { |s| Seahorse::Util.uri_escape(s) }
      url.to_s
    end
  end
end
