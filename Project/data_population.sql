-- Insert into base
INSERT INTO base (location, status) VALUES
('Base A', 'OPEN'),
('Base B', 'OPEN'),
('Base C', 'CLOSED'),
('Base D', 'OPEN'),
('Base Burny', 'OPEN'),
('Base Alfa', 'CLOSED'),
('Base Dunky', 'OPEN'),
('Base Elf', 'OPEN');

-- Insert into mre
INSERT INTO mre (breakfast, lunch, dinner, food_additives, kkal, proteins, fats, carbohydrate) VALUES
('Oatmeal', 'Chicken Stew', 'Beef Stew', 'None', 3500, 100, 60, 300),
('Pasta', 'Tuna Salad', 'Vegetable Curry', 'Spices', 4000, 120, 70, 350),
('Rice', 'Beef Stroganoff', 'Chicken Curry', 'None', 4500, 110, 80, 320),
('Cereal', 'Vegetable Soup', 'Pork Chops', 'None', 3700, 90, 50, 280),
('Granola', 'Fish Tacos', 'Chili', 'Hot Sauce', 3900, 95, 55, 310);

-- Insert into equipment
INSERT INTO equipment (camouflage, communication, intelligence, medical, mre_id, extra) VALUES
('Woodland', 'Radio', 'Drones', 'First Aid Kit', 1, 'Extra Batteries'),
('Desert', 'Satellite Phone', 'Recon', 'Medical Supplies', 2, 'GPS Device'),
('Urban', 'Walkie Talkie', 'Surveillance', 'Trauma Kit', 3, 'Night Vision Goggles'),
('Jungle', 'Signal Flare', 'Recon', 'First Aid Kit', 4, 'Binoculars'),
('Snow', 'Radio', 'Drones', 'Medical Supplies', 5, 'Thermal Blanket');

-- Insert into position
INSERT INTO position (name, salary_rub, rank, equip_id, forces) VALUES
('Infantry Soldier', 60000, 'Private', 1, 'GF'),
('Sniper', 80000, 'Corporal', 2, 'NAVY'),
('Medic', 70000, 'Sergeant', 3, 'AF'),
('Engineer', 90000, 'Lieutenant', 4, 'GF'),
('Pilot', 120000, 'Captain', 5, 'NAVY');

-- Insert into employee
INSERT INTO employee (name, surname, date_of_birth, education, pos_id, is_married, base_id) VALUES
('John', 'Doe', '1990-01-15', 'High School', 1, TRUE, 1),
('Jane', 'Smith', '1985-05-20', 'Bachelor', 2, FALSE, 1),
('Alice', 'Johnson', '1992-03-10', 'Bachelor', 3, TRUE, 2),
('Bob', 'Brown', '1988-07-25', 'Master', 4, FALSE, 2),
('Charlie', 'Davis', '1980-12-30', 'PhD', 5, TRUE, 3),
('David', 'Wilson', '1995-11-11', 'High School', 1, FALSE, 3),
('Eva', 'Garcia', '1987-09-09', 'Bachelor', 2, TRUE, 4),
('Frank', 'Martinez', '1993-04-04', 'Master', 3, FALSE, 4),
('Grace', 'Hernandez', '1982-06-06', 'PhD', 4, TRUE, 5),
('Henry', 'Lopez', '1991-08-08', 'High School', 5, FALSE, 5),
('Isabella', 'Gonzalez', '1989-02-02', 'Bachelor', 1, TRUE, 1),
('Jack', 'Wilson', '1986-10-10', 'Master', 2, FALSE, 1),
('Liam', 'Anderson', '1994-12-12', 'PhD', 3, TRUE, 2),
('Mia', 'Thomas', '1983-03-03', 'High School', 4, FALSE, 2),
('Noah', 'Taylor', '1990-05-05', 'Bachelor', 5, TRUE, 3),
('Olivia', 'Moore', '1988-07-07', 'Master', 1, FALSE, 3),
('Paul', 'Jackson ', '1992-08-08', 'PhD', 2, TRUE, 4),
('Quinn', 'White', '1985-09-09', 'High School', 3, FALSE, 4),
('Riley', 'Harris', '1993-10-10', 'Bachelor', 4, TRUE, 5),
('Sophia', 'Martin', '1981-11-11', 'Master', 5, FALSE, 5),
('Thomas', 'Thompson', '1990-12-12', 'PhD', 1, TRUE, 1),
('Uma', 'Garcia', '1986-01-01', 'High School', 2, FALSE, 1),
('Victor', 'Martinez', '1994-02-02', 'Bachelor', 3, TRUE, 2),
('Wendy', 'Robinson', '1989-03-03', 'Master', 4, FALSE, 2),
('Xander', 'Clark', '1982-04-04', 'PhD', 5, TRUE, 3),
('Yara', 'Rodriguez', '1991-05-05', 'High School', 1, FALSE, 3),
('Zoe', 'Lewis', '1987-06-06', 'Bachelor', 2, TRUE, 4);

