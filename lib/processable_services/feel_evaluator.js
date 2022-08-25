#!/usr/bin/env node

const { feel } = require("js-feel")()

var args = process.argv.slice(2)

const expression = args[0]
const context = JSON.parse(args[1])

const parsedGrammar = feel.parse(expression)

parsedGrammar.build(context).then(result => {
  console.log(result)
  process.exit(0)
}).catch(err => {
  console.error(err)
  process.exit(1)
})
