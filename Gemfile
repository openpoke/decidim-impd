# frozen_string_literal: true

source "https://rubygems.org"

ruby RUBY_VERSION

DECIDIM_VERSION = { github: "decidim/decidim", branch: "release/0.31-stable" }.freeze
gem "decidim", DECIDIM_VERSION
# gem "decidim-ai", "0.31.0.rc2"
# gem "decidim-collaborative_texts", "0.31.0.rc2"
# gem "decidim-conferences", "0.31.0.rc2"
# gem "decidim-demographics", "0.31.0.rc2"
# gem "decidim-design", "0.31.0.rc2"
# gem "decidim-elections", "0.31.0.rc2"
# gem "decidim-initiatives", "0.31.0.rc2"
# gem "decidim-templates", "0.31.0.rc2"

gem "bootsnap", "~> 1.3"

gem "puma", ">= 6.3.1"

gem "health_check"
gem "aws-sdk-s3", "~> 1.203"

group :development, :test do
  gem "byebug", "~> 11.0", platform: :mri

  gem "brakeman", "~> 7.0"
  gem "decidim-dev", DECIDIM_VERSION
  gem "net-imap", "~> 0.5.0"
  gem "net-pop", "~> 0.1.1"
end

group :development do
  gem "letter_opener_web", "~> 2.0"
  gem "listen", "~> 3.1"
  gem "web-console", "~> 4.2"
end

group :production do
  gem "sidekiq"
  gem "sidekiq-cron"
end

gem "commonmarker", "= 0.23.12"


gem "decidim-elections", "~> 0.31.0.rc2"
