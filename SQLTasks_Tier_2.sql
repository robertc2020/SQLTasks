/* Welcome to the SQL mini project. You will carry out this project partly in
the PHPMyAdmin interface, and partly in Jupyter via a Python connection.

This is Tier 2 of the case study, which means that there'll be less guidance for you about how to setup
your local SQLite connection in PART 2 of the case study. This will make the case study more challenging for you: 
you might need to do some digging, aand revise the Working with Relational Databases in Python chapter in the previous resource.

Otherwise, the questions in the case study are exactly the same as with Tier 1. 

PART 1: PHPMyAdmin
You will complete questions 1-9 below in the PHPMyAdmin interface. 
Log in by pasting the following URL into your browser, and
using the following Username and Password:

URL: https://sql.springboard.com/
Username: student
Password: learn_sql@springboard

The data you need is in the "country_club" database. This database
contains 3 tables:
    i) the "Bookings" table,
    ii) the "Facilities" table, and
    iii) the "Members" table.

In this case study, you'll be asked a series of questions. You can
solve them using the platform, but for the final deliverable,
paste the code for each solution into this script, and upload it
to your GitHub.

Before starting with the questions, feel free to take your time,
exploring the data, and getting acquainted with the 3 tables. */


/* QUESTIONS 
/* Q1: Some of the facilities charge a fee to members, but some do not.
Write a SQL query to produce a list of the names of the facilities that do. */

SELECT name
FROM `Facilities`
WHERE membercost >0

/* Q2: How many facilities do not charge a fee to members? */

SELECT count( * )
FROM `Facilities`
WHERE membercost =0

Answer: 4 facilities

/* Q3: Write an SQL query to show a list of facilities that charge a fee to members,
where the fee is less than 20% of the facility's monthly maintenance cost.
Return the facid, facility name, member cost, and monthly maintenance of the
facilities in question. */

SELECT facid, name, membercost, monthlymaintenance
FROM `Facilities`
WHERE membercost >0
AND membercost < 0.2 * monthlymaintenance

/* Q4: Write an SQL query to retrieve the details of facilities with ID 1 and 5.
Try writing the query without using the OR operator. */

SELECT *
FROM `Facilities`
WHERE facid
IN ( 1, 5 ) 

/* Q5: Produce a list of facilities, with each labelled as
'cheap' or 'expensive', depending on if their monthly maintenance cost is
more than $100. Return the name and monthly maintenance of the facilities
in question. */

SELECT name, monthlymaintenance,
CASE WHEN monthlymaintenance >100
THEN 'expensive'
ELSE 'cheap'
END AS label
FROM `Facilities` 

/* Q6: You'd like to get the first and last name of the last member(s)
who signed up. Try not to use the LIMIT clause for your solution. */

SELECT firstname, surname
FROM `Members`
ORDER BY joindate DESC
LIMIT 1 

or

SELECT firstname, surname
FROM `Members`
WHERE joindate = (
SELECT max( joindate )
FROM Members ) 

/* Q7: Produce a list of all members who have used a tennis court.
Include in your output the name of the court, and the name of the member
formatted as a single column. Ensure no duplicate data, and order by
the member name. */

SELECT DISTINCT name, concat( surname, " ", firstname ) AS member_name
FROM Bookings
INNER JOIN Facilities
USING ( facid )
INNER JOIN Members
USING ( memid )
WHERE name LIKE 'Tennis Court%'
ORDER BY member_name

/* Q8: Produce a list of bookings on the day of 2012-09-14 which
will cost the member (or guest) more than $30. Remember that guests have
different costs to members (the listed costs are per half-hour 'slot'), and
the guest user's ID is always 0. Include in your output the name of the
facility, the name of the member formatted as a single column, and the cost.
Order by descending cost, and do not use any subqueries. */

SELECT starttime, name AS facility_name, concat( surname, " ", firstname ) AS member_name,
CASE WHEN memid =0 THEN slots * guestcost
ELSE slots * membercost END AS cost
FROM Bookings
INNER JOIN Facilities
USING ( facid )
INNER JOIN Members
USING ( memid )
HAVING ( cost >30 AND starttime LIKE '2012-09-14%')
ORDER BY cost DESC 

or, without the "starttime" in the output:

SELECT name AS facility_name, concat( surname, " ", firstname ) AS member_name,
CASE WHEN memid =0 THEN slots * guestcost
ELSE slots * membercost END AS cost
FROM Bookings
INNER JOIN Facilities
USING ( facid )
INNER JOIN Members
USING ( memid )
WHERE starttime LIKE '2012-09-14%'
HAVING ( cost >30 )
ORDER BY cost DESC 

/* Q9: This time, produce the same result as in Q8, but using a subquery. */

SELECT facility_name, concat( surname, " ", firstname ) AS member_name,
       CASE WHEN memid =0 THEN g_cost ELSE m_cost END AS cost
FROM (
     SELECT memid, slots * guestcost AS g_cost, slots * membercost AS m_cost, name AS facility_name
     FROM Bookings
     INNER JOIN Facilities
     USING ( facid )
     WHERE starttime LIKE '2012-09-14%') AS book_fac
INNER JOIN Members
USING ( memid )
HAVING (cost >30)
ORDER BY cost DESC 


