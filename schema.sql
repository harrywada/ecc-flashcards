CREATE TABLE categories (
    PRIMARY KEY (name),
    name VARCHAR(32)
);

CREATE TABLE courses (
    PRIMARY KEY (name),
    name VARCHAR(2)
);

CREATE TABLE cards (
    PRIMARY KEY (category, index),
    category VARCHAR(32),
    index    INTEGER,
             CONSTRAINT CK_positive_index
	     CHECK(index > 0),
    FOREIGN KEY (category)
        REFERENCES categories(name)
);

CREATE TABLE themes (
    PRIMARY KEY (name, course),
    name VARCHAR(64),
    course VARCHAR(2),
    FOREIGN KEY (course)
        REFERENCES courses(name)
);

CREATE TABLE lessons (
    PRIMARY KEY (week, course),
    week   INTEGER,
    course VARCHAR(2),
    theme  VARCHAR(64),
           CONSTRAINT CK_week_range
	   CHECK(week BETWEEN 1 AND 37),
    FOREIGN KEY (course)
        REFERENCES courses(name),
    FOREIGN KEY (theme, course)
        REFERENCES themes(name, course)
);

CREATE TABLE materials (
    lesson_week   INTEGER,
    lesson_course VARCHAR(2),
    card_category VARCHAR(32),
    card_index    INTEGER,
                  CONSTRAINT UC_lesson_card
		  UNIQUE (lesson_week, lesson_course,
			  card_category, card_index),
    FOREIGN KEY (lesson_week, lesson_course)
        REFERENCES lessons(week, course)
	ON DELETE CASCADE,
    FOREIGN KEY (card_category, card_index)
        REFERENCES cards (category, index)
	ON DELETE CASCADE
);

CREATE TABLE schedule (
    lesson_week   INTEGER,
    lesson_course VARCHAR(2),
    date          DATE,
                  CONSTRAINT UC_lesson_date
		  UNIQUE (lesson_week, lesson_course, date),
    FOREIGN KEY (lesson_week, lesson_course)
        REFERENCES lessons(week, course)
	ON DELETE CASCADE
);
