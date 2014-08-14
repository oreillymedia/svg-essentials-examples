#!/bin/bash
for file
do
  expand --tabs=2 $file > tmp
  mv tmp $file
done

