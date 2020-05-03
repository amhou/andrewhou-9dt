# 98point6 Drop-Token Interview Homework

This is my solution for the at-home interview question for backend engineers. It provides a REST web-service that allows people to play the game of 98point6 drop token. This service is implemented in Ruby, using the Sinatra web framework, with a MySQL database. Orchestration is performed via Docker Compose.

I chose Ruby and Sinatra as it's my current go-to for lightweight web services. I debated between using SQLite and MySQL, but ultimately chose MySQL for it's more real-world-like behavior (i.e. the prompt's discussion about scaling). This is also the reason I chose to use Docker.

## Instructions

To run this project, make sure you have Docker installed.
- [Mac](https://www.docker.com/docker-mac)
- [Windows](https://hub.docker.com/editions/community/docker-ce-desktop-windows)
- [Ubuntu](https://docs.docker.com/engine/install/ubuntu/)

Then, execute the following:

```
$ make && make setup
```

This will build and pull any required images, as well as initialize the database.

Then, you can run:

```
$ make start
```

This will initialize and start the app.

In all, you will have two services running.

```
            Name                         Command              State           Ports
--------------------------------------------------------------------------------------------
andrewhou-9dt_game_app         bin/entrypoint game_app        Up      0.0.0.0:80->80/tcp
andrewhou-9dt_mysql_1     docker-entrypoint.sh mysqld    Up      0.0.0.0:3306->3306/tcp
```

From here you can execute commands against the service.

```
$ curl localhost:80/drop_token
{"games":["3c6bad69-d24e-45ee-92c9-62886ff631bf","7c7c6350-5fc7-40df-883f-9937d318f959"]}

$ curl localhost:80/drop_token/3c6bad69-d24e-45ee-92c9-62886ff631bf/moves
{"moves":[{"type":"MOVE","player":"player1","column":3}]}

$ curl localhost:80/drop_token/3c6bad69-d24e-45ee-92c9-62886ff631bf
{"players":["player1","player2"],"state":"IN_PROGRESS"}
```

## Tests

To run tests, first make sure your database is running, then execute the following:

```
$ make test
```
