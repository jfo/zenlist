# Setup

You'll need [SQLite](https://www.sqlite.org/)

`brew install sqlite3` on OSX should work.

From there, `bundle install` and then `rake run` whould set up a db with dummy
data and run a server. It drops the db on close; this is not a fully functional
application.

Also, you'll need to run this in an up to date ES6 running browser. I'm not
compiling the source for older browsers.

# TokenBucket

You'll find an implementation of the requested algorithm in `tokenbucket.rb`.
It's currently rate limiting requests on page load at `r = 1` and `b = 5`.
Experience the magic of a 503 by reloading your browser a bunch of times.

I'm currently holding the bucket in a global variable instantiated in
`server.rb` because the state needs to be persistent across requests. It maybe
should properly live in a cache or somewhere else but this is adequate to
demonstrate the usage.

# Help Center Menu

```sql
/* db_setup.sql */

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
```

A straightforward approach is to persist only parent relationships in the database.
The application code is responsible for assembling the records into a tree
structure. I've implemented a rudimentary dynamic ORM library in `ORM.rb` and
models in `models.rb`. `Menu` is the class we're interested in, which
takes a root node and returns a `MenuItem` that has been recursively populated
with its children. I've also appended metadata to those nodes as to whether or
not there is an article in their branch, which the view will use to decide
whether or not to render them. That could have also happened on the client.

This is the simplest way to structure this data but also the most naive; it
necessitates many trips to the database. That shouldn't be an issue as long as
there is a sane ORM (that persists db connections in some way at least over the
course of the request) and/or the structures are not too deep (5 levels is very
small).

If for some reason that took too long, you could add a `root_id INTEGER` to
both tables and then you would only ever need 2 calls to the database to get
all the records needed for a given root menu. You could also choose to
denormalize into another table with `varchar` fields of comma separated
`children` id's, but that would require a lot of extra code on the Model side
and also need to be kept up to date somehow.

As per tasks `b` and `c`, adding is as simple as creating a new record with an
appropriate parent id. Deleting is only slightly more complicated and would
require either recursively deleting all child nodes, reassigning the deleted
node's children to its parent, or doing nothing and dealing with orphaned
records offline.

IRL these tables would probably include at least a `user_id INTEGER`, or maybe
a `project_id INTEGER`, either of which could also serve to return all the
necessary records.

# Things that are bad about this code.

In real life, the folder structure would not be so flat. The javascript would
be split into modules and browserified as part of the deploy process instead of
being dumped into one big file. The ORM layer would be ActiveRecord, because
why would anyone write their own ORM, and there would be more exception
handling in general all over and also more tests. There would probably be better
data modeling on the client side. The ORM code wouldn't be so clever and
compact (probably because it would be ActiveRecord, but even if it wasn't).

The next steps would be to implement an editing UX and a `save` endpoint.

# Things that are good about this code.

The ORM code is very clever and compact. Metaprogramming is the absolute worst
to try to read but it sure is satisfying to write. Given a subclass `Whatever <
Model` the ORM will automagically map the object to the schema of the
associated table `whatevers` in the database. Nifty! That's what really nerd
sniped me, by the way. `TokenBucket` is more along the lines of what and how I
would produce code at work, commented, tested, and more straightforward.
