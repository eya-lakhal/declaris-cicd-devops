FROM docker.io/nginx:alpine
RUN mkdir -p /usr/share/nginx/html/upload
COPY nginx.conf /etc/nginx/conf.d/default.conf
COPY dist/declaris/ /usr/share/nginx/html
EXPOSE 4500
CMD ["nginx", "-g", "daemon off;"]