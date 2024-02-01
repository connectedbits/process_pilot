// Reads an input stream and returns as a utf8 string.
module.exports = async (input) => {
  var chunks = [];

  for await (const chunk of input) {
    chunks.push(chunk);
  }

  return Buffer.concat(chunks).toString("utf8");
};
