print("Started Adding the Users.");

db.getSiblingDB("admin").auth(
    process.env.MONGO_INITDB_ROOT_USERNAME, 
    process.env.MONGO_INITDB_ROOT_PASSWORD
);

db = db.getSiblingDB(process.env.MONGO_INITDB_DATABASE);
db.createUser({ 
    user: process.env.MONGO_USER, 
    pwd: process.env.MONGO_PASS, 
    roles: [{ role: 'dbOwner', db: process.env.MONGO_INITDB_DATABASE }] 
});

print("End Adding the User Roles.");

// db.getSiblingDB("admin").auth('admin', 'passs');
// show collections;
// mongorestore --host localhost --port 27017 --username user --password pass --db mydb ./aff_products