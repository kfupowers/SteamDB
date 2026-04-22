```javascript
db.genres.insertMany([{
    name: "Геройский шутер"
    },
    {
        name: "Платформер"
    },
    {
        name: "Файтинг"
    }]);

db.genres.insertMany([{
    name: "Пиксельная"
},
    {
        name: "Бесплатная игра"
    },
    ]);

db.games.insertMany([{
    name: "Team Fortress 2",
    genres: ["69e5207d0c5c7a0bd6bdec22", "69e521390c5c7a0bd6bdec28"]
},
    {
        name: "Celeste",
        genres: ["69e5207d0c5c7a0bd6bdec23", "69e521390c5c7a0bd6bdec27"]
    },
    {
        name: "2XKO",
        genres: ["69e5207d0c5c7a0bd6bdec24", "69e521390c5c7a0bd6bdec28"]
    }]);

db.users.insertOne({
    username: "arstotzka",
    games: ["69e5225b0c5c7a0bd6bdec2a", "69e5225b0c5c7a0bd6bdec2b", "69e5225b0c5c7a0bd6bdec2c"]
});

db.users.find({username: "arstotzka"}, {username: 0});

db.games.find({genres: "69e521390c5c7a0bd6bdec28"});

db.games.updateOne({name: "Team Fortress 2"}, {$set: {name: "Team Fortress Classic"}});

db.users.updateOne({name: "arstotzka"}, {$pull: {genres: "69e5225b0c5c7a0bd6bdec2c"}});

db.games.updateMany({}, {$set: { "price": 100 }});

db.games.aggregate([
    { $match: {name: {$in: ["Team Fortress Classic", "Celeste", "2XKO"]}}},
    { $unwind: "$genres" },
    {$group: {_id: "$genres", total: { $sum: "$price"}}},
    { $sort: { total: -1 } }
])
```