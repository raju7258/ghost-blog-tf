#FROM ghost:4-alpine

FROM public.ecr.aws/e5s7u0b5/ghost-4-alpine:latest

WORKDIR /var/lib/ghost

COPY . /var/lib/ghost/current

##########
#COPY config.production.json /var/lib/ghost/
### Added by Ahhmed
#RUN npm install ghost-storage-adapter-s3 \
   # && mkdir -p ./content.orig/adapters/storage \
    #&& cp -vr ./node_modules/ghost-storage-adapter-s3 ./content.orig/adapters/storage/s3
############
RUN npm install ghost-storage-adapter-s3

RUN mkdir -p ./content/adapters/storage && mkdir -p ./content.orig/adapters/storage && cp -r ./node_modules/ghost-storage-adapter-s3 ./content/adapters/storage/s3 && cp -vr ./node_modules/ghost-storage-adapter-s3 ./content.orig/adapters/storage/s3

#COPY content/settings/routes.yaml ./content.orig/settings/routes.yaml

#RUN apk update

#RUN echo "Healthcheck success" > /var/lib/ghost/current/robots.txt

#EXPOSE 2368
