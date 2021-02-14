FROM perl:5.32
RUN cpanm Mojolicious
RUN cpanm Dotenv
RUN cpanm LWP
RUN cpanm LWP::Protocol::https
RUN cpanm MIME::Base64
RUN cpanm Syntax::Keyword::Try
WORKDIR /opt
COPY email-microservice.pl .
COPY .env .
CMD ["perl", "email-microservice.pl", "daemon"]