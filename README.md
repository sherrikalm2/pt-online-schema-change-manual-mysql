# roll_your_own_pt-online-schema-change
An explaination of how I do the same functionality of pt-online-schema change. 

# Use Case
Large table needs a change and downtime is not an option. 

Percona Toolkit has a utility that does this, but it has some issues. This roll your own method is basically the same as pt-online-schema-change with additional functionality. 

Its a bit more tricky to do than a single line of command line code, so some explaination as to why you may want to do it this way is in order. 

## Let's look at what pt-online-schema-change is actually doing under the hood 

1. Creates a new target table that will replace the old source table when the process is complete
2. Add triggers to the source table that replicate traffic to the old table into the new table 
3. Backfill from old source table into new target table. This can take quite some time depending on the size of the table 
4. When backfill is finished, renames the tables and the foreign  (see rebuild_constraints for options)

In many cases this is just fine. Here's why I had to roll my own. 

1. Have no control over when the rename happens. Most folks don't want this to happen during peak traffic. Say you need to change a data type from INTEGER to BIGINT. If the ORM mapping fails, containers may start falling from the sky at this point. The tool doesn't upgrade a migration version at the rename event. So there can be issues with versions of the apps not being in sync with the changes to the db. 
2. Rollback is clunky and almost impossible ( always use --no-drop-old-table )
3. The handling of foreign keys is clunky. Some ORMS have really fussy naming issues with foreign keys.  
4. Cannot split the source table into multiple tables. 

## When to use pt-online-schema-change out of the box (https://www.percona.com/doc/percona-toolkit/LATEST/pt-online-schema-change.html)

1. No foreign keys are involved. 
2. You are simply adding a new column 
- New column should not affect existing apps
- Caveat: as long it has a default value if not null is specified

Obviously, you would test in the test bed before doing in production. 


## When to roll your own
1. Changes to the table will adversely affect existing apps. Must control the rename time to move the migration version at the same time as the rename.  
2. Splitting an overly wide table into a better design. pt-online-schema-change can only affect a single table. 
3. If you are attempting to create a new compound key on the table. 


# Important 
This method and pt-online-schema-change both create a copy of the table being modified. Check your disk space. 

## How to Roll Your Own pt-online-schema-change
For this example, I am going to try to keep it pretty simple. Once you get the dance steps you can improvise all you want. 

--print

### Obviously, do all these things in dev/test before doing them in prod. 

1. Create two schemas that are separate from the production schema. This also prevents name collisions on foreign keys 
- schema_change (this is the schema where the work is being done)
- undo (this is where the old table will reside once the swip swap rename event is complete )

2. Create the new table (or tables) as you want it to look after the update. 

3. Create the triggers to mirror actions in the old table to the new table(s). And the rollback script to remove them. 

4. Create backfill script. 

5. Create Swip Swap Table rename script 

6. Create Rollback script in case it all goes foo bar 

7. Bundle the whole bunch up into format acceptable for migration tool. 

5. Before deployment in test bed coordinate these events with relevant dev teams: 
- Trigger deployment (a bug in the triggers will cause all manner of trouble, but otherwise the apps will be none the wiser)
- Swip Swap Rename table event must be coordinated with app code changes. 

6. Wait to see if there is any unexpected fallout in the test bed. 

7. Be sure to test the rollback script before deployment 

## Deployment 

### Phase 1
Add scripts going to be used to servers. These are just the creation scripts. Not attached or active to anything yet. 

### Phase 2 
Add Mirror Triggers - should not need to drain connection pool or throttle traffic, depending on your business needs. Adding a trigger to a table does indeed lock it for a very brief time. Typically less than a second. 

Begin backfill process. 

### Phase 3 
Once backfill is complete. Schedule the Swip Swap Rename Event with relevant dev teams. They will need to rollout their code changes at this time as well. 

Highly recommend draining the connection pool and throttling traffic for this if you have the kind of business that needs a full audit trail of everything. Apps that touch the table will need to be updated as well. 

### After Depoloyment to Prod 
Monitor and insure that the changes are all good. 

Keep the old table for a couple days just in case if desired and space is not urgent. Be sure to add a ticket to the remove all the old scripts and tables used in the process. 














