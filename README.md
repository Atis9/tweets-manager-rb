# tweets-manager-rb

## Usage

```sh
git clone https://github.com/Atis9/tweets-manager-rb.git
cd tweets-manager-rb
cp secrets.yml.example secrets.yml

# 1. Modify secrets.yml
#
# your_screen_name:
#   consumer_key:
#   consumer_secret:
#   access_token:
#   access_token_secret:

# 2. Modify main.rb
#
# TweetsDestroyer.new('your_screen_name')
# TweetsUnfavoriter.new('your_screen_name')

docker compose build
docker compose up
```

### Optional (Get "Access Token" and "Access Token Secret")

```sh
docker compose run --rm app get-twitter-oauth-token
```
