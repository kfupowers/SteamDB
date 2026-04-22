MATCH (u:User {name: "Alex"})-[r:FRIENDS]->(user:User)
RETURN user.name;

MATCH (a:User {name: "Maria"}), (i:Movie {title: "The Matrix"})
CREATE (a)-[:WATCHED {rating: 5}]->(i)


MATCH (alex:User {name: "Alex"})-[:FRIENDS]-(friends)
MATCH (friends)-[:WATCHED]-(films)
WHERE NOT (alex)-[:WATCHED]-(films)
RETURN DISTINCT films;

