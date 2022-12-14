FROM node:14-alpine as builder
WORKDIR '/app'
COPY ./package.json ./
COPY . .

ARG BACKEND_URL

RUN  sed -i "s|\$BACKEND_URL|${BACKEND_URL} |g" ./src/App.js

RUN yarn
RUN yarn build

FROM nginx:alpine
COPY nginx.conf /etc/nginx/conf.d/configfile.template

ENV PORT 8080
ENV HOST 0.0.0.0


EXPOSE 8080

COPY ./nginx.conf /etc/nginx/conf.d/default.conf
COPY --from=builder /app/build /usr/share/nginx/html

CMD sh -c "envsubst '\$PORT' < /etc/nginx/conf.d/configfile.template > /etc/nginx/conf.d/default.conf && nginx -g 'daemon off;'"
