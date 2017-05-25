# JDK docker image

jdk docker image based on Alpine Linux with a glibc-2.25 and Oracle Java 8.

## Vsersion/Tags

- alpine:3.5
- glibc-2.25
- jdk1.8.0_131 build11

## Usage

Example:

```
docker pull asion/alpine-java
```
or:
```
docker build -t asion/alpine-java:8 .
```
or:
```
docker run -it --rm asion/alpine-java:8 java -version
```

## Anything else?