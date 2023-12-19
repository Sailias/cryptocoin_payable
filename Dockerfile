FROM ruby:3.2.2-bullseye

RUN apt update -qq && apt install -y libpq-dev dh-autoreconf libvips

RUN gem update --system && gem install foreman

WORKDIR /gem
ADD . /gem
RUN bundle install
VOLUME .:/gem/

ARG DEFAULT_PORT 3001
EXPOSE 3001

#CMD ["bin/dev"]