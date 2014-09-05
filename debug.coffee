Game = require('./shared/game.coffee')

data = {
    "t0": 1409440953530,
    "rand": 0.3983471845276654,
    "moves": [
        {
            "type": "addPlayer",
            "playerId": "GrKQLVIscd5fktEqAAAy",
            "playerName": "ishaan",
            "t": 1409440953530,
            "agentId": null
        },
        {
            "type": "addPlayer",
            "playerId": "4PwntIAIBw-lFQb7AAA0",
            "playerName": "ishaan2",
            "t": 1409440968246,
            "agentId": null
        },
        {
            "type": "start",
            "playerId": "4PwntIAIBw-lFQb7AAA0",
            "t": 1409440969326,
            "agentId": null
        },
        {
            "type": "removePlayer",
            "playerId": "GrKQLVIscd5fktEqAAAy",
            "t": 1409442767727,
            "agentId": "GrKQLVIscd5fktEqAAAy"
        },
        {
            "type": "removePlayer",
            "playerId": "4PwntIAIBw-lFQb7AAA0",
            "t": 1409442906287,
            "agentId": "4PwntIAIBw-lFQb7AAA0"
        },
        {
            "type": "removePlayer",
            "playerId": "_3NxcJWmYkO78oY2AAA1",
            "t": 1409442906732,
            "agentId": "_3NxcJWmYkO78oY2AAA1"
        },
        {
            "type": "removePlayer",
            "playerId": "co3oz5M-8_BpOeCEAAA2",
            "t": 1409442908192,
            "agentId": "co3oz5M-8_BpOeCEAAA2"
        },
        {
            "type": "removePlayer",
            "playerId": "99iuvifa3oHxBh4zAAA3",
            "t": 1409442971547,
            "agentId": "99iuvifa3oHxBh4zAAA3"
        },
        {
            "type": "removePlayer",
            "playerId": "U3ivThVK5Pz1VkNYAAA4",
            "t": 1409442972243,
            "agentId": "U3ivThVK5Pz1VkNYAAA4"
        },
        {
            "type": "removePlayer",
            "playerId": "gqioLAcyh0pr1e6JAAA5",
            "t": 1409442974172,
            "agentId": "gqioLAcyh0pr1e6JAAA5"
        },
        {
            "type": "removePlayer",
            "playerId": "Qgjn9KWTBHNWn3x8AAA6",
            "t": 1409443023828,
            "agentId": "Qgjn9KWTBHNWn3x8AAA6"
        },
        {
            "type": "removePlayer",
            "playerId": "J6mBsKRIgOA2irbKAAA7",
            "t": 1409443110586,
            "agentId": "J6mBsKRIgOA2irbKAAA7"
        },
        {
            "type": "removePlayer",
            "playerId": "V3ZLCKBZeeLEdXLtAAA8",
            "t": 1409443174374,
            "agentId": "V3ZLCKBZeeLEdXLtAAA8"
        },
        {
            "type": "removePlayer",
            "playerId": "RZ0xfjtmliqc-lMKAAA9",
            "t": 1409443177425,
            "agentId": "RZ0xfjtmliqc-lMKAAA9"
        },
        {
            "type": "removePlayer",
            "playerId": "pDbLeELXmn7Sbvs_AAA-",
            "t": 1409443302512,
            "agentId": "pDbLeELXmn7Sbvs_AAA-"
        },
        {
            "type": "removePlayer",
            "playerId": "e9j2eyqbWygJl6tQAAA_",
            "t": 1409443330185,
            "agentId": "e9j2eyqbWygJl6tQAAA_"
        },
        {
            "type": "removePlayer",
            "playerId": "P3_HIMl0uWT93qKXAABA",
            "t": 1409443386325,
            "agentId": "P3_HIMl0uWT93qKXAABA"
        }
    ],
    "currentTime": 1409443405577
}

game = new Game()
game.replaceData(data)

game.generateStateAtTimeForPlayer(1409442966287,null)