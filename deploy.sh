#!/bin/zsh

rm -r docs

mdbook build

mv book docs

cd docs/html

mv * ../

cd ../../

git add .

git commit -m "updated"

git push -u origin main