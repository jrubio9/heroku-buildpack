# Retype docs buildpack for Heroku

This is a buildpack intended to build documentation out of a repository containing retype-aware documentation.

## Quick start guide

Follow these steps to publish your repository in Heroku:

1. [Set up Retype in the repo](https://retype.com/guides/getting_started/)
2. [Create a new app in Heroku](https://dashboard.heroku.com/new-app)
3. In the app's **settings** tab, add the following buildpack:
https://github.com/fabriciomurta/retype-buildpack
4. Push your repository to the heroku app (see instructions in the app's **Deploy** tab)
5. Wait process to complete
6. Open App in the link heroku provided (usually https://_<app_name>_.herokuapp.com/).

## To-do

- Ensure cached build works
- Check installed dependencies whether they should be updates (zlib, lpcre, lighttpd, retype, dotnet)