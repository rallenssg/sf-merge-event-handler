# Modular Record Merge Custom Platform Event

## Description

The custom Merge Event object can be used on any object by triggering Apex after delete and in the case of a delete,
in a Handler class, check if the MasterRecordId on the deleted record is not null, indicating a merge. If populated,
create new MergeEvent\_\_e record populating the ObjectName\_\_c, current time for MergedAt\_\_c, the delted record Id for
MergedRecordID\_\_c, and the MasterRecordId from the deleted record for MasterRecordID\_\_c.

Account is provided for example in this project.

## Components

### Custom Platform Event

> **MergeEvent\_\_e**
>
> > <ins>Fields:</ins>
> >
> > > _ObjectName\_\_c_: Text(255)  
> > > _MasterRecordID\_\_c_: Text(18)  
> > > _MergedRecordID\_\_c_: Text(18)  
> > > _MergedAt\_\_c_: DateTime

### Apex

> **AccountTrigger**  
> **AccountMergeEventHandler**  
> **AccountMergeEventHandlerTest**
