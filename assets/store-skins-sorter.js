#!/usr/bin/env node

const fs = require("fs");

const originalJson = require("./store-skins.json");

const sortedJson = ({
  skins: originalJson.skins.sort((a, b) => a.cost - b.cost)
});

fs.writeFileSync("./store-skins.json", JSON.stringify(sortedJson, null, 2), "utf8");
