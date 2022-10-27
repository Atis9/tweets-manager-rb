FROM ruby:3.1.2

RUN bundle config --global frozen 1

WORKDIR /app

COPY Gemfile Gemfile.lock ./
RUN bundle install

COPY . .

CMD ["ruby", "main.rb"]
