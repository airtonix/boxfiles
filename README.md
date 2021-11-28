# BoxFiles

Uses ansible to setup your workstation.

## Usage


```console
$ curl -L https://raw.github.com/airtonix/boxfiles/master/pull.sh | sh
```


## Customisation

Fork this repo, make your changes to `./playbooks/workstation-*.yml`


## Local Development

1. have asdf, asdf-poetry installed
2. `asdf install`
3. `poetry install`
4. install galaxy deps: `./run.sh deps`

### Deploy Home Automation Server

1. ensure `inventory/home-server.yaml` talks about servers you care about
2. run `poetry run poe provision-omv`

#### To deploy only parts of the server

1. pick `tags` from `inventory/home-server.yaml`.
2. run `poetry run poe provision-omv --tags [tag, tag, tag]` (yes the square brackets are required for more than one tag)
