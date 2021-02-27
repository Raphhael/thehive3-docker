ADMIN=admin
ADMIN_PWD=azerty

docker-compose down -t0
docker-compose up -d

echo -n "Starting Cortex "

while [ $(docker logs thv3_cortex |grep 'Listening for HTTP on /0.0.0.0:9001' | wc -l) -eq 0 ]
do
    echo -n .
    sleep 2
done

echo OK
echo -n 'Waiting elasticsearch '

while true
do
    status=$(curl -s -o /dev/null -w "%{http_code}" -XPOST 'http://localhost:9001/api/maintenance/migrate' -d '{}')
    if [ $(echo "$status / 200" | bc) = "1" ]
    then
      break
    fi
    echo -n .
    sleep 1
done

echo OK

echo Cortex DB migrated OK

echo -n 'Creating Cortex admin '

curl -XPOST 'http://localhost:9001/api/user/_search' -d '{}' -s -o /dev/null

curl -XPOST 'http://localhost:9001/api/user' \
  -H 'Content-Type: application/json;charset=UTF-8' \
  -d '{"login":"'$ADMIN'","name":"'$ADMIN'","'$ADMIN_PWD'":"azerty","roles":["superadmin"],"organization":"cortex"}' \
  -s -o /dev/null

echo OK
echo -n 'TheHive DB migrated '

curl -XPOST 'http://127.0.0.1:9000/api/maintenance/migrate' -d '{}'

echo OK

echo -n 'Creating TheHive admin '

curl -XPOST 'http://127.0.0.1:9000/api/user/_search' -d '{}' -s -o /dev/null

curl 'http://127.0.0.1:9000/api/user' -H 'Content-Type: application/json;charset=UTF-8' \
    -d '{"login":"'$ADMIN'","name":"'$ADMIN'","password":"'$ADMIN_PWD'","roles":["read","write","admin"]}' \
    -s -o /dev/null

echo OK

echo -n Get new XSRF
curl -XGET 'http://127.0.0.1:9000/api/status' --cookie-jar ./cookies -o /dev/null -s

pat='THE-HIVE-XSRF-TOKEN[[:space:]]*([^[:space:]]*)'
s="$(cat ./cookies)"
[[ "$s" =~ $pat ]]
h_xsrf="X-THE-HIVE-XSRF-TOKEN: ${BASH_REMATCH[1]}"
h_json='Content-Type: application/json;charset=UTF-8'

echo $h_xsrf

echo Login as $ADMIN
curl -XPOST 'http://127.0.0.1:9000/api/login' -H "$h_json" -H "$h_xsrf" -d '{"user":"'$ADMIN'","password":"'$ADMIN_PWD'"}' --cookie-jar ./cookies --cookie ./cookies -o /dev/null -s
curl -XGET 'http://127.0.0.1:9000/api/user/current' --cookie ./cookies -H "$h_xsrf" -o /dev/null -s

echo Create webhook user
curl -XPOST 'http://127.0.0.1:9000/api/user' -H "$h_json" -H "$h_xsrf" -d '{"login":"webhook","name":"webhook","roles":["read","write","alert"]}' --cookie ./cookies -o /dev/null -s
curl -XPOST 'http://127.0.0.1:9000/api/user/webhook/password/set' -H "$h_json" -H "$h_xsrf" -d '{"password":"azerty"}' --cookie ./cookies  -o /dev/null -s

echo Save API key in file
curl -XPOST 'http://127.0.0.1:9000/api/user/webhook/key/renew' -H "$h_json" -H "$h_xsrf" -o 'API' -s -d '{}' --cookie ./cookies
echo API KEY : $(cat API)

echo Logout
curl -XGET 'http://127.0.0.1:9000/api/logout' --cookie ./cookies

rm cookies

echo Finish

echo Cortex : http://localhost:9001
echo TheHive : http://localhost:9000
