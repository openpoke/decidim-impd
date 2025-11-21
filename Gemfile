# frozen_string_literal: true

source "https://rubygems.org"

ruby RUBY_VERSION

DECIDIM_VERSION = { github: "decidim/decidim", branch: "release/0.31-stable" }.freeze
gem "decidim", DECIDIM_VERSION
gem "decidim-decidim_awesome", { github: "decidim-ice/decidim-module-decidim_awesome", branch: "release/0.31-stable" }
gem "decidim-elections", DECIDIM_VERSION
# gem "decidim-ai", DECIDIM_VERSION
# gem "decidim-collaborative_texts", DECIDIM_VERSION
# gem "decidim-conferences", DECIDIM_VERSION
# gem "decidim-demographics", DECIDIM_VERSION
# gem "decidim-design", DECIDIM_VERSION
# gem "decidim-initiatives", DECIDIM_VERSION
# gem "decidim-templates", DECIDIM_VERSION

gem "aws-sdk-s3", "~> 1.205"
gem "bootsnap", "~> 1.3"
gem "commonmarker", "= 0.23.12"
gem "deface", "~> 1.9"
gem "health_check"
gem "puma"
gem "sentry"
gem "sentry-ruby"

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
