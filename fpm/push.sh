# if [ -z $1 ]; then
#     echo "Please provide the image hash id"
#     exit
# fi
docker tag docker-fpm:latest wbeater/php-8-fpm-alpine
docker push wbeater/php-8-fpm-alpine