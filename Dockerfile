FROM ruby:2.7

RUN mkdir -p /usr/src/app
WORKDIR /usr/src/app

ADD Gemfile /usr/src/app/
ADD Gemfile.lock /usr/src/app/
RUN gem install bundler
RUN bundle install

ADD . /usr/src/app

ENTRYPOINT ["bin/entrypoint"]
CMD ["pass"]
