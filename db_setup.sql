create table menuitems (
    id INTEGER PRIMARY KEY,
    name VARCHAR(255) NOT NULL,
    parent INTEGER
);

create table articles (
    id INTEGER PRIMARY KEY,
    title VARCHAR(255) NOT NULL,
    body VARCHAR(2048) NOT NULL,
    parent INTEGER
);
