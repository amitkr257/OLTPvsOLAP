This is a simple project to explain why analaysis of data to derive meaningful insights should be done on DWH side (popularly called as OLAP), rather OLTP.

To prove that have created a databse of dvdrental store (credit: Postgre official site)
using pgAdmin 4. Now after that create a sample datamodel for DWH comprising of fact and dimension tables (using draw.io).

Post modelling created and inserted data using  pgAdmin 4 query tool and solved a use case to record timing of query on both sides of table.

And Yes ! OLTP side tables does take more time to fetch same result than OLAP tables. Such time difference matters when we are dealling with peta/exa bytes of data.

Components:
DWHmodelling from OLTP DB dvdrental.drawio -  Simple DataModel Diagram
DWHmodellingQueries.sql                    - Create and Insert Scripts
OLTP_vs_OLAP_query_time_compare            - Use case to prove time





