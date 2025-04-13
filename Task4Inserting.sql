-- 🎯 Campaign
INSERT INTO Campaign (Campaign_Name, Target_Audience)
VALUES
('Letnia Promka', '< 10000'),
('Zimowy Szał', '< 5000'),
('Fit Start Wiosna', '< 3000'),
('Tech Week', '< 8000'),
('Eko Dom 2025', '< 2000');

-- 📺 Medium
INSERT INTO Medium (Type_Of_Medium, Ad_Location)
VALUES
('Online', 'Instagram'),
('TV', 'TVP1'),
('Billboard', 'Galeria Krakowska'),
('Radio', 'Radio 357'),
('Online', 'YouTube');

-- 📚 Interests
INSERT INTO Interests (Interest_Name)
VALUES
('Technologia'),
('Moda'),
('Podróże'),
('Fitness'),
('Zdrowie');

-- 📅 Date
INSERT INTO Date ([Date], Year, Month, MonthNo, DayOfWeek, DayOfWeekNo, WorkingDay, Vacation, Holiday, BeforeHolidayDay)
VALUES
('2025-04-10', 2025, 'April', 4, 'Thursday', 4, 'working day', 'non-holiday', '', ''),
('2025-04-11', 2025, 'April', 4, 'Friday', 5, 'working day', 'non-holiday', '', 'tomorrow is Grandmother’s day'),
('2025-04-12', 2025, 'April', 4, 'Saturday', 6, 'day off', 'non-holiday', 'Grandmother’s day', ''),
('2025-04-13', 2025, 'April', 4, 'Sunday', 7, 'day off', 'non-holiday', '', ''),
('2025-04-14', 2025, 'April', 4, 'Monday', 1, 'working day', 'non-holiday', '', '');

-- ⏰ Time
INSERT INTO Time (Hour, Time_Of_Day)
VALUES
(8, 'between 0 and 8'),
(10, 'between 9 and 12'),
(14, 'between 13 and 15'),
(18, 'between 16 and 20'),
(22, 'between 21 and 23');

-- 👤 User
INSERT INTO [User] (Email, Age, Gender, Location)
VALUES
('ania.kowalska@example.com', '25-34', 'Female', 'Warszawa'),
('piotr.nowak@example.com', '18-24', 'Male', 'Kraków'),
('joanna.zielona@example.com', '35-44', 'Female', 'Wrocław'),
('marek.bialy@example.com', '30-39', 'Male', 'Poznań'),
('alicja.smart@example.com', '25-34', 'Female', 'Gdańsk');

-- 🧑‍💼 Client
INSERT INTO Client (NameAndSurname, NIP)
VALUES
('Michał Brzozowski', '1112223334'),
('Karolina Zielińska', '9876543210'),
('Tomasz Rutkowski', '4567891230');

-- 👔 Owner
INSERT INTO Owner (NameAndSurname, NIP)
VALUES
('Natalia Nowak', '3213213210'),
('Dominik Maj', '6549873210');

-- 📈 Conduct_a_campaign
-- Kampanie: 1,2,3; Medium: 1,2,3; Owner: 1,2; Client: 1,2,3; Dates: 1–5
INSERT INTO Conduct_a_campaign (
    Campaign_ID, Medium_ID, OContract_ID, CContract_ID, StartDate_ID, EndDate_ID, Duration, Profit, Expense)
VALUES
(1, 1, 1, 1, 1, 3, 3, 25000.00, 7000.00),
(2, 2, 2, 2, 2, 4, 3, 18000.00, 4000.00),
(3, 3, 1, 3, 3, 5, 3, 12000.00, 3500.00);

-- 🖱 Views_Clicks
-- User: 1–5, Interests: 1–5, Time: 1–5, Date: 1–5
INSERT INTO Views_Clicks (
    Campaign_ID, View_Click, Click_Profit, User_ID, Time_ID, Date_ID, OContract_ID, CContract_ID, Interest_ID)
VALUES
(1, 1, 0.00, 1, 1, 1, 1, 1, 2), -- view
(1, 0, 3.50, 2, 2, 2, 1, 1, 1), -- click
(2, 1, 0.00, 3, 3, 3, 2, 2, 4), -- view
(2, 0, 2.75, 4, 4, 4, 2, 2, 3), -- click
(3, 0, 1.90, 5, 5, 5, 1, 3, 1); -- click
