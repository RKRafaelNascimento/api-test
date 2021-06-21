FROM node:10-alpine

WORKDIR /user/src/app
COPY package*.json .

RUN npm install

COPY . . 
EXPOSE 3010
CMD ["npm", "start"]