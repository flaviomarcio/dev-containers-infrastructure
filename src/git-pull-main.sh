#!/bin/bash

git checkout master
git submodule foreach git checkout master
git pull origin master
git submodule foreach git pull origin master