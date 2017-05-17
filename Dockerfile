FROM ruby

WORKDIR /opt/terraforming
ADD . /opt/terraforming
RUN gem install terraforming

ENV AWS_ACCESS_KEY_ID=XXXXXXXXXXXXXXXXXXXX
ENV AWS_SECRET_ACCESS_KEY=XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
ENV AWS_DEFAULT_REGION=us-east-1

ENTRYPOINT /bin/bash
