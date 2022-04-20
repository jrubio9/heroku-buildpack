# Retype docs buildpack for Heroku

This is a buildpack intended to build documentation out of a repository containing a [Retype](https://retype.com) project.

## Quick start guide

The guide will show how to deploy the Retype Website in your custom app using the commandline and [the Heroku CLI](https://devcenter.heroku.com/articles/heroku-command-line)

1. Clone the repository
```
git clone https://github.com/retypeapp/retype
cd retype
```

2. Login to Heroku (you can skip it if already logged in)
```
heroku login
```

3. [Create a new app in Heroku](https://dashboard.heroku.com/new-app)
```
heroku create my-app-name
```

**Note:** Replace `my-app-name` with the app name you want to allocate in Heroku
4. Set up the app to use retype buildpack
```
heroku buildpacks:set 'https://github.com/retypeapp/heroku-buildpack'
```

5. Push the repo to Heroku

```
git push heroku main
```

**Pro Tip:** If Heroku asks for password during the `git` command, use username `blank` and for the password, the key heroku informs via `heroku auth:token`.

When this step is done, you will then be able to access the fresh Retype website hosted in Heroku via https://_<my-app-name>_.herokuapp.com

**Note:** Remember to replace `my-app-name` with your unique app name in Heroku. If the name is already taken, you'd need to use a different one.

## Buildpack config vars

The Retype Buildpack accepts the following config vars to set up specific aspects of the running app. You can set config vars via Heroku web interface, in the app's **Settings** tab or via the [`heroku config` CLI command](https://devcenter.heroku.com/articles/heroku-cli-commands#heroku-config)

### `DOTNET_VERSION`

Specifies the [.NET version](https://dotnet.microsoft.com/) to use during build.

### `RETYPE_CONFIG`

Specifies the path to Retype's configuration file. By default the build pack will look for `retype.yml`, `retype.yaml`, and `retype.json` in the repository's root, then search everywhere within the repo for the file. If this option is present, no search will be attempted even if the path is invalid.

- If the path points to a directory, it will check whether there's a Retype config file therein.
- If the path points to a file, it will tell the Retype CLI that file is to be used as the configuration file, so it is possible to use a different retype config file for the Heroku environment than the one used elsewhere.

### `RETYPE_VERSION`

Specifies the Retype version to use. Without this, the buildpack should use the Retype version specified in the Buildpack files. Usually the default branch of the buildpack will have the latest version, updated every Retype release.

## Troubleshooting

### The app is not accessible in after push

We received some reports that the default - US - location may not be accessible for some people. If that's the case, there's a chance creating the app in the EU (Europe) region fixes the problem. To specify the region specify the `create` command like this:

```
heroku create my-app-name --region eu
```

### The repository does not have a `heroku` remote

When you create the heroku app, the Heroku CLI will automatically assign the necessary git configs for you. But in case the app was created from the Heroku website, or created before the repository was cloned or outside the repository, you may need to add that configuration.

To do so, simply issue the command, when in the repository root:

```
heroku git:remote --app my-app-name
```

### Heroku does not recognize my app as a Retype App

There are two main reasons this may happen in your app:

- the buildpack was not set: ensure `buildpacks:set` command was accepted (step 4 in quick start guide). Alternatively, the buildpack can be set via Heroku's web interface in the app's **Settings** tab.

- in order for the buildpack to detect and build the retype project, it requires a **retype.json** file somewhere within the repository. You can create a default copy of the file via the `retype init` command (see [Retype's Getting Started guide](https://retype.com/guides/getting-started/) if you don't have Retype CLI installed).

## Other ways to publish a retype docs to Heroku

Heroku offers a range of configuration options and integrations besides the approach covered in the Quick Start Guide above:

- the app can be created and set up from Heroku's WebSite,
- there is a [GitHub Integration](https://devcenter.heroku.com/articles/github-integration) for simplified deploys from GitHub,
- for docker-based apps, the [Heroku CLI also has support to publish Docker Containers through the docker's Container Registry](https://devcenter.heroku.com/articles/container-registry-and-runtime)

**Note:** No matter what the chosen approach is, the Retype BuildPack (step 4 in quick start guide) must be set, unless the goal is to host the built static files directly, where another third party static files serving buildpack should be used. Heroku has an official, but [experimental, buildpack for static files](https://elements.heroku.com/buildpacks/heroku/heroku-buildpack-static).

## To-do

- Avoid rebuilds / redownloads (effectively use Heroku Cache)
- Trigger rebuild of dependencies if the cached ones don't match the desired version (zlib, lpcre, lighttpd, retype, dotnet)
- Set up mime-db for arbitrary file mime types

1. [Set up Retype in the repo by adding a configuration file](https://retype.com/configuration/project/)