node -v
npm i -g nvm
nvm ls - remote | grep v14.16.1
nvm install v14.16.1
nvm alias default v14.16.1
node -v
npm i -g yarn
yarn -v
yarn install --pure-lockfile --production
npx blitz -v