-- Insert into medical_card
INSERT INTO medical_card (emp_id, height_cm, weight_kg, diseases, blood, gender) VALUES
(1, 180, 75, 'Diabet', 'A', 'M'),
(2, 165, 60, 'None', 'B', 'F'),
(3, 170, 65, 'Infulenza', 'O', 'F'),
(4, 175, 80, 'Malaria, Diabet', 'AB', 'M'),
(5, 185, 90, 'None', 'AO', 'M'),
(6, 160, 55, 'None', 'BO', 'F'),
(7, 178, 70, 'None', 'A', 'M'),
(8, 172, 68, 'Influenza, Gripp', 'B', 'F'),
(9, 169, 62, 'None', 'O', 'F'),
(10, 182, 85, 'None', 'AB', 'M'),
(11, 177, 72, 'Gripp', 'AO', 'F'),
(12, 165, 58, 'None', 'BO', 'F'),
(13, 180, 78, 'None', 'A', 'M'),
(14, 173, 66, 'None', 'B', 'F'),
(15, 168, 64, 'Malaria, Gripp', 'O', 'F'),
(16, 184, 88, 'None', 'AB', 'M'),
(17, 176, 74, 'None', 'AO', 'F'),
(18, 162, 57, 'Typhoid', 'BO', 'F'),
(19, 179, 77, 'None', 'A', 'M'),
(20, 171, 69, 'None', 'B', 'F'),
(21, 167, 63, 'Tyhoid, Malaria', 'O', 'F'),
(22, 183, 86, 'None', 'AB', 'M'),
(23, 175, 73, 'None', 'AO', 'F'),
(24, 164, 59, 'None', 'BO', 'F'),
(25, 181, 82, 'None', 'A', 'M');

-- Insert into weapon
INSERT INTO weapon (name, type, caliber, rate_of_fire, sighting_range_m) VALUES
('AK-47', 'Assault Rifle', 7.62, 600, 400),
('M4 Carbine', 'Assault Rifle', 5.56, 700, 500),
('M16', 'Assault Rifle', 5.56, 800, 600),
('Glock 17', 'Pistol', 9.0, 1200, 50),
('M249 SAW', 'Light Machine Gun', 5.56, 1000, 800);

-- Insert into campaign
INSERT INTO campaign (name, customer, earning, spending, execution_status) VALUES
('Operation Alpha', 'Department of Defense', 100762500, 500000, 'STARTED'),
('Operation Bravo', 'NATO', 2000000, 1500000, 'ON_GOING'),
('Operation Charlie 1', 'Private Contractor', 1500860, 800000, 'PENDING'),
('Operation Bravo', 'Private Agency', 2000000, 1500000, 'ON_GOING'),
('Operation Camar', 'Private Contractor', 1500000, 800000, 'PENDING'),
('Operation Bravo', 'NATO', 2000000, 500000, 'ON_GOING'),
('Operation Charlie 2', 'Private Contractor', 33300000, 800000, 'PENDING'),
('Operation Bravo 1', 'NATO', 2000000, 150000, 'ON_GOING'),
('Operation Eagle', 'Private Contractor', 21500000, 800000, 'PENDING'),
('Operation Delta', 'Local Government', '500000', '200000', 'FINISHED'),
('Operation Echo', 'Private Contractor', 750000, 300000, 'NOT_STARTED');

-- Insert into mission
INSERT INTO mission (camp_id, start_date_and_time, end_date_and_time, legal_status, departure_location, arrival_location, enemies) VALUES
(1, '2023-01-01 08:00:00', '2023-01-10 18:00:00', TRUE, 'Base A', 'Base B', 'Enemy Forces A'),
(2, '2023-02-01 09:00:00', '2023-02-15 17:00:00', TRUE, 'Base B', 'Base C', 'Enemy Forces B'),
(3, '2023-03-01 10:00:00', '2023-03-20 16:00:00', FALSE, 'Base C', 'Base D', 'Enemy Forces C'),
(4, '2023-04-01 11:00:00', '2023-04-25 15:00:00', TRUE, 'Base D', 'Base E', 'Enemy Forces D'),
(5, '2023-05-01 12:00:00', '2023-05-30 14:00:00', TRUE, 'Base E', 'Base A', 'Enemy Forces E');

-- Insert into transport
INSERT INTO transport (name, type, status) VALUES
('Transport Vehicle 1', 'Truck', 'VERIFIED'),
('Transport Vehicle 2', 'Helicopter', 'NEED_VERIFICATION'),
('Transport Vehicle 3', 'Boat', 'MAINTAINED'),
('Transport Vehicle 4', 'Tank', 'NOT_MAINTAINED'),
('Transport Vehicle 5', 'Drone', 'OUT_OF_USE');

-- Insert into equip_weapon
INSERT INTO equip_weapon (equip_id, weapon_id) VALUES
(1, 1),
(2, 2),
(3, 3),
(4, 4),
(5, 5);

-- Insert into missions_transport
INSERT INTO missions_transport (miss_id, trans_id) VALUES
(1, 1),
(2, 2),
(3, 3),
(4, 4),
(5, 5);

-- Insert into inspection
INSERT INTO inspection (emp_id, trans_id, service_date) VALUES
(1, 1, '2023-01-05'),
(2, 2, '2023-02-05'),
(3, 3, '2023-03-05'),
(4, 4, '2023-04-05'),
(5, 5, '2023-05-05');

-- Insert into missions_emp
INSERT INTO missions_emp (miss_id, emp_id) VALUES
(1, 1),
(1, 2),
(2, 3),
(2, 4),
(3, 5),
(4, 1),
(4, 3),
(5, 2),
(5, 4),
(5, 5);