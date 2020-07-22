#!/bin/bash

curl -X PUT "localhost:9200/_snapshot/es_backups/snapshot_1?wait_for_completion=true&pretty"

