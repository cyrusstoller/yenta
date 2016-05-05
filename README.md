# Yenta

Yenta is built to match students with alumni with relevant backgrounds
as part of a mentorship program.
It matches students with alumni using a variation of
the [Gale–Shapley algorithm](https://en.wikipedia.org/wiki/Stable_marriage_problem).
Then once the preliminary matches have been computed, 
there's an opportunity for the operator to make adjustments based on attributes
that are not fully coded into the multiple choice questions.

Once the matches have been solidified, there's a script to
send personalized emails to students, notifying them of their 
new alumni mentors.

## Collecting data

Use your favorite method of sending out a poll. Google Forms works well.

Columns for `data/alumni.csv` are as follows:

- Timestamp
- First Name
- Last Name
- Email Address
- Class Year
- Industry
- Function
- Geography
- How many students are you willing to mentor?
- Gender
- Race / Ethnicity
- Do you identify as LGBT?
- Do have a military background?
- Do you have a joint degree?
- Have you worked in a family business?
- Is there anything else that is critically important to you?

Columns for `data/students.csv` are as follows (priorities are collected with matrix radio buttons):

- Timestamp
- First Name
- Last Name
- Email Address
- Class Year
- Section
- Industry
- Function
- Geography
- Gender
- Race / Ethnicity
- Would you prefer a mentor that is LGBT?
- Would you prefer a mentor with a military background?
- Would you prefer a mentor with a joint degree?
- Would you prefer a mentor from a family business?
- Are you open to having an alumni mentor from the MBA Program and Exec Ed?
- Other (did the above miss something critically important to you?)
- Priority [Industry]
- Priority [Function]
- Priority [Geography]
- Priority [Gender]
- Priority [Race]
- Priority [Sexual Orientation]
- Priority [Military]
- Priority [Joint Degree]
- Priority [Family Business]

## Calculating the matches

```
$ bundle install
$ ruby match.rb
```

## Sending email notifications

Sign up for your [favorite transactional email service](https://www.metachris.com/2016/03/free-transactional-email-services-the-best-alternatives-to-mandrill/). Then set the following variables in `.env`.

```bash
# .env
SMTP_USERNAME=*SENDGRID_USERNAME*
SMTP_PASSWORD=*SENDGRID_PASSWORD*
SMTP_PORT=587
SMTP_HOST=smtp.sendgrid.net
REACHOUT_FORM=*URL to reach out form*
IDEAS_DOC=*URL to idea doc*
FROM=*Email address*
```

Emails will be sent based on the data in `output.csv`.

```
$ bundle exec ruby email_match.rb
```
