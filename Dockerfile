FROM node:21-alpine3.18

# get git
RUN apk add --no-cache git bash

WORKDIR /mydraft

# setup the server
COPY . .

RUN npm i
RUN echo -e "\nVITE_SERVER_URL=/api" >> ./.env
RUN npm run build
RUN cp ./.env ./dist/

# setup react app
RUN cd ./dist/ && git clone https://github.com/mydraft-cc/ui.git

RUN cd ./dist/ui && echo "VITE_SERVER_URL=/api" > ./.env
RUN cd ./dist/ui && rm -rf ./package-lock.json
RUN cd ./dist/ui && npm install
RUN cd ./dist/ui && npm run build

RUN mkdir ./localFileStore
RUN chmod -R a+rw ./localFileStore

USER node
EXPOSE 8001/tcp

CMD ["node", "./dist/index.js"]