# zoycam-server
zoycam is a client-server based image processing system. It is compatible with [zoycam-client](https://github.com/zoycam/zoycam-client).

## Building and Installation

### Required packages
```sh
erlang/OTP 20 (other versions untested)
rebar
```

### Build
```sh
rebar get-deps
rebar compile
cd rel && rebar generate
```

## Run
It's recommended not to expose zoycam-server daemon as it uses an old version of [cowboy](https://github.com/ninenines/cowboy). Instead put it behind a proxy, like [nginx](https://www.nginx.com/) for instance.
