docker build -t estonezzz/multi-client:latest -t estonezzz/multi-client:$SHA -f ./client/Dockerfile ./client
docker build -t estonezzz/multi-server:latest -t estonezzz/multi-server:$SHA -f ./server/Dockerfile ./server
docker build -t estonezzz/multi-worker:latest -t estonezzz/multi-worker:$SHA -f ./worker/Dockerfile ./worker

docker push estonezzz/multi-client:latest
docker push estonezzz/multi-server:latest
docker push estonezzz/multi-worker:latest
docker push estonezzz/multi-client:$SHA
docker push estonezzz/multi-server:$SHA
docker push estonezzz/multi-worker:$SHA

kubectl apply -f k8s
kubectl set image deployments/server-deployment server=estonezzz/multi-server:$SHA
kubectl set image deployments/client-deployment client=estonezzz/multi-client:$SHA
kubectl set image deployments/worker-deployment worker=estomezzz/multi-worker:$SHA
