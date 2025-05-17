CREATE TABLE users (
    id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    phone VARCHAR(11) NOT NULL,
    `date` DATE NOT NULL,
    `hour` TIME NOT NULL
);

