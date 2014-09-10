# SuperbAuth

## Installation

Add this line to your application's Gemfile:

    gem 'superb_auth'

Add to your application's Gemfile OmniAuth strategies that you want to use. Now SuperbAuth supports the following gems:

    gem 'omniauth-facebook'
    gem 'omniauth-vkontakte'
    gem 'omniauth-twitter'

And then execute:

    $ bundle

Install Devise:

    $ rails g devise:install

Generate user model:

    $ rails g devise User

(optional) If users are allowed to register without emails then remove `null: false` and `default: ""` options from `db/migrate/*_devise_create_users.rb` migration. Otherwise they won't be able to edit their profiles without setting unique email.

@todo Write full installation guide

## Usage

@todo

## Development

Copy `oauth.yml` config before running test:

    cp spec/dummy/config/oauth.yml.example spec/dummy/config/oauth.yml

Fill it with real credentials and you are ready.

## Contributing

1. Fork it ( https://github.com/[my-github-username]/superb_auth/fork )
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request