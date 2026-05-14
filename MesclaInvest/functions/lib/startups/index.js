"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.createStartupQuestion = exports.listStartups = exports.getStartupDetails = exports.seedStartupCatalog = void 0;
var seedStartupCatalog_1 = require("./handlers/seedStartupCatalog");
Object.defineProperty(exports, "seedStartupCatalog", { enumerable: true, get: function () { return seedStartupCatalog_1.seedStartupCatalog; } });
// Laura Lugli Fonseca Pereira RA: 25000739
var getStartupDetails_1 = require("./handlers/getStartupDetails");
Object.defineProperty(exports, "getStartupDetails", { enumerable: true, get: function () { return getStartupDetails_1.getStartupDetails; } });
var listStartups_1 = require("./handlers/listStartups");
Object.defineProperty(exports, "listStartups", { enumerable: true, get: function () { return listStartups_1.listStartups; } });
var createStartupQuestion_1 = require("./handlers/createStartupQuestion");
Object.defineProperty(exports, "createStartupQuestion", { enumerable: true, get: function () { return createStartupQuestion_1.createStartupQuestion; } });
//# sourceMappingURL=index.js.map