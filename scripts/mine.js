const { moveBlocks } = require('../utils/move-block');

const BLOCKS = 1;
const SLEEP_AMOUNT = 1000;

async function mine() {
  await moveBlocks(BLOCKS, (sleepAmount = SLEEP_AMOUNT));
}

mine()
  .then(() => {
    process.exit(0);
  })
  .catch((error) => {
    console.log(error);
    process.exit(1);
  });