/* PART 2: SQLite

Export the country club data from PHPMyAdmin, and connect to a local SQLite instance from Jupyter notebook 
for the following questions.  

QUESTIONS:
/* Q10: Produce a list of facilities with a total revenue less than 1000.
The output of facility name and total revenue, sorted by revenue. Remember
that there's a different cost for guests and members! */

with cte as (SELECT name,
CASE WHEN memid = 0 THEN slots * guestcost
ELSE slots * membercost END AS cost
FROM Bookings
INNER JOIN Facilities
USING ( facid ) )

SELECT name as facility_name, sum(cost) as revenue
FROM cte
GROUP BY name
HAVING(revenue < 1000)
ORDER BY revenue

('Table Tennis', 180) ,
('Snooker Table', 240) ,
('Pool Table', 270)

/* Q11: Produce a report of members and who recommended them in alphabetic surname,firstname order */

SELECT m1.surname,m1.firstname, 
         m2.surname || " " || m2.firstname as recommended_by
FROM Members as m1
LEFT JOIN Members as m2
ON m1.recommendedby = m2.memid
WHERE m1.surname <> "GUEST"
ORDER BY m1.surname,m1.firstname

['surname', 'firstname', 'recommended_by']

[('Bader', 'Florence', 'Stibbons Ponder'),
 ('Baker', 'Anne', 'Stibbons Ponder'),
 ('Baker', 'Timothy', 'Farrell Jemima'),
 ('Boothe', 'Tim', 'Rownam Tim'),
 ('Butters', 'Gerald', 'Smith Darren'),
 ('Coplin', 'Joan', 'Baker Timothy'),
 ('Crumpet', 'Erica', 'Smith Tracy'),
 ('Dare', 'Nancy', 'Joplette Janice'),
 ('Farrell', 'David', None),
 ('Farrell', 'Jemima', None),
 ('Genting', 'Matthew', 'Butters Gerald'),
 ('Hunt', 'John', 'Purview Millicent'),
 ('Jones', 'David', 'Joplette Janice'),
 ('Jones', 'Douglas', 'Jones David'),
 ('Joplette', 'Janice', 'Smith Darren'),
 ('Mackenzie', 'Anna', 'Smith Darren'),
 ('Owen', 'Charles', 'Smith Darren'),
 ('Pinker', 'David', 'Farrell Jemima'),
 ('Purview', 'Millicent', 'Smith Tracy'),
 ('Rownam', 'Tim', None),
 ('Rumney', 'Henrietta', 'Genting Matthew'),
 ('Sarwin', 'Ramnaresh', 'Bader Florence'),
 ('Smith', 'Darren', None),
 ('Smith', 'Darren', None),
 ('Smith', 'Jack', 'Smith Darren'),
 ('Smith', 'Tracy', None),
 ('Stibbons', 'Ponder', 'Tracy Burton'),
 ('Tracy', 'Burton', None),
 ('Tupperware', 'Hyacinth', None),
 ('Worthington-Smyth', 'Henry', 'Smith Tracy')]

/* Q12: Find the facilities with their usage by member, but not guests */

SELECT name,count(memid) as usage_by_member
FROM Bookings
INNER JOIN Facilities
USING (facid)
WHERE memid <> 0
GROUP BY name
ORDER BY usage_by_member DESC

['name', 'usage_by_member']

[('Pool Table', 783),
 ('Snooker Table', 421),
 ('Massage Room 1', 421),
 ('Table Tennis', 385),
 ('Badminton Court', 344),
 ('Tennis Court 1', 308),
 ('Tennis Court 2', 276),
 ('Squash Court', 195),
 ('Massage Room 2', 27)]


/* Q13: Find the facilities usage by month, but not guests */

SELECT name, strftime('%m', starttime) as month, count(memid) as usage_by_member
FROM Bookings
INNER JOIN Facilities
USING (facid)
WHERE memid <> 0
GROUP BY name,month
ORDER BY usage_by_member DESC

['name', 'month', 'usage_by_member']

[('Pool Table', '09', 408),
 ('Pool Table', '08', 272),
 ('Snooker Table', '09', 199),
 ('Table Tennis', '09', 194),
 ('Massage Room 1', '09', 191),
 ('Badminton Court', '09', 161),
 ('Snooker Table', '08', 154),
 ('Massage Room 1', '08', 153),
 ('Table Tennis', '08', 143),
 ('Badminton Court', '08', 132),
 ('Tennis Court 1', '09', 132),
 ('Tennis Court 2', '09', 126),
 ('Tennis Court 1', '08', 111),
 ('Tennis Court 2', '08', 109),
 ('Pool Table', '07', 103),
 ('Squash Court', '09', 87),
 ('Squash Court', '08', 85),
 ('Massage Room 1', '07', 77),
 ('Snooker Table', '07', 68),
 ('Tennis Court 1', '07', 65),
 ('Badminton Court', '07', 51),
 ('Table Tennis', '07', 48),
 ('Tennis Court 2', '07', 41),
 ('Squash Court', '07', 23),
 ('Massage Room 2', '09', 14),
 ('Massage Room 2', '08', 9),
 ('Massage Room 2', '07', 4)]
