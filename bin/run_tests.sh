#!/usr/bin/env bash

dockerize -wait tcp://greenplum:5432 -timeout 1m
bundle exec rake
