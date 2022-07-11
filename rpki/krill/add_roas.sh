#!/bin/bash -e
krillc roas update --ca $1 --add "42.42.42.42/32 => 42"
krillc roas update --ca $1 --add "1.0.0.0/8 => 1"
krillc roas update --ca $1 --add "2.0.0.0/8 => 2"
krillc roas update --ca $1 --add "11.0.0.0/8 => 11"
krillc roas update --ca $1 --add "20.0.0.0/8 => 20"
krillc roas update --ca $1 --add "30.0.0.0/8 => 30"
krillc roas update --ca $1 --add "200.0.0.0/24 => 200"
krillc roas update --ca $1 --add "201.0.0.0/24 => 201"
krillc roas update --ca $1 --add "150.0.0.0/24 => 150"
