# NAME:     homeland/homeland
FROM homeland/base:2.7-jemalloc-slim

ENV RAILS_ENV "production"
ENV HOMELAND_VERSION "master"
ENV RUBYOPT "W0"

WORKDIR /home/app/homeland

VOLUME /home/app/homeland/plugins

RUN mkdir -p /home/app &&\
  rm -rf '/tmp/*' &&\
  rm -rf /etc/nginx/conf.d/default.conf

ADD Gemfile Gemfile.lock package.json yarn.lock /home/app/homeland/
RUN gem install puma
RUN bundle config mirror.https://rubygems.org https://gems.ruby-china.com
RUN bundle config set deployment 'true'
RUN bundle install
RUN rm -rf ./node_module
RUN yarn --netwrok -timeout 100000
RUN yarn config set sass-binary-site http://npm.taobao.org/mirrors/node-sass
RUN yarn
RUN find /home/app/homeland/vendor/bundle -name tmp -type d -exec rm -rf {} +
ADD . /home/app/homeland
ADD ./config/nginx/ /etc/nginx

RUN rm -Rf /home/app/homeland/vendor/cache

RUN bundle exec rails assets:precompile RAILS_PRECOMPILE=1 RAILS_ENV=production SECRET_KEY_BASE=fake_secure_for_compile


