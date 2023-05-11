#!/bin/bash

string="1,2,3,4"
IFS=',' read -ra arr <<< "$string"

for i in "${arr[@]}"
do
    echo "$i"
done