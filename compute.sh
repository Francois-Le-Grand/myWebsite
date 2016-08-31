#!/bin/bash

ghc --make site.hs
./site rebuild
./site watch
