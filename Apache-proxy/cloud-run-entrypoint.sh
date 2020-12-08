#!/usr/bin/env bash

# Start the sql proxy

 cloud_sql_proxy -instances=kebernetes-258422:us-central1:mysql4=tcp:3306 &

# Execute the rest of your ENTRYPOINT and CMD as expected.
exec "$@"