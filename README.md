# ECC Kids Flashcards Data

A simple database I whipped up in a few hours to help plan and organize
flashcards for KEW lesson boxes. The data herein pertains specifically to
the 2025–2026 AL, AM, and AN term—you'll have to manually add data for your
own year (pain in the ass, good luck), and only to the regular lessons—no
event, holiday, model, or extra lessons.

No actual lesson information or even the contents of the flashcards themselves
is stored, so there should be no copyright issues.

## Getting started

First, you'll need to initialize the database. I'm using Postgres 18.1,
although slightly earlier versions should work; I'm not using any bleeding-edge
syntax. However there might be some Postgres-isms so this might not work with
other databases.

Of course we gotta create the database, something like

```sql
CREATE DATABASE ecc_2025;
```

Then we'll load in the schemas contained in `schema.sql`. From the terminal
that'll probably look like

```sh
psql -d ecc_2025 -f schema.sql
```

Now we `INSERT` the data for each of the classes. Assuming you want to load all
AL, AM, and AN

```sh
psql -d ecc_2025 -f al.sql -f am.sql -f an.sql
```

## Database structure

The data itself isn't too complex; you can probably skim `schema.sql` in less
time than it takes to read this, but if you're not super familiar with SQL I'll
leave some of the more important tables below.

### cards

| category               | index   |
| ---------------------- | ------- |
| string (e.g. Alphabet) | integer | 

### lessons

| week           | course                | theme                |
| -------------- | --------------------- | -------------------- |
| integer (1-37) | string (AL, AM or AN) | string (e.g. Can I?) |

### materials

| lesson\_week   | lesson\_course         | card\_category         | card\_index      |
| -------------- | ---------------------- | ---------------------- | ---------------- |
| integer (1–37) | string (AL, AM, or AN) | string (e.g. Alphabet) | integer          |

### schedule

| lesson\_week   | lesson\_course         | date                 |
| -------------- | ---------------------- | -------------------- |
| integer (1–37) | string (AL, AM, or AN) | date (of occurrence) |

## Usage

I might work on a simple HTML interface in the future to make it easier to use
this for less technical folks, but for now I'll just include a few useful
queries that should be relatively easy to adapt for your own use case.

```sql
-- Print an alphabetized list of all flashcards and their lessons
SELECT category, index, STRING_AGG(lesson, ', ')
  FROM (SELECT category, index, CONCAT(lesson_course, ' ', lesson_week) AS lesson
          FROM cards AS c
          JOIN materials AS m
            ON m.card_category = c.category
           AND m.card_index = c.index
            -- Exclude common flashcards
         WHERE category NOT IN ('Alphabet',
                                'Calendar',
                                'Weather'  ))
 GROUP BY category, index
 ORDER BY category, index;

-- Print counts of duplicate FCs across all lessons
SELECT category, index, COUNT(lesson_course)
  FROM (SELECT DISTINCT category, index, m.lesson_course
          FROM cards AS c
          JOIN materials AS m
            ON m.card_category = c.category
           AND m.card_index = c.index
          JOIN schedule AS s
            ON s.lesson_week = m.lesson_week
           AND s.lesson_course = m.lesson_course
            -- Exclude common flashcards
         WHERE category NOT IN ('Alphabet',
                                'Calendar',
                                'Weather'  ))
 GROUP BY category, index
HAVING COUNT(lesson_course) > 1
 ORDER BY category, index;

-- Find flashcards needed for a given theme
SELECT DISTINCT category, index
  FROM cards AS c
  JOIN materials AS m
    ON m.card_category = c.category
   AND m.card_index = c.index
  JOIN lessons AS l
    ON l.week = m.lesson_week
   AND l.course = m.lesson_course
    -- Change to desired theme
 WHERE theme = 'At the Beach'
 ORDER BY category, index;

-- Find flashcards needed for all courses for a given date range
SELECT DISTINCT category, index
  FROM cards AS c
  JOIN materials AS m
    ON m.card_category = c.category
   AND m.card_index = c.index
  JOIN schedule AS s
    ON s.lesson_week = m.lesson_week
   AND s.lesson_course = m.lesson_course
    -- Change to desired date range
 WHERE date BETWEEN '2026-01-01' AND '2026-01-31'
 ORDER BY category, index;
```

## License

[Do what the fuck you want](./LICENSE).
