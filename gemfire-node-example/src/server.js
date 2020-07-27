var gemfire = require('gemfire');
const {
    JSONPath
} = require('jsonpath-plus');
var express = require('express');
var app = express();
var region = null;

app.use(express.json())

// JSON Query to get `User Provided Service` connection details from VCAP_SERVICES
const jsonPathLocators = "$.user-provided[0].credentials.locators";

async function init() {
    cacheFactory = gemfire.createCacheFactory();
    var cache = await cacheFactory.create();
    var poolFactory = await cache.getPoolManager().createFactory();

    var locators = JSONPath({
        path: jsonPathLocators,
        json: JSON.parse(process.env.VCAP_SERVICES)
    })[0];

    for (i = 0; i < locators.length; i++) {
        var serverPort = locators[i].split(/[[\]]/);
        poolFactory.addLocator(serverPort[0], parseInt(serverPort[1]));
    }
    poolFactory.create("pool")

    region = cache.createRegion("books", {type: 'PROXY', poolName: 'pool'});
}

app.get("/book/get", async (req, res) => {
    var result = await region.get(req.query.isbn);
    res.json(result);
});

app.put(['/book/put'], async (req, res) => {
    await region.put(req.query.isbn, req.body)
    res.json({
        success: true
    });
});
app.put(['/book/removeall'], async (req, res) => {

    var keys = await region.serverKeys();
    for (i = 0; i < keys.length; i++) {
        region.remove(keys[i]);
    }
    res.json({
        success: true
    });
});

app.set("port", process.env.PORT || 8080);

init();

app.listen(app.get("port"), () => {
    console.log(`Hello from bookstore test app.`);
});
