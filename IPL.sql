Create Database IPL;

/*1. Create a table named 'matches' with appropriate data types for columns */
Create Table Matches(
id int,	
city varchar(100),	
date date,	
player_of_match varchar(100),	
venue varchar(100),	
neutral_venue int,	
team1 varchar(100),	
team2 varchar(100),	
toss_winner varchar(100),	
toss_decision varchar(100),	
winner varchar(100),	
result varchar(100),	
result_margin int,	
eliminator varchar(100),	
method varchar(100),	
umpire1 varchar(100),	
umpire2 varchar(100));

/*2. Create a table named 'deliveries' with appropriate data types for columns */
Create Table deliveries(
id int,
inning int,	
`over` int,	
ball int,	
batsman varchar(100),	
non_striker varchar(100),	
bowler varchar(100),	
batsman_runs int,	
extra_runs int,	
total_runs int,	
is_wicket int,	
dismissal_kind varchar(100),	
player_dismissed varchar(100),	
fielder varchar(100),
extras_type varchar(100),	
batting_team varchar(100),	
bowling_team varchar(100),	
venue varchar(100),	
match_date varchar(100));


/*3. Import data from csv file 'IPL_matches.csv'attached in resources to 'matches'
 4. Import data from csv file 'IPL_Ball.csv' attached in resources to 'matches */
/* 5. Select the top 20 rows of the deliveries table. */
Select *
From deliveries
Order By total_runs Desc
Limit 20;

/*6. Select the top 20 rows of the matches table. */
Select *
From matches
Order By result_margin Desc
limit 20;

/*7. Fetch data of all the matches played on 2nd May 2013.*/
Select *
From matches
Where date = "2013-05-02";

/*8. Fetch data of all the matches where the margin of victory is more than 100 runs. */
Select *
From matches
where result_margin > 100;

/*9. Fetch data of all the matches where the final scores of both teams tied and order it in descending order of the date. */
Select *
From matches
Where result = "tie"
Order By date Desc;

/*10. Get the count of cities that have hosted an IPL match. */
Select Count(Distinct(city))
From matches;

/*11. Create table deliveries_v02 with all the columns of deliveries and an additional column ball_result containing value boundary, 
dot or other depending on the total_run (boundary for >= 4, dot for 0 and other for any other number) */
Create Table deliveries_v02
Select *
From deliveries;

Alter Table deliveries_v02
Drop Column ball_result;
Alter Table deliveries_v02
Add Column ball_result varchar(100);

Update deliveries_v02
Set ball_result = Case When total_runs = 0 Then "Dot"
						When total_runs < 4 Then "Other"
                        Else "Boundry"
                        End;
Select * from deliveries_v02;
/*12. Write a query to fetch the total number of boundaries and dot balls */
Select ball_result ,count(*)
From deliveries_v02
Where ball_result in ("Dot", "Boundry")
Group by ball_result;

/*13. Write a query to fetch the total number of boundaries scored by each team */
Select batting_team, Count(*)
From deliveries_v02
Where ball_result = "Boundry"
Group By batting_team;

/*14. Write a query to fetch the total number of dot balls bowled by each team */
Select batting_team, Count(*)
From deliveries_v02
Where ball_result = "Dot"
Group By batting_team;

/*15. Write a query to fetch the total number of dismissals by dismissal kinds */
Select dismissal_kind, Count(*)
From deliveries_v02
Group By dismissal_kind;

/*16. Write a query to get the top 5 bowlers who conceded maximum extra runs */
Select bowler, Sum(extra_runs)
From deliveries_v02
Group By bowler
Order By Sum(extra_runs) Desc
Limit 5;

/*17. Write a query to create a table named deliveries_v03 with all the columns of deliveries_v02 
table and two additional column (named venue and match_date) of venue and date from table matches */
Create Table deliveries_v03
Select d.*, (m.venue) as venue1, m.date
From matches m right join deliveries_v02 d on m.id= d.id;

/*18. Write a query to fetch the total runs scored for each venue and order it in the descending order of total runs scored.*/
Select venue, Sum(total_runs)
From deliveries_v03
Group By venue
Order By Sum(total_runs) Desc;

/*19. Write a query to fetch the year-wise total runs scored at Eden Gardens and order it in the descending order of total runs scored. */
Select Year(match_date), Sum(total_runs)
From deliveries_v03
Group By Year(match_date)
Order By Sum(total_runs) Desc;

/*20. Get unique team1 names from the matches table, you will notice that there are two entries for Rising Pune Supergiant 
one with Rising Pune Supergiant and another one with Rising Pune Supergiants. 
Your task is to create a matches_corrected table with two additional columns team1_corr and team2_corr 
containing team names with replacing Rising Pune Supergiants with Rising Pune Supergiant. Now analyse these newly created columns. */
Select distinct	team1
From matches
Order By team1;

Create Table matches_corrected
Select *
From matches;

Alter Table matches_corrected
Add Column team1_corr varchar(100), Add Column team2_corr varchar(100);

Update matches_corrected
Set team1_corr = team1, team2_corr = team2;

Update matches_corrected
Set team1_corr = "Rising Pune Supergiants", team2_corr = "Rising Pune Supergiants"
Where team1_corr = "Rising Pune Supergiant" or team2_corr = "Rising Pune Supergiant";

Select distinct	team1_corr
From matches_corrected
Order By team1_corr;

/*21. Create a new table deliveries_v04 with the first column as ball_id containing information of match_id, inning, 
over and ball separated by'(For ex. 335982-1-0-1 match_idinning-over-ball) and rest of the columns same as deliveries_v03) */
Create Table deliveries_v04
Select Concat(d.id,"-",d.inning,"-",d.over,"-",d.ball) As ball_id ,d.*
From deliveries_v03 d;

/*22. Compare the total count of rows and total count of distinct ball_id in deliveries_v04; */
Select Count(*) As Cnt_total_rows, Count(Distinct(ball_id)) As Cnt_dis_ball
From deliveries_v04;

/*23. Create table deliveries_v05 with all columns of deliveries_v04 and an additional column for row number partition over ball_id. 
(HINT : row_number() over (partition by ball_id) as r_num) */
Create Table deliveries_v05
Select *, row_number() over (partition by ball_id) as r_num
From deliveries_v04;

Select * From deliveries_v05;

/*24. Use the r_num created in deliveries_v05 to identify instances where ball_id is repeating. 
(HINT : select * from deliveries_v05 WHERE r_num=2;) */
Select *
From deliveries_v05
Where r_num=2;

/*25. Use subqueries to fetch data of all the ball_id which are repeating. (HINT: SELECT * FROM deliveries_v05 WHERE ball_id in 
(select BALL_ID from deliveries_v05 WHERE r_num=2); 
Note: Solve the project in your pgAdmin and keep it open for reference as you will be finding several questions in 
the upcoming module test based on this project*/
Select * 
From deliveries_v05 
Where ball_id in (Select BALL_ID From deliveries_v05 Where r_num=2); 



