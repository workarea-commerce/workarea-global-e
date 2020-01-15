source 'https://rubygems.org'
git_source(:github) { |repo| "https://github.com/#{repo}.git" }

source 'https://gems.weblinc.com' do
  gem 'workarea-ci'
end

gem 'workarea-gift_cards', github: 'workarea-commerce/workarea-gift-cards', branch: 'GIFTCARDS-7-backport-missing-via-param' # '~> 3.4.7'
gem 'sprockets', '~> 3'

gemspec

group :test do
  gem 'simplecov', require: false
end
