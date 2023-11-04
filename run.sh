docker stop translink || true
docker rm translink || true
docker build -t translink .
docker run -d -p 3000:3000 --name translink --restart always translink
docker image prune -f