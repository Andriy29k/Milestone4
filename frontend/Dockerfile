FROM nginx:alpine AS production-stage

RUN rm -rf /usr/share/nginx/html

COPY ./build/ /usr/share/nginx/html
COPY nginx.conf /etc/nginx/nginx.conf
RUN ls -l /etc/nginx/

ENV DOMAIN_TOKEN=DOMAIN_TOKEN
COPY entrypoint.sh /conf/entrypoint.sh
RUN chmod +x /conf/entrypoint.sh
ENTRYPOINT [ "/conf/entrypoint.sh" ]

EXPOSE 3000

CMD [ "nginx", "-g", "daemon off;", "-c", "/etc/nginx/nginx.conf" ]